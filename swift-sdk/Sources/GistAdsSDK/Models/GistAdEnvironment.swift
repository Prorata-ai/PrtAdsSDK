//
//  GistAdEnvironment.swift
//  GistAdsSDK
//
//  Objective-C compatible environment enum
//

import Foundation

/// Objective-C compatible environment enum for API endpoints
@objc public enum GistAdEnvironment: Int {
    case staging = 0
    case integration = 1
    case production = 2
    
    /// Convert to SwiftUI APIEnvironment type
    internal var swiftEnvironment: GistAdControl.APIEnvironment {
        switch self {
        case .staging:
            return .staging
        case .integration:
            return .integration
        case .production:
            return .production
        }
    }
    
    /// Get iframe base URL for this environment. Also used as the base URL
    /// for the embedded `adtag.js` bundle for both search and display ads.
    internal var iframeBaseURL: String {
        return APIConstants.iframeBaseURL(for: swiftEnvironment)
    }
}

