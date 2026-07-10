//
//  DisplayAdResponseTests.swift
//  GistAdsSDKTests
//
//  Unit tests for decoding the Display Ad API (`/decision`) response,
//  covering the shapes discovered in PAA-5351 Step 0: a flat raw-field ad
//  object, a `{"selection": [...]}`-wrapped object, and the live-confirmed
//  no-fill body `{}`.
//

import XCTest
@testable import GistAdsSDK

final class DisplayAdResponseTests: XCTestCase {

    // MARK: - No-fill

    func testEmptyObjectDecodesToNoFill() throws {
        let json = "{}".data(using: .utf8)!
        let response = try JSONDecoder().decode(DisplayAdResponse.self, from: json)
        XCTAssertNil(response.ad)
    }

    // MARK: - Flat ad object

    func testFlatAdObjectDecodesRawFields() throws {
        let json = """
        {
            "adId": "ad-123",
            "adUrl": "https://advertiser.example.com/landing",
            "adHeadline": "Big Sale Today",
            "adText": "Save 20% on everything",
            "adCTA": "Shop Now",
            "adImage": "https://cdn.example.com/creative.png",
            "adName": "Acme Co",
            "templateId": "text/image"
        }
        """.data(using: .utf8)!

        let response = try JSONDecoder().decode(DisplayAdResponse.self, from: json)
        let ad = try XCTUnwrap(response.ad)

        XCTAssertEqual(ad.adId, "ad-123")
        XCTAssertEqual(ad.adUrl, "https://advertiser.example.com/landing")
        XCTAssertEqual(ad.adHeadline, "Big Sale Today")
        XCTAssertEqual(ad.adText, "Save 20% on everything")
        XCTAssertEqual(ad.adCta, "Shop Now")
        XCTAssertEqual(ad.adImage, "https://cdn.example.com/creative.png")
        XCTAssertEqual(ad.adName, "Acme Co")
        XCTAssertEqual(ad.templateId, "text/image")
    }

    func testFlatObjectWithoutAdIdDecodesToNoFill() throws {
        // Mirrors adtag.js's own no-fill check: absence of `adId` means "no ad",
        // even if other stray fields are present.
        let json = """
        { "message": "no inventory" }
        """.data(using: .utf8)!

        let response = try JSONDecoder().decode(DisplayAdResponse.self, from: json)
        XCTAssertNil(response.ad)
    }

    // MARK: - selection-wrapped object

    func testSelectionWrappedObjectDecodesFirstItem() throws {
        let json = """
        {
            "selection": [
                {
                    "adId": "ad-1",
                    "adUrl": "https://advertiser.example.com/1",
                    "adHeadline": "First Ad"
                },
                {
                    "adId": "ad-2",
                    "adUrl": "https://advertiser.example.com/2",
                    "adHeadline": "Second Ad"
                }
            ]
        }
        """.data(using: .utf8)!

        let response = try JSONDecoder().decode(DisplayAdResponse.self, from: json)
        let ad = try XCTUnwrap(response.ad)

        XCTAssertEqual(ad.adId, "ad-1")
        XCTAssertEqual(ad.adHeadline, "First Ad")
    }

    func testSelectionWrappedEmptyArrayFallsBackToFlatDecodeAndNoFill() throws {
        let json = """
        { "selection": [] }
        """.data(using: .utf8)!

        let response = try JSONDecoder().decode(DisplayAdResponse.self, from: json)
        XCTAssertNil(response.ad)
    }

    // MARK: - Minimal image-only ad

    func testImageOnlyAdDecodesWithoutText() throws {
        let json = """
        {
            "adId": "ad-image-only",
            "adUrl": "https://advertiser.example.com/landing",
            "adImage": "https://cdn.example.com/creative.png"
        }
        """.data(using: .utf8)!

        let response = try JSONDecoder().decode(DisplayAdResponse.self, from: json)
        let ad = try XCTUnwrap(response.ad)

        XCTAssertEqual(ad.adImage, "https://cdn.example.com/creative.png")
        XCTAssertNil(ad.adHeadline)
        XCTAssertNil(ad.adText)
    }
}
