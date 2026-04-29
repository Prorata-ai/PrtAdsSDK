package com.gist.ads.sdk.utils

import java.net.URLDecoder
import java.net.URLEncoder

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
        // Workaround: the Search API returns pr_templateid=1 (legacy numeric id)
        // but PrtAdsTag's render code only recognizes string aliases like
        // "text", "image", "text/image". Map the legacy id before passing the
        // URL to the WebView so the ad actually renders.
        val normalizedUrl = normalizeTemplateId(iframeUrl)

        // Append pr_theme parameter to the iframe URL
        val separator = if (normalizedUrl.contains("?")) "&" else "?"
        val urlWithTheme = "$normalizedUrl${separator}pr_theme=$theme"

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
        sandbox="allow-scripts allow-same-origin allow-forms allow-popups allow-popups-to-escape-sandbox allow-top-navigation-by-user-activation"
        style="width:100%;height:100%;min-height:250px;border:none;">
</iframe>
"""
    }

    /**
     * If the URL has `pr_templateid=1` (or `native`), replace it with a
     * recognized alias inferred from the ad fields present in the URL.
     * Returns the URL unchanged when the template id is already a known
     * alias or when the URL cannot be parsed.
     *
     * Uses plain string parsing (no android.net.Uri) so this is testable in
     * pure-JVM unit tests and avoids any URL-encoding side effects on the
     * existing query parameters.
     */
    fun normalizeTemplateId(url: String): String {
        val queryStart = url.indexOf('?')
        if (queryStart < 0) return url

        val fragmentStart = url.indexOf('#', queryStart)
        val queryEnd = if (fragmentStart >= 0) fragmentStart else url.length
        val query = url.substring(queryStart + 1, queryEnd)
        if (query.isEmpty()) return url

        val params = query.split('&').map { pair ->
            val eq = pair.indexOf('=')
            if (eq < 0) pair to "" else pair.substring(0, eq) to pair.substring(eq + 1)
        }

        fun decoded(name: String): String? = params
            .firstOrNull { it.first == name }
            ?.second
            ?.let {
                try {
                    URLDecoder.decode(it, "UTF-8")
                } catch (_: Exception) {
                    it
                }
            }

        val rawTemplateId = decoded("pr_templateid")
        if (rawTemplateId != "1" && rawTemplateId != "native") return url

        val adType = decoded("pr_adtype")
        val hasImage = !decoded("pr_adimage").isNullOrEmpty()
        val hasText = !decoded("pr_adtext").isNullOrEmpty()
        val resolved = resolveTemplateId(adType, hasImage, hasText)
        val encodedResolved = URLEncoder.encode(resolved, "UTF-8")

        val rebuiltQuery = params.joinToString("&") { (name, value) ->
            if (name == "pr_templateid") "pr_templateid=$encodedResolved" else "$name=$value"
        }

        val prefix = url.substring(0, queryStart + 1)
        val suffix = if (fragmentStart >= 0) url.substring(fragmentStart) else ""
        return "$prefix$rebuiltQuery$suffix"
    }

    private fun resolveTemplateId(adType: String?, hasImage: Boolean, hasText: Boolean): String {
        when (adType) {
            "text/answer", "generative-text-answer" -> return "text/answer"
            "text/image", "generative-image-text" -> return "text/image"
            "text/questions", "generative-questions" -> return "text/questions"
            "image", "legacy-banner" -> return "image"
            "text", "generative-text" -> return "text"
        }

        return when {
            hasImage && hasText -> "text/image"
            hasImage -> "image"
            else -> "text"
        }
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
