package com.gist.ads.sdk.ui

// Main ad control for displaying Gist contextual display ads: embeds the
// real `adtag.js` script in a WebView and drives it via
// `defineSlot({id, url}, slotId, sizes)` -> `displayAd(slotId)`, mirroring
// exactly how a publisher's own webpage would embed the tag directly.
//
// This control is a thin wrapper around that HTML/JS embed: it makes no
// API calls of its own. `adtag.js` owns the entire ad request, response
// parsing, and rendering, so as the tag and backend evolve, this control
// keeps working without needing to track along. (An earlier revision
// fetched ads natively to support a `context` targeting param that
// `adtag.js`'s own request has no field for; that param has been removed
// so this control can stay a pure embed -- see PR #7 review discussion.)

import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.foundation.layout.*
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Warning
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.gist.ads.sdk.APIConstants
import com.gist.ads.sdk.models.AdSize
import com.gist.ads.sdk.models.AdTagLoadState
import com.gist.ads.sdk.utils.DisplayAdBootstrapHTML
import java.util.UUID
import kotlinx.coroutines.launch

/**
 * Main composable control for displaying Gist contextual display ads.
 *
 * Unlike [GistAdControl] (search ads, gated by a secret publisher key),
 * display ads are targeted purely by publisher ID + page URL + size, and
 * the backend does not require a publisher key. Mirrors the web tag's
 * `defineSlot({id, url}, slotId, sizes)` -> `displayAd(slotId)` flow.
 *
 * @param publisherId Your publisher ID
 * @param pageUrl The current page/context URL to target the ad against (mirrors `url` in
 *   `defineSlot`). Must not be blank -- a blank value surfaces as a [AdTagLoadState.Failed] state
 *   (with retry) rather than silently sending an empty `url` to `adtag.js`.
 * @param sizes One or more supported ad sizes (mirrors `sizes` in `defineSlot`)
 * @param environment API environment (defaults to production)
 * @param theme Theme preference - "light", "dark", or "system" (defaults to "system" for auto-detection)
 * @param modifier Modifier for styling the ad control
 * @param onAdLoaded Optional callback invoked when ad successfully loads
 * @param onAdClicked Optional callback invoked when user clicks an ad link (provides URL); if
 *   null, opens the URL in the default browser
 * @param onContentHeightChanged Optional callback invoked when ad content height is measured
 * @param passback Composable shown when no ad is available (no-fill), mirroring the web tag's
 *   `definePassbackFunction`: callers get full control over the fallback UI instead of a
 *   hard-coded empty state. Defaults to a simple "No ad available" text when not provided.
 */
@Composable
fun GistDisplayAdControl(
    publisherId: String,
    pageUrl: String,
    sizes: List<AdSize>,
    environment: APIConstants.Environment = APIConstants.Environment.PRODUCTION,
    theme: String = "system",
    modifier: Modifier = Modifier,
    onAdLoaded: (() -> Unit)? = null,
    onAdClicked: ((String) -> Unit)? = null,
    onContentHeightChanged: ((Float) -> Unit)? = null,
    passback: (@Composable () -> Unit)? = null
) {
    val isDarkMode = isSystemInDarkTheme()
    val resolvedTheme = remember(theme, isDarkMode) {
        when (theme) {
            "light" -> "light"
            "dark" -> "dark"
            "system" -> if (isDarkMode) "dark" else "light"
            else -> if (isDarkMode) "dark" else "light"
        }
    }

    var state by remember { mutableStateOf<AdTagLoadState>(AdTagLoadState.Loading) }
    var currentSlot by remember { mutableStateOf<DisplayAdSlotLoad?>(null) }

    val scope = rememberCoroutineScope()

    // Identity key capturing every load-triggering parameter, mirroring the
    // Swift SDK's `loadKey`: `LaunchedEffect` below re-runs `prepareSlot()`
    // whenever this changes.
    val loadKey = remember(pageUrl, sizes, environment, resolvedTheme) {
        listOf(
            pageUrl,
            sizes.joinToString(",") { it.displayName },
            environment.name,
            resolvedTheme
        ).joinToString("|")
    }

    // Prepare (or re-prepare, on retry/param change) the WebView's bootstrap
    // HTML: mint a fresh slot id + passback function name and build the
    // bootstrap HTML. This is purely local string generation -- no network
    // call is made here or anywhere else in this control; `adtag.js` makes
    // its own request once the resulting WebView loads.
    fun prepareSlot() {
        val slotId = "pr-display-ad-${UUID.randomUUID()}"
        val passbackFunctionName = "prDisplayAdPassback${UUID.randomUUID().toString().replace("-", "")}"
        state = AdTagLoadState.Loading
        currentSlot = null

        try {
            val html = DisplayAdBootstrapHTML.generate(
                publisherId = publisherId,
                pageUrl = pageUrl,
                sizes = sizes,
                slotId = slotId,
                passbackFunctionName = passbackFunctionName,
                adTagScriptUrl = environment.adTagScriptUrl
            )
            currentSlot = DisplayAdSlotLoad(slotId, html)
        } catch (e: Exception) {
            state = AdTagLoadState.Failed(e.message ?: "Unknown error")
        }
    }

    LaunchedEffect(loadKey) {
        prepareSlot()
    }

    Box(
        modifier = modifier.fillMaxWidth(),
        contentAlignment = Alignment.Center
    ) {
        when (val currentState = state) {
            is AdTagLoadState.Loading, is AdTagLoadState.Loaded -> {
                currentSlot?.let { slot ->
                    key(slot.slotId) {
                        AdTagBridgeWebView(
                            html = slot.html,
                            baseUrl = environment.adTagScriptUrl,
                            modifier = Modifier.fillMaxWidth(),
                            theme = resolvedTheme,
                            onAdRendered = { height ->
                                state = AdTagLoadState.Loaded(height)
                                onContentHeightChanged?.invoke(height.toFloat())
                                onAdLoaded?.invoke()
                            },
                            onNoFill = {
                                state = AdTagLoadState.NoFill
                            },
                            onLoadFailure = { message ->
                                state = AdTagLoadState.Failed(message)
                            },
                            onAdClicked = onAdClicked
                        )
                    }
                }
                if (currentState is AdTagLoadState.Loading) {
                    DisplayAdLoadingView()
                }
            }
            is AdTagLoadState.Failed -> {
                DisplayAdErrorView(
                    message = currentState.message,
                    onRetry = { scope.launch { prepareSlot() } }
                )
            }
            is AdTagLoadState.NoFill -> {
                if (passback != null) {
                    passback()
                } else {
                    DisplayAdDefaultNoFillView()
                }
            }
        }
    }
}

private data class DisplayAdSlotLoad(val slotId: String, val html: String)

@Composable
private fun DisplayAdLoadingView() {
    Column(
        modifier = Modifier
            .fillMaxWidth()
            .padding(32.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center
    ) {
        CircularProgressIndicator()
        Spacer(modifier = Modifier.height(16.dp))
        Text(
            text = "Loading ad...",
            style = MaterialTheme.typography.bodyMedium
        )
    }
}

@Composable
private fun DisplayAdErrorView(
    message: String,
    onRetry: () -> Unit
) {
    Column(
        modifier = Modifier
            .fillMaxWidth()
            .padding(24.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center
    ) {
        Icon(
            imageVector = Icons.Default.Warning,
            contentDescription = "Error",
            modifier = Modifier.size(48.dp),
            tint = MaterialTheme.colorScheme.error
        )

        Spacer(modifier = Modifier.height(16.dp))

        Text(
            text = "Unable to load ad",
            style = MaterialTheme.typography.titleMedium,
            color = MaterialTheme.colorScheme.onSurface
        )

        Spacer(modifier = Modifier.height(8.dp))

        Text(
            text = message,
            style = MaterialTheme.typography.bodySmall,
            color = MaterialTheme.colorScheme.onSurfaceVariant,
            textAlign = androidx.compose.ui.text.style.TextAlign.Center
        )

        Spacer(modifier = Modifier.height(16.dp))

        Button(onClick = onRetry) {
            Text("Retry")
        }
    }
}

@Composable
private fun DisplayAdDefaultNoFillView() {
    Box(
        modifier = Modifier
            .fillMaxWidth()
            .padding(32.dp),
        contentAlignment = Alignment.Center
    ) {
        Text(
            text = "No ad available",
            style = MaterialTheme.typography.bodyMedium,
            color = MaterialTheme.colorScheme.onSurfaceVariant
        )
    }
}
