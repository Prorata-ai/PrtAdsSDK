//
//  AdWebView.swift
//  GistAdsSDK
//
//  WebKit-based view for rendering ads in iframe mode
//

import SwiftUI
import WebKit

#if os(iOS)
/// SwiftUI wrapper for WKWebView to render ads
struct AdWebView: UIViewRepresentable {
    let htmlContent: String
    
    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = []
        
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.scrollView.isScrollEnabled = false
        webView.isOpaque = false
        webView.backgroundColor = .clear
        
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        // Wrap content in iframe with responsive styling
        let wrappedHTML = """
        <!DOCTYPE html>
        <html>
        <head>
            <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
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
                .ad-content {
                    width: 100%;
                    max-width: 600px;
                }
            </style>
        </head>
        <body>
            <div class="ad-container">
                <div class="ad-content">
                    \(htmlContent)
                </div>
            </div>
        </body>
        </html>
        """
        
        webView.loadHTMLString(wrappedHTML, baseURL: nil)
    }
}

#elseif os(macOS)
/// SwiftUI wrapper for WKWebView to render ads (macOS)
struct AdWebView: NSViewRepresentable {
    let htmlContent: String
    
    func makeNSView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.mediaTypesRequiringUserActionForPlayback = []
        let webView = WKWebView(frame: .zero, configuration: configuration)
        
        return webView
    }
    
    func updateNSView(_ webView: WKWebView, context: Context) {
        let wrappedHTML = """
        <!DOCTYPE html>
        <html>
        <head>
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
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
            </style>
        </head>
        <body>
            <div class="ad-container">
                \(htmlContent)
            </div>
        </body>
        </html>
        """
        
        webView.loadHTMLString(wrappedHTML, baseURL: nil)
    }
}
#endif

