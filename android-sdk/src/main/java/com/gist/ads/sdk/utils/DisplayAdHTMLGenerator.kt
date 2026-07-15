package com.gist.ads.sdk.utils

import com.gist.ads.sdk.models.DisplayAdItem

/**
 * Minimal HTML renderer for raw-field display ad responses.
 *
 * This object only exists because the `/decision` endpoint returns raw ad
 * fields (adUrl, adHeadline, adText, adCTA, adImage, ...) rather than a
 * hosted `iframeUrl` -- see the contract notes at the top of
 * DisplayAdAPIService.kt. If the backend contract ever changes to return an
 * iframeUrl instead, this object (and the raw-field parsing in
 * DisplayAdResponse.kt) can be deleted wholesale in favor of reusing
 * IframeHTMLGenerator + AdWebView exactly like search ads already do.
 *
 * Deliberately minimal for v1: renders an image (if present) + headline +
 * body text + CTA as a single clickable card. This does not attempt to
 * replicate every ad template the web tag supports (questions,
 * conversational, etc.).
 */
object DisplayAdHTMLGenerator {
    /**
     * Generate a self-contained HTML snippet for a display ad.
     * @param ad The decoded raw-field ad to render.
     * @param theme Theme preference - "light" or "dark" (resolved from system if "system" was selected).
     * @return HTML string suitable for passing to `AdWebView`.
     */
    fun generate(ad: DisplayAdItem, theme: String): String {
        val clickUrl = ad.adUrl?.htmlAttributeEscaped() ?: "#"
        // Used both as `alt="..."` (an attribute) and as inline text content below,
        // so it needs attribute-level escaping (quotes too) to avoid breaking the
        // `alt` attribute boundary on a headline containing a `"`.
        val headline = (ad.adHeadline ?: ad.adName ?: "").htmlAttributeEscaped()
        val bodyText = ad.adText?.htmlEscaped()
        val cta = ad.adCta?.htmlEscaped()
        val brandName = ad.adName?.htmlEscaped()

        val imageBlock = if (!ad.adImage.isNullOrEmpty()) {
            """<img class="pr-display-ad-image" src="${ad.adImage.htmlAttributeEscaped()}" alt="$headline">"""
        } else {
            ""
        }

        val bodyTextBlock = bodyText?.let { """<div class="pr-display-ad-text">$it</div>""" } ?: ""
        val ctaBlock = cta?.let { """<span class="pr-display-ad-cta">$it</span>""" } ?: ""
        val brandBlock = brandName?.let { """<span class="pr-display-ad-brand">$it</span>""" } ?: ""

        // Deliberately NOT target="_blank": Android WebView requires a
        // WebChromeClient.onCreateWindow implementation to correctly handle
        // target="_blank"/window.open() clicks, which this SDK doesn't
        // provide. Without it, the click silently does nothing. A same-frame
        // link (no target) goes through the normal, working
        // shouldOverrideUrlLoading interception in AdWebView.kt instead.
        return """
        <a class="pr-display-ad" href="$clickUrl" data-pr-theme="${theme.htmlAttributeEscaped()}">
            $imageBlock
            <div class="pr-display-ad-body">
                <div class="pr-display-ad-headline">$headline</div>
                $bodyTextBlock
                $ctaBlock
                $brandBlock
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
        """.trimIndent()
    }

    private fun String.htmlEscaped(): String =
        this.replace("&", "&amp;")
            .replace("<", "&lt;")
            .replace(">", "&gt;")

    private fun String.htmlAttributeEscaped(): String =
        this.htmlEscaped().replace("\"", "&quot;")
}
