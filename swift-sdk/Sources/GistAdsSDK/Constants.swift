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
    // API version constants (public for use in apps)
    public static let apiVersionV1 = "v1"
    public static let apiVersionV2 = "v2"
    
    static let auctionType = "native"
    
    // Environment-specific iframe base URLs (can be overridden via environment variables)
    static let stagingIframeBaseURL = "https://tp-at.staging.prorata.ai"
    static let integrationIframeBaseURL = "https://tp-at.integration.prorata.ai"
    static let productionIframeBaseURL = "https://tp-at.prorata.ai"
    
    /// Allowed ad server domains for URL filtering (used in click handling)
    /// Derived from iframe base URLs, including any environment variable overrides
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
    
    /// Get API version from environment variable, defaults to v2
    /// Environment variable: GIST_ADS_API_VERSION
    /// - Returns: API version string (e.g., "v1", "v2", "v3")
    public static func apiVersion() -> String {
        return ProcessInfo.processInfo.environment["GIST_ADS_API_VERSION"] ?? apiVersionV2
    }
    
    /// Get search endpoint for a given API version
    /// - Parameter version: API version string (e.g., "v1", "v2", "v3")
    /// - Returns: Endpoint path (e.g., "/v1/search", "/v2/search")
    static func searchEndpoint(for version: String) -> String {
        return "/\(version)/search"
    }
    
    // Environment-specific base URLs (can be overridden via environment variables)
    static let stagingBaseURL = "https://tp-srch-api.staging.prorata.ai"
    static let integrationBaseURL = "https://tp-srch-api.integration.prorata.ai"
    static let productionBaseURL = "https://tp-srch-api.gist.ai"
    
    /// Get base URL for environment, checking environment variables first
    /// - Parameter environment: The environment to get the base URL for
    /// - Returns: Base URL from environment variable if set, otherwise the default constant
    static func baseURL(for environment: GistAdControl.APIEnvironment) -> String {
        let envKey: String
        let defaultValue: String
        
        switch environment {
        case .staging:
            envKey = "GIST_ADS_STAGING_URL"
            defaultValue = stagingBaseURL
        case .integration:
            envKey = "GIST_ADS_INTEGRATION_URL"
            defaultValue = integrationBaseURL
        case .production:
            envKey = "GIST_ADS_PRODUCTION_URL"
            defaultValue = productionBaseURL
        }
        
        // Check environment variable first, fall back to constant
        return ProcessInfo.processInfo.environment[envKey] ?? defaultValue
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

