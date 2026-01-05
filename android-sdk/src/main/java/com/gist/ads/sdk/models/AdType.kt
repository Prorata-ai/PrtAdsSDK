package com.gist.ads.sdk.models

import com.google.gson.annotations.SerializedName

/**
 * Ad types supported by Gist AI Search
 */
enum class AdType(val value: String) {
    @SerializedName("image")
    IMAGE("image"),
    
    @SerializedName("text/image")
    TEXT_IMAGE("text/image"),
    
    @SerializedName("text")
    TEXT("text");
    
    /**
     * Display name for the ad type
     */
    val displayName: String
        get() = when (this) {
            IMAGE -> "Image"
            TEXT_IMAGE -> "Text/Image"
            TEXT -> "Text"
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


