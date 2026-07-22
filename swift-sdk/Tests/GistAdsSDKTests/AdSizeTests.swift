//
//  AdSizeTests.swift
//  GistAdsSDKTests
//
//  Unit tests for AdSize, including sizes-param JSON encoding used by the
//  Display Ad API.
//

import XCTest
@testable import GistAdsSDK

final class AdSizeTests: XCTestCase {

    // MARK: - Dimensions

    func testStandardSizeDimensions() {
        XCTAssertEqual(AdSize.leaderboard.width, 728)
        XCTAssertEqual(AdSize.leaderboard.height, 90)

        XCTAssertEqual(AdSize.superLeaderboard.width, 970)
        XCTAssertEqual(AdSize.superLeaderboard.height, 90)

        XCTAssertEqual(AdSize.mediumRectangle.width, 300)
        XCTAssertEqual(AdSize.mediumRectangle.height, 250)

        XCTAssertEqual(AdSize.mobileBanner.width, 320)
        XCTAssertEqual(AdSize.mobileBanner.height, 50)

        XCTAssertEqual(AdSize.billboard.width, 970)
        XCTAssertEqual(AdSize.billboard.height, 250)

        XCTAssertEqual(AdSize.largeRectangle.width, 300)
        XCTAssertEqual(AdSize.largeRectangle.height, 600)

        XCTAssertEqual(AdSize.skyscraper.width, 160)
        XCTAssertEqual(AdSize.skyscraper.height, 600)
    }

    func testDynamicHasNoFixedDimensions() {
        XCTAssertNil(AdSize.dynamic.width)
        XCTAssertNil(AdSize.dynamic.height)
    }

    func testAllCasesCount() {
        XCTAssertEqual(AdSize.allCases.count, 8)
    }

    // MARK: - Display names

    func testDisplayNames() {
        XCTAssertEqual(AdSize.leaderboard.displayName, "Leaderboard (728x90)")
        XCTAssertEqual(AdSize.dynamic.displayName, "Dynamic")
    }

    // MARK: - sizes param encoding

    func testEncodeSingleFixedSize() throws {
        let json = try AdSize.encodeSizesParam([.mediumRectangle])
        XCTAssertEqual(json, "[[300,250]]")
    }

    func testEncodeMultipleFixedSizes() throws {
        let json = try AdSize.encodeSizesParam([.leaderboard, .mediumRectangle])
        let data = json.data(using: .utf8)!
        let decoded = try JSONSerialization.jsonObject(with: data) as? [[Int]]
        XCTAssertEqual(decoded, [[728, 90], [300, 250]])
    }

    func testEncodeDynamicSize() throws {
        // Per the live OpenAPI schema: "Use 0x0 for dynamic."
        let json = try AdSize.encodeSizesParam([.dynamic])
        XCTAssertEqual(json, "[[0,0]]")
    }

    func testEncodeEmptySizesProducesEmptyArray() throws {
        let json = try AdSize.encodeSizesParam([])
        XCTAssertEqual(json, "[]")
    }
}
