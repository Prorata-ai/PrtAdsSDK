//
//  DisplayAdBootstrapHTMLTests.swift
//  GistAdsSDKTests
//
//  Unit tests for DisplayAdBootstrapHTML: string assertions on the
//  generated bootstrap document's `defineSlot`/`defineAdData`/
//  `definePassbackFunction`/script-src content, without needing a live
//  WebView (see the "Testing strategy" notes in the embed-adtag.js plan).
//

import XCTest
@testable import GistAdsSDK

final class DisplayAdBootstrapHTMLTests: XCTestCase {

    private func generate(
        publisherID: String = "pub-123",
        pageURL: String = "https://example.com/article",
        sizes: [AdSize] = [.mediumRectangle],
        slotID: String = "slot-abc",
        passbackFunctionName: String = "prPassbackFn",
        adTagScriptURL: String = "https://tp-at.staging.prorata.ai/adtag.js"
    ) throws -> String {
        try DisplayAdBootstrapHTML.generate(
            publisherID: publisherID,
            pageURL: pageURL,
            sizes: sizes,
            slotID: slotID,
            passbackFunctionName: passbackFunctionName,
            adTagScriptURL: adTagScriptURL
        )
    }

    // MARK: - Structure

    func testGeneratesSlotDivMatchingSlotID() throws {
        let html = try generate(slotID: "slot-abc")
        XCTAssertTrue(html.contains(#"<div id="slot-abc""#))
    }

    func testGeneratesScriptTagForAdTagScriptURL() throws {
        let html = try generate(adTagScriptURL: "https://tp-at.staging.prorata.ai/adtag.js")
        XCTAssertTrue(html.contains(#"<script src="https://tp-at.staging.prorata.ai/adtag.js" defer></script>"#))
    }

    func testCallsDefineSlotWithPublisherIDAndPageURL() throws {
        let html = try generate(publisherID: "pub-123", pageURL: "https://example.com/article")
        XCTAssertTrue(html.contains(#"defineSlot({ id: "pub-123", url: "https://example.com/article" }, "slot-abc""#))
    }

    func testCallsDefineSlotWithEncodedSizes() throws {
        let html = try generate(sizes: [.mediumRectangle, .leaderboard])
        XCTAssertTrue(html.contains("[[300,250],[728,90]]"))
    }

    func testCallsDefineSlotWithDynamicSizeAsZeroZero() throws {
        let html = try generate(sizes: [.dynamic])
        XCTAssertTrue(html.contains("[[0,0]]"))
    }

    func testDefinesPassbackFunctionWithGivenName() throws {
        let html = try generate(passbackFunctionName: "prPassbackFn")
        XCTAssertTrue(html.contains(#"window["prPassbackFn"] = function()"#))
        XCTAssertTrue(html.contains(#"slot.definePassbackFunction("prPassbackFn")"#))
    }

    func testCallsDisplayAdWithSlotID() throws {
        let html = try generate(slotID: "slot-abc")
        XCTAssertTrue(html.contains(#"window.prtag.displayAd("slot-abc")"#))
    }

    func testRegistersAdRenderedListener() throws {
        let html = try generate()
        XCTAssertTrue(html.contains(#"addEventListener("adRendered""#))
    }

    func testNeverIncludesDefineAdData() throws {
        let html = try generate()
        XCTAssertFalse(html.contains("defineAdData"))
    }

    // MARK: - Validation

    func testThrowsInvalidSizesForEmptySizes() {
        XCTAssertThrowsError(try generate(sizes: [])) { error in
            XCTAssertEqual(error as? DisplayAdBootstrapError, .invalidSizes)
        }
    }

    func testThrowsEmptyPageURLForBlankPageURL() {
        XCTAssertThrowsError(try generate(pageURL: "   ")) { error in
            XCTAssertEqual(error as? DisplayAdBootstrapError, .emptyPageURL)
        }
    }

    func testThrowsEmptyPageURLForEmptyPageURL() {
        XCTAssertThrowsError(try generate(pageURL: "")) { error in
            XCTAssertEqual(error as? DisplayAdBootstrapError, .emptyPageURL)
        }
    }

    // MARK: - Escaping / injection safety

    func testPageURLWithQuoteIsEscapedInJSStringLiteral() throws {
        let html = try generate(pageURL: #"https://example.com/"><script>alert(1)</script>"#)
        // The raw payload must never appear verbatim (would break out of the string literal / close the script tag).
        XCTAssertFalse(html.contains(#"url: "https://example.com/"><script>alert(1)</script>""#))
        XCTAssertFalse(html.contains("</script>alert"))
    }

    func testPublisherIDWithBackslashAndQuoteIsEscaped() throws {
        let html = try generate(publisherID: #"pub\"123"#)
        XCTAssertTrue(html.contains(#"id: "pub\\\"123""#))
    }

    // MARK: - jsStringLiteral / scriptSafeJSON helpers directly

    func testJSStringLiteralEscapesBackslashAndQuote() {
        XCTAssertEqual(jsStringLiteral(#"a\b"c"#), #""a\\b\"c""#)
    }

    func testJSStringLiteralEscapesLessThanToDefuseScriptClose() {
        XCTAssertEqual(jsStringLiteral("</script>"), #""\u003C/script>""#)
    }

    func testJSStringLiteralEscapesLineAndParagraphSeparators() {
        XCTAssertEqual(jsStringLiteral("a\u{2028}b\u{2029}c"), "\"a\\u2028b\\u2029c\"")
    }

    func testScriptSafeJSONEscapesLessThan() {
        XCTAssertEqual(scriptSafeJSON(#"{"a":"</script>"}"#), #"{"a":"\u003C/script>"}"#)
    }
}
