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
        // Workaround: the Search API returns pr_templateid=1 (legacy numeric id)
        // but PrtAdsTag's render code only recognizes string aliases like
        // "text", "image", "text/image". Map the legacy id before passing the
        // URL to the WebView so the ad actually renders.
        let normalizedUrl = normalizeTemplateId(in: iframeUrl)

        // Append pr_theme parameter to the iframe URL
        let separator = normalizedUrl.contains("?") ? "&" : "?"
        let urlWithTheme = "\(normalizedUrl)\(separator)pr_theme=\(theme)"

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
        sandbox="allow-scripts allow-same-origin allow-forms allow-popups allow-popups-to-escape-sandbox allow-top-navigation-by-user-activation"
        style="width:100%;height:100%;min-height:250px;border:none;">
</iframe>
"""
    }

    /// If the URL has `pr_templateid=1` (or `native`), replace it with a
    /// recognized alias inferred from the ad fields present in the URL.
    /// Returns the URL unchanged when the template id is already a known
    /// alias or when the URL cannot be parsed.
    static func normalizeTemplateId(in url: String) -> String {
        guard var components = URLComponents(string: url),
              let queryItems = components.queryItems
        else {
            return url
        }

        let rawTemplateId = queryItems.first(where: { $0.name == "pr_templateid" })?.value
        guard rawTemplateId == "1" || rawTemplateId == "native" else {
            return url
        }

        let adType = queryItems.first(where: { $0.name == "pr_adtype" })?.value
        let hasImage = !(queryItems.first(where: { $0.name == "pr_adimage" })?.value?.isEmpty ?? true)
        let hasText = !(queryItems.first(where: { $0.name == "pr_adtext" })?.value?.isEmpty ?? true)
        let resolved = resolveTemplateId(adType: adType, hasImage: hasImage, hasText: hasText)

        components.queryItems = queryItems.map { item in
            if item.name == "pr_templateid" {
                return URLQueryItem(name: "pr_templateid", value: resolved)
            }
            return item
        }

        return components.string ?? url
    }

    private static func resolveTemplateId(adType: String?, hasImage: Bool, hasText: Bool) -> String {
        switch adType {
        case "text/answer", "generative-text-answer":
            return "text/answer"
        case "text/image", "generative-image-text":
            return "text/image"
        case "text/questions", "generative-questions":
            return "text/questions"
        case "image", "legacy-banner":
            return "image"
        case "text", "generative-text":
            return "text"
        default:
            break
        }

        if hasImage && hasText { return "text/image" }
        if hasImage { return "image" }
        return "text"
    }
}

