//
//  GistDisplayAdControlTests.swift
//  GistAdsSDKTests
//
//  Unit tests for GistDisplayAdControl. SwiftUI view bodies aren't directly
//  inspectable in a plain XCTest target, so the state-transition logic lives
//  in the pure, testable `AdTagLoadState` (see AdTagLoadState.swift)
//  and is exercised here; initializer tests confirm the public API compiles
//  and accepts the documented parameters, matching the existing convention
//  for GistAdControl in GistAdsSDKTests.swift.
//

import SwiftUI
import XCTest
@testable import GistAdsSDK

final class GistDisplayAdControlTests: XCTestCase {

    // MARK: - AdTagLoadState

    // `AdTagLoadState` is now event-derived (see AdTagLoadState.swift):
    // GistDisplayAdControl assigns it directly from bridge callbacks/native
    // failures rather than deriving it from a single `Result`. These tests
    // just confirm the value type's equality semantics, which the control
    // relies on for its `switch state` body and `isLoaded` check.

    func testLoadedStatesWithSameHeightAreEqual() {
        XCTAssertEqual(AdTagLoadState.loaded(height: 250), AdTagLoadState.loaded(height: 250))
    }

    func testLoadedStatesWithDifferentHeightAreNotEqual() {
        XCTAssertNotEqual(AdTagLoadState.loaded(height: 250), AdTagLoadState.loaded(height: 100))
    }

    func testLoadingNoFillAndFailedAreDistinctStates() {
        XCTAssertNotEqual(AdTagLoadState.loading, AdTagLoadState.noFill)
        XCTAssertNotEqual(AdTagLoadState.loading, AdTagLoadState.failed("error"))
        XCTAssertNotEqual(AdTagLoadState.noFill, AdTagLoadState.failed("error"))
    }

    func testFailedStatesCompareByMessage() {
        XCTAssertEqual(AdTagLoadState.failed("boom"), AdTagLoadState.failed("boom"))
        XCTAssertNotEqual(AdTagLoadState.failed("boom"), AdTagLoadState.failed("other"))
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

    // MARK: - loadKey (drives .task(id:) reload behavior)

    func testLoadKeyChangesWhenPageURLChanges() {
        let control1 = GistDisplayAdControl(publisherID: "pub", pageURL: "https://example.com/a", sizes: [.mediumRectangle])
        let control2 = GistDisplayAdControl(publisherID: "pub", pageURL: "https://example.com/b", sizes: [.mediumRectangle])
        XCTAssertNotEqual(control1.loadKey, control2.loadKey)
    }

    func testLoadKeyChangesWhenSizesChange() {
        let control1 = GistDisplayAdControl(publisherID: "pub", pageURL: "https://example.com/a", sizes: [.mediumRectangle])
        let control2 = GistDisplayAdControl(publisherID: "pub", pageURL: "https://example.com/a", sizes: [.leaderboard])
        XCTAssertNotEqual(control1.loadKey, control2.loadKey)
    }

    func testLoadKeyChangesWhenEnvironmentChanges() {
        let control1 = GistDisplayAdControl(publisherID: "pub", pageURL: "https://example.com/a", sizes: [.mediumRectangle], environment: .staging)
        let control2 = GistDisplayAdControl(publisherID: "pub", pageURL: "https://example.com/a", sizes: [.mediumRectangle], environment: .production)
        XCTAssertNotEqual(control1.loadKey, control2.loadKey)
    }

    func testLoadKeyIsStableWhenNothingChanges() {
        let control1 = GistDisplayAdControl(publisherID: "pub", pageURL: "https://example.com/a", sizes: [.mediumRectangle, .leaderboard])
        let control2 = GistDisplayAdControl(publisherID: "pub", pageURL: "https://example.com/a", sizes: [.mediumRectangle, .leaderboard])
        XCTAssertEqual(control1.loadKey, control2.loadKey)
    }
}
