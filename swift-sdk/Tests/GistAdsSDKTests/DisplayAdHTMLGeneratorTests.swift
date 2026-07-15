//
//  DisplayAdHTMLGeneratorTests.swift
//  GistAdsSDKTests
//
//  Unit tests for DisplayAdHTMLGenerator, focused on HTML escaping of raw
//  ad fields (particularly the `alt` attribute, which needs quote escaping
//  in addition to the base entity escaping used for text content).
//

import XCTest
@testable import GistAdsSDK

final class DisplayAdHTMLGeneratorTests: XCTestCase {

    // MARK: - Escaping

    func testHeadlineQuotesAreEscapedInAltAttribute() {
        let ad = DisplayAdItem(adHeadline: "Best \"Deals\" Today", adImage: "https://example.com/img.jpg")
        let result = DisplayAdHTMLGenerator.generate(ad: ad, theme: "light")

        XCTAssertTrue(result.contains("alt=\"Best &quot;Deals&quot; Today\""))
        XCTAssertFalse(result.contains("alt=\"Best \"Deals\" Today\""))
    }

    func testHeadlineAmpersandAndBracketsAreEscapedInTextContent() {
        let ad = DisplayAdItem(adHeadline: "A & B <script>")
        let result = DisplayAdHTMLGenerator.generate(ad: ad, theme: "light")

        XCTAssertTrue(result.contains("<div class=\"pr-display-ad-headline\">A &amp; B &lt;script&gt;</div>"))
    }

    func testClickUrlQuotesAreEscaped() {
        let ad = DisplayAdItem(adUrl: "https://example.com/ad?q=\"x\"")
        let result = DisplayAdHTMLGenerator.generate(ad: ad, theme: "light")

        XCTAssertTrue(result.contains("href=\"https://example.com/ad?q=&quot;x&quot;\""))
    }

    // MARK: - Structure

    func testClickUrlDefaultsToHashWhenAdUrlIsNil() {
        let ad = DisplayAdItem(adHeadline: "Headline")
        let result = DisplayAdHTMLGenerator.generate(ad: ad, theme: "light")

        XCTAssertTrue(result.contains("href=\"#\""))
    }

    func testImageBlockOmittedWhenAdImageIsNilOrEmpty() {
        let ad = DisplayAdItem(adHeadline: "Headline", adImage: "")
        let result = DisplayAdHTMLGenerator.generate(ad: ad, theme: "light")

        XCTAssertFalse(result.contains("<img"))
    }

    func testImageBlockIncludedWhenAdImagePresent() {
        let ad = DisplayAdItem(adHeadline: "Headline", adImage: "https://example.com/img.jpg")
        let result = DisplayAdHTMLGenerator.generate(ad: ad, theme: "light")

        XCTAssertTrue(result.contains("<img class=\"pr-display-ad-image\" src=\"https://example.com/img.jpg\""))
    }

    func testDoesNotIncludeTargetBlank() {
        let ad = DisplayAdItem(adUrl: "https://example.com/ad")
        let result = DisplayAdHTMLGenerator.generate(ad: ad, theme: "light")

        XCTAssertFalse(result.contains("target="))
    }

    func testThemeIsIncludedAsDataAttribute() {
        let ad = DisplayAdItem(adUrl: "https://example.com/ad")
        let result = DisplayAdHTMLGenerator.generate(ad: ad, theme: "dark")

        XCTAssertTrue(result.contains("data-pr-theme=\"dark\""))
    }

    func testHeadlineFallsBackToAdNameWhenHeadlineIsNil() {
        let ad = DisplayAdItem(adName: "Acme Corp")
        let result = DisplayAdHTMLGenerator.generate(ad: ad, theme: "light")

        XCTAssertTrue(result.contains("<div class=\"pr-display-ad-headline\">Acme Corp</div>"))
    }
}
