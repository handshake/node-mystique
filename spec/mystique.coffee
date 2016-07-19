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
    },
    {
        original: "it shouldn't choke on abbreviations or initialisms like URL"
        expected:
            lowerCamelCase: "itShouldntChokeOnAbbreviationsOrInitialismsLikeURL"
            upperCamelCase: "ItShouldntChokeOnAbbreviationsOrInitialismsLikeURL"
            lowerUnderscoreCase: "it_shouldnt_choke_on_abbreviations_or_initialisms_like_url"
            upperUnderscoreCase: "It_Shouldnt_Choke_On_Abbreviations_Or_Initialisms_Like_URL"
            constantCase: "IT_SHOULDNT_CHOKE_ON_ABBREVIATIONS_OR_INITIALISMS_LIKE_URL"
            lowerHyphenCase: "it-shouldnt-choke-on-abbreviations-or-initialisms-like-url"
            upperHyphenCase: "It-Shouldnt-Choke-On-Abbreviations-Or-Initialisms-Like-URL"
            lowerHumanCase: "it shouldnt choke on abbreviations or initialisms like url"
            upperHumanCase: "It Shouldnt Choke On Abbreviations Or Initialisms Like URL"
            sentenceCase: "It shouldnt choke on abbreviations or initialisms like URL"
    },
    {
        original: """it shouldn't choke on newlines
            or "quoted strings" in the middle"""
        expected:
            lowerCamelCase: "itShouldntChokeOnNewlinesOrQuotedStringsInTheMiddle"
            upperCamelCase: "ItShouldntChokeOnNewlinesOrQuotedStringsInTheMiddle"
            lowerUnderscoreCase: "it_shouldnt_choke_on_newlines_or_quoted_strings_in_the_middle"
            upperUnderscoreCase: "It_Shouldnt_Choke_On_Newlines_Or_Quoted_Strings_In_The_Middle"
            constantCase: "IT_SHOULDNT_CHOKE_ON_NEWLINES_OR_QUOTED_STRINGS_IN_THE_MIDDLE"
            lowerHyphenCase: "it-shouldnt-choke-on-newlines-or-quoted-strings-in-the-middle"
            upperHyphenCase: "It-Shouldnt-Choke-On-Newlines-Or-Quoted-Strings-In-The-Middle"
            lowerHumanCase: "it shouldnt choke on newlines or quoted strings in the middle"
            upperHumanCase: "It Shouldnt Choke On Newlines Or Quoted Strings In The Middle"
            sentenceCase: "It shouldnt choke on newlines or quoted strings in the middle"
    }
]

describe "Mystique:", ->
    for testSuite in TEST_SUITES
        describe testSuite.original, ->
            for key, value of testSuite.expected
                do (testSuite, key, value) ->
                    it "should render in #{key}", ->
                        mystique[key](testSuite.original).should.equal value

describe "Prototype:", ->
    mystique.registerPrototypes()
    for testSuite in TEST_SUITES
        describe testSuite.original, ->
            for key, value of testSuite.expected
                do (testSuite, key, value) ->
                    it "should render in #{key}", ->
                        testSuite.original["to#{mystique.upperCamelCase key}"]().should.equal value
