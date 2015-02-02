mystique = require "../lib/mystique"

TEST_SUITES = [
    {
        original: "thisIs/1test/of-the/emergency/CaseChangingSystem"
        expected:
            lowerCamelCase: "thisIs/1Test/ofThe/emergency/caseChangingSystem"
            upperCamelCase: "ThisIs/1Test/OfThe/Emergency/CaseChangingSystem"
            lowerUnderscoreCase: "this_is/1_test/of_the/emergency/case_changing_system"
            upperUnderscoreCase: "This_Is/1_Test/Of_The/Emergency/Case_Changing_System"
            constantCase: "THIS_IS/1_TEST/OF_THE/EMERGENCY/CASE_CHANGING_SYSTEM"
            lowerHyphenCase: "this-is/1-test/of-the/emergency/case-changing-system"
            upperHyphenCase: "This-Is/1-Test/Of-The/Emergency/Case-Changing-System"
            lowerHumanCase: "this is/1 test/of the/emergency/case changing system"
            upperHumanCase: "This Is/1 Test/Of The/Emergency/Case Changing System"
            sentenceCase: "This is/1 test/Of the/Emergency/Case changing system"
    }
]

describe "Mystique:", ->
    for testSuite in TEST_SUITES
        describe testSuite.original, ->
            for key, value of testSuite.expected
                do (key, value) ->
                    it "should render in #{key}", ->
                        mystique[key](testSuite.original).should.equal value

describe "Prototype:", ->
    mystique.registerPrototypes()
    for testSuite in TEST_SUITES
        describe testSuite.original, ->
            for key, value of testSuite.expected
                do (key, value) ->
                    it "should render in #{key}", ->
                        testSuite.original["to#{mystique.upperCamelCase key}"]().should.equal value
