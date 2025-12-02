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
}

/// Internal view-related constants
enum AdViewConstants {
    static let defaultMinHeight: CGFloat = 100
    static let defaultMaxHeight: CGFloat = 300
    static let iframeMinHeight: CGFloat = 250
}

