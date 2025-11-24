package com.gist.ads.sdk.models

import com.google.gson.annotations.SerializedName

/**
 * Ad types supported by Gist AI Search
 */
enum class AdType(val value: String) {
    @SerializedName("image")
    IMAGE("image"),
    
    @SerializedName("image/text")
    IMAGE_TEXT("image/text");
    
    /**
     * Display name for the ad type
     */
    val displayName: String
        get() = when (this) {
            IMAGE -> "Image"
            IMAGE_TEXT -> "Image/Text"
        }
    
    companion object {
        /**
         * Convert string value to AdType
         */
        fun fromValue(value: String): AdType? {
            return values().find { it.value == value }
        }
    }
}


