package com.gist.ads.sdk

/**
 * API-related constants for Gist Ads SDK.
 * Matches the Swift SDK's Constants.swift implementation.
 */
object APIConstants {

    // Environment-specific ad-tag-script (iframe) base URLs
    private const val STAGING_IFRAME_URL = "https://tp-at.staging.prorata.ai"
    private const val INTEGRATION_IFRAME_URL = "https://tp-at.integration.prorata.ai"
    private const val PRODUCTION_IFRAME_URL = "https://tp-at.prorata.ai"

    /**
     * Environment configuration with override support.
     * URLs can be overridden via system properties:
     * - gist.ads.staging.iframe.url
     * - gist.ads.integration.iframe.url
     * - gist.ads.production.iframe.url
     */
    enum class Environment(
        private val defaultIframeUrl: String,
        private val iframeUrlProperty: String
    ) {
        STAGING(
            STAGING_IFRAME_URL,
            "gist.ads.staging.iframe.url"
        ),
        INTEGRATION(
            INTEGRATION_IFRAME_URL,
            "gist.ads.integration.iframe.url"
        ),
        PRODUCTION(
            PRODUCTION_IFRAME_URL,
            "gist.ads.production.iframe.url"
        );

        /**
         * Get iframe base URL, checking system property first then falling back to default
         */
        val iframeBaseUrl: String
            get() = System.getProperty(iframeUrlProperty) ?: defaultIframeUrl

        /**
         * URL of the `adtag.js` bundle to embed for this environment. Reuses
         * [iframeBaseUrl] (and its override system property) since `adtag.js`
         * is one bundle serving both search and display ads, distinguished
         * by whether `api_key` is passed to `defineSlot`. Also used as
         * [AdTagBridgeWebView]'s base URL for `loadDataWithBaseURL`.
         */
        val adTagScriptUrl: String
            get() = iframeBaseUrl.trimEnd('/') + "/adtag.js"
    }
}
