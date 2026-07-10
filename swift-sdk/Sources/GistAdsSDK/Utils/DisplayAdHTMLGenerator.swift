//
//  DisplayAdHTMLGenerator.swift
//  GistAdsSDK
//
//  Minimal HTML renderer for raw-field display ad responses.
//
//  This file only exists because Step 0 confirmed the `/decision` endpoint
//  returns raw ad fields (adUrl, adHeadline, adText, adCta, adImage, ...)
//  rather than a hosted `iframeUrl` -- see the contract notes at the top of
//  DisplayAdAPIService.swift. If the backend contract ever changes to return
//  an iframeUrl instead, this file (and the raw-field parsing in
//  DisplayAdResponse.swift) can be deleted wholesale in favor of reusing
//  IframeHTMLGenerator + AdWebView exactly like search ads already do.
//
//  Deliberately minimal for v1: renders an image (if present) + headline +
//  body text + CTA as a single clickable card. This does not attempt to
//  replicate every ad template the web tag supports (questions,
//  conversational, etc.) -- see ticket PAA-5351.
//

import Foundation

enum DisplayAdHTMLGenerator {
    /// Generate a self-contained HTML snippet for a display ad.
    /// - Parameters:
    ///   - ad: The decoded raw-field ad to render.
    ///   - theme: Theme preference - "light" or "dark" (resolved from system if "system" was selected).
    /// - Returns: HTML string suitable for passing to `AdWebView`.
    static func generate(ad: DisplayAdItem, theme: String) -> String {
        let clickURL = ad.adUrl?.htmlAttributeEscaped ?? "#"
        let headline = (ad.adHeadline ?? ad.adName ?? "").htmlEscaped
        let bodyText = ad.adText?.htmlEscaped
        let cta = ad.adCta?.htmlEscaped
        let brandName = ad.adName?.htmlEscaped

        let imageBlock: String
        if let adImage = ad.adImage, !adImage.isEmpty {
            imageBlock = """
            <img class="pr-display-ad-image" src="\(adImage.htmlAttributeEscaped)" alt="\(headline)">
            """
        } else {
            imageBlock = ""
        }

        let bodyTextBlock = bodyText.map { "<div class=\"pr-display-ad-text\">\($0)</div>" } ?? ""
        let ctaBlock = cta.map { "<span class=\"pr-display-ad-cta\">\($0)</span>" } ?? ""
        let brandBlock = brandName.map { "<span class=\"pr-display-ad-brand\">\($0)</span>" } ?? ""

        // Deliberately NOT `target="_blank"`: WKWebView requires a
        // `WKUIDelegate.createWebViewWith` implementation to correctly
        // handle target="_blank"/window.open() clicks, which this SDK
        // doesn't provide. Without it, WebKit's fallback behavior misfires
        // and `decidePolicyFor navigationAction` receives a broken URL
        // (just the base origin, no path/query) instead of the real href.
        // A same-frame link (no target) goes through the normal, working
        // navigation-delegate interception in `AdWebView`/`GistAdView`
        // instead, which already cancels and hands off every non-allowed
        // domain via `onAdClicked` / `UIApplication.shared.open`.
        return """
        <a class="pr-display-ad" href="\(clickURL)" data-pr-theme="\(theme.htmlAttributeEscaped)">
            \(imageBlock)
            <div class="pr-display-ad-body">
                <div class="pr-display-ad-headline">\(headline)</div>
                \(bodyTextBlock)
                \(ctaBlock)
                \(brandBlock)
            </div>
        </a>
        <style>
            .pr-display-ad {
                display: flex;
                align-items: center;
                gap: 8px;
                width: 100%;
                text-decoration: none;
                color: inherit;
                font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            }
            .pr-display-ad-image {
                max-width: 100%;
                max-height: 100%;
                object-fit: contain;
                border-radius: 4px;
                flex-shrink: 0;
            }
            .pr-display-ad-body {
                display: flex;
                flex-direction: column;
                gap: 2px;
                overflow: hidden;
            }
            .pr-display-ad-headline {
                font-weight: 600;
                font-size: 14px;
            }
            .pr-display-ad-text {
                font-size: 12px;
                opacity: 0.8;
            }
            .pr-display-ad-cta {
                display: inline-block;
                margin-top: 4px;
                font-size: 12px;
                font-weight: 600;
                color: #1a73e8;
            }
            .pr-display-ad-brand {
                font-size: 11px;
                opacity: 0.6;
            }
        </style>
        """
    }
}

private extension String {
    var htmlEscaped: String {
        self.replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
    }

    var htmlAttributeEscaped: String {
        self.htmlEscaped.replacingOccurrences(of: "\"", with: "&quot;")
    }
}
