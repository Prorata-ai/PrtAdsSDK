package com.gist.ads.sdk.ui

import android.content.Intent
import android.net.Uri
import android.webkit.WebResourceRequest
import android.webkit.WebSettings
import android.webkit.WebView
import android.webkit.WebViewClient
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.viewinterop.AndroidView
import androidx.webkit.WebSettingsCompat
import androidx.webkit.WebViewFeature
import com.gist.ads.sdk.utils.IframeHTMLGenerator

/**
 * Custom WebViewClient to handle ad click interception and height measurement
 */
private class AdWebViewClient(
    private val onAdClicked: ((String) -> Unit)?,
    private val onContentHeightChanged: ((Float) -> Unit)?
) : WebViewClient() {
    
    override fun shouldOverrideUrlLoading(
        view: WebView,
        request: WebResourceRequest
    ): Boolean {
        val url = request.url.toString()
        
        // Allow about:blank and data URLs (for initial load)
        if (url.startsWith("about:") || url.startsWith("data:")) {
            return false
        }
        
        // Intercept http/https clicks
        if (url.startsWith("http://") || url.startsWith("https://")) {
            onAdClicked?.let {
                // Invoke callback
                it(url)
            } ?: run {
                // Default behavior: open in external browser
                val intent = Intent(Intent.ACTION_VIEW, Uri.parse(url))
                view.context.startActivity(intent)
            }
            return true
        }
        
        return false
    }
    
    override fun onPageFinished(view: WebView, url: String) {
        super.onPageFinished(view, url)
        
        // Measure content height after page loads
        view.evaluateJavascript(
            "(function() { return document.documentElement.scrollHeight; })();"
        ) { result ->
            try {
                val height = result?.trim('"')?.toFloatOrNull()
                height?.let { onContentHeightChanged?.invoke(it) }
            } catch (e: Exception) {
                // Ignore parsing errors
            }
        }
    }
}

/**
 * Apply the SDK theme to the WebView so iframe content with
 * `prefers-color-scheme` rules renders correctly.
 *
 * Uses [WebSettingsCompat] which transparently picks the right API depending
 * on the platform version (algorithmic darkening on API 33+, force-dark on
 * older versions).
 */
private fun applyThemeToWebView(webView: WebView, theme: String) {
    val settings = webView.settings

    if (WebViewFeature.isFeatureSupported(WebViewFeature.ALGORITHMIC_DARKENING)) {
        // API 33+: lets the embedded page declare it supports dark theme.
        // We allow algorithmic darkening when the user wants dark or system,
        // and disable it when the user explicitly wants light.
        @Suppress("DEPRECATION")
        WebSettingsCompat.setAlgorithmicDarkeningAllowed(settings, theme != "light")
    }

    @Suppress("DEPRECATION")
    if (WebViewFeature.isFeatureSupported(WebViewFeature.FORCE_DARK)) {
        val mode = when (theme) {
            "light" -> WebSettingsCompat.FORCE_DARK_OFF
            "dark" -> WebSettingsCompat.FORCE_DARK_ON
            else -> WebSettingsCompat.FORCE_DARK_AUTO
        }
        WebSettingsCompat.setForceDark(settings, mode)
    }
}

/**
 * WebView component for rendering ads
 * Uses Android WebView wrapped in Compose for iframe-based ad display
 *
 * @param htmlContent The ad HTML content to display
 * @param modifier Modifier for styling
 * @param theme Theme preference - "light", "dark", or "system"
 * @param onAdClicked Optional callback invoked when user clicks an ad link
 * @param onContentHeightChanged Optional callback invoked when content height is measured
 */
@Composable
fun AdWebView(
    htmlContent: String,
    modifier: Modifier = Modifier,
    theme: String = "system",
    onAdClicked: ((String) -> Unit)? = null,
    onContentHeightChanged: ((Float) -> Unit)? = null
) {
    AndroidView(
        modifier = modifier,
        factory = { context ->
            WebView(context).apply {
                // Set custom WebViewClient with callbacks
                webViewClient = AdWebViewClient(onAdClicked, onContentHeightChanged)

                // Configure WebView settings
                settings.apply {
                    javaScriptEnabled = true
                    domStorageEnabled = true
                    loadWithOverviewMode = true
                    useWideViewPort = true
                    setSupportZoom(false)
                }

                // Set transparent background
                setBackgroundColor(android.graphics.Color.TRANSPARENT)

                applyThemeToWebView(this, theme)
            }
        },
        update = { webView ->
            applyThemeToWebView(webView, theme)
            val wrappedHtml = IframeHTMLGenerator.wrapForWebView(htmlContent)
            webView.loadDataWithBaseURL(
                null,
                wrappedHtml,
                "text/html",
                "UTF-8",
                null
            )
        }
    )
}

