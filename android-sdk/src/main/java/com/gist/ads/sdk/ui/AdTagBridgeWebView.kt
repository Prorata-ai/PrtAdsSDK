package com.gist.ads.sdk.ui

import android.content.Intent
import android.net.Uri
import android.os.Message
import android.view.ViewGroup
import android.webkit.JavascriptInterface
import android.webkit.WebChromeClient
import android.webkit.WebResourceRequest
import android.webkit.WebView
import android.webkit.WebViewClient
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.Modifier
import androidx.compose.ui.viewinterop.AndroidView

/**
 * WebView that loads the bootstrap HTML built by [com.gist.ads.sdk.utils.DisplayAdBootstrapHTML]
 * or [com.gist.ads.sdk.utils.SearchAdBootstrapHTML] and bridges its `adRendered`/passback signals
 * back to native state via a [JavascriptInterface]. Shared by both display and search ads --
 * it's fully generic, just loading whatever HTML/baseURL it's given and bridging the two message
 * names. Also implements [WebChromeClient.onCreateWindow] to intercept the ad tag's
 * `target="_blank"` links (confirmed by reading adtag.js: ad links always render with
 * `target="_blank"`), which `WebView` would otherwise silently drop without this override.
 */
private class PrtagBridge(
    var onAdRendered: ((Double) -> Unit)?,
    var onNoFill: (() -> Unit)?
) {
    @JavascriptInterface
    fun onAdRendered(height: Double) {
        onAdRendered?.invoke(height)
    }

    @JavascriptInterface
    fun onNoFill() {
        onNoFill?.invoke()
    }
}

/**
 * Intercepts `target="_blank"`/`window.open()` navigations from the embedded
 * ad tag by creating a temporary, never-attached `WebView` whose first
 * navigation is captured and handed off natively instead of actually being
 * loaded -- the standard Android pattern for `onCreateWindow`.
 */
private class AdTagWebChromeClient(
    private val onAdClicked: (String) -> Unit
) : WebChromeClient() {
    override fun onCreateWindow(
        view: WebView,
        isDialog: Boolean,
        isUserGesture: Boolean,
        resultMsg: Message
    ): Boolean {
        val transientWebView = WebView(view.context)
        transientWebView.webViewClient = object : WebViewClient() {
            override fun shouldOverrideUrlLoading(v: WebView, request: WebResourceRequest): Boolean {
                onAdClicked(request.url.toString())
                return true
            }

            @Suppress("DEPRECATION", "OVERRIDE_DEPRECATION")
            override fun shouldOverrideUrlLoading(v: WebView, url: String): Boolean {
                onAdClicked(url)
                return true
            }
        }

        val transport = resultMsg.obj as? WebView.WebViewTransport
        transport?.webView = transientWebView
        resultMsg.sendToTarget()
        return true
    }
}

private class AdTagWebViewClient(
    private val allowedHost: String?,
    private val onAdClicked: (String) -> Unit,
    private val onLoadFailure: (String) -> Unit
) : WebViewClient() {
    override fun shouldOverrideUrlLoading(view: WebView, request: WebResourceRequest): Boolean {
        val url = request.url
        val scheme = url.scheme?.lowercase()
        if (scheme != "http" && scheme != "https") {
            return false
        }
        // Same-frame http(s) navigations shouldn't normally happen (ad
        // links use target="_blank", handled by AdTagWebChromeClient
        // above), but treat any as an ad click defensively rather than
        // letting the WebView navigate away from the bootstrap document.
        if (url.host != null && url.host == allowedHost) {
            return false
        }
        onAdClicked(url.toString())
        return true
    }

    override fun onReceivedError(
        view: WebView,
        request: WebResourceRequest,
        error: android.webkit.WebResourceError
    ) {
        if (request.isForMainFrame) {
            onLoadFailure(error.description?.toString() ?: "WebView load failed")
        }
    }
}

/**
 * Composable embedding the real ad tag for a single ad slot (display or search).
 *
 * @param html Bootstrap HTML document to load (see [com.gist.ads.sdk.utils.DisplayAdBootstrapHTML]
 *   / [com.gist.ads.sdk.utils.SearchAdBootstrapHTML]).
 * @param baseUrl Base URL used for [WebView.loadDataWithBaseURL] -- must be a real origin (not
 *   null) matching the ad tag script's host, both so the tag's own cross-origin fetches see a
 *   proper `Origin` header and so relative resource resolution behaves like a real embed.
 * @param theme Theme preference - "light", "dark", or "system".
 * @param onAdRendered Invoked when the ad tag reports `adRendered`, with the measured height in px.
 * @param onNoFill Invoked when the ad tag invokes its passback function.
 * @param onLoadFailure Invoked on a native WebView-level load failure.
 * @param onAdClicked Invoked when the user clicks the ad; if null, opens the URL in the default browser.
 */
// PrtagBridge's methods are correctly annotated with @JavascriptInterface (see above); lint's
// UAST type resolution loses the concrete type across the remember{}/apply{} lambda boundaries
// here and misreports the type as the generic parameter name "T" -- a known resolver limitation,
// not a real missing-annotation issue.
@Suppress("JavascriptInterface")
@Composable
fun AdTagBridgeWebView(
    html: String,
    baseUrl: String,
    modifier: Modifier = Modifier,
    theme: String = "system",
    onAdRendered: ((Double) -> Unit)? = null,
    onNoFill: (() -> Unit)? = null,
    onLoadFailure: ((String) -> Unit)? = null,
    onAdClicked: ((String) -> Unit)? = null
) {
    val bridge: PrtagBridge = remember { PrtagBridge(onAdRendered, onNoFill) }
    bridge.onAdRendered = onAdRendered
    bridge.onNoFill = onNoFill

    fun handleExternalUrl(context: android.content.Context, url: String) {
        if (onAdClicked != null) {
            onAdClicked(url)
        } else {
            val intent = Intent(Intent.ACTION_VIEW, Uri.parse(url))
            context.startActivity(intent)
        }
    }

    val allowedHost = remember(baseUrl) { Uri.parse(baseUrl).host }

    AndroidView(
        modifier = modifier,
        factory = { context ->
            WebView(context).apply {
                layoutParams = ViewGroup.LayoutParams(
                    ViewGroup.LayoutParams.MATCH_PARENT,
                    ViewGroup.LayoutParams.WRAP_CONTENT
                )

                settings.apply {
                    javaScriptEnabled = true
                    domStorageEnabled = true
                    loadWithOverviewMode = true
                    useWideViewPort = true
                    setSupportZoom(false)
                    javaScriptCanOpenWindowsAutomatically = true
                    setSupportMultipleWindows(true)
                }

                setBackgroundColor(android.graphics.Color.TRANSPARENT)
                addJavascriptInterface(bridge, "prtagBridge")

                webViewClient = AdTagWebViewClient(
                    allowedHost = allowedHost,
                    onAdClicked = { url -> handleExternalUrl(context, url) },
                    onLoadFailure = { message -> onLoadFailure?.invoke(message) }
                )
                webChromeClient = AdTagWebChromeClient(
                    onAdClicked = { url -> handleExternalUrl(context, url) }
                )

                applyThemeToWebView(this, theme)
                loadDataWithBaseURL(baseUrl, html, "text/html", "UTF-8", null)
            }
        },
        update = { webView ->
            applyThemeToWebView(webView, theme)
        },
        onRelease = { webView ->
            webView.removeJavascriptInterface("prtagBridge")
            webView.destroy()
        }
    )
}
