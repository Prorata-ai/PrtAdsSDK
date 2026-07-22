package com.gist.ads.sdk.ui

// Main ad control for displaying Gist AI Search ads: embeds the real
// `adtag.js` script in a WebView and drives it via
// `defineSlot({id, api_key, geo}, slotId, sizes, adTypes)` ->
// `slot.definePrompt(query)` -> `displayAd(slotId)`, mirroring exactly how a
// publisher's own webpage would embed the tag directly.
//
// This control is a thin wrapper around that HTML/JS embed: it makes no API
// calls of its own. `adtag.js` owns the entire search request, response
// parsing, and rendering (via its own JSONP GET to the Search API), so as
// the tag and backend evolve, this control keeps working without needing to
// track along. This mirrors the pure-embed pattern already shipped for
// `GistDisplayAdControl` -- see that file's header comment and the plan
// that migrated search ads to match it.
//
// Because `adtag.js`'s own search request has no concept of a selectable
// API version, the previous `apiVersion` parameter has been dropped
// entirely (no v1 fallback), matching the precedent set when `context` was
// dropped from display ads. `sizes` is a new public param since
// `defineSlot` requires a non-empty `sizes` array and the previous
// iframe-based control had no sizing concept at all.
//
// Note on the publisher-key exposure trade-off: `publisherKey` is now
// embedded directly in the bootstrap HTML/JS and sent by `adtag.js` as a
// `publisher_key` query param in a public JSONP GET made from inside the
// WebView -- visible in the loaded HTML/JS source (inspectable via WebView
// dev tools). This is the same exposure model a publisher already accepts
// by embedding the JS tag on a public webpage; native apps lose the extra
// native-only protection they previously had from sending it as a hidden
// HTTP header in a server-side POST.

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
import com.gist.ads.sdk.models.AdType
import com.gist.ads.sdk.utils.SearchAdBootstrapHTML
import java.util.UUID
import kotlinx.coroutines.launch

/**
 * Main composable control for displaying Gist AI Search ads.
 *
 * Unlike [GistDisplayAdControl] (display ads, no secret key), search ads are
 * gated by a secret publisher key and targeted by a search query. Mirrors
 * the web tag's `defineSlot({id, api_key, geo}, slotId, sizes, adTypes)` ->
 * `slot.definePrompt(query)` -> `displayAd(slotId)` flow.
 *
 * @param publisherId Your publisher ID credential
 * @param publisherKey Your publisher API key
 * @param query Search query to fetch relevant ads for (mirrors `slot.definePrompt(...)`)
 * @param geo Geographic location code (e.g., "US", "GB", "CA")
 * @param answer Answer text (mirrors `slot.defineAnswer(...)`); the ad tag docs mark this as
 *   required for search ads, so when omitted it defaults to [query]
 * @param adTypes Optional list of ad types to filter (null = all types)
 * @param sizes One or more supported ad sizes (mirrors `sizes` in `defineSlot`); defaults to
 *   `[AdSize.DYNAMIC]`
 * @param environment API environment (defaults to production)
 * @param modifier Modifier for styling the ad control
 * @param theme Theme preference - "light", "dark", or "system" (defaults to "system" for auto-detection)
 * @param onAdLoaded Optional callback invoked when ad successfully loads
 * @param onAdClicked Optional callback invoked when user clicks an ad link (provides URL); if
 *   null, opens the URL in the default browser
 * @param onContentHeightChanged Optional callback invoked when ad content height is measured
 * @param passback Composable shown when no ad is available (no-fill), mirroring the web tag's
 *   `definePassbackFunction`: callers get full control over the fallback UI instead of a
 *   hard-coded empty state. Defaults to a simple "No ad available" text when not provided.
 */
@Composable
fun GistAdControl(
    publisherId: String,
    publisherKey: String,
    query: String,
    geo: String = "US",
    answer: String? = null,
    adTypes: List<AdType>? = null,
    sizes: List<AdSize> = listOf(AdSize.DYNAMIC),
    environment: APIConstants.Environment = APIConstants.Environment.PRODUCTION,
    modifier: Modifier = Modifier,
    theme: String = "system",
    onAdLoaded: (() -> Unit)? = null,
    onAdClicked: ((String) -> Unit)? = null,
    onContentHeightChanged: ((Float) -> Unit)? = null,
    passback: (@Composable () -> Unit)? = null
) {
    val isDarkMode = isSystemInDarkTheme()

    // Resolve theme to "light" or "dark".
    //
    // WORKAROUND: PrtAdsTag's CSS for `data-theme="dark"` sets
    // `color-scheme: dark` on `:root` while the wrapper is transparent and
    // `.content-container` keeps explicit `color: #000000` for text. This
    // produces black text on a dark canvas (invisible) for any non-`gist.ai`
    // publisher. Until PrtAdsTag adds proper dark theme support for
    // arbitrary publishers, we coerce "dark" to "light" here so the ad
    // renders correctly. The surrounding app UI is unaffected — it still
    // follows `isSystemInDarkTheme()` / Material theming.
    val resolvedTheme = remember(theme, isDarkMode) {
        val requested = when (theme) {
            "light" -> "light"
            "dark" -> "dark"
            "system" -> if (isDarkMode) "dark" else "light"
            else -> if (isDarkMode) "dark" else "light"
        }
        if (requested == "dark") "light" else requested
    }

    var state by remember { mutableStateOf<AdTagLoadState>(AdTagLoadState.Loading) }
    var currentSlot by remember { mutableStateOf<SearchAdSlotLoad?>(null) }

    val scope = rememberCoroutineScope()

    // Identity key capturing every load-triggering parameter, mirroring
    // GistDisplayAdControl's `loadKey`: `LaunchedEffect` below re-runs
    // `prepareSlot()` whenever this changes.
    val loadKey = remember(query, geo, answer, adTypes, sizes, environment, resolvedTheme) {
        listOf(
            query,
            geo,
            answer ?: "",
            adTypes?.joinToString(",") { it.value } ?: "",
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
        val slotId = "pr-search-ad-${UUID.randomUUID()}"
        val passbackFunctionName = "prSearchAdPassback${UUID.randomUUID().toString().replace("-", "")}"
        state = AdTagLoadState.Loading
        currentSlot = null

        try {
            val html = SearchAdBootstrapHTML.generate(
                publisherId = publisherId,
                publisherKey = publisherKey,
                query = query,
                geo = geo,
                answer = answer,
                adTypes = adTypes,
                sizes = sizes,
                slotId = slotId,
                passbackFunctionName = passbackFunctionName,
                adTagScriptUrl = environment.adTagScriptUrl
            )
            currentSlot = SearchAdSlotLoad(slotId, html)
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
                    SearchAdLoadingView()
                }
            }
            is AdTagLoadState.Failed -> {
                SearchAdErrorView(
                    message = currentState.message,
                    onRetry = { scope.launch { prepareSlot() } }
                )
            }
            is AdTagLoadState.NoFill -> {
                if (passback != null) {
                    passback()
                } else {
                    SearchAdDefaultNoFillView()
                }
            }
        }
    }
}

private data class SearchAdSlotLoad(val slotId: String, val html: String)

@Composable
private fun SearchAdLoadingView() {
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
private fun SearchAdErrorView(
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
private fun SearchAdDefaultNoFillView() {
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
