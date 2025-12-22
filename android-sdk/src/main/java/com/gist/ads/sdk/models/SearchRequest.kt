package com.gist.ads.sdk.models

import com.gist.ads.sdk.APIConstants
import com.google.gson.annotations.SerializedName

/**
 * Request model for v1/search endpoint
 */
data class SearchRequestV1(
    @SerializedName("text")
    val text: String,
    
    @SerializedName("geo")
    val geo: String,
    
    @SerializedName("auction_type")
    val auctionType: String,
    
    @SerializedName("ad_type")
    val adType: List<String>? = null
)

/**
 * Request model for v2/search endpoint
 */
data class SearchRequestV2(
    @SerializedName("prompt")
    val prompt: String,
    
    @SerializedName("answer")
    val answer: String,
    
    @SerializedName("geo")
    val geo: String,
    
    @SerializedName("auction_type")
    val auctionType: String,
    
    @SerializedName("ad_type")
    val adType: List<String>? = null,
    
    @SerializedName("text")
    val text: String? = null
)

/**
 * Factory function to create appropriate search request based on API version
 * @param version API version string (e.g., "v1", "v2")
 * @param query The search query text
 * @param geo Geographic location (e.g., "US", "GB")
 * @param adTypes Optional list of ad type strings
 * @param answer Optional answer string for v2 (defaults to query if nil)
 * @return Request model appropriate for the version
 */
fun createSearchRequest(
    version: String,
    query: String,
    geo: String,
    adTypes: List<String>?,
    answer: String? = null
): Any {
    return when (version) {
        APIConstants.API_VERSION_V1 -> SearchRequestV1(
            text = query,
            geo = geo,
            auctionType = APIConstants.AUCTION_TYPE,
            adType = adTypes
        )
        else -> SearchRequestV2(
            prompt = query,
            answer = answer ?: query,
            geo = geo,
            auctionType = APIConstants.AUCTION_TYPE,
            adType = adTypes,
            text = query
        )
    }
}


