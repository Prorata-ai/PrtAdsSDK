//
//  GistAdControl.swift
//  GistAdsSDK
//
//  Main ad control for displaying Gist AI Search ads
//

import SwiftUI

/// Main control for displaying Gist AI Search ads
public struct GistAdControl: View {
    
    /// Environment configuration for API endpoints
    public enum APIEnvironment {
        case staging
        case integration
        case production
        
        /// Base URL for the environment (internal)
        /// Can be overridden via environment variables: GIST_ADS_STAGING_URL, GIST_ADS_INTEGRATION_URL, GIST_ADS_PRODUCTION_URL
        internal var baseURL: String {
            APIConstants.baseURL(for: self)
        }
        
        /// Iframe base URL for the environment (internal)
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
    private let adTypes: [AdType]?
    private let environment: APIEnvironment
    private let apiVersion: String?
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
    
    // MARK: - State
    
    @State private var adContent: String?
    @State private var isLoading = false
    @State private var error: Error?
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    
    private let apiService: AdAPIService
    
    // MARK: - Initialization
    
    /// Initialize the Gist ad control
    /// - Parameters:
    ///   - publisherID: Your publisher ID
    ///   - publisherKey: Your publisher API key
    ///   - query: The search query to fetch ads for
    ///   - geo: Geographic location code (e.g., "US", "GB")
    ///   - adTypes: Optional array of ad types to filter (defaults to all types)
    ///   - environment: API environment (defaults to production)
    ///   - apiVersion: API version to use (defaults to v2, or from GIST_ADS_API_VERSION env var)
    ///   - onAdLoaded: Optional callback when ad successfully loads
    ///   - onAdClicked: Optional callback when user clicks an ad link (defaults to opening in browser)
    ///   - onContentHeightChanged: Optional callback when ad content height is determined
    ///   - theme: Theme preference - "light", "dark", or "system" (defaults to "system" for auto-detection)
    public init(
        publisherID: String,
        publisherKey: String,
        query: String,
        geo: String = "US",
        adTypes: [AdType]? = nil,
        environment: APIEnvironment = .production,
        apiVersion: String? = nil,
        onAdLoaded: (() -> Void)? = nil,
        onAdClicked: ((URL) -> Void)? = nil,
        onContentHeightChanged: ((CGFloat) -> Void)? = nil,
        theme: String = "system"
    ) {
        self.publisherID = publisherID
        self.publisherKey = publisherKey
        self.query = query
        self.geo = geo
        self.adTypes = adTypes
        self.environment = environment
        self.apiVersion = apiVersion
        self.onAdLoaded = onAdLoaded
        self.onAdClicked = onAdClicked
        self.onContentHeightChanged = onContentHeightChanged
        self.theme = theme
        
        self.apiService = AdAPIService(
            baseURL: environment.baseURL,
            publisherID: publisherID,
            publisherKey: publisherKey,
            apiVersion: apiVersion
        )
    }
    
    // MARK: - Body
    
    public var body: some View {
        ZStack {
            if isLoading {
                ProgressView("Loading ad...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let error = error {
                errorView(error: error)
            } else if let adContent = adContent {
                AdWebView(
                    htmlContent: adContent,
                    iframeBaseURL: environment.iframeBaseURL,
                    theme: resolvedTheme,
                    onAdClicked: onAdClicked,
                    onContentHeightChanged: onContentHeightChanged
                )
                .frame(maxWidth: .infinity)
                .frame(minHeight: AdViewConstants.configurableMinHeight, maxHeight: AdViewConstants.configurableMaxHeight)
            } else {
                emptyView
            }
        }
        .task {
            await loadAd()
        }
    }
    
    // MARK: - Views
    
    private var emptyView: some View {
        Text("No ad available")
            .foregroundColor(.secondary)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func errorView(error: Error) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundColor(.orange)
            
            Text("Unable to load ad")
                .font(.headline)
            
            Text(error.localizedDescription)
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
    ///
    /// WORKAROUND: PrtAdsTag's CSS for `data-theme="dark"` sets
    /// `color-scheme: dark` on `:root` while the wrapper is transparent and
    /// `.content-container` keeps explicit `color: #000000` for text. This
    /// produces black text on a dark canvas (invisible) for any non-`gist.ai`
    /// publisher. Until PrtAdsTag adds proper dark theme support for
    /// arbitrary publishers, we coerce "dark" to "light" here so the ad
    /// renders correctly. The surrounding app UI is unaffected — it can
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
    
    /// Load ad from API
    private func loadAd() async {
        isLoading = true
        error = nil
        
        do {
            let content = try await apiService.fetchAd(
                query: query,
                geo: geo,
                adTypes: adTypes,
                theme: resolvedTheme
            )
            
            await MainActor.run {
                self.adContent = content
                self.isLoading = false
                self.onAdLoaded?()
            }
        } catch {
            await MainActor.run {
                self.error = error
                self.isLoading = false
            }
        }
    }
    
    /// Reload the ad with current configuration
    public func reload() async {
        await loadAd()
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
        environment: APIEnvironment = .production,
        apiVersion: String? = nil,
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
            environment: environment,
            apiVersion: apiVersion,
            onAdLoaded: onAdLoaded,
            onAdClicked: onAdClicked,
            onContentHeightChanged: onContentHeightChanged,
            theme: theme
        )
    }
}

