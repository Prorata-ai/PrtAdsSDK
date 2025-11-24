package com.gist.ads.sdk.models

import com.google.gson.annotations.SerializedName

/**
 * Request model for v1/search endpoint
 */
data class SearchRequest(
    @SerializedName("text")
    val text: String,
    
    @SerializedName("geo")
    val geo: String,
    
    @SerializedName("auction_type")
    val auctionType: String,
    
    @SerializedName("ad_type")
    val adType: List<String>? = null
)


