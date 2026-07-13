package com.gist.ads.sdk.services

//  Service for communicating with the Gist Display Ad API.
//
//  ============================================================================
//  BACKEND CONTRACT
//  ============================================================================
//
//  ENDPOINT
//  --------
//  `GET /decision` on a *separate host* from the search API (tp-srch-api):
//    - production:  https://disp-api.prorata.ai
//    - staging:     https://disp-api.staging.prorata.ai
//    - integration: https://prtadsdisplayapi-integration.up.railway.app
//        (temporary Railway infra as of this writing -- NOT the
//        disp-api.integration.prorata.ai pattern used by the other two
//        environments. Overridable via the gist.ads.display.integration.url
//        system property if this changes; see DisplayAPIConstants.)
//
//  AUTH
//  ----
//  None. There is no Publisher-Key header for display ads. The publisher ID
//  is passed as a plain `publisher` query parameter alongside the page
//  `url`. This makes sense once you see how the browser tag calls this
//  endpoint: via a JSONP `<script>` tag, which cannot carry custom headers.
//  Search ads, by contrast, use a secret Publisher-Key because they're
//  gated more tightly.
//
//  REQUEST
//  -------
//  Query parameters, confirmed directly against the live OpenAPI schema
//  (`GET /openapi.json` on the staging/integration hosts, which expose
//  Swagger docs at `/docs`):
//    - `publisher`:      publisher ID/slug
//    - `url`:            the page URL to target contextually
//    - `ad_size`:        JSON-encoded array, e.g. `[[300,250]]`, or
//                        `[[0,0]]` for dynamic. NOTE: this is `ad_size`,
//                        NOT `sizes` -- an unrecognized query param is
//                        silently dropped by the backend, not rejected, so
//                        getting this name wrong makes size-based ad
//                        selection completely inert.
//    - `ad_types`:       pipe-joined type aliases (supported by the backend,
//                        but intentionally NOT sent by this SDK for v1 --
//                        omitting the param simply requests all eligible
//                        types for the given sizes)
//    - `format`:         "json" (the browser tag uses "jsonp"; this SDK
//                        talks to the endpoint directly, so plain JSON works)
//    - `cb`:             cache-buster (current time in ms) -- not part of
//                        the documented schema, but harmless to include
//    - `correlation_id`: UUID for request tracing -- also not part of the
//                        documented schema, but harmless to include
//    - `data`:           JSON-encoded object of publisher-provided key-value
//                        data, per the live OpenAPI schema: "JSON object
//                        with publisher-provided key-value data for LLM
//                        context". This is the SDK's escape hatch for
//                        native apps: unlike a real webpage, a native
//                        screen has no crawlable HTML for the backend to
//                        analyze via `url` alone, so `context` lets the
//                        host app hand over explicit signal (category,
//                        keywords, section, etc.) instead. The POST
//                        `/decision` endpoint models this as two separate
//                        fields (`context` and `data`), but the GET
//                        endpoint this SDK uses only exposes `data` -- so
//                        this SDK's `context` param is encoded into that
//                        single `data` query parameter.
//    - `geo`:            confirmed in the POST `/decision` schema but NOT
//                        present in the GET endpoint's parameter list --
//                        so this SDK does not send `geo`. If/when the GET
//                        endpoint adds it, wire it through the same way as
//                        `data` above.
//
//  RESPONSE
//  --------
//  Raw ad fields, NOT an iframeUrl -- see DisplayAdResponse.kt. The response
//  may be wrapped in `{"selection": [...]}` (matching the search API's
//  convention) or be a flat single-ad object at the root; `DisplayAdResponse`
//  handles both.
//
//  NOTE: the live schema (`/openapi.json`) uses `adCTA` (all-caps CTA), not
//  `adCta` -- see the `@SerializedName` override in `DisplayAdItem`.
//
//  NO-FILL
//  -------
//  Confirmed LIVE against staging, integration, and production: every
//  environment returned `HTTP 200` with body `{}` (empty JSON object, no
//  `adId`). No special error status or error envelope -- absence of `adId`
//  is the no-fill signal.
//
//  WHY THIS MEANS A CUSTOM RENDERER
//  ---------------------------------
//  Because the response is raw fields rather than an iframeUrl, this SDK
//  cannot reuse `IframeHTMLGenerator` for display ads. See
//  `DisplayAdHTMLGenerator.kt` for the (intentionally minimal, isolated)
//  raw-field renderer used instead.
//  ============================================================================

import com.gist.ads.sdk.DisplayAPIConstants
import com.gist.ads.sdk.models.AdSize
import com.gist.ads.sdk.models.DisplayAdItem
import com.gist.ads.sdk.models.DisplayAdResponse
import com.gist.ads.sdk.utils.DisplayAdHTMLGenerator
import com.google.gson.Gson
import com.google.gson.GsonBuilder
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import okhttp3.HttpUrl.Companion.toHttpUrlOrNull
import okhttp3.OkHttpClient
import okhttp3.Request
import java.io.IOException
import java.util.UUID
import java.util.concurrent.TimeUnit

/**
 * API service for fetching display ads from the Gist Display Ad API.
 */
class DisplayAdAPIService(
    private val baseUrl: String,
    private val publisherId: String
) {
    private val client: OkHttpClient = OkHttpClient.Builder()
        .connectTimeout(30, TimeUnit.SECONDS)
        .readTimeout(30, TimeUnit.SECONDS)
        .writeTimeout(30, TimeUnit.SECONDS)
        .build()

    private val gson: Gson = GsonBuilder()
        .registerTypeAdapter(DisplayAdResponse::class.java, DisplayAdResponse.Deserializer)
        .create()

    /**
     * Fetch a display ad from the Display Ad API.
     * @param pageUrl The current page/context URL to target the ad against.
     * @param sizes One or more supported ad sizes.
     * @param theme Theme preference - "light" or "dark" (resolved from system if "system" was selected).
     * @param context Optional publisher-provided key-value data (e.g. category, keywords, section)
     *   sent as the `data` query param for LLM context. Primarily useful for native apps, where
     *   `pageUrl` alone gives the backend nothing crawlable to analyze -- see the contract notes above.
     * @return HTML string containing the rendered ad.
     * @throws DisplayAdAPIException.NoFill when the server has no ad to serve.
     */
    suspend fun fetchAd(
        pageUrl: String,
        sizes: List<AdSize>,
        theme: String,
        context: Map<String, Any>? = null
    ): String = withContext(Dispatchers.IO) {
        val request = buildRequest(pageUrl, sizes, context)

        val response = try {
            client.newCall(request).execute()
        } catch (e: IOException) {
            throw DisplayAdAPIException.NetworkError(e)
        }

        if (!response.isSuccessful) {
            val body = response.body?.string()
            throw DisplayAdAPIException.HttpError(response.code, body)
        }

        val responseBody = response.body?.string()
            ?: throw DisplayAdAPIException.InvalidResponse

        val decoded: DisplayAdResponse = try {
            gson.fromJson(responseBody, DisplayAdResponse::class.java)
        } catch (e: Exception) {
            throw DisplayAdAPIException.InvalidData(e)
        }

        val ad: DisplayAdItem = decoded.ad ?: throw DisplayAdAPIException.NoFill

        DisplayAdHTMLGenerator.generate(ad, theme)
    }

    /**
     * Build the GET request for the `/decision` endpoint.
     * @param context Optional publisher-provided key-value data, JSON-encoded into the `data` query param.
     */
    internal fun buildRequest(
        pageUrl: String,
        sizes: List<AdSize>,
        context: Map<String, Any>? = null
    ): Request {
        if (sizes.isEmpty()) {
            throw DisplayAdAPIException.InvalidSizes
        }

        val trimmedBase = baseUrl.trimEnd('/')
        val httpUrl = (trimmedBase + DisplayAPIConstants.DECISION_ENDPOINT).toHttpUrlOrNull()
            ?: throw DisplayAdAPIException.InvalidUrl

        val sizesJson = AdSize.encodeSizesParam(sizes)

        val urlBuilder = httpUrl.newBuilder()
            .addQueryParameter("publisher", publisherId)
            .addQueryParameter("url", pageUrl)
            .addQueryParameter("ad_size", sizesJson)
            .addQueryParameter("format", "json")
            .addQueryParameter("cb", System.currentTimeMillis().toString())
            .addQueryParameter("correlation_id", UUID.randomUUID().toString())

        if (!context.isNullOrEmpty()) {
            urlBuilder.addQueryParameter("data", encodeContextParam(context))
        }

        return Request.Builder()
            .url(urlBuilder.build())
            .get()
            .build()
    }

    companion object {
        /**
         * Encode a publisher-provided context map into the JSON string
         * expected by the `data` query param.
         * @throws DisplayAdAPIException.InvalidContext if the map contains
         *   values that aren't valid JSON (e.g. non-JSON types).
         */
        fun encodeContextParam(context: Map<String, Any>): String {
            if (!isValidJsonValue(context)) {
                throw DisplayAdAPIException.InvalidContext
            }
            return Gson().toJson(context)
        }

        private fun isValidJsonValue(value: Any?): Boolean = when (value) {
            null -> true
            is String, is Boolean, is Int, is Long, is Float, is Double, is Short -> true
            is Map<*, *> -> value.keys.all { it is String } && value.values.all { isValidJsonValue(it) }
            is List<*> -> value.all { isValidJsonValue(it) }
            is Array<*> -> value.all { isValidJsonValue(it) }
            else -> false
        }
    }
}

/**
 * Errors that can occur during Display Ad API operations.
 */
sealed class DisplayAdAPIException(message: String, cause: Throwable? = null) : Exception(message, cause) {
    object InvalidUrl : DisplayAdAPIException("Invalid Display Ad API URL")
    object InvalidSizes : DisplayAdAPIException("At least one AdSize must be provided")
    object InvalidContext : DisplayAdAPIException(
        "Context data must be a valid JSON object (String/Number/Boolean/List/Map values only)"
    )
    object InvalidResponse : DisplayAdAPIException("Invalid response from server")

    data class InvalidData(val underlying: Throwable) : DisplayAdAPIException(
        "Unable to parse response data: ${underlying.message}",
        underlying
    )

    data class HttpError(val statusCode: Int, val responseBody: String?) : DisplayAdAPIException(
        "HTTP error: $statusCode"
    )

    object NoFill : DisplayAdAPIException("No display ad available for this request")

    data class NetworkError(val error: Throwable) : DisplayAdAPIException(
        "Network error: ${error.message ?: "Unable to connect to ad server"}",
        error
    )
}
