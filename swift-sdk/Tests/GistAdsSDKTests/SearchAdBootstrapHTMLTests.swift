//
//  SearchAdBootstrapHTMLTests.swift
//  GistAdsSDKTests
//
//  Unit tests for SearchAdBootstrapHTML: string assertions on the generated
//  bootstrap document's `defineSlot`/`definePrompt`/`defineAnswer`/
//  `definePassbackFunction`/script-src content, without needing a live
//  WebView. Mirrors DisplayAdBootstrapHTMLTests.swift.
//

import XCTest
@testable import GistAdsSDK

final class SearchAdBootstrapHTMLTests: XCTestCase {

    private func generate(
        publisherID: String = "pub-123",
        publisherKey: String = "key-abc",
        query: String = "best running shoes",
        geo: String = "US",
        answer: String? = nil,
        adTypes: [AdType]? = nil,
        sizes: [AdSize] = [.dynamic],
        slotID: String = "slot-abc",
        passbackFunctionName: String = "prPassbackFn",
        adTagScriptURL: String = "https://tp-at.staging.prorata.ai/adtag.js"
    ) throws -> String {
        try SearchAdBootstrapHTML.generate(
            publisherID: publisherID,
            publisherKey: publisherKey,
            query: query,
            geo: geo,
            answer: answer,
            adTypes: adTypes,
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

    func testCallsDefineSlotWithPublisherIDApiKeyAndGeo() throws {
        let html = try generate(publisherID: "pub-123", publisherKey: "key-abc", geo: "US")
        XCTAssertTrue(html.contains(#"defineSlot({ id: "pub-123", api_key: "key-abc", geo: "US" }, "slot-abc""#))
    }

    func testDefineSlotNeverIncludesUrlField() throws {
        // Search slots are valid without `url` (defineSlot accepts either
        // `url` or `api_key`) -- confirm we never emit one.
        let html = try generate()
        XCTAssertFalse(html.contains("url:"))
    }

    func testCallsDefinePromptWithQuery() throws {
        let html = try generate(query: "best running shoes")
        XCTAssertTrue(html.contains(#"slot.definePrompt("best running shoes")"#))
    }

    func testDefaultsDefineAnswerToQueryWhenNil() throws {
        // The ad tag docs mark `answer` as required for search ads, so we
        // always call defineAnswer, falling back to the query (matching the
        // pre-embed native SDK's request body default) when not provided.
        let html = try generate(query: "best running shoes", answer: nil)
        XCTAssertTrue(html.contains(#"slot.defineAnswer("best running shoes")"#))
    }

    func testDefaultsDefineAnswerToQueryWhenBlank() throws {
        let html = try generate(query: "best running shoes", answer: "   ")
        XCTAssertTrue(html.contains(#"slot.defineAnswer("best running shoes")"#))
    }

    func testIncludesDefineAnswerWhenProvided() throws {
        let html = try generate(answer: "running shoes for beginners")
        XCTAssertTrue(html.contains(#"slot.defineAnswer("running shoes for beginners")"#))
    }

    func testOmitsAdTypesArgumentWhenNil() throws {
        let html = try generate(adTypes: nil)
        XCTAssertTrue(html.contains(#"undefined);"#))
    }

    func testIncludesAdTypesArrayWhenProvided() throws {
        let html = try generate(adTypes: [.text, .image])
        XCTAssertTrue(html.contains(#"["text", "image"]"#))
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

    // MARK: - Validation

    func testThrowsInvalidSizesForEmptySizes() {
        XCTAssertThrowsError(try generate(sizes: [])) { error in
            XCTAssertEqual(error as? SearchAdBootstrapError, .invalidSizes)
        }
    }

    func testThrowsEmptyQueryForBlankQuery() {
        XCTAssertThrowsError(try generate(query: "   ")) { error in
            XCTAssertEqual(error as? SearchAdBootstrapError, .emptyQuery)
        }
    }

    // MARK: - Escaping / injection safety

    func testQueryWithQuoteAndScriptTagIsEscaped() throws {
        let html = try generate(query: #"shoes"><script>alert(1)</script>"#)
        XCTAssertFalse(html.contains(#"definePrompt("shoes"><script>alert(1)</script>")"#))
        XCTAssertFalse(html.contains("</script>alert"))
    }

    func testPublisherKeyWithBackslashAndQuoteIsEscaped() throws {
        let html = try generate(publisherKey: #"key\"abc"#)
        XCTAssertTrue(html.contains(#"api_key: "key\\\"abc""#))
    }
}
