//
//  DisplayAdAPIService.swift
//  GistAdsSDK
//
//  Service for communicating with the Gist Display Ad API.
//
//  ============================================================================
//  BACKEND CONTRACT (discovered 2026-07-08, PAA-5351 Step 0)
//  ============================================================================
//
//  Discovery method: traced adtag.js's own network calls by downloading and
//  reading the bundle from staging/integration/production, then hit the live
//  endpoint directly with a real demo publisher ID (`guest-api`, found in
//  this SDK's existing test fixtures) to confirm behavior.
//
//  ENDPOINT
//  --------
//  `GET /decision` on a *separate host* from the search API (tp-srch-api):
//    - production:  https://disp-api.prorata.ai
//    - staging:     https://disp-api.staging.prorata.ai
//    - integration: https://prtadsdisplayapi-integration.up.railway.app
//        (temporary Railway infra as of this writing -- NOT the
//        disp-api.integration.prorata.ai pattern used by the other two
//        environments. Overridable via GIST_ADS_DISPLAY_INTEGRATION_URL if
//        this changes; see DisplayAPIConstants.)
//
//  AUTH
//  ----
//  None. There is no Publisher-Key header for display ads. The publisher ID
//  is passed as a plain `publisher` query parameter alongside the page
//  `url`. This makes sense once you see how the browser tag calls this
//  endpoint: via a JSONP `<script>` tag, which cannot carry custom headers.
//  Search ads, by contrast, use a secret Publisher-Key because they're
//  gated more tightly (the native SDK also uses a POST + header for search,
//  a separate code path from the browser's JSONP call to the same
//  endpoint).
//
//  REQUEST
//  -------
//  Query parameters, confirmed directly against the live OpenAPI schema
//  (`GET /openapi.json` on the staging/integration hosts, which expose
//  Swagger docs at `/docs`) -- this superseded and corrected an earlier
//  guess based only on reading adtag.js:
//    - `publisher`:      publisher ID/slug
//    - `url`:            the page URL to target contextually
//    - `ad_size`:        JSON-encoded array, e.g. `[[300,250]]`, or
//                        `[[0,0]]` for dynamic. NOTE: this is `ad_size`,
//                        NOT `sizes` -- an earlier version of this file used
//                        `sizes`, which the backend silently ignores
//                        (unrecognized query params are dropped, not
//                        rejected), so size-based ad selection was
//                        completely inert until this was corrected.
//    - `ad_types`:       pipe-joined type aliases (supported by the backend,
//                        but intentionally NOT sent by this SDK for v1 --
//                        the real aliases, e.g. "generative-image-text",
//                        don't map cleanly onto the existing search-oriented
//                        `AdType` enum, and omitting the param simply
//                        requests all eligible types for the given sizes)
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
//    - `geo`:            NOTE: confirmed in the POST `/decision` schema
//                        (`DecisionRequest.geo`, "Optional geographic
//                        location override (country code)") but NOT
//                        present in the GET endpoint's parameter list --
//                        the GET endpoint (used here) has no equivalent
//                        override today, so this SDK does not send `geo`.
//                        If/when the GET endpoint adds it, wire it through
//                        the same way as `data` below.
//
//  RESPONSE
//  --------
//  Raw ad fields, NOT an iframeUrl. Confirmed by reading adtag.js's own
//  `parseResponse` / `convertAdResponseJson`, which normalize and feed
//  fields like `adId`, `adUrl`, `adHeadline`, `adText`, `adCTA`, `adImage`,
//  `adName`, `templateId` into client-side templates -- `iframeUrl` never
//  appears anywhere in the tag's code. The response may be wrapped in
//  `{"selection": [...]}` (matching the search API's convention) or be a
//  flat single-ad object at the root; `DisplayAdResponse` handles both (see
//  that file).
//
//  NOTE: the live schema (`/openapi.json`) uses `adCTA` (all-caps CTA), not
//  `adCta` -- see the `CodingKeys` override in `DisplayAdItem`. A live
//  response also includes several fields not modeled here (`adRelevance`,
//  `adSource`, `flightId`, `brandColors`, `viewUrl`, `adSize`/`width`/
//  `height` echoing back what was actually served, etc.); `Codable` ignores
//  unrecognized keys by default, so decoding is unaffected -- only the v1
//  rendering-relevant fields are modeled.
//
//  NO-FILL
//  -------
//  Confirmed LIVE against staging, integration, and production using the
//  `guest-api` demo publisher ID: every environment returned `HTTP 200`
//  with body `{}` (empty JSON object, no `adId`). No special error status
//  or error envelope -- absence of `adId` is the no-fill signal.
//
//  WHY THIS MEANS A CUSTOM RENDERER
//  ---------------------------------
//  Because the response is raw fields rather than an iframeUrl, this SDK
//  cannot reuse `IframeHTMLGenerator` for display ads. See
//  `DisplayAdHTMLGenerator.swift` for the (intentionally minimal, isolated)
//  raw-field renderer used instead.
//  ============================================================================
//

import Foundation

/// API service for fetching display ads from the Gist Display Ad API.
class DisplayAdAPIService {

    private let baseURL: String
    private let publisherID: String
    private let urlSession: URLSession

    init(baseURL: String, publisherID: String, urlSession: URLSession = .shared) {
        self.baseURL = baseURL
        self.publisherID = publisherID
        self.urlSession = urlSession
    }

    /// Fetch a display ad from the Display Ad API.
    /// - Parameters:
    ///   - pageURL: The current page/context URL to target the ad against.
    ///   - sizes: One or more supported ad sizes.
    ///   - theme: Theme preference - "light" or "dark" (resolved from system if "system" was selected).
    ///   - context: Optional publisher-provided key-value data (e.g. category,
    ///     keywords, section) sent as the `data` query param for LLM context.
    ///     Primarily useful for native apps, where `pageURL` alone gives the
    ///     backend nothing crawlable to analyze -- see the contract notes
    ///     above.
    /// - Returns: HTML string containing the rendered ad.
    /// - Throws: `DisplayAdAPIError.noFill` when the server has no ad to serve.
    func fetchAd(pageURL: String, sizes: [AdSize], theme: String, context: [String: Any]? = nil) async throws -> String {
        let request = try buildRequest(pageURL: pageURL, sizes: sizes, context: context)

        let (data, response) = try await urlSession.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw DisplayAdAPIError.invalidResponse
        }

        guard httpResponse.statusCode == 200 else {
            throw DisplayAdAPIError.httpError(statusCode: httpResponse.statusCode, response: data)
        }

        let decoded: DisplayAdResponse
        do {
            decoded = try JSONDecoder().decode(DisplayAdResponse.self, from: data)
        } catch {
            throw DisplayAdAPIError.invalidData(underlying: error)
        }

        guard let ad = decoded.ad else {
            throw DisplayAdAPIError.noFill
        }

        return DisplayAdHTMLGenerator.generate(ad: ad, theme: theme)
    }

    /// Build the GET request for the `/decision` endpoint.
    /// - Parameter context: Optional publisher-provided key-value data, JSON-encoded into the `data` query param.
    func buildRequest(pageURL: String, sizes: [AdSize], context: [String: Any]? = nil) throws -> URLRequest {
        guard !sizes.isEmpty else {
            throw DisplayAdAPIError.invalidSizes
        }

        guard var components = URLComponents(string: baseURL) else {
            throw DisplayAdAPIError.invalidURL
        }

        let sizesJSON = try AdSize.encodeSizesParam(sizes)
        components.path = components.path.replacingOccurrences(of: "/$", with: "", options: .regularExpression)
            + DisplayAPIConstants.decisionEndpoint
        var queryItems = [
            URLQueryItem(name: "publisher", value: publisherID),
            URLQueryItem(name: "url", value: pageURL),
            URLQueryItem(name: "ad_size", value: sizesJSON),
            URLQueryItem(name: "format", value: "json"),
            URLQueryItem(name: "cb", value: String(Int(Date().timeIntervalSince1970 * 1000))),
            URLQueryItem(name: "correlation_id", value: UUID().uuidString)
        ]

        if let context = context, !context.isEmpty {
            queryItems.append(URLQueryItem(name: "data", value: try Self.encodeContextParam(context)))
        }

        components.queryItems = queryItems

        guard let url = components.url else {
            throw DisplayAdAPIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        return request
    }

    /// Encode a publisher-provided context dictionary into the JSON string
    /// expected by the `data` query param.
    /// - Throws: `DisplayAdAPIError.invalidContext` if the dictionary contains
    ///   values that aren't valid JSON (e.g. non-JSON types).
    static func encodeContextParam(_ context: [String: Any]) throws -> String {
        guard JSONSerialization.isValidJSONObject(context) else {
            throw DisplayAdAPIError.invalidContext
        }
        let data = try JSONSerialization.data(withJSONObject: context)
        return String(data: data, encoding: .utf8) ?? "{}"
    }
}

/// Errors that can occur during Display Ad API operations
enum DisplayAdAPIError: LocalizedError, Equatable {
    case invalidURL
    case invalidSizes
    case invalidContext
    case invalidResponse
    case invalidData(underlying: Error)
    case httpError(statusCode: Int, response: Data?)
    case noFill

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid Display Ad API URL"
        case .invalidSizes:
            return "At least one AdSize must be provided"
        case .invalidContext:
            return "Context data must be a valid JSON object (String/Number/Bool/Array/Dictionary values only)"
        case .invalidResponse:
            return "Invalid response from server"
        case .invalidData(let underlying):
            return "Unable to parse response data: \(underlying.localizedDescription)"
        case .httpError(let statusCode, _):
            return "HTTP error: \(statusCode)"
        case .noFill:
            return "No display ad available for this request"
        }
    }

    static func == (lhs: DisplayAdAPIError, rhs: DisplayAdAPIError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidURL, .invalidURL),
             (.invalidSizes, .invalidSizes),
             (.invalidContext, .invalidContext),
             (.invalidResponse, .invalidResponse),
             (.noFill, .noFill):
            return true
        case (.invalidData, .invalidData):
            return true
        case (.httpError(let lStatus, _), .httpError(let rStatus, _)):
            return lStatus == rStatus
        default:
            return false
        }
    }
}
