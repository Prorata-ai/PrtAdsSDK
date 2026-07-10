//
//  ProrataAdsSDKTests.swift
//  GistAdsSDKTests
//
//  Unit tests for Gist Ads SDK
//

import XCTest
@testable import GistAdsSDK

final class ProrataAdsSDKTests: XCTestCase {
    
    func testAdTypeRawValues() {
        XCTAssertEqual(AdType.image.rawValue, "image")
        XCTAssertEqual(AdType.textImage.rawValue, "text/image")
        XCTAssertEqual(AdType.text.rawValue, "text")
    }
    
    func testAdTypeDisplayNames() {
        XCTAssertEqual(AdType.image.displayName, "Image")
        XCTAssertEqual(AdType.textImage.displayName, "Text/Image")
        XCTAssertEqual(AdType.text.displayName, "Text")
    }
    
    func testAdTypeAllCases() {
        XCTAssertEqual(AdType.allCases.count, 3)
        XCTAssertTrue(AdType.allCases.contains(.image))
        XCTAssertTrue(AdType.allCases.contains(.textImage))
        XCTAssertTrue(AdType.allCases.contains(.text))
    }
    
    func testSearchRequestEncoding() throws {
        let request = SearchRequestV1(
            text: "test query",
            geo: "US",
            auctionType: "native",
            adType: ["image"]
        )
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(request)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        
        XCTAssertEqual(json?["text"] as? String, "test query")
        XCTAssertEqual(json?["geo"] as? String, "US")
        XCTAssertEqual(json?["auction_type"] as? String, "native")
        
        let adTypes = json?["ad_type"] as? [String]
        XCTAssertEqual(adTypes?.first, "image")
    }
    
    func testSearchRequestWithoutAdTypes() throws {
        let request = SearchRequestV1(
            text: "test query",
            geo: "GB",
            auctionType: "native",
            adType: nil
        )
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(request)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        
        XCTAssertEqual(json?["text"] as? String, "test query")
        XCTAssertEqual(json?["geo"] as? String, "GB")
        XCTAssertNil(json?["ad_type"])
    }
    
    func testAdAPIErrorDescriptions() {
        XCTAssertEqual(
            AdAPIError.invalidURL.errorDescription,
            "Invalid API URL"
        )
        XCTAssertEqual(
            AdAPIError.invalidResponse.errorDescription,
            "Invalid response from server"
        )
        // Test invalidData with underlying error
        let testError = NSError(domain: "test", code: 1, userInfo: [NSLocalizedDescriptionKey: "Test error"])
        XCTAssertEqual(
            AdAPIError.invalidData(underlying: testError).errorDescription,
            "Unable to parse response data: Test error"
        )
        // Test httpError with status code and optional response
        XCTAssertEqual(
            AdAPIError.httpError(statusCode: 404, response: nil).errorDescription,
            "HTTP error: 404"
        )
        XCTAssertEqual(
            AdAPIError.noAdsAvailable.errorDescription,
            "No ads available for this query"
        )
        XCTAssertEqual(
            AdAPIError.missingIframeUrl.errorDescription,
            "Ad response missing iframe URL"
        )
    }
    
    func testSDKVersion() {
        XCTAssertEqual(GistAdsSDK.version, "1.0.3")
        XCTAssertEqual(GistAdsSDK.name, "GistAdsSDK")
    }
    
    // MARK: - AdViewConstants Tests
    
    func testAdViewConstantsDefaultValues() {
        // Test defaults when no env vars are set
        XCTAssertEqual(AdViewConstants.defaultMinHeight, 100)
        XCTAssertEqual(AdViewConstants.defaultMaxHeight, 300)
        XCTAssertEqual(AdViewConstants.iframeMinHeight, 250)
    }
    
    func testAdViewConstantsEnvironmentVariableOverride() {
        // Verify configurable properties exist and return defaults when env vars not set
        XCTAssertEqual(AdViewConstants.configurableMinHeight, AdViewConstants.defaultMinHeight)
        XCTAssertEqual(AdViewConstants.configurableMaxHeight, AdViewConstants.defaultMaxHeight)
        XCTAssertEqual(AdViewConstants.configurableIframeMinHeight, AdViewConstants.iframeMinHeight)
        
        // Verify they are CGFloat values
        XCTAssertTrue(AdViewConstants.configurableMinHeight >= 0)
        XCTAssertTrue(AdViewConstants.configurableMaxHeight >= 0)
        XCTAssertTrue(AdViewConstants.configurableIframeMinHeight >= 0)
    }
    
    func testAdViewConstantsInvalidEnvironmentVariable() {
        // Test that invalid values fall back to defaults
        let minHeight = AdViewConstants.configurableMinHeight
        let maxHeight = AdViewConstants.configurableMaxHeight
        let iframeHeight = AdViewConstants.configurableIframeMinHeight
        
        // Should be valid positive numbers
        XCTAssertGreaterThanOrEqual(minHeight, 0)
        XCTAssertGreaterThanOrEqual(maxHeight, 0)
        XCTAssertGreaterThanOrEqual(iframeHeight, 0)
        
        // Should match defaults when env vars not set
        XCTAssertEqual(minHeight, AdViewConstants.defaultMinHeight)
        XCTAssertEqual(maxHeight, AdViewConstants.defaultMaxHeight)
        XCTAssertEqual(iframeHeight, AdViewConstants.iframeMinHeight)
    }
    
    func testAdViewConstantsPartialOverride() {
        // Verify each configurable property works independently
        let minHeight = AdViewConstants.configurableMinHeight
        let maxHeight = AdViewConstants.configurableMaxHeight
        let iframeHeight = AdViewConstants.configurableIframeMinHeight
        
        // Each should independently return its default
        XCTAssertEqual(minHeight, 100)
        XCTAssertEqual(maxHeight, 300)
        XCTAssertEqual(iframeHeight, 250)
    }
}

