package com.gist.ads.sdk.utils

/**
 * Internal utility for generating iframe HTML for ad display
 * Matches Swift SDK's IframeHTMLGenerator.swift implementation
 */
object IframeHTMLGenerator {
    /**
     * Generate iframe HTML with proper escaping and attributes
     * @param iframeUrl The URL for the iframe src attribute
     * @return Complete iframe HTML string
     */
    fun generate(iframeUrl: String): String {
        // Only escape quotes for HTML attribute - don't escape & in URLs
        // URLs in HTML attributes should keep & as-is for query parameters
        val escapedUrl = iframeUrl.replace("\"", "&quot;")
        
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
}
