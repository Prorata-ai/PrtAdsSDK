package com.gist.ads.sdk.utils

import com.gist.ads.sdk.models.AdSize
import com.gist.ads.sdk.models.AdType

//  Builds the self-contained HTML document that `AdTagBridgeWebView` loads
//  to embed the real `adtag.js` script for a search ad slot, mirroring how
//  a publisher's own webpage would embed it directly. This is a pure embed:
//  the tag makes its own JSONP request to the Search API and does its own
//  rendering, so the SDK is a thin wrapper around the HTML/JS embed with no
//  API calls of its own -- see `DisplayAdBootstrapHTML.kt` for the
//  display-ad sibling of this file and the PR #7 review discussion that
//  established the pattern.
//
//  Confirmed by reading the live adtag.js bundle: `defineSlot`'s config
//  accepts `{id, api_key, url, geo}` and treats `api_key` as an alternative
//  to `url` (a slot is valid if either is present); when `api_key` is set,
//  `displayAd()` calls `requestSearchAd()`, which sends its own JSONP GET to
//  `{publisher_key, publisher_id, prompt, answer, ad_type, geo, ...}` and
//  renders the result directly into the slot's DOM (no iframe). `prompt`/
//  `answer` are set via `slot.definePrompt(...)`/`slot.defineAnswer(...)`.

/**
 * Errors that can occur while building the search ad bootstrap HTML document.
 */
sealed class SearchAdBootstrapException(message: String) : Exception(message) {
    object InvalidSizes : SearchAdBootstrapException("At least one AdSize must be provided")
    object EmptyQuery : SearchAdBootstrapException("A non-empty query is required")
}

/**
 * Builds the bootstrap HTML document loaded into `AdTagBridgeWebView` for search ads.
 */
object SearchAdBootstrapHTML {

    /**
     * Build the bootstrap HTML document for a single search ad slot.
     *
     * @param publisherId Publisher ID, passed as `defineSlot`'s `id`.
     * @param publisherKey Publisher API key, passed as `defineSlot`'s `api_key`. Note: this
     *   becomes visible in the loaded HTML/JS source and is sent as a public JSONP query param --
     *   the same exposure a publisher already accepts by embedding the JS tag directly.
     * @param query The search query, passed via `slot.definePrompt(...)`.
     * @param geo Geographic location code, passed as `defineSlot`'s `geo`.
     * @param answer Answer text, passed via `slot.defineAnswer(...)`. The ad tag docs mark this
     *   as required for search ads (alongside `query`); when null/blank, it defaults to `query`
     *   so `defineAnswer` is always called, matching the pre-embed native SDK's behavior of
     *   defaulting the request body's `answer` field to the query.
     * @param adTypes Optional ad type filter (mirrors `types` in `defineSlot`).
     * @param sizes One or more supported ad sizes (mirrors `sizes` in `defineSlot`).
     * @param slotId Unique per-instance element/slot id (so multiple search ad controls on
     *   screen don't collide -- each gets its own WebView anyway, but the id must still match the
     *   DOM element `defineSlot` targets).
     * @param passbackFunctionName Unique global function name the tag will call on
     *   no-fill/render failure (see `definePassbackFunction`).
     * @param adTagScriptUrl URL of the `adtag.js` bundle to load.
     * @throws SearchAdBootstrapException.InvalidSizes if `sizes` is empty.
     * @throws SearchAdBootstrapException.EmptyQuery if `query` is blank.
     */
    fun generate(
        publisherId: String,
        publisherKey: String,
        query: String,
        geo: String,
        answer: String? = null,
        adTypes: List<AdType>? = null,
        sizes: List<AdSize>,
        slotId: String,
        passbackFunctionName: String,
        adTagScriptUrl: String
    ): String {
        if (sizes.isEmpty()) {
            throw SearchAdBootstrapException.InvalidSizes
        }
        if (query.isBlank()) {
            throw SearchAdBootstrapException.EmptyQuery
        }

        val sizesJson = scriptSafeJson(AdSize.encodeSizesParam(sizes))

        val slotIdLiteral = jsStringLiteral(slotId)
        val publisherIdLiteral = jsStringLiteral(publisherId)
        val publisherKeyLiteral = jsStringLiteral(publisherKey)
        val geoLiteral = jsStringLiteral(geo)
        val queryLiteral = jsStringLiteral(query)
        val passbackFunctionNameLiteral = jsStringLiteral(passbackFunctionName)

        val adTypesJson = if (!adTypes.isNullOrEmpty()) {
            adTypes.joinToString(prefix = "[", postfix = "]", separator = ", ") { jsStringLiteral(it.value) }
        } else {
            "undefined"
        }

        // The ad tag docs mark `answer` as required for search ads (alongside `query`);
        // default to `query` when not provided so `defineAnswer` is always called, matching
        // the pre-embed native SDK's request body, which defaulted `answer` to the query.
        val resolvedAnswer = if (!answer.isNullOrBlank()) answer else query
        val defineAnswerLine = "\n                slot.defineAnswer(${jsStringLiteral(resolvedAnswer)});"

        return """
        <!DOCTYPE html>
        <html>
        <head>
        <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
        <style>
            html, body {
                margin: 0;
                padding: 0;
                background: transparent;
            }
        </style>
        </head>
        <body>
        <div id="${htmlAttributeEscaped(slotId)}" style="width:100%;"></div>
        <script>
        window.prtag = window.prtag || { cmd: [] };
        window[$passbackFunctionNameLiteral] = function() {
            if (window.prtagBridge && window.prtagBridge.onNoFill) {
                window.prtagBridge.onNoFill();
            }
        };
        window.prtag.cmd.push(function() {
            window.prtag.addEventListener("adRendered", function(e) {
                if (!e || e.id === $slotIdLiteral) {
                    var el = document.getElementById($slotIdLiteral);
                    var height = el ? el.scrollHeight : 0;
                    if (window.prtagBridge && window.prtagBridge.onAdRendered) {
                        window.prtagBridge.onAdRendered(height);
                    }
                }
            });
            var slot = window.prtag.defineSlot({ id: $publisherIdLiteral, api_key: $publisherKeyLiteral, geo: $geoLiteral }, $slotIdLiteral, $sizesJson, $adTypesJson);
            if (slot) {
                slot.definePrompt($queryLiteral);$defineAnswerLine
                slot.definePassbackFunction($passbackFunctionNameLiteral);
            }
            window.prtag.displayAd($slotIdLiteral);
        });
        </script>
        <script src="${htmlAttributeEscaped(adTagScriptUrl)}" defer></script>
        </body>
        </html>
        """.trimIndent()
    }
}
