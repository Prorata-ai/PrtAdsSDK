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
    /// - Parameters:
    ///   - iframeUrl: The URL for the iframe src attribute
    ///   - theme: Theme preference - "light" or "dark"
    /// - Returns: Complete iframe HTML string
    static func generate(iframeUrl: String, theme: String) -> String {
        // Append pr_theme parameter to the iframe URL
        let separator = iframeUrl.contains("?") ? "&" : "?"
        let urlWithTheme = "\(iframeUrl)\(separator)pr_theme=\(theme)"
        
        // Only escape quotes for HTML attribute - don't escape & in URLs
        // URLs in HTML attributes should keep & as-is for query parameters
        let escapedUrl = urlWithTheme.replacingOccurrences(of: "\"", with: "&quot;")

        // Generate iframe HTML with proper attributes
        // Removed sandbox attribute as it may block cross-origin iframes
        return """
<iframe src="\(escapedUrl)" 
        frameborder="0" 
        scrolling="no" 
        allowfullscreen 
        allow="autoplay; fullscreen; payment"
        sandbox="allow-scripts allow-same-origin allow-forms allow-popups allow-popups-to-escape-sandbox"
        style="width:100%;height:100%;min-height:250px;border:none;">
</iframe>
"""
    }
}

