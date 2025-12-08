//
//  GistAdsSDK.swift
//  GistAdsSDK
//
//  Main SDK file - exports public interfaces
//

import Foundation

/// Version information for the SDK
public struct GistAdsSDK {
    public static let version = "1.0.0"
    public static let name = "GistAdsSDK"
}

// Export public types
public typealias AdControl = GistAdControl

// Objective-C compatible types are also exported:
// - GistAdView: UIKit UIView for Objective-C/UIKit projects
// - GistAdViewDelegate: Delegate protocol for ad loading callbacks
// - GistAdEnvironment: Objective-C compatible environment enum
// - GistAdType: Objective-C compatible ad type enum

