//
//  GistDisplayAdControlTests.swift
//  GistAdsSDKTests
//
//  Unit tests for GistDisplayAdControl. SwiftUI view bodies aren't directly
//  inspectable in a plain XCTest target, so the state-transition logic lives
//  in the pure, testable `DisplayAdLoadState` (see DisplayAdLoadState.swift)
//  and is exercised here; initializer tests confirm the public API compiles
//  and accepts the documented parameters, matching the existing convention
//  for GistAdControl in GistAdsSDKTests.swift.
//

import SwiftUI
import XCTest
@testable import GistAdsSDK

final class GistDisplayAdControlTests: XCTestCase {

    // MARK: - DisplayAdLoadState transitions

    func testSuccessResultTransitionsToLoaded() {
        let state = DisplayAdLoadState.from(result: .success("<div>ad</div>"))
        XCTAssertEqual(state, .loaded("<div>ad</div>"))
    }

    func testNoFillErrorTransitionsToNoFill() {
        let state = DisplayAdLoadState.from(result: .failure(DisplayAdAPIError.noFill))
        XCTAssertEqual(state, .noFill)
    }

    func testOtherErrorTransitionsToFailedWithMessage() {
        let state = DisplayAdLoadState.from(result: .failure(DisplayAdAPIError.httpError(statusCode: 500, response: nil)))
        XCTAssertEqual(state, .failed("HTTP error: 500"))
    }

    func testInvalidSizesErrorTransitionsToFailed() {
        let state = DisplayAdLoadState.from(result: .failure(DisplayAdAPIError.invalidSizes))
        XCTAssertEqual(state, .failed("At least one AdSize must be provided"))
    }

    func testNonDisplayAdErrorTransitionsToFailed() {
        let underlying = NSError(domain: "test", code: 1, userInfo: [NSLocalizedDescriptionKey: "Something else broke"])
        let state = DisplayAdLoadState.from(result: .failure(underlying))
        XCTAssertEqual(state, .failed("Something else broke"))
    }

    // MARK: - Initialization (compiles + accepts documented parameters)

    func testInitWithDefaultNoFillView() {
        let control = GistDisplayAdControl(
            publisherID: "test-publisher",
            pageURL: "https://example.com/article",
            sizes: [.mediumRectangle]
        )
        XCTAssertNotNil(control)
    }

    func testInitWithCustomPassbackView() {
        let control = GistDisplayAdControl(
            publisherID: "test-publisher",
            pageURL: "https://example.com/article",
            sizes: [.leaderboard, .mediumRectangle],
            environment: .staging,
            theme: "dark",
            passback: {
                Text("Custom fallback")
            }
        )
        XCTAssertNotNil(control)
    }

    func testInitWithContext() {
        let control = GistDisplayAdControl(
            publisherID: "test-publisher",
            pageURL: "https://example.com/article",
            sizes: [.mediumRectangle],
            context: ["category": "technology", "keywords": ["AI", "ML"]]
        )
        XCTAssertNotNil(control)
    }

    func testInitWithAllCallbacks() {
        let control = GistDisplayAdControl(
            publisherID: "test-publisher",
            pageURL: "https://example.com/article",
            sizes: [.dynamic],
            environment: .integration,
            theme: "system",
            onAdLoaded: {},
            onAdClicked: { _ in },
            onContentHeightChanged: { _ in }
        )
        XCTAssertNotNil(control)
    }

    // MARK: - DisplayAPIConstants

    func testDisplayAPIConstantsDefaultBaseURLs() {
        XCTAssertEqual(
            DisplayAPIConstants.baseURL(for: .staging),
            "https://disp-api.staging.prorata.ai"
        )
        XCTAssertEqual(
            DisplayAPIConstants.baseURL(for: .production),
            "https://disp-api.prorata.ai"
        )
        XCTAssertEqual(
            DisplayAPIConstants.baseURL(for: .integration),
            "https://prtadsdisplayapi-integration.up.railway.app"
        )
    }

    func testDisplayAPIConstantsDecisionEndpointPath() {
        XCTAssertEqual(DisplayAPIConstants.decisionEndpoint, "/decision")
    }
}
