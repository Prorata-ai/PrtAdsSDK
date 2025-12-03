//
//  Constants.swift
//  GistAdsSDK
//
//  Internal constants for API endpoints and view configuration
//

import Foundation
import SwiftUI

/// Internal API-related constants
enum APIConstants {
    static let searchEndpoint = "/v1/search"
    static let auctionType = "native"
    static let iframeBaseURL = "https://tp-at.prorata.ai"
    
    // Environment-specific base URLs (can be overridden via environment variables)
    static let stagingBaseURL = "https://tp-srch-api.staging.prorata.ai"
    static let integrationBaseURL = "https://tp-srch-api.integration.prorata.ai"
    static let productionBaseURL = "https://tp-srch-api.gist.ai"
    
    /// Get base URL for environment, checking environment variables first
    /// - Parameter environment: The environment to get the base URL for
    /// - Returns: Base URL from environment variable if set, otherwise the default constant
    static func baseURL(for environment: GistAdControl.Environment) -> String {
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
}

/// Internal view-related constants
enum AdViewConstants {
    static let defaultMinHeight: CGFloat = 100
    static let defaultMaxHeight: CGFloat = 300
    static let iframeMinHeight: CGFloat = 250
}

