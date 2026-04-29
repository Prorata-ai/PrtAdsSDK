//
//  IframeHTMLGeneratorTests.swift
//  GistAdsSDKTests
//
//  Unit tests for IframeHTMLGenerator, including the templateId workaround
//  for the legacy numeric `pr_templateid=1` returned by the Search API.
//

import XCTest
@testable import GistAdsSDK

final class IframeHTMLGeneratorTests: XCTestCase {

    // MARK: - Theme appending

    func testAppendsThemeWithQuestionMarkWhenNoQueryParams() {
        let result = IframeHTMLGenerator.generate(iframeUrl: "https://example.com/ad", theme: "dark")
        XCTAssertTrue(result.contains("https://example.com/ad?pr_theme=dark"))
    }

    func testAppendsThemeWithAmpersandWhenExistingQueryParams() {
        let result = IframeHTMLGenerator.generate(iframeUrl: "https://example.com/ad?foo=bar", theme: "light")
        XCTAssertTrue(result.contains("foo=bar&pr_theme=light"))
    }

    // MARK: - Iframe attributes

    func testIframeIncludesRequiredAttributes() {
        let result = IframeHTMLGenerator.generate(iframeUrl: "https://example.com/ad", theme: "dark")
        XCTAssertTrue(result.contains("<iframe"))
        XCTAssertTrue(result.contains("</iframe>"))
        XCTAssertTrue(result.contains("frameborder=\"0\""))
        XCTAssertTrue(result.contains("scrolling=\"no\""))
        XCTAssertTrue(result.contains("allowfullscreen"))
        XCTAssertTrue(result.contains("min-height:250px"))
    }

    // MARK: - normalizeTemplateId workaround

    func testNormalizeTemplateIdLeavesUrlUnchangedWhenNoTemplateId() {
        let url = "https://example.com/ad?foo=bar"
        XCTAssertEqual(IframeHTMLGenerator.normalizeTemplateId(in: url), url)
    }

    func testNormalizeTemplateIdLeavesValidAliasUnchanged() {
        let url = "https://example.com/ad?pr_templateid=text/image&pr_adimage=https://example.com/img.jpg"
        let result = IframeHTMLGenerator.normalizeTemplateId(in: url)
        XCTAssertTrue(result.contains("pr_templateid=text/image"))
    }

    func testNormalizeTemplateIdMapsNumericOneToTextImage() {
        let url = "https://example.com/ad?pr_templateid=1&pr_adimage=https://example.com/img.jpg&pr_adtext=hello"
        let result = IframeHTMLGenerator.normalizeTemplateId(in: url)
        XCTAssertTrue(result.contains("pr_templateid=text/image"))
        XCTAssertFalse(result.contains("pr_templateid=1"))
    }

    func testNormalizeTemplateIdMapsNumericOneToImageWhenOnlyImagePresent() {
        let url = "https://example.com/ad?pr_templateid=1&pr_adimage=https://example.com/img.jpg"
        let result = IframeHTMLGenerator.normalizeTemplateId(in: url)
        XCTAssertTrue(result.contains("pr_templateid=image"))
    }

    func testNormalizeTemplateIdMapsNumericOneToTextWhenOnlyTextPresent() {
        let url = "https://example.com/ad?pr_templateid=1&pr_adtext=hello"
        let result = IframeHTMLGenerator.normalizeTemplateId(in: url)
        XCTAssertTrue(result.contains("pr_templateid=text"))
    }

    func testNormalizeTemplateIdPrefersExplicitAdType() {
        let url = "https://example.com/ad?pr_templateid=1&pr_adtype=text/answer&pr_adtext=hi"
        let result = IframeHTMLGenerator.normalizeTemplateId(in: url)
        XCTAssertTrue(result.contains("pr_templateid=text/answer"))
    }

    func testNormalizeTemplateIdMapsNativeIdSameAsNumericOne() {
        let url = "https://example.com/ad?pr_templateid=native&pr_adimage=https://img&pr_adtext=hi"
        let result = IframeHTMLGenerator.normalizeTemplateId(in: url)
        XCTAssertTrue(result.contains("pr_templateid=text/image"))
    }

    func testGenerateNormalizesTemplateIdInProductionLikeUrl() {
        let url = "https://tp-at.prorata.ai/render_generic.html?pr_adimage=https://img&pr_adtext=hello&pr_templateid=1&pr_publisher=guest-api"
        let result = IframeHTMLGenerator.generate(iframeUrl: url, theme: "light")
        XCTAssertTrue(result.contains("pr_templateid=text/image"))
        XCTAssertFalse(result.contains("pr_templateid=1"))
        XCTAssertTrue(result.contains("pr_theme=light"))
    }
}
