package com.gist.ads.sdk.ui

import android.webkit.WebView
import androidx.webkit.WebSettingsCompat
import androidx.webkit.WebViewFeature

/**
 * Apply the SDK theme to the WebView so embedded content with
 * `prefers-color-scheme` rules renders correctly.
 *
 * Uses [WebSettingsCompat] which transparently picks the right API depending
 * on the platform version (algorithmic darkening on API 33+, force-dark on
 * older versions).
 *
 * Shared by [AdTagBridgeWebView]'s embedded ad tag WebView (used by both
 * display and search ads).
 */
internal fun applyThemeToWebView(webView: WebView, theme: String) {
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
