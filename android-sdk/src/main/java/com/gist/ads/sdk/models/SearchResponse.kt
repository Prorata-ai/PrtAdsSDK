package com.gist.ads.sdk.models

import com.google.gson.annotations.SerializedName

/**
 * Response model for search endpoint
 * Matches the actual API response structure with 'selection' array
 */
data class SearchResponse(
    @SerializedName("selection")
    val selection: List<AdSelection>? = null,
    
    @SerializedName("message")
    val message: String? = null
) {
    /**
     * Ad selection from the API response
     */
    data class AdSelection(
        @SerializedName("adId")
        val adId: String? = null,
        
        @SerializedName("iframeUrl")
        val iframeUrl: String? = null,
        
        @SerializedName("flightId")
        val flightId: String? = null,
        
        @SerializedName("adName")
        val adName: String? = null,
        
        @SerializedName("adSource")
        val adSource: String? = null,
        
        @SerializedName("render")
        val render: String? = null
    )
}


