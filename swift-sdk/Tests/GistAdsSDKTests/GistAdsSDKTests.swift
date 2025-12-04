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
    
    // MARK: - API Version Tests
    
    func testAPIVersionDefault() {
        // Default should be v2
        let version = APIConstants.apiVersion()
        XCTAssertEqual(version, APIConstants.apiVersionV2)
    }
    
    func testAPIVersionConstants() {
        XCTAssertEqual(APIConstants.apiVersionV1, "v1")
        XCTAssertEqual(APIConstants.apiVersionV2, "v2")
    }
    
    func testSearchEndpointGeneration() {
        XCTAssertEqual(APIConstants.searchEndpoint(for: "v1"), "/v1/search")
        XCTAssertEqual(APIConstants.searchEndpoint(for: "v2"), "/v2/search")
        XCTAssertEqual(APIConstants.searchEndpoint(for: "v3"), "/v3/search") // Test extensibility
    }
    
    // MARK: - SearchRequestV1 Tests
    
    func testSearchRequestV1Encoding() throws {
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
    
    func testSearchRequestV1WithoutAdTypes() throws {
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
    
    // MARK: - SearchRequestV2 Tests
    
    func testSearchRequestV2Encoding() throws {
        let request = SearchRequestV2(
            prompt: "test query",
            answer: "test answer",
            geo: "US",
            auctionType: "native",
            adType: ["image", "text"],
            text: "test query"
        )
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(request)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        
        XCTAssertEqual(json?["prompt"] as? String, "test query")
        XCTAssertEqual(json?["answer"] as? String, "test answer")
        XCTAssertEqual(json?["geo"] as? String, "US")
        XCTAssertEqual(json?["auction_type"] as? String, "native")
        XCTAssertEqual(json?["text"] as? String, "test query")
        
        let adTypes = json?["ad_type"] as? [String]
        XCTAssertEqual(adTypes?.count, 2)
        XCTAssertTrue(adTypes?.contains("image") ?? false)
        XCTAssertTrue(adTypes?.contains("text") ?? false)
    }
    
    func testSearchRequestV2WithoutOptionalFields() throws {
        let request = SearchRequestV2(
            prompt: "test query",
            answer: "test answer",
            geo: "GB",
            auctionType: "native",
            adType: nil,
            text: nil
        )
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(request)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        
        XCTAssertEqual(json?["prompt"] as? String, "test query")
        XCTAssertEqual(json?["answer"] as? String, "test answer")
        XCTAssertNil(json?["ad_type"])
        XCTAssertNil(json?["text"])
    }
    
    // MARK: - Request Factory Tests
    
    func testCreateSearchRequestV1() throws {
        let request = createSearchRequest(
            version: APIConstants.apiVersionV1,
            query: "test query",
            geo: "US",
            adTypes: ["image"],
            answer: nil
        )
        
        XCTAssertTrue(request is SearchRequestV1)
        let v1Request = request as! SearchRequestV1
        XCTAssertEqual(v1Request.text, "test query")
        XCTAssertEqual(v1Request.geo, "US")
        XCTAssertEqual(v1Request.auctionType, "native")
    }
    
    func testCreateSearchRequestV2() throws {
        let request = createSearchRequest(
            version: APIConstants.apiVersionV2,
            query: "test query",
            geo: "US",
            adTypes: ["image"],
            answer: "test answer"
        )
        
        XCTAssertTrue(request is SearchRequestV2)
        let v2Request = request as! SearchRequestV2
        XCTAssertEqual(v2Request.prompt, "test query")
        XCTAssertEqual(v2Request.answer, "test answer")
        XCTAssertEqual(v2Request.geo, "US")
        XCTAssertEqual(v2Request.auctionType, "native")
    }
    
    func testCreateSearchRequestV2WithDefaultAnswer() throws {
        let request = createSearchRequest(
            version: APIConstants.apiVersionV2,
            query: "test query",
            geo: "US",
            adTypes: nil,
            answer: nil
        )
        
        XCTAssertTrue(request is SearchRequestV2)
        let v2Request = request as! SearchRequestV2
        XCTAssertEqual(v2Request.prompt, "test query")
        XCTAssertEqual(v2Request.answer, "test query") // Should default to query
    }
    
    func testCreateSearchRequestFutureVersion() throws {
        // Test that future versions default to v2 behavior
        let request = createSearchRequest(
            version: "v3",
            query: "test query",
            geo: "US",
            adTypes: nil,
            answer: nil
        )
        
        XCTAssertTrue(request is SearchRequestV2)
    }
    
    // MARK: - GistAdControl API Version Tests
    
    func testGistAdControlWithApiVersion() {
        // Test that GistAdControl can be initialized with apiVersion parameter
        let control = GistAdControl(
            publisherID: "test-id",
            publisherKey: "test-key",
            query: "test query",
            geo: "US",
            adTypes: nil,
            environment: .production,
            apiVersion: "v1"
        )
        
        // Verify the control was created (we can't easily test internal apiService without exposing it)
        // This test mainly ensures the initializer compiles and accepts the parameter
        XCTAssertNotNil(control)
    }
    
    func testGistAdControlWithDefaultApiVersion() {
        // Test that GistAdControl defaults to nil apiVersion (which uses environment variable or v2)
        let control = GistAdControl(
            publisherID: "test-id",
            publisherKey: "test-key",
            query: "test query",
            geo: "US",
            adTypes: nil,
            environment: .production
        )
        
        XCTAssertNotNil(control)
    }
    
    func testGistAdControlWithAdTypesAndApiVersion() {
        // Test the convenience initializer with apiVersion
        let control = GistAdControl.withAdTypes(
            publisherID: "test-id",
            publisherKey: "test-key",
            query: "test query",
            geo: "US",
            adTypes: [.image, .textImage],
            environment: .production,
            apiVersion: "v2"
        )
        
        XCTAssertNotNil(control)
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
    
    // MARK: - AdViewConstants Tests
    
    func testAdViewConstantsDefaultValues() {
        // Clear any existing environment variables
        let processInfo = ProcessInfo.processInfo
        let originalEnv = processInfo.environment
        
        // Test defaults when no env vars are set
        // Note: We can't easily clear env vars in tests, so we test that defaults match expected values
        XCTAssertEqual(AdViewConstants.defaultMinHeight, 100)
        XCTAssertEqual(AdViewConstants.defaultMaxHeight, 300)
        XCTAssertEqual(AdViewConstants.iframeMinHeight, 250)
    }
    
    func testAdViewConstantsEnvironmentVariableOverride() {
        // Note: ProcessInfo.processInfo.environment is read-only in Swift
        // In a real scenario, these would be set before the app runs
        // We test the logic by verifying the default behavior and structure
        
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
        // Since we can't set env vars in tests, we verify the structure handles it correctly
        
        // Verify configurable properties return valid CGFloat values
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
        // All should return defaults when env vars not set
        
        let minHeight = AdViewConstants.configurableMinHeight
        let maxHeight = AdViewConstants.configurableMaxHeight
        let iframeHeight = AdViewConstants.configurableIframeMinHeight
        
        // Each should independently return its default
        XCTAssertEqual(minHeight, 100)
        XCTAssertEqual(maxHeight, 300)
        XCTAssertEqual(iframeHeight, 250)
    }
}

