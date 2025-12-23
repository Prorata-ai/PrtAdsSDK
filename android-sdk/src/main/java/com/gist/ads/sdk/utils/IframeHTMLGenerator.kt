package com.gist.ads.sdk.utils

/**
 * Internal utility for generating iframe HTML for ad display
 * Matches Swift SDK's IframeHTMLGenerator.swift implementation
 */
object IframeHTMLGenerator {
    /**
     * Generate iframe HTML with proper escaping and attributes
     * @param iframeUrl The URL for the iframe src attribute
     * @param theme Theme preference - "light" or "dark"
     * @return Complete iframe HTML string
     */
    fun generate(iframeUrl: String, theme: String): String {
        // Append pr_theme parameter to the iframe URL
        val separator = if (iframeUrl.contains("?")) "&" else "?"
        val urlWithTheme = "$iframeUrl${separator}pr_theme=$theme"
        
        // Only escape quotes for HTML attribute - don't escape & in URLs
        // URLs in HTML attributes should keep & as-is for query parameters
        val escapedUrl = urlWithTheme.replace("\"", "&quot;")
        
        // Generate iframe HTML with proper attributes
        return """
<iframe src="$escapedUrl" 
        frameborder="0" 
        scrolling="no" 
        allowfullscreen 
        allow="autoplay; fullscreen; payment"
        sandbox="allow-scripts allow-same-origin allow-forms allow-popups allow-popups-to-escape-sandbox"
        style="width:100%;height:100%;min-height:250px;border:none;">
</iframe>
"""
    }
    
    /**
     * Wraps ad content in a responsive HTML template for WebView display
     * @param content The ad HTML content to wrap
     * @return Complete HTML document with styling
     */
    fun wrapForWebView(content: String): String {
        return """
<!DOCTYPE html>
<html>
<head>
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        body {
            background: transparent;
            overflow: hidden;
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
        }
        .ad-container {
            width: 100%;
            display: flex;
            justify-content: center;
            align-items: center;
            padding: 8px;
        }
        .ad-content {
            width: 100%;
            max-width: 600px;
        }
        img {
            max-width: 100%;
            height: auto;
        }
    </style>
</head>
<body>
    <div class="ad-container">
        <div class="ad-content">
            $content
        </div>
    </div>
</body>
</html>
        """.trimIndent()
    }
}
