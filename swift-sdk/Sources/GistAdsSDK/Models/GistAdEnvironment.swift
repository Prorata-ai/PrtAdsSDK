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
    
    /// Convert to SwiftUI Environment type
    internal var swiftEnvironment: GistAdControl.Environment {
        switch self {
        case .staging:
            return .staging
        case .integration:
            return .integration
        case .production:
            return .production
        }
    }
    
    /// Get base URL for this environment
    internal var baseURL: String {
        return APIConstants.baseURL(for: swiftEnvironment)
    }
    
    /// Get iframe base URL for this environment
    internal var iframeBaseURL: String {
        return APIConstants.iframeBaseURL(for: swiftEnvironment)
    }
}

