//
//  Constants.swift
//  GistAdsSDK
//
//  Internal constants for API endpoints and view configuration
//

import Foundation
import SwiftUI

/// API-related constants
public enum APIConstants {
    // Environment-specific iframe base URLs (can be overridden via environment variables)
    static let stagingIframeBaseURL = "https://tp-at.staging.prorata.ai"
    static let integrationIframeBaseURL = "https://tp-at.integration.prorata.ai"
    static let productionIframeBaseURL = "https://tp-at.prorata.ai"
    
    /// Allowed ad server domains for URL filtering (used in click handling).
    /// Derived from the iframe/ad-tag-script base URLs, including any
    /// environment variable overrides.
    ///
    /// `AdTagBridgeWebView` (used by both search and display ads, which
    /// embed `adtag.js` from this same host) uses
    /// `webView.loadHTMLString(_:baseURL:)`. That call triggers exactly one
    /// synthetic `decidePolicyForNavigationAction` call with
    /// `url == baseURL` (not a real network request -- WebKit reports the
    /// load's origin-setup this way). If that base host isn't allowlisted,
    /// the navigation delegate cancels its own page load and immediately
    /// kicks the user out to Safari with the bare base URL, on every single
    /// ad load, with no tap required.
    ///
    /// NOTE: neither the Display Ad API (`disp-api.*`) nor the Search API
    /// (`tp-srch-api.*`) REST hosts need to be listed here -- neither ad type
    /// navigates the WebView there, or calls it from native code at all;
    /// `adtag.js` hits them on its own via a background JSONP request from
    /// the ad-tag-script host below.
    static var allowedAdDomains: [String] {
        let staticDomains = [stagingIframeBaseURL, integrationIframeBaseURL, productionIframeBaseURL]
        let dynamicDomains = [
            iframeBaseURL(for: .staging),
            iframeBaseURL(for: .integration),
            iframeBaseURL(for: .production)
        ]
        return Array(Set(staticDomains + dynamicDomains))
            .compactMap { URL(string: $0)?.host }
    }
    
    /// Check if a URL host is an allowed ad server domain
    /// - Parameter url: The URL to check
    /// - Returns: True if the URL's host is an allowed ad domain
    static func isAllowedAdDomain(_ url: URL) -> Bool {
        guard let host = url.host else { return false }
        return allowedAdDomains.contains(host)
    }
    
    /// Get iframe base URL for environment, checking environment variables first
    /// - Parameter environment: The environment to get the iframe base URL for
    /// - Returns: Iframe base URL from environment variable if set, otherwise the default constant
    static func iframeBaseURL(for environment: GistAdControl.APIEnvironment) -> String {
        let envKey: String
        let defaultValue: String
        
        switch environment {
        case .staging:
            envKey = "GIST_ADS_STAGING_IFRAME_URL"
            defaultValue = stagingIframeBaseURL
        case .integration:
            envKey = "GIST_ADS_INTEGRATION_IFRAME_URL"
            defaultValue = integrationIframeBaseURL
        case .production:
            envKey = "GIST_ADS_PRODUCTION_IFRAME_URL"
            defaultValue = productionIframeBaseURL
        }
        
        // Check environment variable first, fall back to constant
        return ProcessInfo.processInfo.environment[envKey] ?? defaultValue
    }
}

/// Internal view-related constants
enum AdViewConstants {
    static let defaultMinHeight: CGFloat = 100
    static let defaultMaxHeight: CGFloat = 300
    static let iframeMinHeight: CGFloat = 250
    
    /// Get default minimum height, checking environment variable first
    /// Environment variable: GIST_ADS_DEFAULT_MIN_HEIGHT
    /// - Returns: Height from environment variable if set and valid, otherwise the default constant
    static var configurableMinHeight: CGFloat {
        if let envValue = ProcessInfo.processInfo.environment["GIST_ADS_DEFAULT_MIN_HEIGHT"],
           let height = Double(envValue),
           height >= 0 {
            return CGFloat(height)
        }
        return defaultMinHeight
    }
    
    /// Get default maximum height, checking environment variable first
    /// Environment variable: GIST_ADS_DEFAULT_MAX_HEIGHT
    /// - Returns: Height from environment variable if set and valid, otherwise the default constant
    static var configurableMaxHeight: CGFloat {
        if let envValue = ProcessInfo.processInfo.environment["GIST_ADS_DEFAULT_MAX_HEIGHT"],
           let height = Double(envValue),
           height >= 0 {
            return CGFloat(height)
        }
        return defaultMaxHeight
    }
    
    /// Get iframe minimum height, checking environment variable first
    /// Environment variable: GIST_ADS_IFRAME_MIN_HEIGHT
    /// - Returns: Height from environment variable if set and valid, otherwise the default constant
    static var configurableIframeMinHeight: CGFloat {
        if let envValue = ProcessInfo.processInfo.environment["GIST_ADS_IFRAME_MIN_HEIGHT"],
           let height = Double(envValue),
           height >= 0 {
            return CGFloat(height)
        }
        return iframeMinHeight
    }
}

