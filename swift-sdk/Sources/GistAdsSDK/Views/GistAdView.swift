//
//  GistAdView.swift
//  GistAdsSDK
//
//  UIKit wrapper for displaying Gist AI Search ads (Objective-C compatible).
//
//  Like `GistAdControl`, this is a pure `adtag.js` embed: it builds bootstrap
//  HTML via `SearchAdBootstrapHTML` and drives a `WKWebView` with the same
//  `AdTagBridgeCoordinator` used by the SwiftUI controls (it's a plain
//  `NSObject`-based `WKScriptMessageHandler`/`WKNavigationDelegate`/
//  `WKUIDelegate`, usable directly outside SwiftUI). No native API calls are
//  made; `adtag.js` owns the request and rendering. `sizes` is not yet
//  exposed on this Objective-C surface -- it's fixed to `[.dynamic]` -- to
//  keep this migration's ObjC-facing API change minimal; exposing it is a
//  documented follow-up if full parity is wanted.
//

#if os(iOS)
import UIKit
import WebKit

/// Wraps a WebView-level load failure message (from `AdTagBridgeCoordinator.onLoadFailure`)
/// as an `Error` for `GistAdViewDelegate.adView(_:didFailWithError:)`.
private struct AdViewLoadError: LocalizedError {
    let message: String
    var errorDescription: String? { message }
}

/// UIKit-based ad view for displaying Gist AI Search ads
/// This class is Objective-C compatible and can be used in both Swift and Objective-C projects
@objcMembers
@objc public class GistAdView: UIView {
    
    // MARK: - Public Properties
    
    /// Publisher ID for API authentication
    @objc public var publisherID: String? {
        didSet {
            if publisherID != oldValue {
                needsReload = true
            }
        }
    }
    
    /// Publisher API key for authentication. Note: unlike display ads, this
    /// is a secret credential -- embedding it here means it becomes visible
    /// in the loaded HTML/JS source, the same exposure a publisher already
    /// accepts by embedding the JS tag on a public webpage.
    @objc public var publisherKey: String? {
        didSet {
            if publisherKey != oldValue {
                needsReload = true
            }
        }
    }
    
    /// Search query to fetch relevant ads for
    @objc public var query: String? {
        didSet {
            if query != oldValue {
                needsReload = true
            }
        }
    }
    
    /// Geographic location code (e.g., "US", "GB", "CA")
    @objc public var geo: String = "US" {
        didSet {
            if geo != oldValue {
                needsReload = true
            }
        }
    }
    
    /// Array of ad types to filter (as NSNumber array of GistAdType raw values)
    @objc public var adTypes: [NSNumber]? {
        didSet {
            if adTypes != oldValue {
                needsReload = true
            }
        }
    }
    
    /// API environment (staging, integration, production)
    @objc public var environment: GistAdEnvironment = .production {
        didSet {
            if environment != oldValue {
                needsReload = true
            }
        }
    }
    
    /// Theme mode: "light", "dark", or "system" (default: "system")
    @objc public var theme: String = "system" {
        didSet {
            if theme != oldValue {
                needsReload = true
            }
        }
    }
    
    /// Delegate for ad loading callbacks
    @objc public weak var delegate: GistAdViewDelegate?
    
    // MARK: - Private Properties
    
    private var webView: WKWebView?
    private var coordinator: AdTagBridgeCoordinator?
    private var loadingIndicator: UIActivityIndicatorView?
    private var needsReload = false
    private var isLoading = false
    
    /// Resolved theme based on system appearance if theme is "system".
    ///
    /// WORKAROUND: PrtAdsTag's CSS for `data-theme="dark"` produces
    /// invisible (black-on-dark) text for any non-`gist.ai` publisher (see
    /// the same coercion in `GistAdControl.swift`). We coerce "dark" to
    /// "light" here until PrtAdsTag adds proper dark theme support for
    /// arbitrary publishers.
    private var resolvedTheme: String {
        let requested: String
        switch theme {
        case "light":
            requested = "light"
        case "dark":
            requested = "dark"
        case "system":
            requested = traitCollection.userInterfaceStyle == .dark ? "dark" : "light"
        default:
            requested = traitCollection.userInterfaceStyle == .dark ? "dark" : "light"
        }
        return requested == "dark" ? "light" : requested
    }

    /// URL of the `adtag.js` bundle to embed for this environment. Also used
    /// as the WebView's `baseURL` for `loadHTMLString`.
    private var adTagScriptURL: String {
        let base = environment.iframeBaseURL
        return base.replacingOccurrences(of: "/$", with: "", options: .regularExpression) + "/adtag.js"
    }
    
    // MARK: - Initialization
    
    /// Initialize with frame
    /// - Parameter frame: Initial frame for the view
    @objc public override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    /// Initialize from storyboard/nib
    /// - Parameter coder: NSCoder for decoding
    @objc public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    /// Convenience initializer with configuration
    /// - Parameters:
    ///   - frame: Initial frame
    ///   - publisherID: Publisher ID
    ///   - publisherKey: Publisher API key
    ///   - query: Search query
    ///   - geo: Geographic location (defaults to "US")
    @objc public convenience init(
        frame: CGRect,
        publisherID: String,
        publisherKey: String,
        query: String,
        geo: String = "US"
    ) {
        self.init(frame: frame)
        self.publisherID = publisherID
        self.publisherKey = publisherKey
        self.query = query
        self.geo = geo
    }
    
    // MARK: - Setup
    
    private func setupView() {
        backgroundColor = .clear
        
        // Setup loading indicator
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        addSubview(indicator)
        NSLayoutConstraint.activate([
            indicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        loadingIndicator = indicator
    }
    
    // MARK: - Layout
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        webView?.frame = bounds
        
        // Auto-load if needed when view appears
        if needsReload && !isLoading && canLoadAd() {
            loadAd()
        }
    }
    
    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        // Reload if theme is "system" and appearance changed
        if theme == "system" && previousTraitCollection?.userInterfaceStyle != traitCollection.userInterfaceStyle {
            needsReload = true
            if !isLoading && canLoadAd() {
                loadAd()
            }
        }
    }
    
    // MARK: - Public Methods
    
    /// Load the ad with current configuration
    @objc public func loadAd() {
        guard canLoadAd() else {
            return
        }
        
        guard !isLoading else {
            return
        }
        
        isLoading = true
        needsReload = false
        
        // Show loading indicator
        loadingIndicator?.startAnimating()
        delegate?.adViewDidStartLoading?(self)
        
        let slotID = "pr-search-ad-\(UUID().uuidString)"
        let passbackFunctionName = "prSearchAdPassback\(UUID().uuidString.replacingOccurrences(of: "-", with: ""))"
        let swiftAdTypes = convertAdTypes(adTypes)
        
        do {
            let html = try SearchAdBootstrapHTML.generate(
                publisherID: publisherID ?? "",
                publisherKey: publisherKey ?? "",
                query: query ?? "",
                geo: geo,
                adTypes: swiftAdTypes,
                sizes: [.dynamic],
                slotID: slotID,
                passbackFunctionName: passbackFunctionName,
                adTagScriptURL: adTagScriptURL
            )
            loadHTML(html)
        } catch {
            handleError(error)
        }
    }
    
    /// Reload the ad with current configuration
    @objc public func reload() {
        loadAd()
    }
    
    // MARK: - Private Methods
    
    private func canLoadAd() -> Bool {
        return publisherID != nil &&
               publisherKey != nil &&
               query != nil &&
               !query!.isEmpty
    }
    
    private func loadHTML(_ html: String) {
        if webView == nil {
            setupWebView()
        }
        guard let webView = webView else { return }
        let baseURL = URL(string: adTagScriptURL) ?? URL(string: "about:blank")!
        applyThemeToWebView(webView, theme: resolvedTheme)
        webView.loadHTMLString(html, baseURL: baseURL)
    }
    
    private func setupWebView() {
        let coordinator = AdTagBridgeCoordinator()
        coordinator.onAdRendered = { [weak self] height in
            self?.handleAdRendered(height: height)
        }
        coordinator.onNoFill = { [weak self] in
            self?.handleNoFill()
        }
        coordinator.onLoadFailure = { [weak self] message in
            self?.handleError(AdViewLoadError(message: message))
        }
        coordinator.onAdClicked = { [weak self] url in
            self?.handleClickURL(url)
        }
        self.coordinator = coordinator
        
        let configuration = WKWebViewConfiguration()
        configuration.userContentController.add(coordinator, name: AdTagBridgeMessage.adRendered)
        configuration.userContentController.add(coordinator, name: AdTagBridgeMessage.noFill)
        
        let webView = WKWebView(frame: bounds, configuration: configuration)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.navigationDelegate = coordinator
        webView.uiDelegate = coordinator
        configureWebView(webView, isIOS: true)
        
        addSubview(webView)
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: topAnchor),
            webView.leadingAnchor.constraint(equalTo: leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        self.webView = webView
    }
    
    private func handleAdRendered(height: Double) {
        isLoading = false
        loadingIndicator?.stopAnimating()
        delegate?.adViewDidLoad?(self)
        delegate?.adView?(self, didLoadWithContentHeight: CGFloat(height))
    }
    
    private func handleNoFill() {
        isLoading = false
        loadingIndicator?.stopAnimating()
        delegate?.adViewDidReceiveNoFill?(self)
    }
    
    private func handleError(_ error: Error) {
        isLoading = false
        loadingIndicator?.stopAnimating()
        teardownWebView()
        delegate?.adView?(self, didFailWithError: error)
    }
    
    private func teardownWebView() {
        webView?.configuration.userContentController.removeScriptMessageHandler(forName: AdTagBridgeMessage.adRendered)
        webView?.configuration.userContentController.removeScriptMessageHandler(forName: AdTagBridgeMessage.noFill)
        webView?.removeFromSuperview()
        webView = nil
        coordinator = nil
    }
    
    private func handleClickURL(_ url: URL) {
        // Try calling the delegate method - returns Void? (nil if not implemented)
        if delegate?.adView?(self, didClickURL: url) == nil {
            // Delegate method not implemented, open in Safari
            DispatchQueue.main.async {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
}

#endif // os(iOS)
