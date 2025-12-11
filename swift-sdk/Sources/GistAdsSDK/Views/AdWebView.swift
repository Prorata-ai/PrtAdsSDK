//
//  AdWebView.swift
//  GistAdsSDK
//
//  WebKit-based view for rendering ads in iframe mode
//

import SwiftUI
import WebKit

#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

// MARK: - Shared Helpers

/// Generate wrapped HTML for ad content
/// - Parameters:
///   - content: The ad HTML content to wrap
///   - isIOS: Whether this is for iOS (affects viewport meta tag)
/// - Returns: Complete HTML document string
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

/// Configure WebView with common settings
private func configureWebView(_ webView: WKWebView, isIOS: Bool) {
    #if os(iOS)
    webView.scrollView.isScrollEnabled = false
    webView.isOpaque = false
    webView.backgroundColor = .clear
    webView.configuration.allowsInlineMediaPlayback = true
    #endif
    
    webView.configuration.mediaTypesRequiringUserActionForPlayback = []
}

/// Create and configure a new WKWebView with the given delegate
private func createWebView(delegate: NavigationDelegate?, isIOS: Bool) -> WKWebView {
    let configuration = WKWebViewConfiguration()
    let webView = WKWebView(frame: .zero, configuration: configuration)
    webView.navigationDelegate = delegate
    configureWebView(webView, isIOS: isIOS)
    return webView
}

/// Update the webview with new content and callbacks
private func updateWebView(
    _ webView: WKWebView,
    coordinator: AdWebViewCoordinator,
    htmlContent: String,
    baseURL: URL,
    onAdClicked: ((URL) -> Void)?,
    onContentHeightChanged: ((CGFloat) -> Void)?,
    isIOS: Bool
) {
    // Ensure navigation delegate is set
    if webView.navigationDelegate !== coordinator.delegate {
        webView.navigationDelegate = coordinator.delegate
    }
    
    // Update callbacks in case they changed
    coordinator.delegate?.onAdClicked = onAdClicked
    coordinator.delegate?.onContentHeightChanged = onContentHeightChanged
    
    // Only reload if content has changed
    if coordinator.lastContent != htmlContent {
        coordinator.lastContent = htmlContent
        let html = wrappedHTML(content: htmlContent, isIOS: isIOS)
        webView.loadHTMLString(html, baseURL: baseURL)
    }
}

// MARK: - Shared Coordinator

/// Coordinator for AdWebView that holds the navigation delegate and tracks content state
class AdWebViewCoordinator {
    var lastContent: String?
    fileprivate var delegate: NavigationDelegate?
    
    fileprivate init(onAdClicked: ((URL) -> Void)?, onContentHeightChanged: ((CGFloat) -> Void)?) {
        let navDelegate = NavigationDelegate()
        navDelegate.onAdClicked = onAdClicked
        navDelegate.onContentHeightChanged = onContentHeightChanged
        self.delegate = navDelegate
    }
}

// MARK: - Navigation Delegate

/// Navigation delegate to handle iframe navigation, click events, and content height
fileprivate class NavigationDelegate: NSObject, WKNavigationDelegate {
    var onAdClicked: ((URL) -> Void)?
    var onContentHeightChanged: ((CGFloat) -> Void)?
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url else {
            decisionHandler(.allow)
            return
        }
        
        // Allow navigation for non-http schemes (about:blank, etc.)
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
        
        // External URL clicked - cancel navigation and handle
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
                  error == nil,
                  let height = result as? CGFloat else {
                return
            }
            
            DispatchQueue.main.async {
                self.onContentHeightChanged?(height)
            }
        }
    }
    
    private func handleExternalURL(_ url: URL) {
        if let onAdClicked = onAdClicked {
            DispatchQueue.main.async {
                onAdClicked(url)
            }
        } else {
            // Default behavior: open in default browser
            DispatchQueue.main.async {
                #if os(iOS)
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                #elseif os(macOS)
                NSWorkspace.shared.open(url)
                #endif
            }
        }
    }
}

// MARK: - Platform-Specific AdWebView

#if os(iOS)

/// SwiftUI wrapper for WKWebView to render ads (iOS)
struct AdWebView: UIViewRepresentable {
    let htmlContent: String
    let iframeBaseURL: String
    var onAdClicked: ((URL) -> Void)?
    var onContentHeightChanged: ((CGFloat) -> Void)?
    
    private var baseURL: URL {
        URL(string: iframeBaseURL) ?? URL(string: "about:blank")!
    }
    
    func makeCoordinator() -> AdWebViewCoordinator {
        AdWebViewCoordinator(onAdClicked: onAdClicked, onContentHeightChanged: onContentHeightChanged)
    }
    
    func makeUIView(context: Context) -> WKWebView {
        createWebView(delegate: context.coordinator.delegate, isIOS: true)
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        updateWebView(webView, coordinator: context.coordinator, htmlContent: htmlContent, baseURL: baseURL, onAdClicked: onAdClicked, onContentHeightChanged: onContentHeightChanged, isIOS: true)
    }
}

#elseif os(macOS)

/// SwiftUI wrapper for WKWebView to render ads (macOS)
struct AdWebView: NSViewRepresentable {
    let htmlContent: String
    let iframeBaseURL: String
    var onAdClicked: ((URL) -> Void)?
    var onContentHeightChanged: ((CGFloat) -> Void)?
    
    private var baseURL: URL {
        URL(string: iframeBaseURL) ?? URL(string: "about:blank")!
    }
    
    func makeCoordinator() -> AdWebViewCoordinator {
        AdWebViewCoordinator(onAdClicked: onAdClicked, onContentHeightChanged: onContentHeightChanged)
    }
    
    func makeNSView(context: Context) -> WKWebView {
        createWebView(delegate: context.coordinator.delegate, isIOS: false)
    }
    
    func updateNSView(_ webView: WKWebView, context: Context) {
        updateWebView(webView, coordinator: context.coordinator, htmlContent: htmlContent, baseURL: baseURL, onAdClicked: onAdClicked, onContentHeightChanged: onContentHeightChanged, isIOS: false)
    }
}

#endif
