//
//  DisplayAdAPIServiceTests.swift
//  GistAdsSDKTests
//
//  Unit tests for DisplayAdAPIService, using a stubbed URLProtocol so no
//  real network calls are made. The stubbed response shapes mirror what
//  was confirmed live against the real `/decision` endpoint in PAA-5351
//  Step 0 (raw fields for a fill, `{}` for a no-fill).
//

import XCTest
@testable import GistAdsSDK

final class DisplayAdAPIServiceTests: XCTestCase {

    private func makeMockSession() -> URLSession {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        return URLSession(configuration: config)
    }

    override func tearDown() {
        MockURLProtocol.requestHandler = nil
        super.tearDown()
    }

    // MARK: - Request building

    func testBuildRequestIncludesExpectedQueryParamsAndNoAuthHeaders() throws {
        let service = DisplayAdAPIService(baseURL: "https://disp-api.prorata.ai", publisherID: "pub-123")
        let request = try service.buildRequest(pageURL: "https://example.com/article", sizes: [.mediumRectangle])

        XCTAssertEqual(request.httpMethod, "GET")

        let url = try XCTUnwrap(request.url)
        XCTAssertEqual(url.host, "disp-api.prorata.ai")
        XCTAssertEqual(url.path, "/decision")

        let components = try XCTUnwrap(URLComponents(url: url, resolvingAgainstBaseURL: false))
        let queryItems = try XCTUnwrap(components.queryItems)
        func value(for name: String) -> String? {
            queryItems.first(where: { $0.name == name })?.value
        }

        XCTAssertEqual(value(for: "publisher"), "pub-123")
        XCTAssertEqual(value(for: "url"), "https://example.com/article")
        XCTAssertEqual(value(for: "ad_size"), "[[300,250]]")
        XCTAssertEqual(value(for: "format"), "json")
        XCTAssertNotNil(value(for: "cb"))
        XCTAssertNotNil(value(for: "correlation_id"))

        // The display API is not gated by a publisher key -- see the
        // contract notes in DisplayAdAPIService.swift.
        XCTAssertNil(request.value(forHTTPHeaderField: "Publisher-Key"))
    }

    func testBuildRequestWithEmptySizesThrows() {
        let service = DisplayAdAPIService(baseURL: "https://disp-api.prorata.ai", publisherID: "pub-123")
        XCTAssertThrowsError(try service.buildRequest(pageURL: "https://example.com", sizes: [])) { error in
            XCTAssertEqual(error as? DisplayAdAPIError, .invalidSizes)
        }
    }

    func testBuildRequestOmitsDataParamWhenContextIsNil() throws {
        let service = DisplayAdAPIService(baseURL: "https://disp-api.prorata.ai", publisherID: "pub-123")
        let request = try service.buildRequest(pageURL: "https://example.com/article", sizes: [.mediumRectangle], context: nil)

        let url = try XCTUnwrap(request.url)
        let components = try XCTUnwrap(URLComponents(url: url, resolvingAgainstBaseURL: false))
        let queryItems = try XCTUnwrap(components.queryItems)

        XCTAssertFalse(queryItems.contains(where: { $0.name == "data" }))
    }

    func testBuildRequestOmitsDataParamWhenContextIsEmpty() throws {
        let service = DisplayAdAPIService(baseURL: "https://disp-api.prorata.ai", publisherID: "pub-123")
        let request = try service.buildRequest(pageURL: "https://example.com/article", sizes: [.mediumRectangle], context: [:])

        let url = try XCTUnwrap(request.url)
        let components = try XCTUnwrap(URLComponents(url: url, resolvingAgainstBaseURL: false))
        let queryItems = try XCTUnwrap(components.queryItems)

        XCTAssertFalse(queryItems.contains(where: { $0.name == "data" }))
    }

    func testBuildRequestEncodesContextIntoDataParam() throws {
        let service = DisplayAdAPIService(baseURL: "https://disp-api.prorata.ai", publisherID: "pub-123")
        let context: [String: Any] = ["category": "technology", "keywords": ["AI", "machine learning"]]
        let request = try service.buildRequest(pageURL: "https://example.com/article", sizes: [.mediumRectangle], context: context)

        let url = try XCTUnwrap(request.url)
        let components = try XCTUnwrap(URLComponents(url: url, resolvingAgainstBaseURL: false))
        let queryItems = try XCTUnwrap(components.queryItems)
        let dataValue = try XCTUnwrap(queryItems.first(where: { $0.name == "data" })?.value)

        let decoded = try XCTUnwrap(
            try JSONSerialization.jsonObject(with: Data(dataValue.utf8)) as? [String: Any]
        )
        XCTAssertEqual(decoded["category"] as? String, "technology")
        XCTAssertEqual(decoded["keywords"] as? [String], ["AI", "machine learning"])
    }

    func testEncodeContextParamThrowsForInvalidJSONValue() {
        // NSObject() is not a valid JSON value, so JSONSerialization.isValidJSONObject should reject it.
        let invalidContext: [String: Any] = ["bad": NSObject()]
        XCTAssertThrowsError(try DisplayAdAPIService.encodeContextParam(invalidContext)) { error in
            XCTAssertEqual(error as? DisplayAdAPIError, .invalidContext)
        }
    }

    // MARK: - fetchAd

    func testFetchAdSuccessReturnsRenderedHTML() async throws {
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            let body = """
            {
                "adId": "ad-123",
                "adUrl": "https://advertiser.example.com/landing",
                "adHeadline": "Big Sale Today",
                "adCTA": "Shop Now"
            }
            """.data(using: .utf8)!
            return (response, body)
        }

        let service = DisplayAdAPIService(
            baseURL: "https://disp-api.prorata.ai",
            publisherID: "pub-123",
            urlSession: makeMockSession()
        )

        let html = try await service.fetchAd(pageURL: "https://example.com", sizes: [.mediumRectangle], theme: "light")

        XCTAssertTrue(html.contains("Big Sale Today"))
        XCTAssertTrue(html.contains("Shop Now"))
        XCTAssertTrue(html.contains("https://advertiser.example.com/landing"))
    }

    func testFetchAdNoFillThrowsNoFillError() async throws {
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, "{}".data(using: .utf8)!)
        }

        let service = DisplayAdAPIService(
            baseURL: "https://disp-api.prorata.ai",
            publisherID: "pub-123",
            urlSession: makeMockSession()
        )

        do {
            _ = try await service.fetchAd(pageURL: "https://example.com", sizes: [.mediumRectangle], theme: "light")
            XCTFail("Expected DisplayAdAPIError.noFill")
        } catch let error as DisplayAdAPIError {
            XCTAssertEqual(error, .noFill)
        }
    }

    func testFetchAdHTTPErrorThrowsHttpError() async throws {
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 500, httpVersion: nil, headerFields: nil)!
            return (response, Data())
        }

        let service = DisplayAdAPIService(
            baseURL: "https://disp-api.prorata.ai",
            publisherID: "pub-123",
            urlSession: makeMockSession()
        )

        do {
            _ = try await service.fetchAd(pageURL: "https://example.com", sizes: [.mediumRectangle], theme: "light")
            XCTFail("Expected DisplayAdAPIError.httpError")
        } catch let error as DisplayAdAPIError {
            XCTAssertEqual(error, .httpError(statusCode: 500, response: nil))
        }
    }

    func testFetchAdInvalidJSONThrowsInvalidData() async throws {
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, "not json".data(using: .utf8)!)
        }

        let service = DisplayAdAPIService(
            baseURL: "https://disp-api.prorata.ai",
            publisherID: "pub-123",
            urlSession: makeMockSession()
        )

        do {
            _ = try await service.fetchAd(pageURL: "https://example.com", sizes: [.mediumRectangle], theme: "light")
            XCTFail("Expected DisplayAdAPIError.invalidData")
        } catch let error as DisplayAdAPIError {
            if case .invalidData = error {
                // expected
            } else {
                XCTFail("Expected invalidData, got \(error)")
            }
        }
    }

    func testFetchAdWithEmptySizesThrowsInvalidSizes() async throws {
        let service = DisplayAdAPIService(
            baseURL: "https://disp-api.prorata.ai",
            publisherID: "pub-123",
            urlSession: makeMockSession()
        )

        do {
            _ = try await service.fetchAd(pageURL: "https://example.com", sizes: [], theme: "light")
            XCTFail("Expected DisplayAdAPIError.invalidSizes")
        } catch let error as DisplayAdAPIError {
            XCTAssertEqual(error, .invalidSizes)
        }
    }

    func testDisplayAdAPIErrorDescriptions() {
        XCTAssertEqual(DisplayAdAPIError.invalidURL.errorDescription, "Invalid Display Ad API URL")
        XCTAssertEqual(DisplayAdAPIError.invalidSizes.errorDescription, "At least one AdSize must be provided")
        XCTAssertEqual(DisplayAdAPIError.invalidResponse.errorDescription, "Invalid response from server")
        XCTAssertEqual(DisplayAdAPIError.httpError(statusCode: 404, response: nil).errorDescription, "HTTP error: 404")
        XCTAssertEqual(DisplayAdAPIError.noFill.errorDescription, "No display ad available for this request")
        XCTAssertNotNil(DisplayAdAPIError.invalidContext.errorDescription)
    }

    // MARK: - fetchAd with context

    func testFetchAdWithContextSendsDataParam() async throws {
        var capturedRequest: URLRequest?
        MockURLProtocol.requestHandler = { request in
            capturedRequest = request
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, "{}".data(using: .utf8)!)
        }

        let service = DisplayAdAPIService(
            baseURL: "https://disp-api.prorata.ai",
            publisherID: "pub-123",
            urlSession: makeMockSession()
        )

        _ = try? await service.fetchAd(
            pageURL: "https://example.com",
            sizes: [.mediumRectangle],
            theme: "light",
            context: ["section": "sports"]
        )

        let url = try XCTUnwrap(capturedRequest?.url)
        let components = try XCTUnwrap(URLComponents(url: url, resolvingAgainstBaseURL: false))
        let dataValue = try XCTUnwrap(components.queryItems?.first(where: { $0.name == "data" })?.value)
        XCTAssertTrue(dataValue.contains("sports"))
    }
}

// MARK: - Mock URLProtocol

final class MockURLProtocol: URLProtocol {
    static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data))?

    override class func canInit(with request: URLRequest) -> Bool {
        true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        guard let handler = MockURLProtocol.requestHandler else {
            client?.urlProtocol(self, didFailWithError: URLError(.badURL))
            return
        }

        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {}
}
