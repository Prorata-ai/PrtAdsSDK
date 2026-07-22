//
//  GistDisplayAdControl.swift
//  GistAdsSDK
//
//  Main ad control for displaying Gist contextual display ads: embeds the
//  real `adtag.js` script in a WebView and drives it via
//  `defineSlot({id, url}, slotId, sizes)` -> `displayAd(slotId)`, mirroring
//  exactly how a publisher's own webpage would embed the tag directly.
//
//  This control is a thin wrapper around that HTML/JS embed: it makes no
//  API calls of its own. `adtag.js` owns the entire ad request, response
//  parsing, and rendering, so as the tag and backend evolve, this control
//  keeps working without needing to track along. (An earlier revision
//  fetched ads natively to support a `context` targeting param that
//  `adtag.js`'s own request has no field for; that param has been removed
//  so this control can stay a pure embed -- see PR #7 review discussion.)
//

import SwiftUI

/// Main control for displaying Gist contextual display ads.
///
/// Unlike `GistAdControl` (search ads, gated by a secret publisher key),
/// display ads are targeted purely by publisher ID + page URL + size, and
/// the backend does not require a publisher key.
public struct GistDisplayAdControl: View {

    // MARK: - Configuration Properties

    private let publisherID: String
    private let pageURL: String
    private let sizes: [AdSize]
    private let environment: GistAdControl.APIEnvironment
    private let theme: String

    // MARK: - Callbacks

    /// Called when the ad has successfully loaded and is ready to display.
    private let onAdLoaded: (() -> Void)?

    /// Called when the user clicks the ad, navigating to an external URL.
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

    private struct DisplayAdSlotLoad: Equatable {
        let slotID: String
        let html: String
    }

    @State private var state: AdTagLoadState = .loading
    @State private var currentSlot: DisplayAdSlotLoad?
    @Environment(\.colorScheme) var colorScheme: ColorScheme

    /// URL of the `adtag.js` bundle to embed for this environment. Reuses
    /// the same host (and override env vars) as search ads' iframe base
    /// URL, since `adtag.js` is one bundle serving both ad types
    /// (distinguished by whether `api_key` is passed to `defineSlot`). Also
    /// used as the WebView's `baseURL` for `loadHTMLString`, which is why
    /// this host must stay in `APIConstants.allowedAdDomains`.
    private var adTagScriptURL: String {
        let base = APIConstants.iframeBaseURL(for: environment)
        return base.replacingOccurrences(of: "/$", with: "", options: .regularExpression) + "/adtag.js"
    }

    // MARK: - Initialization

    /// Initialize the Gist display ad control with custom no-fill content.
    /// - Parameters:
    ///   - publisherID: Your publisher ID
    ///   - pageURL: The current page/context URL to target the ad against (mirrors `url` in
    ///     `defineSlot`). Must not be blank -- a blank value surfaces as a `.failed` state (with
    ///     retry) rather than silently sending an empty `url` to `adtag.js`.
    ///   - sizes: One or more supported ad sizes (mirrors `sizes` in `defineSlot`)
    ///   - environment: API environment (defaults to production)
    ///   - theme: Theme preference - "light", "dark", or "system" (defaults to "system" for auto-detection)
    ///   - onAdLoaded: Optional callback when ad successfully loads
    ///   - onAdClicked: Optional callback when user clicks the ad (defaults to opening in browser)
    ///   - onContentHeightChanged: Optional callback when ad content height is determined
    ///   - passback: View builder shown when no ad is available (no-fill), mirroring `definePassbackFunction`
    public init<Passback: View>(
        publisherID: String,
        pageURL: String,
        sizes: [AdSize],
        environment: GistAdControl.APIEnvironment = .production,
        theme: String = "system",
        onAdLoaded: (() -> Void)? = nil,
        onAdClicked: ((URL) -> Void)? = nil,
        onContentHeightChanged: ((CGFloat) -> Void)? = nil,
        @ViewBuilder passback: @escaping () -> Passback
    ) {
        self.publisherID = publisherID
        self.pageURL = pageURL
        self.sizes = sizes
        self.environment = environment
        self.theme = theme
        self.onAdLoaded = onAdLoaded
        self.onAdClicked = onAdClicked
        self.onContentHeightChanged = onContentHeightChanged
        self.passback = { AnyView(passback()) }
    }

    /// Initialize the Gist display ad control with a built-in "No ad available" fallback.
    /// - Parameters:
    ///   - publisherID: Your publisher ID
    ///   - pageURL: The current page/context URL to target the ad against (mirrors `url` in
    ///     `defineSlot`). Must not be blank -- a blank value surfaces as a `.failed` state (with
    ///     retry) rather than silently sending an empty `url` to `adtag.js`.
    ///   - sizes: One or more supported ad sizes (mirrors `sizes` in `defineSlot`)
    ///   - environment: API environment (defaults to production)
    ///   - theme: Theme preference - "light", "dark", or "system" (defaults to "system" for auto-detection)
    ///   - onAdLoaded: Optional callback when ad successfully loads
    ///   - onAdClicked: Optional callback when user clicks the ad (defaults to opening in browser)
    ///   - onContentHeightChanged: Optional callback when ad content height is determined
    public init(
        publisherID: String,
        pageURL: String,
        sizes: [AdSize],
        environment: GistAdControl.APIEnvironment = .production,
        theme: String = "system",
        onAdLoaded: (() -> Void)? = nil,
        onAdClicked: ((URL) -> Void)? = nil,
        onContentHeightChanged: ((CGFloat) -> Void)? = nil
    ) {
        self.init(
            publisherID: publisherID,
            pageURL: pageURL,
            sizes: sizes,
            environment: environment,
            theme: theme,
            onAdLoaded: onAdLoaded,
            onAdClicked: onAdClicked,
            onContentHeightChanged: onContentHeightChanged,
            passback: { GistDisplayAdControl.defaultNoFillView }
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
    private var resolvedTheme: String {
        switch theme {
        case "light": return "light"
        case "dark": return "dark"
        case "system": return colorScheme == .dark ? "dark" : "light"
        default: return colorScheme == .dark ? "dark" : "light"
        }
    }

    /// Identity key for `.task(id:)`, capturing every parameter that should
    /// trigger a reload. SwiftUI recreates this struct with new parameter
    /// values whenever a caller updates them (e.g. `pageURL` for a new
    /// article in a scrolling feed), but `.task` alone only fires once for
    /// the view's lifetime -- it needs an explicit `id` to react to those
    /// changes.
    var loadKey: String {
        [
            pageURL,
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
        let slotID = "pr-display-ad-\(UUID().uuidString)"
        let passbackFunctionName = "prDisplayAdPassback\(UUID().uuidString.replacingOccurrences(of: "-", with: ""))"
        state = .loading
        currentSlot = nil

        do {
            let html = try DisplayAdBootstrapHTML.generate(
                publisherID: publisherID,
                pageURL: pageURL,
                sizes: sizes,
                slotID: slotID,
                passbackFunctionName: passbackFunctionName,
                adTagScriptURL: adTagScriptURL
            )
            currentSlot = DisplayAdSlotLoad(slotID: slotID, html: html)
        } catch {
            state = .failed(error.localizedDescription)
        }
    }

    /// Reload the ad with current configuration
    public func reload() async {
        prepareSlot()
    }
}
