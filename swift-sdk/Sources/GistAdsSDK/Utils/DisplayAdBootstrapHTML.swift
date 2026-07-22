//
//  DisplayAdBootstrapHTML.swift
//  GistAdsSDK
//
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
//

import Foundation

/// Errors that can occur while building the bootstrap HTML document.
enum DisplayAdBootstrapError: LocalizedError, Equatable {
    case invalidSizes

    var errorDescription: String? {
        switch self {
        case .invalidSizes:
            return "At least one AdSize must be provided"
        }
    }
}

enum DisplayAdBootstrapHTML {

    /// Build the bootstrap HTML document for a single display ad slot.
    /// - Parameters:
    ///   - publisherID: Publisher ID, passed as `defineSlot`'s `id`.
    ///   - pageURL: Page/context URL, passed as `defineSlot`'s `url`.
    ///   - sizes: One or more supported ad sizes (mirrors `sizes` in `defineSlot`).
    ///   - slotID: Unique per-instance element/slot id (so multiple display
    ///     ad controls on screen don't collide -- each gets its own WebView
    ///     anyway, but the id must still match the DOM element `defineSlot` targets).
    ///   - passbackFunctionName: Unique global function name the tag will
    ///     call on no-fill/render failure (see `definePassbackFunction`).
    ///   - adTagScriptURL: URL of the `adtag.js` bundle to load.
    /// - Returns: A complete HTML document string suitable for
    ///   `WKWebView.loadHTMLString(_:baseURL:)`.
    /// - Throws: `DisplayAdBootstrapError.invalidSizes` if `sizes` is empty.
    static func generate(
        publisherID: String,
        pageURL: String,
        sizes: [AdSize],
        slotID: String,
        passbackFunctionName: String,
        adTagScriptURL: String
    ) throws -> String {
        guard !sizes.isEmpty else {
            throw DisplayAdBootstrapError.invalidSizes
        }

        let sizesJSON = scriptSafeJSON(try AdSize.encodeSizesParam(sizes))

        let slotIDLiteral = jsStringLiteral(slotID)
        let publisherIDLiteral = jsStringLiteral(publisherID)
        let pageURLLiteral = jsStringLiteral(pageURL)
        let passbackFunctionNameLiteral = jsStringLiteral(passbackFunctionName)

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
        <div id="\(htmlAttributeEscaped(slotID))" style="width:100%;"></div>
        <script>
        window.prtag = window.prtag || { cmd: [] };
        window[\(passbackFunctionNameLiteral)] = function() {
            if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.prtagNoFill) {
                window.webkit.messageHandlers.prtagNoFill.postMessage(0);
            }
        };
        window.prtag.cmd.push(function() {
            window.prtag.addEventListener("adRendered", function(e) {
                if (!e || e.id === \(slotIDLiteral)) {
                    var el = document.getElementById(\(slotIDLiteral));
                    var height = el ? el.scrollHeight : 0;
                    if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.prtagAdRendered) {
                        window.webkit.messageHandlers.prtagAdRendered.postMessage(height);
                    }
                }
            });
            var slot = window.prtag.defineSlot({ id: \(publisherIDLiteral), url: \(pageURLLiteral) }, \(slotIDLiteral), \(sizesJSON));
            if (slot) {
                slot.definePassbackFunction(\(passbackFunctionNameLiteral));
            }
            window.prtag.displayAd(\(slotIDLiteral));
        });
        </script>
        <script src="\(htmlAttributeEscaped(adTagScriptURL))" defer></script>
        </body>
        </html>
        """
    }
}

/// Escape a raw string for safe embedding inside a double-quoted JS string
/// literal within a `<script>` block. Escapes backslashes/quotes/control
/// characters, and defuses any `<` (so a value containing literal
/// `</script>` text can't prematurely close the surrounding tag) and the
/// U+2028/U+2029 line/paragraph separators (technically valid unescaped in a
/// JS string, but historically mishandled as line terminators by some
/// engines).
func jsStringLiteral(_ value: String) -> String {
    var escaped = ""
    escaped.reserveCapacity(value.count)
    for scalar in value.unicodeScalars {
        switch scalar {
        case "\\":
            escaped += "\\\\"
        case "\"":
            escaped += "\\\""
        case "\n":
            escaped += "\\n"
        case "\r":
            escaped += "\\r"
        case "<":
            escaped += "\\u003C"
        case "\u{2028}":
            escaped += "\\u2028"
        case "\u{2029}":
            escaped += "\\u2029"
        default:
            if scalar.value < 0x20 {
                escaped += String(format: "\\u%04x", scalar.value)
            } else {
                escaped.unicodeScalars.append(scalar)
            }
        }
    }
    return "\"\(escaped)\""
}

/// Make an already-serialized JSON string safe to embed literally inside a
/// `<script>` block, applying the same `<`/line-separator defusing as
/// `jsStringLiteral` (see above) without re-encoding the JSON itself. Valid
/// JSON never requires an unescaped `<`, so this is a lossless transform.
func scriptSafeJSON(_ json: String) -> String {
    json
        .replacingOccurrences(of: "<", with: "\\u003C")
        .replacingOccurrences(of: "\u{2028}", with: "\\u2028")
        .replacingOccurrences(of: "\u{2029}", with: "\\u2029")
}

func htmlAttributeEscaped(_ value: String) -> String {
    value
        .replacingOccurrences(of: "&", with: "&amp;")
        .replacingOccurrences(of: "<", with: "&lt;")
        .replacingOccurrences(of: ">", with: "&gt;")
        .replacingOccurrences(of: "\"", with: "&quot;")
}
