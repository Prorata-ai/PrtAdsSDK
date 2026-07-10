//
//  GistDisplayAdControl.swift
//  GistAdsSDK
//
//  Main ad control for displaying Gist contextual display ads: image/text/
//  CTA ads targeted by publisher ID + page URL + size, mirroring the web
//  tag's `defineSlot({id, url}, slotId, sizes)` -> `displayAd(slotId)` flow.
//

import SwiftUI

/// Main control for displaying Gist contextual display ads.
///
/// Unlike `GistAdControl` (search ads, gated by a secret publisher key),
/// display ads are targeted purely by publisher ID + page URL + size, and
/// the backend does not require a publisher key -- see the contract notes
/// at the top of `DisplayAdAPIService.swift`.
public struct GistDisplayAdControl: View {

    /// Environment configuration for the Display Ad API endpoint.
    public enum APIEnvironment: Hashable {
        case staging
        case integration
        case production

        /// Base URL for the environment (internal)
        /// Can be overridden via environment variables: GIST_ADS_DISPLAY_STAGING_URL,
        /// GIST_ADS_DISPLAY_INTEGRATION_URL, GIST_ADS_DISPLAY_PRODUCTION_URL
        internal var baseURL: String {
            DisplayAPIConstants.baseURL(for: self)
        }
    }

    // MARK: - Configuration Properties

    private let publisherID: String
    private let pageURL: String
    private let sizes: [AdSize]
    private let environment: APIEnvironment
    private let theme: String

    /// Optional publisher-provided key-value data (e.g. `["category": "sports",
    /// "keywords": ["nfl", "playoffs"]]`) sent to the backend for LLM context.
    ///
    /// `pageURL` alone works well for a real webpage, which the backend can
    /// crawl to infer relevance. A native screen has no crawlable HTML, so
    /// `context` is the way to hand over that signal explicitly instead --
    /// see the contract notes at the top of `DisplayAdAPIService.swift`.
    private let context: [String: Any]?

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

    @State private var state: DisplayAdLoadState = .loading
    @Environment(\.colorScheme) var colorScheme: ColorScheme

    private let apiService: DisplayAdAPIService

    // MARK: - Initialization

    /// Initialize the Gist display ad control with custom no-fill content.
    /// - Parameters:
    ///   - publisherID: Your publisher ID
    ///   - pageURL: The current page/context URL to target the ad against (mirrors `url` in `defineSlot`)
    ///   - sizes: One or more supported ad sizes (mirrors `sizes` in `defineSlot`)
    ///   - environment: API environment (defaults to production)
    ///   - theme: Theme preference - "light", "dark", or "system" (defaults to "system" for auto-detection)
    ///   - context: Optional publisher-provided key-value data (category, keywords, section, etc.)
    ///     sent to the backend for LLM context -- especially useful for native screens, which have
    ///     no crawlable HTML for the backend to infer relevance from via `pageURL` alone.
    ///   - onAdLoaded: Optional callback when ad successfully loads
    ///   - onAdClicked: Optional callback when user clicks the ad (defaults to opening in browser)
    ///   - onContentHeightChanged: Optional callback when ad content height is determined
    ///   - passback: View builder shown when no ad is available (no-fill), mirroring `definePassbackFunction`
    public init<Passback: View>(
        publisherID: String,
        pageURL: String,
        sizes: [AdSize],
        environment: APIEnvironment = .production,
        theme: String = "system",
        context: [String: Any]? = nil,
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
        self.context = context
        self.onAdLoaded = onAdLoaded
        self.onAdClicked = onAdClicked
        self.onContentHeightChanged = onContentHeightChanged
        self.passback = { AnyView(passback()) }
        self.apiService = DisplayAdAPIService(baseURL: environment.baseURL, publisherID: publisherID)
    }

    /// Initialize the Gist display ad control with a built-in "No ad available" fallback.
    /// - Parameters:
    ///   - publisherID: Your publisher ID
    ///   - pageURL: The current page/context URL to target the ad against (mirrors `url` in `defineSlot`)
    ///   - sizes: One or more supported ad sizes (mirrors `sizes` in `defineSlot`)
    ///   - environment: API environment (defaults to production)
    ///   - theme: Theme preference - "light", "dark", or "system" (defaults to "system" for auto-detection)
    ///   - context: Optional publisher-provided key-value data (category, keywords, section, etc.)
    ///     sent to the backend for LLM context -- especially useful for native screens, which have
    ///     no crawlable HTML for the backend to infer relevance from via `pageURL` alone.
    ///   - onAdLoaded: Optional callback when ad successfully loads
    ///   - onAdClicked: Optional callback when user clicks the ad (defaults to opening in browser)
    ///   - onContentHeightChanged: Optional callback when ad content height is determined
    public init(
        publisherID: String,
        pageURL: String,
        sizes: [AdSize],
        environment: APIEnvironment = .production,
        theme: String = "system",
        context: [String: Any]? = nil,
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
            context: context,
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
            case .loading:
                ProgressView("Loading ad...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            case .failed(let message):
                errorView(message: message)
            case .loaded(let content):
                AdWebView(
                    htmlContent: content,
                    iframeBaseURL: environment.baseURL,
                    theme: resolvedTheme,
                    onAdClicked: onAdClicked,
                    onContentHeightChanged: onContentHeightChanged
                )
                .frame(maxWidth: .infinity)
                .frame(minHeight: AdViewConstants.configurableMinHeight, maxHeight: AdViewConstants.configurableMaxHeight)
            case .noFill:
                passback()
            }
        }
        .task {
            await loadAd()
        }
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
                Task {
                    await loadAd()
                }
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

    /// Load ad from the Display Ad API
    private func loadAd() async {
        state = .loading

        let result: Result<String, Error>
        do {
            let content = try await apiService.fetchAd(pageURL: pageURL, sizes: sizes, theme: resolvedTheme, context: context)
            result = .success(content)
        } catch {
            result = .failure(error)
        }

        let newState = DisplayAdLoadState.from(result: result)

        await MainActor.run {
            self.state = newState
            if case .loaded = newState {
                self.onAdLoaded?()
            }
        }
    }

    /// Reload the ad with current configuration
    public func reload() async {
        await loadAd()
    }
}
