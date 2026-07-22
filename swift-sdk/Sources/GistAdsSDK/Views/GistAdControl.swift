//
//  GistAdControl.swift
//  GistAdsSDK
//
//  Main ad control for displaying Gist AI Search ads: embeds the real
//  `adtag.js` script in a WebView and drives it via
//  `defineSlot({id, api_key, geo}, slotId, sizes, adTypes)` ->
//  `slot.definePrompt(query)` -> `displayAd(slotId)`, mirroring exactly how
//  a publisher's own webpage would embed the tag directly for search.
//
//  This control is a thin wrapper around that HTML/JS embed: it makes no
//  API calls of its own. `adtag.js` owns the entire ad request (its own
//  JSONP GET to the Search API), response parsing, and rendering directly
//  into the slot's DOM (no iframe), so as the tag and backend evolve, this
//  control keeps working without needing to track along. (An earlier
//  revision fetched ads natively via `AdAPIService` and wrapped the
//  response's `iframeUrl` in an `<iframe>`; that path has been removed so
//  this control can be a pure embed, mirroring `GistDisplayAdControl` --
//  see PR #7 review discussion and the follow-up search-ad migration.)
//
//  Note: unlike display ads, search ads are gated by a secret
//  `publisherKey`. Embedding it here means it becomes visible in the
//  loaded HTML/JS source and is sent as a public `publisher_key` query
//  param in the tag's own JSONP request -- the same exposure a publisher
//  already accepts by embedding the JS tag on a public webpage. Native
//  apps lose the extra protection of keeping it server-side/header-only.
//

import SwiftUI

/// Main control for displaying Gist AI Search ads.
public struct GistAdControl: View {

    /// Environment configuration for API endpoints
    public enum APIEnvironment {
        case staging
        case integration
        case production

        /// Iframe base URL for the environment (internal). Also used as the
        /// base URL for the embedded `adtag.js` bundle.
        /// Can be overridden via environment variables: GIST_ADS_STAGING_IFRAME_URL, GIST_ADS_INTEGRATION_IFRAME_URL, GIST_ADS_PRODUCTION_IFRAME_URL
        internal var iframeBaseURL: String {
            APIConstants.iframeBaseURL(for: self)
        }
    }

    // MARK: - Configuration Properties

    private let publisherID: String
    private let publisherKey: String
    private let query: String
    private let geo: String
    private let answer: String?
    private let adTypes: [AdType]?
    private let sizes: [AdSize]
    private let environment: APIEnvironment
    private let theme: String

    // MARK: - Callbacks

    /// Called when the ad has successfully loaded and is ready to display.
    private let onAdLoaded: (() -> Void)?

    /// Called when the user clicks an ad link that navigates to an external URL.
    /// If not provided, the URL will be opened in the default browser.
    private let onAdClicked: ((URL) -> Void)?

    /// Called when the ad content has loaded and the actual content height is known.
    /// Use this to resize your ad container to match the actual ad content size.
    private let onContentHeightChanged: ((CGFloat) -> Void)?

    /// View builder invoked when no ad is available (no-fill), mirroring the
    /// web tag's `definePassbackFunction`: the caller gets full control over
    /// what to show instead of the ad, rather than a hard-coded empty state.
    private let passback: () -> AnyView

    // MARK: - State

    private struct SearchAdSlotLoad: Equatable {
        let slotID: String
        let html: String
    }

    @State private var state: AdTagLoadState = .loading
    @State private var currentSlot: SearchAdSlotLoad?
    @Environment(\.colorScheme) var colorScheme: ColorScheme

    /// URL of the `adtag.js` bundle to embed for this environment. Reuses
    /// the same host as display ads, since `adtag.js` is one bundle serving
    /// both ad types (distinguished by whether `api_key` is passed to
    /// `defineSlot`). Also used as the WebView's `baseURL` for
    /// `loadHTMLString`, which is why this host must stay in
    /// `APIConstants.allowedAdDomains`.
    private var adTagScriptURL: String {
        let base = APIConstants.iframeBaseURL(for: environment)
        return base.replacingOccurrences(of: "/$", with: "", options: .regularExpression) + "/adtag.js"
    }

    // MARK: - Initialization

    /// Initialize the Gist ad control with custom no-fill content.
    /// - Parameters:
    ///   - publisherID: Your publisher ID
    ///   - publisherKey: Your publisher API key
    ///   - query: The search query to fetch ads for (passed via `slot.definePrompt(...)`)
    ///   - geo: Geographic location code (e.g., "US", "GB")
    ///   - answer: Answer text (passed via `slot.defineAnswer(...)`); the ad tag docs mark this
    ///     as required for search ads, so when omitted it defaults to `query`
    ///   - adTypes: Optional array of ad types to filter (defaults to all types)
    ///   - sizes: One or more supported ad sizes (mirrors `sizes` in `defineSlot`; defaults to `[.dynamic]`)
    ///   - environment: API environment (defaults to production)
    ///   - theme: Theme preference - "light", "dark", or "system" (defaults to "system" for auto-detection)
    ///   - onAdLoaded: Optional callback when ad successfully loads
    ///   - onAdClicked: Optional callback when user clicks an ad link (defaults to opening in browser)
    ///   - onContentHeightChanged: Optional callback when ad content height is determined
    ///   - passback: View builder shown when no ad is available (no-fill), mirroring `definePassbackFunction`
    public init<Passback: View>(
        publisherID: String,
        publisherKey: String,
        query: String,
        geo: String = "US",
        answer: String? = nil,
        adTypes: [AdType]? = nil,
        sizes: [AdSize] = [.dynamic],
        environment: APIEnvironment = .production,
        theme: String = "system",
        onAdLoaded: (() -> Void)? = nil,
        onAdClicked: ((URL) -> Void)? = nil,
        onContentHeightChanged: ((CGFloat) -> Void)? = nil,
        @ViewBuilder passback: @escaping () -> Passback
    ) {
        self.publisherID = publisherID
        self.publisherKey = publisherKey
        self.query = query
        self.geo = geo
        self.answer = answer
        self.adTypes = adTypes
        self.sizes = sizes
        self.environment = environment
        self.theme = theme
        self.onAdLoaded = onAdLoaded
        self.onAdClicked = onAdClicked
        self.onContentHeightChanged = onContentHeightChanged
        self.passback = { AnyView(passback()) }
    }

    /// Initialize the Gist ad control with a built-in "No ad available" fallback.
    /// - Parameters:
    ///   - publisherID: Your publisher ID
    ///   - publisherKey: Your publisher API key
    ///   - query: The search query to fetch ads for
    ///   - geo: Geographic location code (e.g., "US", "GB")
    ///   - answer: Answer text; the ad tag docs mark this as required for search ads, so when
    ///     omitted it defaults to `query`
    ///   - adTypes: Optional array of ad types to filter (defaults to all types)
    ///   - sizes: One or more supported ad sizes (defaults to `[.dynamic]`)
    ///   - environment: API environment (defaults to production)
    ///   - theme: Theme preference - "light", "dark", or "system" (defaults to "system" for auto-detection)
    ///   - onAdLoaded: Optional callback when ad successfully loads
    ///   - onAdClicked: Optional callback when user clicks an ad link (defaults to opening in browser)
    ///   - onContentHeightChanged: Optional callback when ad content height is determined
    public init(
        publisherID: String,
        publisherKey: String,
        query: String,
        geo: String = "US",
        answer: String? = nil,
        adTypes: [AdType]? = nil,
        sizes: [AdSize] = [.dynamic],
        environment: APIEnvironment = .production,
        theme: String = "system",
        onAdLoaded: (() -> Void)? = nil,
        onAdClicked: ((URL) -> Void)? = nil,
        onContentHeightChanged: ((CGFloat) -> Void)? = nil
    ) {
        self.init(
            publisherID: publisherID,
            publisherKey: publisherKey,
            query: query,
            geo: geo,
            answer: answer,
            adTypes: adTypes,
            sizes: sizes,
            environment: environment,
            theme: theme,
            onAdLoaded: onAdLoaded,
            onAdClicked: onAdClicked,
            onContentHeightChanged: onContentHeightChanged,
            passback: { GistAdControl.defaultNoFillView }
        )
    }

    private static var defaultNoFillView: some View {
        Text("No ad available")
            .foregroundColor(.secondary)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Body

    public var body: some View {
        ZStack {
            switch state {
            case .loading, .loaded:
                if let currentSlot {
                    AdTagBridgeWebView(
                        html: currentSlot.html,
                        baseURLString: adTagScriptURL,
                        theme: resolvedTheme,
                        onAdRendered: { height in
                            state = .loaded(height: height)
                            onContentHeightChanged?(CGFloat(height))
                            onAdLoaded?()
                        },
                        onNoFill: {
                            state = .noFill
                        },
                        onLoadFailure: { message in
                            state = .failed(message)
                        },
                        onAdClicked: onAdClicked
                    )
                    .id(currentSlot.slotID)
                    .opacity(isLoaded ? 1 : 0)
                }
                if !isLoaded {
                    ProgressView("Loading ad...")
                }
            case .noFill:
                passback()
            case .failed(let message):
                errorView(message: message)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(minHeight: AdViewConstants.configurableMinHeight, maxHeight: AdViewConstants.configurableMaxHeight)
        .task(id: loadKey) {
            prepareSlot()
        }
    }

    private var isLoaded: Bool {
        if case .loaded = state { return true }
        return false
    }

    // MARK: - Views

    private func errorView(message: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundColor(.orange)

            Text("Unable to load ad")
                .font(.headline)

            Text(message)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            Button("Retry") {
                prepareSlot()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Methods

    /// Resolve theme to "light" or "dark" based on preference and system settings.
    ///
    /// WORKAROUND: PrtAdsTag's CSS for `data-theme="dark"` sets
    /// `color-scheme: dark` on `:root` while the wrapper is transparent and
    /// `.content-container` keeps explicit `color: #000000` for text. This
    /// produces black text on a dark canvas (invisible) for any non-`gist.ai`
    /// publisher. Until PrtAdsTag adds proper dark theme support for
    /// arbitrary publishers, we coerce "dark" to "light" here so the ad
    /// renders correctly. The surrounding app UI is unaffected -- it can
    /// still be styled dark via SwiftUI's `.preferredColorScheme`.
    private var resolvedTheme: String {
        let requested: String
        switch theme {
        case "light": requested = "light"
        case "dark": requested = "dark"
        case "system": requested = colorScheme == .dark ? "dark" : "light"
        default: requested = colorScheme == .dark ? "dark" : "light"
        }
        return requested == "dark" ? "light" : requested
    }

    /// Identity key for `.task(id:)`, capturing every parameter that should
    /// trigger a reload. SwiftUI recreates this struct with new parameter
    /// values whenever a caller updates them (e.g. `query` for a new search),
    /// but `.task` alone only fires once for the view's lifetime -- it needs
    /// an explicit `id` to react to those changes.
    var loadKey: String {
        [
            query,
            geo,
            answer ?? "",
            (adTypes?.map(\.rawValue).joined(separator: ",")) ?? "",
            sizes.map(\.displayName).joined(separator: ","),
            String(describing: environment),
            resolvedTheme
        ].joined(separator: "|")
    }

    /// Prepare (or re-prepare, on retry/param change) the WebView's bootstrap
    /// HTML: mints a fresh slot id + passback function name and builds the
    /// bootstrap HTML. This is purely local string generation -- no network
    /// call is made here or anywhere else in this control; `adtag.js` makes
    /// its own request once the resulting WebView loads. Mounting that
    /// WebView and waiting for its bridge signals is what drives `state` to
    /// `.loaded`/`.noFill` from there.
    private func prepareSlot() {
        let slotID = "pr-search-ad-\(UUID().uuidString)"
        let passbackFunctionName = "prSearchAdPassback\(UUID().uuidString.replacingOccurrences(of: "-", with: ""))"
        state = .loading
        currentSlot = nil

        do {
            let html = try SearchAdBootstrapHTML.generate(
                publisherID: publisherID,
                publisherKey: publisherKey,
                query: query,
                geo: geo,
                answer: answer,
                adTypes: adTypes,
                sizes: sizes,
                slotID: slotID,
                passbackFunctionName: passbackFunctionName,
                adTagScriptURL: adTagScriptURL
            )
            currentSlot = SearchAdSlotLoad(slotID: slotID, html: html)
        } catch {
            state = .failed(error.localizedDescription)
        }
    }

    /// Reload the ad with current configuration
    public func reload() async {
        prepareSlot()
    }
}

// MARK: - Convenience Initializers

extension GistAdControl {
    /// Initialize with specific ad types
    public static func withAdTypes(
        publisherID: String,
        publisherKey: String,
        query: String,
        geo: String = "US",
        adTypes: [AdType],
        sizes: [AdSize] = [.dynamic],
        environment: APIEnvironment = .production,
        onAdLoaded: (() -> Void)? = nil,
        onAdClicked: ((URL) -> Void)? = nil,
        onContentHeightChanged: ((CGFloat) -> Void)? = nil,
        theme: String = "system"
    ) -> GistAdControl {
        GistAdControl(
            publisherID: publisherID,
            publisherKey: publisherKey,
            query: query,
            geo: geo,
            adTypes: adTypes,
            sizes: sizes,
            environment: environment,
            theme: theme,
            onAdLoaded: onAdLoaded,
            onAdClicked: onAdClicked,
            onContentHeightChanged: onContentHeightChanged
        )
    }
}
