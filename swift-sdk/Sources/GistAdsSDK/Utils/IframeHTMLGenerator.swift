//
//  IframeHTMLGenerator.swift
//  GistAdsSDK
//
//  Utility for generating iframe HTML for ad display
//

import Foundation

/// Internal utility for generating iframe HTML
enum IframeHTMLGenerator {
    /// Generate iframe HTML with proper escaping and attributes
    /// - Parameter iframeUrl: The URL for the iframe src attribute
    /// - Returns: Complete iframe HTML string
    static func generate(iframeUrl: String) -> String {
        // Only escape quotes for HTML attribute - don't escape & in URLs
        // URLs in HTML attributes should keep & as-is for query parameters
        let escapedUrl = iframeUrl.replacingOccurrences(of: "\"", with: "&quot;")

        // Generate iframe HTML with proper attributes
        // Removed sandbox attribute as it may block cross-origin iframes
        return """
<iframe src="\(escapedUrl)" 
        frameborder="0" 
        scrolling="no" 
        allowfullscreen 
        allow="autoplay; fullscreen; payment" 
        style="width:100%;height:100%;min-height:250px;border:none;">
</iframe>
"""
    }
}

