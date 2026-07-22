//
//  AdWebView.swift
//  GistAdsSDK
//
//  Shared WKWebView configuration helpers, used by `AdTagBridgeWebView`
//  (SwiftUI) and `GistAdView` (UIKit) for the embedded `adtag.js` WebView.
//
//  This file used to also define a standalone `AdWebView` view that loaded
//  a search ad's `iframeUrl` HTML fetched natively via `AdAPIService`. Now
//  that both search and display ads are pure `adtag.js` embeds rendered by
//  `AdTagBridgeWebView`, that view is no longer needed -- only these two
//  configuration helpers remain.
//

import WebKit

#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

/// Configure WebView with common settings
///
/// Not `private`: shared by `AdTagBridgeWebView` (SwiftUI) and `GistAdView`
/// (UIKit), which need the same scroll/opacity/media-playback setup.
func configureWebView(_ webView: WKWebView, isIOS: Bool) {
    #if os(iOS)
    webView.scrollView.isScrollEnabled = false
    webView.isOpaque = false
    webView.backgroundColor = .clear
    webView.configuration.allowsInlineMediaPlayback = true
    #endif
    
    webView.configuration.mediaTypesRequiringUserActionForPlayback = []
}

/// Apply the SDK theme to the WebView so the embedded ad tag content sees a
/// matching `prefers-color-scheme` and the WebView's own background tracks
/// the theme. Themes: "light", "dark", or "system".
///
/// Not `private`: shared by `AdTagBridgeWebView` and `GistAdView`, which
/// rely on this same `prefers-color-scheme` override for the embedded ad
/// tag's own dark-mode CSS to respond correctly.
func applyThemeToWebView(_ webView: WKWebView, theme: String) {
    #if os(iOS)
    if #available(iOS 13.0, *) {
        switch theme {
        case "light":
            webView.overrideUserInterfaceStyle = .light
        case "dark":
            webView.overrideUserInterfaceStyle = .dark
        default:
            webView.overrideUserInterfaceStyle = .unspecified
        }
    }
    #elseif os(macOS)
    switch theme {
    case "light":
        webView.appearance = NSAppearance(named: .aqua)
    case "dark":
        webView.appearance = NSAppearance(named: .darkAqua)
    default:
        webView.appearance = nil
    }
    #endif
}
