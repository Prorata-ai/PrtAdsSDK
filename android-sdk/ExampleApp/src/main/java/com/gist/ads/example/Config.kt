package com.gist.ads.example

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
    const val PUBLISHER_ID = "your-publisher-id"
    
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

