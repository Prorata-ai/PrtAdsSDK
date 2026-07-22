package com.gist.ads.sdk.utils

import com.gist.ads.sdk.models.AdSize

//  Builds the self-contained HTML document that `AdTagBridgeWebView`
//  loads to embed the real `adtag.js` script, mirroring how a publisher's
//  own webpage would embed it directly. This is a pure embed: the tag makes
//  its own `/decision` request and does its own rendering, so the SDK is a
//  thin wrapper around the HTML/JS embed with no API calls of its own (see
//  PR #7 review discussion). An earlier revision supported a `context`
//  targeting param by fetching ad data natively and feeding it into
//  `slot.defineAdData(...)` (confirmed by reading the live adtag.js bundle:
//  `defineSlot`'s config only accepts `{id, api_key, url, geo}`, and
//  `requestDisplayAd`'s own request only sends
//  `{publisher, url, ad_types, sizes, format, cb, correlation_id}` -- there
//  was never a `data`/`context` field to plumb through). That param has
//  been removed rather than kept as a native-fetch special case.

/**
 * Errors that can occur while building the bootstrap HTML document.
 */
sealed class DisplayAdBootstrapException(message: String) : Exception(message) {
    object InvalidSizes : DisplayAdBootstrapException("At least one AdSize must be provided")
}

/**
 * Builds the bootstrap HTML document loaded into `AdTagBridgeWebView`.
 */
object DisplayAdBootstrapHTML {

    /**
     * Build the bootstrap HTML document for a single display ad slot.
     *
     * @param publisherId Publisher ID, passed as `defineSlot`'s `id`.
     * @param pageUrl Page/context URL, passed as `defineSlot`'s `url`.
     * @param sizes One or more supported ad sizes (mirrors `sizes` in `defineSlot`).
     * @param slotId Unique per-instance element/slot id (each control gets its own WebView, but the
     *   id must still match the DOM element `defineSlot` targets).
     * @param passbackFunctionName Unique global function name the tag will call on no-fill/render
     *   failure (see `definePassbackFunction`).
     * @param adTagScriptUrl URL of the `adtag.js` bundle to load.
     * @throws DisplayAdBootstrapException.InvalidSizes if `sizes` is empty.
     */
    fun generate(
        publisherId: String,
        pageUrl: String,
        sizes: List<AdSize>,
        slotId: String,
        passbackFunctionName: String,
        adTagScriptUrl: String
    ): String {
        if (sizes.isEmpty()) {
            throw DisplayAdBootstrapException.InvalidSizes
        }

        val sizesJson = scriptSafeJson(AdSize.encodeSizesParam(sizes))

        val slotIdLiteral = jsStringLiteral(slotId)
        val publisherIdLiteral = jsStringLiteral(publisherId)
        val pageUrlLiteral = jsStringLiteral(pageUrl)
        val passbackFunctionNameLiteral = jsStringLiteral(passbackFunctionName)

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
            var slot = window.prtag.defineSlot({ id: $publisherIdLiteral, url: $pageUrlLiteral }, $slotIdLiteral, $sizesJson);
            if (slot) {
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

/**
 * Escape a raw string for safe embedding inside a double-quoted JS string
 * literal within a `<script>` block. Escapes backslashes/quotes/control
 * characters, and defuses any `<` (so a value containing literal
 * `</script>` text can't prematurely close the surrounding tag) and the
 * U+2028/U+2029 line/paragraph separators (technically valid unescaped in a
 * JS string, but historically mishandled as line terminators by some
 * engines).
 */
fun jsStringLiteral(value: String): String {
    val escaped = StringBuilder(value.length)
    for (ch in value) {
        when (ch) {
            '\\' -> escaped.append("\\\\")
            '"' -> escaped.append("\\\"")
            '\n' -> escaped.append("\\n")
            '\r' -> escaped.append("\\r")
            '<' -> escaped.append("\\u003C")
            '\u2028' -> escaped.append("\\u2028")
            '\u2029' -> escaped.append("\\u2029")
            else -> {
                if (ch.code < 0x20) {
                    escaped.append(String.format("\\u%04x", ch.code))
                } else {
                    escaped.append(ch)
                }
            }
        }
    }
    return "\"$escaped\""
}

/**
 * Make an already-serialized JSON string safe to embed literally inside a
 * `<script>` block, applying the same `<`/line-separator defusing as
 * [jsStringLiteral] (see above) without re-encoding the JSON itself. Valid
 * JSON never requires an unescaped `<`, so this is a lossless transform.
 */
fun scriptSafeJson(json: String): String {
    return json
        .replace("<", "\\u003C")
        .replace("\u2028", "\\u2028")
        .replace("\u2029", "\\u2029")
}

internal fun htmlAttributeEscaped(value: String): String {
    return value
        .replace("&", "&amp;")
        .replace("<", "&lt;")
        .replace(">", "&gt;")
        .replace("\"", "&quot;")
}
