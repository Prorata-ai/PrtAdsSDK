package com.gist.ads.sdk.models

import com.google.gson.annotations.SerializedName

/**
 * Response model for search endpoint
 */
data class SearchResponse(
    @SerializedName("ads")
    val ads: List<Ad>? = null,
    
    @SerializedName("message")
    val message: String? = null
) {
    /**
     * Individual ad data
     */
    data class Ad(
        @SerializedName("id")
        val id: String? = null,
        
        @SerializedName("title")
        val title: String? = null,
        
        @SerializedName("description")
        val description: String? = null,
        
        @SerializedName("image_url")
        val imageUrl: String? = null,
        
        @SerializedName("click_url")
        val clickUrl: String? = null,
        
        @SerializedName("impression_url")
        val impressionUrl: String? = null
    )
}


