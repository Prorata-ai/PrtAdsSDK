package com.gist.ads.sdk.ui

import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.foundation.layout.*
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Warning
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.gist.ads.sdk.DisplayAPIConstants
import com.gist.ads.sdk.models.AdSize
import com.gist.ads.sdk.models.DisplayAdLoadState
import com.gist.ads.sdk.services.DisplayAdAPIService
import kotlinx.coroutines.launch

/**
 * Main composable control for displaying Gist contextual display ads.
 *
 * Unlike [GistAdControl] (search ads, gated by a secret publisher key),
 * display ads are targeted purely by publisher ID + page URL + size, and
 * the backend does not require a publisher key -- see the contract notes
 * at the top of `DisplayAdAPIService.kt`. Mirrors the web tag's
 * `defineSlot({id, url}, slotId, sizes)` -> `displayAd(slotId)` flow.
 *
 * @param publisherId Your publisher ID
 * @param pageUrl The current page/context URL to target the ad against (mirrors `url` in `defineSlot`)
 * @param sizes One or more supported ad sizes (mirrors `sizes` in `defineSlot`)
 * @param environment API environment (defaults to production)
 * @param theme Theme preference - "light", "dark", or "system" (defaults to "system" for auto-detection)
 * @param context Optional publisher-provided key-value data (category, keywords, section, etc.)
 *   sent to the backend for LLM context -- especially useful for native screens, which have no
 *   crawlable HTML for the backend to infer relevance from via `pageUrl` alone.
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
    environment: DisplayAPIConstants.Environment = DisplayAPIConstants.Environment.PRODUCTION,
    theme: String = "system",
    context: Map<String, Any>? = null,
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

    var state by remember { mutableStateOf<DisplayAdLoadState>(DisplayAdLoadState.Loading) }

    val apiService = remember(publisherId, environment) {
        DisplayAdAPIService(
            baseUrl = environment.baseUrl,
            publisherId = publisherId
        )
    }

    val scope = rememberCoroutineScope()

    suspend fun loadAd() {
        state = DisplayAdLoadState.Loading
        val result = runCatching {
            apiService.fetchAd(pageUrl = pageUrl, sizes = sizes, theme = resolvedTheme, context = context)
        }
        val newState = DisplayAdLoadState.from(result)
        state = newState
        if (newState is DisplayAdLoadState.Loaded) {
            onAdLoaded?.invoke()
        }
    }

    LaunchedEffect(pageUrl, sizes, environment, resolvedTheme, context) {
        loadAd()
    }

    Box(
        modifier = modifier.fillMaxWidth(),
        contentAlignment = Alignment.Center
    ) {
        when (val currentState = state) {
            is DisplayAdLoadState.Loading -> {
                DisplayAdLoadingView()
            }
            is DisplayAdLoadState.Failed -> {
                DisplayAdErrorView(
                    message = currentState.message,
                    onRetry = { scope.launch { loadAd() } }
                )
            }
            is DisplayAdLoadState.Loaded -> {
                AdWebView(
                    htmlContent = currentState.html,
                    modifier = Modifier.fillMaxWidth(),
                    theme = resolvedTheme,
                    onAdClicked = onAdClicked,
                    onContentHeightChanged = onContentHeightChanged
                )
            }
            is DisplayAdLoadState.NoFill -> {
                if (passback != null) {
                    passback()
                } else {
                    DisplayAdDefaultNoFillView()
                }
            }
        }
    }
}

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
