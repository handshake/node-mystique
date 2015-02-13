_ = require "underscore"

NORMALIZE_WORD_BOUNDARIES = /(?!')[\W_]/g

NORMALIZE_INNER_WORD_PUNCTUATION = /[']/g

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
    preserveInitialisms: false

DEFAULT_PARSING_OPTIONS =
    leftBoundary: ""
    rightBoundary: ""
    segmentLeftBoundary: ""
    segmentRightBoundary: ""
    segmentDelimiter: "/"

capitalize = (word, normal, invert, invertFirst, invertAll) ->
    if invertAll
        word[invert]()
    else
        word = word[normal]()
        if invertFirst
            word = word.replace FIRST_LETTER, (letter) -> letter[invert]()
        word

tokenize = (variable, opts) ->
    _.map( variable
        .match(///^#{opts.leftBoundary}(.*)#{opts.rightBoundary}$///)[1]
        .split(opts.segmentDelimiter)
    , (segment) ->
        isAllCaps = segment.toUpperCase() is segment
        _.map(
            segment
                .match(///^#{opts.segmentLeftBoundary}(.*)#{opts.segmentRightBoundary}$///)[1]
                .replace(NORMALIZE_INNER_WORD_PUNCTUATION, "")
                .replace(NORMALIZE_WORD_BOUNDARIES, " ")
                .match TOKENIZE
        , (token) ->
            isInitialism: unless isAllCaps then token.toUpperCase() is token else false
            value: token
        )
    )

mutateCase = (variable, renderOpts = {}, parseOpts = renderOpts.parseOpts or {}) ->
    renderOpts = _.defaults renderOpts, DEFAULT_RENDERING_OPTIONS
    parseOpts = _.defaults parseOpts, DEFAULT_PARSING_OPTIONS

    parseOpts.normalCase = renderOpts.normalCase

    [normal, invert] = switch renderOpts.normalCase
        when "lower" then ["toLowerCase", "toUpperCase"]
        when "upper" then ["toUpperCase", "toLowerCase"]
        else              ["toString",    "toString"]

    renderOpts.leftBoundary + _.map( tokenize(variable, parseOpts), (segment) ->
        segment = _.map segment, (token, i) ->
            capitalize token.value, normal, invert, (
                if i then renderOpts.invertFirstLetters else renderOpts.invertInitialLetter
            ), token.isInitialism and renderOpts.preserveInitialisms

        renderOpts.segmentLeftBoundary +
            segment.join(renderOpts.wordDelimiter) +
            renderOpts.segmentRightBoundary

    ).join renderOpts.segmentDelimiter + renderOpts.rightBoundary

fns =
    lowerCamelCase: (variable) ->
        mutateCase variable,
            invertFirstLetters: true,
            preserveInitialisms: true

    upperCamelCase: (variable) ->
        mutateCase variable,
            invertFirstLetters: true,
            invertInitialLetter: true,
            preserveInitialisms: true

    lowerUnderscoreCase: (variable) ->
        mutateCase variable,
            wordDelimiter: "_"

    upperUnderscoreCase: (variable) ->
        mutateCase variable,
            wordDelimiter: "_",
            invertFirstLetters: true,
            invertInitialLetter: true,
            preserveInitialisms: true

    constantCase: (variable) ->
        mutateCase variable,
            wordDelimiter: "_",
            normalCase: "upper"

    lowerHyphenCase: (variable) ->
        mutateCase variable,
            wordDelimiter: "-"

    upperHyphenCase: (variable) ->
        mutateCase variable,
            wordDelimiter: "-",
            invertFirstLetters: true,
            invertInitialLetter: true,
            preserveInitialisms: true

    lowerHumanCase: (variable) ->
        mutateCase variable,
            wordDelimiter: " "

    upperHumanCase: (variable) ->
        mutateCase variable,
            wordDelimiter: " ",
            invertFirstLetters: true,
            invertInitialLetter: true,
            preserveInitialisms: true

    sentenceCase: (variable) ->
        mutateCase variable,
            wordDelimiter: " ",
            invertInitialLetter: true,
            preserveInitialisms: true

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
