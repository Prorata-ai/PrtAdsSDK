package com.gist.ads.sdk.models

import com.google.gson.Gson
import com.google.gson.JsonDeserializationContext
import com.google.gson.JsonDeserializer
import com.google.gson.JsonElement
import com.google.gson.annotations.SerializedName
import java.lang.reflect.Type

/**
 * Models for the Display Ad API (`/decision`) response.
 *
 * Shape discovered by reading adtag.js's own `parseResponse` /
 * `convertAdResponseJson`, then confirmed field-for-field against the live
 * OpenAPI schema (see the contract notes at the top of
 * DisplayAdAPIService.kt for the full write-up):
 *
 * - A filled response contains raw ad fields (adId, adUrl, adHeadline,
 *   adText, adCTA, adImage, adName, templateId, ...) -- there is no
 *   `iframeUrl`. Note the field is `adCTA` (all-caps CTA), not `adCta`.
 * - The response may either be wrapped in `{"selection": [...]}` (matching
 *   the search API's convention, which this SDK's `SearchResponse` already
 *   models) or be a single flat ad object at the root. adtag.js handles
 *   both: `"selection" in e ? e.selection[0] : e`.
 * - A no-fill response is `{}` (HTTP 200, empty JSON object) -- confirmed
 *   live against staging/integration/production. adtag.js treats the
 *   absence of `adId` as "no ad".
 */

/**
 * A single display ad's raw fields, as returned by the `/decision` endpoint.
 *
 * Only the fields needed for basic image/text/CTA ads (v1 scope) are
 * modeled. Richer template types (questions, conversational, etc.) that the
 * web tag also supports are intentionally out of scope.
 */
data class DisplayAdItem(
    /** Presence of this field is how a filled response is distinguished from a no-fill. */
    @SerializedName("adId")
    val adId: String? = null,

    /** Click-through destination URL. */
    @SerializedName("adUrl")
    val adUrl: String? = null,

    /** Headline / title text. */
    @SerializedName("adHeadline")
    val adHeadline: String? = null,

    /** Supporting body text. */
    @SerializedName("adText")
    val adText: String? = null,

    /** Call-to-action button text (e.g. "Shop Now"). The live API returns `adCTA` (all-caps CTA), not `adCta`. */
    @SerializedName("adCTA")
    val adCta: String? = null,

    /** Creative image URL. */
    @SerializedName("adImage")
    val adImage: String? = null,

    /** Advertiser / brand name. */
    @SerializedName("adName")
    val adName: String? = null,

    /** Template alias describing which creative layout this ad uses (e.g. "image", "text/image", "text"). */
    @SerializedName("templateId")
    val templateId: String? = null
)

/**
 * Top-level response from the `/decision` endpoint.
 *
 * Parsing never throws for a well-formed no-fill (`{}`) or filled body --
 * `ad` is simply `null` when there's no fill. This mirrors the tolerant
 * parsing adtag.js itself does.
 */
data class DisplayAdResponse(val ad: DisplayAdItem?) {

    /**
     * Custom deserializer that handles both response shapes: prefers the
     * `{"selection": [...]}` wrapper used by the search API (in case the
     * display endpoint adopts the same convention), and otherwise falls
     * back to treating the body as a single flat ad object -- matching
     * adtag.js's `"selection" in e ? e.selection[0] : e`.
     */
    private data class SelectionWrapper(val selection: List<DisplayAdItem>?)

    companion object Deserializer : JsonDeserializer<DisplayAdResponse> {
        private val gson = Gson()

        override fun deserialize(
            json: JsonElement,
            typeOfT: Type,
            context: JsonDeserializationContext
        ): DisplayAdResponse {
            val obj = json.asJsonObject

            val wrapped = if (obj.has("selection")) {
                gson.fromJson(obj, SelectionWrapper::class.java)
            } else {
                null
            }
            val fromSelection = wrapped?.selection?.firstOrNull()
            if (fromSelection != null) {
                return DisplayAdResponse(ad = fromSelection)
            }

            val flat = gson.fromJson(obj, DisplayAdItem::class.java)
            return DisplayAdResponse(ad = if (flat?.adId != null) flat else null)
        }
    }
}
