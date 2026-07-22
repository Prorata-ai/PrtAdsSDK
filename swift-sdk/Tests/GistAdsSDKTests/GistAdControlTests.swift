//
//  GistAdControlTests.swift
//  GistAdsSDKTests
//
//  Unit tests for GistAdControl (search ads). SwiftUI view bodies aren't
//  directly inspectable in a plain XCTest target, so the state-transition
//  logic lives in the pure, testable `AdTagLoadState` (see
//  AdTagLoadState.swift, exercised in GistDisplayAdControlTests.swift);
//  these tests cover the search-specific initializer surface and `loadKey`
//  composition, mirroring GistDisplayAdControlTests.swift.
//

import SwiftUI
import XCTest
@testable import GistAdsSDK

final class GistAdControlTests: XCTestCase {

    // MARK: - Initialization (compiles + accepts documented parameters)

    func testInitWithDefaultNoFillView() {
        let control = GistAdControl(
            publisherID: "test-publisher",
            publisherKey: "test-key",
            query: "best running shoes"
        )
        XCTAssertNotNil(control)
    }

    func testInitWithCustomPassbackView() {
        let control = GistAdControl(
            publisherID: "test-publisher",
            publisherKey: "test-key",
            query: "best running shoes",
            geo: "GB",
            answer: "custom answer",
            adTypes: [.text, .image],
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
        let control = GistAdControl(
            publisherID: "test-publisher",
            publisherKey: "test-key",
            query: "best running shoes",
            sizes: [.dynamic],
            environment: .integration,
            theme: "system",
            onAdLoaded: {},
            onAdClicked: { _ in },
            onContentHeightChanged: { _ in }
        )
        XCTAssertNotNil(control)
    }

    func testWithAdTypesConvenienceInitializer() {
        let control = GistAdControl.withAdTypes(
            publisherID: "test-publisher",
            publisherKey: "test-key",
            query: "best running shoes",
            adTypes: [.image, .textImage],
            sizes: [.mediumRectangle],
            environment: .production
        )
        XCTAssertNotNil(control)
    }

    // MARK: - loadKey (drives .task(id:) reload behavior)

    func testLoadKeyChangesWhenQueryChanges() {
        let control1 = GistAdControl(publisherID: "pub", publisherKey: "key", query: "shoes")
        let control2 = GistAdControl(publisherID: "pub", publisherKey: "key", query: "boots")
        XCTAssertNotEqual(control1.loadKey, control2.loadKey)
    }

    func testLoadKeyChangesWhenGeoChanges() {
        let control1 = GistAdControl(publisherID: "pub", publisherKey: "key", query: "shoes", geo: "US")
        let control2 = GistAdControl(publisherID: "pub", publisherKey: "key", query: "shoes", geo: "GB")
        XCTAssertNotEqual(control1.loadKey, control2.loadKey)
    }

    func testLoadKeyChangesWhenAnswerChanges() {
        let control1 = GistAdControl(publisherID: "pub", publisherKey: "key", query: "shoes", answer: "a")
        let control2 = GistAdControl(publisherID: "pub", publisherKey: "key", query: "shoes", answer: "b")
        XCTAssertNotEqual(control1.loadKey, control2.loadKey)
    }

    func testLoadKeyChangesWhenAdTypesChange() {
        let control1 = GistAdControl(publisherID: "pub", publisherKey: "key", query: "shoes", adTypes: [.text])
        let control2 = GistAdControl(publisherID: "pub", publisherKey: "key", query: "shoes", adTypes: [.image])
        XCTAssertNotEqual(control1.loadKey, control2.loadKey)
    }

    func testLoadKeyChangesWhenSizesChange() {
        let control1 = GistAdControl(publisherID: "pub", publisherKey: "key", query: "shoes", sizes: [.dynamic])
        let control2 = GistAdControl(publisherID: "pub", publisherKey: "key", query: "shoes", sizes: [.leaderboard])
        XCTAssertNotEqual(control1.loadKey, control2.loadKey)
    }

    func testLoadKeyChangesWhenEnvironmentChanges() {
        let control1 = GistAdControl(publisherID: "pub", publisherKey: "key", query: "shoes", environment: .staging)
        let control2 = GistAdControl(publisherID: "pub", publisherKey: "key", query: "shoes", environment: .production)
        XCTAssertNotEqual(control1.loadKey, control2.loadKey)
    }

    func testLoadKeyIsStableWhenNothingChanges() {
        let control1 = GistAdControl(publisherID: "pub", publisherKey: "key", query: "shoes", sizes: [.mediumRectangle, .leaderboard])
        let control2 = GistAdControl(publisherID: "pub", publisherKey: "key", query: "shoes", sizes: [.mediumRectangle, .leaderboard])
        XCTAssertEqual(control1.loadKey, control2.loadKey)
    }
}
