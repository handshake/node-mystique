module.exports = (grunt) ->
    grunt.loadNpmTasks "grunt-coffeelint"
    grunt.loadNpmTasks "grunt-mocha-test"

    grunt.initConfig
        pkg: grunt.file.readJSON "package.json"
        coffeelint:
            options:
                configFile: "coffeelint.json"
            files: [
                "lib/*.coffee"
                "spec/*.coffee"
            ]
        mochaTest:
            test:
                options:
                    reporter: "spec"
                    require: [
                        "coffee-script/register"
                        -> require("chai").should()
                    ]
                src: ["spec/*.coffee"]

    grunt.registerTask "test", ["coffeelint", "mochaTest"]
