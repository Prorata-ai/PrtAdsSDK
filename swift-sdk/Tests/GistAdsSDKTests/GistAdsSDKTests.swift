//
//  GistAdsSDKTests.swift
//  GistAdsSDKTests
//
//  Unit tests for Gist Ads SDK
//

import XCTest
@testable import GistAdsSDK

final class GistAdsSDKTests: XCTestCase {
    
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
        let request = SearchRequest(
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
        let request = SearchRequest(
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
        XCTAssertEqual(GistAdsSDK.version, "1.0.0")
        XCTAssertEqual(GistAdsSDK.name, "GistAdsSDK")
    }
}

