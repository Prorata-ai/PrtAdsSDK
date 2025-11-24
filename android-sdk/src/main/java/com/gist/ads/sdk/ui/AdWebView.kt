package com.gist.ads.sdk.ui

import android.webkit.WebView
import android.webkit.WebViewClient
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.viewinterop.AndroidView

/**
 * WebView component for rendering ads
 * Uses Android WebView wrapped in Compose for iframe-based ad display
 */
@Composable
fun AdWebView(
    htmlContent: String,
    modifier: Modifier = Modifier
) {
    AndroidView(
        modifier = modifier,
        factory = { context ->
            WebView(context).apply {
                webViewClient = WebViewClient()
                
                // Configure WebView settings
                settings.apply {
                    javaScriptEnabled = true
                    domStorageEnabled = true
                    loadWithOverviewMode = true
                    useWideViewPort = true
                    setSupportZoom(false)
                }
                
                // Set transparent background
                setBackgroundColor(android.graphics.Color.TRANSPARENT)
            }
        },
        update = { webView ->
            // Wrap content in responsive HTML template
            val wrappedHtml = """
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
                            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
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
                        img {
                            max-width: 100%;
                            height: auto;
                        }
                    </style>
                </head>
                <body>
                    <div class="ad-container">
                        <div class="ad-content">
                            $htmlContent
                        </div>
                    </div>
                </body>
                </html>
            """.trimIndent()
            
            webView.loadDataWithBaseURL(
                null,
                wrappedHtml,
                "text/html",
                "UTF-8",
                null
            )
        }
    )
}

