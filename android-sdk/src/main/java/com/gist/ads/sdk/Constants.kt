package com.gist.ads.sdk

/**
 * API-related constants for Gist Ads SDK
 * Matches Swift SDK's Constants.swift implementation
 */
object APIConstants {
    const val API_VERSION_V1 = "v1"
    const val API_VERSION_V2 = "v2"
    const val AUCTION_TYPE = "native"
    
    // Environment-specific default URLs
    private const val STAGING_BASE_URL = "https://tp-srch-api.staging.prorata.ai"
    private const val INTEGRATION_BASE_URL = "https://tp-srch-api.integration.prorata.ai"
    private const val PRODUCTION_BASE_URL = "https://tp-srch-api.gist.ai"
    
    private const val STAGING_IFRAME_URL = "https://tp-at.staging.prorata.ai"
    private const val INTEGRATION_IFRAME_URL = "https://tp-at.integration.prorata.ai"
    private const val PRODUCTION_IFRAME_URL = "https://tp-at.prorata.ai"
    
    /**
     * Environment configuration with override support
     * URLs can be overridden via system properties:
     * - gist.ads.staging.url / gist.ads.staging.iframe.url
     * - gist.ads.integration.url / gist.ads.integration.iframe.url
     * - gist.ads.production.url / gist.ads.production.iframe.url
     */
    enum class Environment(
        private val defaultBaseUrl: String,
        private val defaultIframeUrl: String,
        private val baseUrlProperty: String,
        private val iframeUrlProperty: String
    ) {
        STAGING(
            STAGING_BASE_URL, 
            STAGING_IFRAME_URL,
            "gist.ads.staging.url",
            "gist.ads.staging.iframe.url"
        ),
        INTEGRATION(
            INTEGRATION_BASE_URL,
            INTEGRATION_IFRAME_URL,
            "gist.ads.integration.url",
            "gist.ads.integration.iframe.url"
        ),
        PRODUCTION(
            PRODUCTION_BASE_URL,
            PRODUCTION_IFRAME_URL,
            "gist.ads.production.url",
            "gist.ads.production.iframe.url"
        );
        
        /**
         * Get base URL, checking system property first then falling back to default
         */
        val baseUrl: String
            get() = System.getProperty(baseUrlProperty) ?: defaultBaseUrl
        
        /**
         * Get iframe base URL, checking system property first then falling back to default
         */
        val iframeBaseUrl: String
            get() = System.getProperty(iframeUrlProperty) ?: defaultIframeUrl
    }
    
    /**
     * Get default API version, checking system property first
     * System property: gist.ads.api.version
     */
    fun defaultApiVersion(): String {
        return System.getProperty("gist.ads.api.version") ?: API_VERSION_V2
    }
    
    /**
     * Get search endpoint path for a given API version
     */
    fun searchEndpoint(version: String): String = "/$version/search"
}
