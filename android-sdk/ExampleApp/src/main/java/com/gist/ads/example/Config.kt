package com.gist.ads.example

import com.gist.ads.sdk.APIConstants

/**
 * Configuration for the example app
 * 
 * IMPORTANT: Replace these with your actual credentials
 */
object Config {
    /**
     * Your publisher ID
     * Get this from your Gist Ads dashboard
     */
    // const val PUBLISHER_ID = "your-publisher-id"
    const val PUBLISHER_ID = "guest-api"
    
    /**
     * Your publisher API key
     * Get this from your Gist Ads dashboard
     */
    const val PUBLISHER_KEY = "your-publisher-key"
    
    /**
     * Default geographic location
     */
    const val DEFAULT_GEO = "US"
    
    /**
     * API Configuration
     */
    val DEFAULT_ENVIRONMENT = APIConstants.Environment.PRODUCTION
    val DEFAULT_API_VERSION = APIConstants.API_VERSION_V2
    
    /**
     * Available API versions for switching
     */
    val AVAILABLE_API_VERSIONS = listOf(
        APIConstants.API_VERSION_V1 to "API Version 1",
        APIConstants.API_VERSION_V2 to "API Version 2"
    )
    
    /**
     * Sample search queries for testing
     */
    val SAMPLE_QUERIES = listOf(
        "wireless headphones",
        "running shoes",
        "laptop computers",
        "coffee makers",
        "smart watches",
        "digital cameras",
        "fitness trackers",
        "tablet devices"
    )
    
    /**
     * Available geographic regions
     */
    val AVAILABLE_GEOS = listOf(
        "US" to "United States",
        "GB" to "United Kingdom",
        "CA" to "Canada",
        "AU" to "Australia",
        "DE" to "Germany",
        "FR" to "France",
        "JP" to "Japan",
        "IN" to "India"
    )
}

