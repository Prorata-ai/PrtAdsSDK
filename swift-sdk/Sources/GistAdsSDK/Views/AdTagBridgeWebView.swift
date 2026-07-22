//
//  AdTagBridgeWebView.swift
//  GistAdsSDK
//
//  WebView that loads the bootstrap HTML built by DisplayAdBootstrapHTML.swift
//  or SearchAdBootstrapHTML.swift and bridges its `adRendered`/passback
//  signals back to native state via WKScriptMessageHandler. Shared by both
//  `GistDisplayAdControl` and `GistAdControl` -- it's a generic embed shell
//  that just loads whatever HTML/baseURL it's given and bridges the two
//  message names; it has no knowledge of display vs. search. Also implements
//  WKUIDelegate.createWebViewWith to intercept the ad tag's target="_blank"
//  links (confirmed by reading adtag.js: ad links always render with
//  target="_blank"), which WKWebView would otherwise silently no-op on
//  without this delegate.
//

import SwiftUI
import WebKit

#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

/// Message names registered on `WKUserContentController` for the bridge --
/// see the matching `window.webkit.messageHandlers.*` calls in
/// `DisplayAdBootstrapHTML` / `SearchAdBootstrapHTML`.
enum AdTagBridgeMessage {
    static let adRendered = "prtagAdRendered"
    static let noFill = "prtagNoFill"
}

/// Coordinator holding the bridge/navigation/UI delegate for a single
/// `AdTagBridgeWebView`.
final class AdTagBridgeCoordinator: NSObject, WKScriptMessageHandler, WKNavigationDelegate, WKUIDelegate {
    var onAdRendered: ((Double) -> Void)?
    var onNoFill: (() -> Void)?
    var onLoadFailure: ((String) -> Void)?
    var onAdClicked: ((URL) -> Void)?

    /// Tracks the last HTML string loaded, so `updateUIView`/`updateNSView`
    /// only reload the WebView when the bootstrap document actually changes.
    var lastLoadedHTML: String?

    // MARK: - WKScriptMessageHandler

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        switch message.name {
        case AdTagBridgeMessage.adRendered:
            let height = (message.body as? NSNumber)?.doubleValue ?? 0
            onAdRendered?(height)
        case AdTagBridgeMessage.noFill:
            onNoFill?()
        default:
            break
        }
    }

    // MARK: - WKUIDelegate

    /// Intercepts `target="_blank"`/`window.open()` navigations (which is
    /// how every ad link renders -- see file header). Returning `nil`
    /// without creating a child WKWebView is Apple's documented pattern for
    /// handling these natively instead of silently dropping them.
    func webView(
        _ webView: WKWebView,
        createWebViewWith configuration: WKWebViewConfiguration,
        for navigationAction: WKNavigationAction,
        windowFeatures: WKWindowFeatures
    ) -> WKWebView? {
        if let url = navigationAction.request.url {
            handleExternalURL(url)
        }
        return nil
    }

    // MARK: - WKNavigationDelegate

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url else {
            decisionHandler(.allow)
            return
        }

        let scheme = url.scheme?.lowercased() ?? ""
        if scheme != "http" && scheme != "https" {
            decisionHandler(.allow)
            return
        }

        // Only main-frame navigations matter here: this covers both the
        // synthetic navigation `loadHTMLString(_:baseURL:)` generates for
        // its `baseURL` (which must be allowlisted or WebKit aborts the
        // load) and any same-frame ad click that -- unlike the tag's usual
        // target="_blank" links -- didn't go through `createWebViewWith`.
        guard navigationAction.targetFrame?.isMainFrame == true else {
            decisionHandler(.allow)
            return
        }

        if APIConstants.isAllowedAdDomain(url) {
            decisionHandler(.allow)
            return
        }

        decisionHandler(.cancel)
        handleExternalURL(url)
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        onLoadFailure?(error.localizedDescription)
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        onLoadFailure?(error.localizedDescription)
    }

    private func handleExternalURL(_ url: URL) {
        if let onAdClicked = onAdClicked {
            DispatchQueue.main.async {
                onAdClicked(url)
            }
        } else {
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

private func makeConfiguredAdTagWebView(coordinator: AdTagBridgeCoordinator, isIOS: Bool) -> WKWebView {
    let configuration = WKWebViewConfiguration()
    configuration.userContentController.add(coordinator, name: AdTagBridgeMessage.adRendered)
    configuration.userContentController.add(coordinator, name: AdTagBridgeMessage.noFill)

    let webView = WKWebView(frame: .zero, configuration: configuration)
    webView.navigationDelegate = coordinator
    webView.uiDelegate = coordinator
    configureWebView(webView, isIOS: isIOS)
    return webView
}

#if os(iOS)

/// SwiftUI wrapper embedding the real ad tag for a single ad slot (iOS).
struct AdTagBridgeWebView: UIViewRepresentable {
    let html: String
    let baseURLString: String
    var theme: String = "system"
    var onAdRendered: ((Double) -> Void)?
    var onNoFill: (() -> Void)?
    var onLoadFailure: ((String) -> Void)?
    var onAdClicked: ((URL) -> Void)?

    private var baseURL: URL {
        URL(string: baseURLString) ?? URL(string: "about:blank")!
    }

    func makeCoordinator() -> AdTagBridgeCoordinator {
        let coordinator = AdTagBridgeCoordinator()
        coordinator.onAdRendered = onAdRendered
        coordinator.onNoFill = onNoFill
        coordinator.onLoadFailure = onLoadFailure
        coordinator.onAdClicked = onAdClicked
        return coordinator
    }

    func makeUIView(context: Context) -> WKWebView {
        let webView = makeConfiguredAdTagWebView(coordinator: context.coordinator, isIOS: true)
        applyThemeToWebView(webView, theme: theme)
        webView.loadHTMLString(html, baseURL: baseURL)
        context.coordinator.lastLoadedHTML = html
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        context.coordinator.onAdRendered = onAdRendered
        context.coordinator.onNoFill = onNoFill
        context.coordinator.onLoadFailure = onLoadFailure
        context.coordinator.onAdClicked = onAdClicked
        applyThemeToWebView(webView, theme: theme)

        if context.coordinator.lastLoadedHTML != html {
            context.coordinator.lastLoadedHTML = html
            webView.loadHTMLString(html, baseURL: baseURL)
        }
    }

    static func dismantleUIView(_ webView: WKWebView, coordinator: AdTagBridgeCoordinator) {
        webView.configuration.userContentController.removeScriptMessageHandler(forName: AdTagBridgeMessage.adRendered)
        webView.configuration.userContentController.removeScriptMessageHandler(forName: AdTagBridgeMessage.noFill)
    }
}

#elseif os(macOS)

/// SwiftUI wrapper embedding the real ad tag for a single ad slot (macOS).
struct AdTagBridgeWebView: NSViewRepresentable {
    let html: String
    let baseURLString: String
    var theme: String = "system"
    var onAdRendered: ((Double) -> Void)?
    var onNoFill: (() -> Void)?
    var onLoadFailure: ((String) -> Void)?
    var onAdClicked: ((URL) -> Void)?

    private var baseURL: URL {
        URL(string: baseURLString) ?? URL(string: "about:blank")!
    }

    func makeCoordinator() -> AdTagBridgeCoordinator {
        let coordinator = AdTagBridgeCoordinator()
        coordinator.onAdRendered = onAdRendered
        coordinator.onNoFill = onNoFill
        coordinator.onLoadFailure = onLoadFailure
        coordinator.onAdClicked = onAdClicked
        return coordinator
    }

    func makeNSView(context: Context) -> WKWebView {
        let webView = makeConfiguredAdTagWebView(coordinator: context.coordinator, isIOS: false)
        applyThemeToWebView(webView, theme: theme)
        webView.loadHTMLString(html, baseURL: baseURL)
        context.coordinator.lastLoadedHTML = html
        return webView
    }

    func updateNSView(_ webView: WKWebView, context: Context) {
        context.coordinator.onAdRendered = onAdRendered
        context.coordinator.onNoFill = onNoFill
        context.coordinator.onLoadFailure = onLoadFailure
        context.coordinator.onAdClicked = onAdClicked
        applyThemeToWebView(webView, theme: theme)

        if context.coordinator.lastLoadedHTML != html {
            context.coordinator.lastLoadedHTML = html
            webView.loadHTMLString(html, baseURL: baseURL)
        }
    }

    static func dismantleNSView(_ webView: WKWebView, coordinator: AdTagBridgeCoordinator) {
        webView.configuration.userContentController.removeScriptMessageHandler(forName: AdTagBridgeMessage.adRendered)
        webView.configuration.userContentController.removeScriptMessageHandler(forName: AdTagBridgeMessage.noFill)
    }
}

#endif
