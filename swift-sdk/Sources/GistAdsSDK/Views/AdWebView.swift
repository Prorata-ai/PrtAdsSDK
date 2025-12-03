//
//  AdWebView.swift
//  GistAdsSDK
//
//  WebKit-based view for rendering ads in iframe mode
//

import SwiftUI
import WebKit

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
/// - Parameters:
///   - webView: The WebView to configure
///   - isIOS: Whether this is for iOS (affects configuration)
private func configureWebView(_ webView: WKWebView, isIOS: Bool) {
    #if os(iOS)
    webView.scrollView.isScrollEnabled = false
    webView.isOpaque = false
    webView.backgroundColor = .clear
    #endif
    
    webView.navigationDelegate = NavigationDelegate.shared
    
    if isIOS {
        #if os(iOS)
        webView.configuration.allowsInlineMediaPlayback = true
        #endif
    }
    webView.configuration.mediaTypesRequiringUserActionForPlayback = []
}

// MARK: - Navigation Delegate

// Navigation delegate to allow iframe navigation
private class NavigationDelegate: NSObject, WKNavigationDelegate {
    static let shared = NavigationDelegate()
    
    private override init() {
        super.init()
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        // Ensure we always call the decision handler exactly once
        // Allow all navigation, including subframes (iframes)
        let policy: WKNavigationActionPolicy = .allow
        decisionHandler(policy)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        // Always allow navigation responses
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        // Navigation failed - silently handle
        // This is expected for cross-origin iframes that may fail to load
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        // Navigation failed - silently handle
        // This is expected for cross-origin iframes that may fail to load
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // Navigation completed successfully
    }
}

#if os(iOS)
/// SwiftUI wrapper for WKWebView to render ads
struct AdWebView: UIViewRepresentable {
    let htmlContent: String
    
    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: configuration)
        configureWebView(webView, isIOS: true)
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        // Ensure navigation delegate is set
        if webView.navigationDelegate == nil {
            configureWebView(webView, isIOS: true)
        }
        
        // Always reload to ensure content is updated
        let html = wrappedHTML(content: htmlContent, isIOS: true)
        let baseURL = URL(string: APIConstants.iframeBaseURL) ?? URL(string: "about:blank")!
        webView.loadHTMLString(html, baseURL: baseURL)
    }
}

#elseif os(macOS)
/// SwiftUI wrapper for WKWebView to render ads (macOS)
struct AdWebView: NSViewRepresentable {
    let htmlContent: String
    
    func makeNSView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: configuration)
        configureWebView(webView, isIOS: false)
        return webView
    }
    
    func updateNSView(_ webView: WKWebView, context: Context) {
        // Ensure navigation delegate is set
        if webView.navigationDelegate == nil {
            configureWebView(webView, isIOS: false)
        }
        
        let html = wrappedHTML(content: htmlContent, isIOS: false)
        let baseURL = URL(string: APIConstants.iframeBaseURL) ?? URL(string: "about:blank")!
        webView.loadHTMLString(html, baseURL: baseURL)
    }
}
#endif

