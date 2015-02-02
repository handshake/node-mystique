_ = require "underscore"

NORMALIZE_WORD_BOUNDARIES = /[\W_]/g

TOKENIZE = /\d+(?=[a-zA-Z]|\b)|[a-z]+(?=[A-Z\d]|\b)|[A-Z]+(?=\b)|[A-Z][a-z]*(?=[A-Z\d]|\b)/g

FIRST_LETTER = /^\w/i

DEFAULT_RENDERING_OPTIONS =
    leftBoundary: ""
    rightBoundary: ""
    segmentLeftBoundary: ""
    segmentRightBoundary: ""
    segmentDelimiter: "/"
    wordDelimiter: ""
    normalCase: "lower"
    invertInitialLetter: false
    invertFirstLetters: false


DEFAULT_PARSING_OPTIONS =
    leftBoundary: ""
    rightBoundary: ""
    segmentLeftBoundary: ""
    segmentRightBoundary: ""
    segmentDelimiter: "/"

capitalize = (word, upperOrLower) ->
    word.replace FIRST_LETTER, (letter) ->
        switch upperOrLower
            when "lower" then letter.toLowerCase()
            when "upper" then letter.toUpperCase()
            else letter

tokenize = (variable, opts) ->
    _.map( variable
        .match(///^#{opts.leftBoundary}(.*)#{opts.rightBoundary}$///)[1]
        .split(opts.segmentDelimiter), (segment) ->
            tokens = segment
                .match(///^#{opts.segmentLeftBoundary}(.*)#{opts.segmentRightBoundary}$///)[1]
                .replace NORMALIZE_WORD_BOUNDARIES, " "
                .match TOKENIZE

            switch opts.normalCase
                when "lower" then _.invoke tokens, "toLowerCase"
                when "upper" then _.invoke tokens, "toUpperCase"
                else tokens
    )

mutateCase = (variable, renderOpts = {}, parseOpts = renderOpts.parseOpts or {}) ->
    renderOpts = _.defaults renderOpts, DEFAULT_RENDERING_OPTIONS
    parseOpts = _.defaults parseOpts, DEFAULT_PARSING_OPTIONS

    parseOpts.normalCase = renderOpts.normalCase
    capitalizedCase = switch renderOpts.normalCase
        when "lower" then "upper"
        when "upper" then "lower"

    renderOpts.leftBoundary + _.map( tokenize(variable, parseOpts), (segment) ->
        if renderOpts.invertInitialLetter
            segment[0] = capitalize segment[0], capitalizedCase

        if renderOpts.invertFirstLetters
            segment = _.map segment, (token, i) ->
                return token unless i
                capitalize token, capitalizedCase

        renderOpts.segmentLeftBoundary +
            segment.join(renderOpts.wordDelimiter) +
            renderOpts.segmentRightBoundary

    ).join renderOpts.segmentDelimiter + renderOpts.rightBoundary

fns =
    lowerCamelCase: (variable) ->
        mutateCase variable, invertFirstLetters: true,

    upperCamelCase: (variable) ->
        mutateCase variable, invertFirstLetters: true, invertInitialLetter: true

    lowerUnderscoreCase: (variable) ->
        mutateCase variable, wordDelimiter: "_"

    upperUnderscoreCase: (variable) ->
        mutateCase variable, wordDelimiter: "_", invertFirstLetters: true, invertInitialLetter: true

    constantCase: (variable) ->
        mutateCase variable, wordDelimiter: "_", normalCase: "upper"

    lowerHyphenCase: (variable) ->
        mutateCase variable, wordDelimiter: "-"

    upperHyphenCase: (variable) ->
        mutateCase variable, wordDelimiter: "-", invertFirstLetters: true, invertInitialLetter: true

    lowerHumanCase: (variable) ->
        mutateCase variable, wordDelimiter: " "

    upperHumanCase: (variable) ->
        mutateCase variable, wordDelimiter: " ", invertFirstLetters: true, invertInitialLetter: true

    sentenceCase: (variable) ->
        mutateCase variable, wordDelimiter: " ", invertInitialLetter: true

aliases =
    camelCase: fns.lowerCamelCase
    medialCase: fns.lowerCamelCase
    pascalCase: fns.upperCamelCase
    dromedaryCase: fns.upperCamelCase
    underscoreCase: fns.lowerUnderscoreCase
    snakeCase: fns.lowerUnderscoreCase
    hyphenCase: fns.lowerHyphenCase
    lispCase: fns.lowerHyphenCase
    kebabCase: fns.lowerHyphenCase
    spinalCase: fns.lowerHyphenCase
    trainCase: fns.upperHyphenCase
    humanCase: fns.lowerHumanCase
    titleCase: fns.upperHumanCase

registerPrototypes = ->
    _.each fns, (fn, key) ->
        String.prototype["to#{fns.upperCamelCase key}"] ?= -> fn this
    _.each aliases, (fn, key) ->
        String.prototype["to#{fns.upperCamelCase key}"] ?= -> fn this

module.exports = _.extend {
    mutateCase: mutateCase
    registerPrototypes: registerPrototypes
}, fns, aliases
