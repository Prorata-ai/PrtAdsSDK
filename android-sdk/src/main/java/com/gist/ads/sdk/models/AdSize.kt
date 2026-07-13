package com.gist.ads.sdk.models

import com.google.gson.Gson

/**
 * Standard IAB display ad sizes, plus "dynamic" for fluid layouts.
 *
 * These mirror the sizes documented for the web ad tag's `defineSlot`
 * (see "Supported Sizes" in the ad tag docs), and match the Swift SDK's
 * `AdSize` enum.
 */
enum class AdSize {
    LEADERBOARD,
    SUPER_LEADERBOARD,
    MEDIUM_RECTANGLE,
    MOBILE_BANNER,
    BILLBOARD,
    LARGE_RECTANGLE,
    SKYSCRAPER,
    DYNAMIC;

    /**
     * Pixel width, or `null` for [DYNAMIC] (which has no fixed dimensions).
     */
    val width: Int?
        get() = when (this) {
            LEADERBOARD -> 728
            SUPER_LEADERBOARD -> 970
            MEDIUM_RECTANGLE -> 300
            MOBILE_BANNER -> 320
            BILLBOARD -> 970
            LARGE_RECTANGLE -> 300
            SKYSCRAPER -> 160
            DYNAMIC -> null
        }

    /**
     * Pixel height, or `null` for [DYNAMIC] (which has no fixed dimensions).
     */
    val height: Int?
        get() = when (this) {
            LEADERBOARD -> 90
            SUPER_LEADERBOARD -> 90
            MEDIUM_RECTANGLE -> 250
            MOBILE_BANNER -> 50
            BILLBOARD -> 250
            LARGE_RECTANGLE -> 600
            SKYSCRAPER -> 600
            DYNAMIC -> null
        }

    val displayName: String
        get() = when (this) {
            LEADERBOARD -> "Leaderboard (728x90)"
            SUPER_LEADERBOARD -> "Super Leaderboard (970x90)"
            MEDIUM_RECTANGLE -> "Medium Rectangle (300x250)"
            MOBILE_BANNER -> "Mobile Banner (320x50)"
            BILLBOARD -> "Billboard (970x250)"
            LARGE_RECTANGLE -> "Large Rectangle (300x600)"
            SKYSCRAPER -> "Skyscraper (160x600)"
            DYNAMIC -> "Dynamic"
        }

    /**
     * JSON-serializable representation matching what the display ad server
     * expects for a single size entry in the `ad_size` query parameter:
     * `[width, height]`, with `[0, 0]` conventionally meaning "dynamic"
     * (confirmed against the live OpenAPI schema: "Use 0x0 for dynamic").
     */
    fun jsonValue(): List<Int> = listOf(width ?: 0, height ?: 0)

    companion object {
        /**
         * Encode a list of sizes into the JSON string expected by the display
         * ad server's `ad_size` query parameter, e.g. `[[300,250]]` or
         * `[[0,0]]` for dynamic.
         */
        fun encodeSizesParam(sizes: List<AdSize>): String {
            val values = sizes.map { it.jsonValue() }
            return Gson().toJson(values)
        }
    }
}
