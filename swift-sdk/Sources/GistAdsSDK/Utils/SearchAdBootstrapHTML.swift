//
//  SearchAdBootstrapHTML.swift
//  GistAdsSDK
//
//  Builds the self-contained HTML document that `AdTagBridgeWebView` loads
//  to embed the real `adtag.js` script for a search ad slot, mirroring how a
//  publisher's own webpage would embed it directly. This is a pure embed:
//  the tag makes its own JSONP request to the Search API and does its own
//  rendering, so the SDK is a thin wrapper around the HTML/JS embed with no
//  API calls of its own -- see `DisplayAdBootstrapHTML.swift` for the
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
//

import Foundation

/// Errors that can occur while building the search ad bootstrap HTML document.
enum SearchAdBootstrapError: LocalizedError, Equatable {
    case invalidSizes
    case emptyQuery

    var errorDescription: String? {
        switch self {
        case .invalidSizes:
            return "At least one AdSize must be provided"
        case .emptyQuery:
            return "A non-empty query is required"
        }
    }
}

enum SearchAdBootstrapHTML {

    /// Build the bootstrap HTML document for a single search ad slot.
    /// - Parameters:
    ///   - publisherID: Publisher ID, passed as `defineSlot`'s `id`.
    ///   - publisherKey: Publisher API key, passed as `defineSlot`'s `api_key`.
    ///     Note: this becomes visible in the loaded HTML/JS source and is
    ///     sent as a public JSONP query param -- the same exposure a
    ///     publisher already accepts by embedding the JS tag directly.
    ///   - query: The search query, passed via `slot.definePrompt(...)`.
    ///   - geo: Geographic location code, passed as `defineSlot`'s `geo`.
    ///   - answer: Answer text, passed via `slot.defineAnswer(...)`. The ad tag docs mark this
    ///     as required for search ads (alongside `query`); when `nil`/blank, it defaults to
    ///     `query` so `defineAnswer` is always called, matching the pre-embed native SDK's
    ///     behavior of defaulting the request body's `answer` field to the query.
    ///   - adTypes: Optional ad type filter (mirrors `types` in `defineSlot`).
    ///   - sizes: One or more supported ad sizes (mirrors `sizes` in `defineSlot`).
    ///   - slotID: Unique per-instance element/slot id (so multiple search
    ///     ad controls on screen don't collide -- each gets its own WebView
    ///     anyway, but the id must still match the DOM element `defineSlot` targets).
    ///   - passbackFunctionName: Unique global function name the tag will
    ///     call on no-fill/render failure (see `definePassbackFunction`).
    ///   - adTagScriptURL: URL of the `adtag.js` bundle to load.
    /// - Returns: A complete HTML document string suitable for
    ///   `WKWebView.loadHTMLString(_:baseURL:)`.
    /// - Throws: `SearchAdBootstrapError.invalidSizes` if `sizes` is empty,
    ///   `SearchAdBootstrapError.emptyQuery` if `query` is blank.
    static func generate(
        publisherID: String,
        publisherKey: String,
        query: String,
        geo: String,
        answer: String? = nil,
        adTypes: [AdType]? = nil,
        sizes: [AdSize],
        slotID: String,
        passbackFunctionName: String,
        adTagScriptURL: String
    ) throws -> String {
        guard !sizes.isEmpty else {
            throw SearchAdBootstrapError.invalidSizes
        }
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw SearchAdBootstrapError.emptyQuery
        }

        let sizesJSON = scriptSafeJSON(try AdSize.encodeSizesParam(sizes))

        let slotIDLiteral = jsStringLiteral(slotID)
        let publisherIDLiteral = jsStringLiteral(publisherID)
        let publisherKeyLiteral = jsStringLiteral(publisherKey)
        let geoLiteral = jsStringLiteral(geo)
        let queryLiteral = jsStringLiteral(query)
        let passbackFunctionNameLiteral = jsStringLiteral(passbackFunctionName)

        let adTypesJSON: String
        if let adTypes, !adTypes.isEmpty {
            adTypesJSON = "[" + adTypes.map { jsStringLiteral($0.rawValue) }.joined(separator: ", ") + "]"
        } else {
            adTypesJSON = "undefined"
        }

        // The ad tag docs mark `answer` as required for search ads (alongside `query`);
        // default to `query` when not provided so `defineAnswer` is always called, matching
        // the pre-embed native SDK's request body, which defaulted `answer` to the query.
        let resolvedAnswer: String
        if let answer, !answer.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            resolvedAnswer = answer
        } else {
            resolvedAnswer = query
        }
        let defineAnswerLine = "\n                slot.defineAnswer(\(jsStringLiteral(resolvedAnswer)));"

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
            var slot = window.prtag.defineSlot({ id: \(publisherIDLiteral), api_key: \(publisherKeyLiteral), geo: \(geoLiteral) }, \(slotIDLiteral), \(sizesJSON), \(adTypesJSON));
            if (slot) {
                slot.definePrompt(\(queryLiteral));\(defineAnswerLine)
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
