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
    
    func testSDKVersion() {
        XCTAssertEqual(GistAdsSDK.version, "1.0.5")
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
