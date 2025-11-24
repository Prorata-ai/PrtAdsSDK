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
        XCTAssertEqual(AdType.imageText.rawValue, "image/text")
    }
    
    func testAdTypeDisplayNames() {
        XCTAssertEqual(AdType.image.displayName, "Image")
        XCTAssertEqual(AdType.imageText.displayName, "Image/Text")
    }
    
    func testAdTypeAllCases() {
        XCTAssertEqual(AdType.allCases.count, 2)
        XCTAssertTrue(AdType.allCases.contains(.image))
        XCTAssertTrue(AdType.allCases.contains(.imageText))
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
        XCTAssertEqual(
            AdAPIError.invalidData.errorDescription,
            "Unable to parse response data"
        )
        XCTAssertEqual(
            AdAPIError.httpError(statusCode: 404).errorDescription,
            "HTTP error: 404"
        )
        XCTAssertEqual(
            AdAPIError.noAdsAvailable.errorDescription,
            "No ads available for this query"
        )
    }
    
    func testSDKVersion() {
        XCTAssertEqual(GistAdsSDK.version, "1.0.0")
        XCTAssertEqual(GistAdsSDK.name, "GistAdsSDK")
    }
}

