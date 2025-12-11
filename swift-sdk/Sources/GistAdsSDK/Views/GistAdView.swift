//
//  GistAdView.swift
//  GistAdsSDK
//
//  UIKit wrapper for displaying Gist AI Search ads (Objective-C compatible)
//

#if os(iOS)
import UIKit
import WebKit

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
    
    /// Publisher API key for authentication
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
    
    /// API version to use (e.g., "v1", "v2")
    @objc public var apiVersion: String? {
        didSet {
            if apiVersion != oldValue {
                needsReload = true
            }
        }
    }
    
    /// Delegate for ad loading callbacks
    @objc public weak var delegate: GistAdViewDelegate?
    
    // MARK: - Private Properties
    
    private var webView: WKWebView?
    private var loadingIndicator: UIActivityIndicatorView?
    private var apiService: AdAPIService?
    private var needsReload = false
    private var isLoading = false
    private var lastContent: String?
    
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
        
        // Setup API service if needed
        if apiService == nil || needsNewAPIService() {
            setupAPIService()
        }
        
        guard let apiService = apiService else {
            handleError(AdAPIError.invalidURL)
            return
        }
        
        // Show loading indicator
        loadingIndicator?.startAnimating()
        delegate?.adViewDidStartLoading?(self)
        
        // Convert ad types
        let swiftAdTypes = convertAdTypes(adTypes)
        
        // Fetch ad
        Task {
            do {
                let content = try await apiService.fetchAd(
                    query: query!,
                    geo: geo,
                    adTypes: swiftAdTypes
                )
                
                await MainActor.run {
                    self.handleSuccess(content: content)
                }
            } catch {
                await MainActor.run {
                    self.handleError(error)
                }
            }
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
    
    private func needsNewAPIService() -> Bool {
        // API service needs to be recreated if environment or API version changed
        // This is handled by checking if setupAPIService was called with different params
        return true // Always recreate for simplicity
    }
    
    private func setupAPIService() {
        guard let publisherID = publisherID,
              let publisherKey = publisherKey else {
            return
        }
        
        let baseURL = environment.baseURL
        apiService = AdAPIService(
            baseURL: baseURL,
            publisherID: publisherID,
            publisherKey: publisherKey,
            apiVersion: apiVersion
        )
    }
    
    private func handleSuccess(content: String) {
        isLoading = false
        loadingIndicator?.stopAnimating()
        
        // Load content if it changed
        let contentChanged = lastContent != content
        lastContent = content
        
        // Setup web view if needed
        if webView == nil {
            setupWebView()
        }
        
        // Load content if web view exists and content changed
        if let webView = webView, contentChanged {
            loadContent(content, in: webView)
        }
        
        delegate?.adViewDidLoad?(self)
    }
    
    private func handleError(_ error: Error) {
        isLoading = false
        loadingIndicator?.stopAnimating()
        
        // Show error state
        showErrorState(error: error)
        
        delegate?.adView?(self, didFailWithError: error)
    }
    
    private func setupWebView() {
        let configuration = WKWebViewConfiguration()
        let webView = WKWebView(frame: bounds, configuration: configuration)
        
        // Configure web view
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.scrollView.isScrollEnabled = false
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.configuration.allowsInlineMediaPlayback = true
        webView.configuration.mediaTypesRequiringUserActionForPlayback = []
        
        // Setup navigation delegate with reference to this ad view
        let navDelegate = NavigationDelegate()
        navDelegate.adView = self
        webView.navigationDelegate = navDelegate
        
        // Store delegate to prevent deallocation
        objc_setAssociatedObject(webView, &AssociatedKeys.navigationDelegate, navDelegate, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        
        addSubview(webView)
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: topAnchor),
            webView.leadingAnchor.constraint(equalTo: leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        self.webView = webView
    }
    
    private func loadContent(_ content: String, in webView: WKWebView) {
        let html = wrappedHTML(content: content, isIOS: true)
        let baseURL = URL(string: environment.iframeBaseURL) ?? URL(string: "about:blank")!
        webView.loadHTMLString(html, baseURL: baseURL)
    }
    
    private func showErrorState(error: Error) {
        // Remove web view if showing error
        webView?.removeFromSuperview()
        webView = nil
        
        // Could add error label here if needed
        // For now, just clear the view
    }
    
    // MARK: - HTML Generation (reused from AdWebView)
    
    private func wrappedHTML(content: String, isIOS: Bool) -> String {
        let viewport = isIOS
            ? "width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no"
            : "width=device-width, initial-scale=1.0"
        
        let adContentDiv = isIOS
            ? "<div class=\"ad-content\">\(content)</div>"
            : content
        
        return """
        <!DOCTYPE html>
        <html>
            <head>
                <meta name="viewport" content="\(viewport)">
                <style>
                    * {
                        margin: 0;
                        padding: 0;
                        box-sizing: border-box;
                    }
                    body {
                        background: transparent;
                        overflow: hidden;
                        font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
                    }
                    .ad-container {
                        width: 100%;
                        display: flex;
                        justify-content: center;
                        align-items: center;
                        padding: 8px;
                    }
                    \(isIOS ? """
                    .ad-content {
                        width: 100%;
                        max-width: 600px;
                    }
                    """ : "")
                </style>
            </head>
            <body>
                <div class="ad-container">
                    \(adContentDiv)
                </div>
            </body>
        </html>
        """
    }
}

// MARK: - Navigation Delegate

private class NavigationDelegate: NSObject, WKNavigationDelegate {
    weak var adView: GistAdView?
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url else {
            decisionHandler(.allow)
            return
        }
        
        // Allow navigation for ad server domains and non-http schemes (about:blank, etc.)
        let scheme = url.scheme?.lowercased() ?? ""
        if scheme != "http" && scheme != "https" {
            decisionHandler(.allow)
            return
        }
        
        // Allow navigation for allowed ad domains
        if APIConstants.isAllowedAdDomain(url) {
            decisionHandler(.allow)
            return
        }
        
        // External URL clicked - cancel navigation and notify delegate
        decisionHandler(.cancel)
        handleExternalURL(url)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // Measure content height after navigation finishes
        webView.evaluateJavaScript("document.documentElement.scrollHeight") { [weak self] result, error in
            guard let self = self,
                  let adView = self.adView,
                  error == nil,
                  let height = result as? CGFloat else {
                return
            }
            
            DispatchQueue.main.async {
                adView.delegate?.adView?(adView, didLoadWithContentHeight: height)
            }
        }
    }
    
    private func handleExternalURL(_ url: URL) {
        guard let adView = adView else { return }
        
        // Try calling the delegate method - returns Void? (nil if not implemented)
        if adView.delegate?.adView?(adView, didClickURL: url) == nil {
            // Delegate method not implemented, open in Safari
            DispatchQueue.main.async {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
}

// MARK: - Associated Keys

private struct AssociatedKeys {
    static var navigationDelegate: UInt8 = 0
}

#endif // os(iOS)

