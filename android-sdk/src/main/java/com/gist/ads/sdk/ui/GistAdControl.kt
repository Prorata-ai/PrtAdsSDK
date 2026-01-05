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
import com.gist.ads.sdk.APIConstants
import com.gist.ads.sdk.models.AdType
import com.gist.ads.sdk.services.AdAPIException
import com.gist.ads.sdk.services.AdAPIService
import kotlinx.coroutines.launch

/**
 * Main composable control for displaying Gist AI Search ads
 * 
 * @param publisherId Your publisher ID credential
 * @param publisherKey Your publisher API key
 * @param query Search query to fetch relevant ads for
 * @param geo Geographic location code (e.g., "US", "GB", "CA")
 * @param adTypes Optional list of ad types to filter (null = all types)
 * @param environment API environment (defaults to production)
 * @param apiVersion API version to use (defaults to v2, or from system property)
 * @param customBaseUrl Optional custom base URL to override environment default
 * @param customIframeUrl Optional custom iframe base URL to override environment default (reserved for future use)
 * @param modifier Modifier for styling the ad control
 * @param enableLogging Enable API request/response logging for debugging
 * @param onAdLoaded Optional callback invoked when ad successfully loads
 * @param onAdClicked Optional callback invoked when user clicks an ad link (provides URL)
 * @param onContentHeightChanged Optional callback invoked when ad content height is measured
 * @param onError Optional callback invoked when an error occurs during ad loading (provides AdAPIException)
 * @param theme Theme preference - "light", "dark", or "system" (defaults to "system" for auto-detection)
 */
@Suppress("UNUSED_PARAMETER")
@Composable
fun GistAdControl(
    publisherId: String,
    publisherKey: String,
    query: String,
    geo: String = "US",
    adTypes: List<AdType>? = null,
    environment: APIConstants.Environment = APIConstants.Environment.PRODUCTION,
    apiVersion: String = APIConstants.defaultApiVersion(),
    customBaseUrl: String? = null,
    customIframeUrl: String? = null,
    modifier: Modifier = Modifier,
    enableLogging: Boolean = false,
    onAdLoaded: (() -> Unit)? = null,
    onAdClicked: ((String) -> Unit)? = null,
    onContentHeightChanged: ((Float) -> Unit)? = null,
    onError: ((AdAPIException) -> Unit)? = null,
    theme: String = "system"
) {
    // Detect system theme
    val isDarkMode = isSystemInDarkTheme()
    
    // Resolve theme to "light" or "dark"
    val resolvedTheme = remember(theme, isDarkMode) {
        when (theme) {
            "light" -> "light"
            "dark" -> "dark"
            "system" -> if (isDarkMode) "dark" else "light"
            else -> if (isDarkMode) "dark" else "light"
        }
    }
    
    // State management
    var adContent by remember { mutableStateOf<String?>(null) }
    var isLoading by remember { mutableStateOf(false) }
    var error by remember { mutableStateOf<AdAPIException?>(null) }
    
    // API service
    val apiService = remember(publisherId, publisherKey, environment, apiVersion, customBaseUrl, enableLogging) {
        AdAPIService(
            baseUrl = customBaseUrl ?: environment.baseUrl,
            publisherId = publisherId,
            publisherKey = publisherKey,
            apiVersion = apiVersion,
            enableLogging = enableLogging
        )
    }
    
    val scope = rememberCoroutineScope()
    
    // Load ad when component is first composed or when key params change
    LaunchedEffect(query, geo, adTypes, apiVersion, resolvedTheme) {
        loadAd(
            apiService = apiService,
            query = query,
            geo = geo,
            adTypes = adTypes,
            theme = resolvedTheme,
            onSuccess = { content ->
                adContent = content
                error = null
            },
            onError = { e ->
                error = e
                adContent = null
                onError?.invoke(e) // Notify consumer of error
            },
            onLoading = { loading -> isLoading = loading },
            onAdLoaded = onAdLoaded
        )
    }
    
    // Render UI based on state
    Box(
        modifier = modifier.fillMaxWidth(),
        contentAlignment = Alignment.Center
    ) {
        when {
            isLoading -> {
                LoadingView()
            }
            error != null -> {
                ErrorView(
                    error = error!!,
                    onRetry = {
                        scope.launch {
                            loadAd(
                                apiService = apiService,
                                query = query,
                                geo = geo,
                                adTypes = adTypes,
                                theme = resolvedTheme,
                                onSuccess = { content ->
                                    adContent = content
                                    error = null
                                },
                                onError = { e ->
                                    error = e
                                    adContent = null
                                    onError?.invoke(e) // Notify consumer of error on retry
                                },
                                onLoading = { loading -> isLoading = loading },
                                onAdLoaded = onAdLoaded
                            )
                        }
                    }
                )
            }
            adContent != null -> {
                AdWebView(
                    htmlContent = adContent!!,
                    modifier = Modifier.fillMaxWidth(),
                    onAdClicked = onAdClicked,
                    onContentHeightChanged = onContentHeightChanged
                )
            }
            else -> {
                EmptyView()
            }
        }
    }
}

/**
 * Helper function to load ad and update state
 * Eliminates code duplication between initial load and retry
 */
private suspend fun loadAd(
    apiService: AdAPIService,
    query: String,
    geo: String,
    adTypes: List<AdType>?,
    theme: String,
    onSuccess: (String) -> Unit,
    onError: (AdAPIException) -> Unit,
    onLoading: (Boolean) -> Unit,
    onAdLoaded: (() -> Unit)?
) {
    if (query.isNotBlank()) {
        onLoading(true)
        try {
            val content = apiService.fetchAd(query, geo, adTypes, theme = theme)
            onSuccess(content)
            onAdLoaded?.invoke()
        } catch (e: AdAPIException) {
            onError(e)
        } finally {
            onLoading(false)
        }
    }
}

/**
 * Loading state view
 */
@Composable
private fun LoadingView() {
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

/**
 * Error state view with retry button
 */
@Composable
private fun ErrorView(
    error: AdAPIException,
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
        
        // Primary error title - context-specific
        Text(
            text = when (error) {
                is AdAPIException.HttpError -> when (error.statusCode) {
                    401 -> "Authentication Failed"
                    403 -> "Access Denied"
                    404 -> "Service Not Found"
                    429 -> "Rate Limit Exceeded"
                    500, 503 -> "Server Error"
                    else -> "Unable to Load Ad"
                }
                is AdAPIException.NetworkError -> "Connection Error"
                is AdAPIException.NoAdsAvailable -> "No Ads Available"
                is AdAPIException.InvalidData -> "Invalid Response"
                else -> "Unable to Load Ad"
            },
            style = MaterialTheme.typography.titleMedium,
            color = MaterialTheme.colorScheme.onSurface
        )
        
        Spacer(modifier = Modifier.height(8.dp))
        
        // Detailed message with action guidance
        Text(
            text = error.message ?: "Unknown error",
            style = MaterialTheme.typography.bodySmall,
            color = MaterialTheme.colorScheme.onSurfaceVariant,
            textAlign = androidx.compose.ui.text.style.TextAlign.Center
        )
        
        Spacer(modifier = Modifier.height(16.dp))
        
        // Show retry button only for recoverable errors
        // Don't show retry for auth errors (401, 403) as they require credential fixes
        if (error !is AdAPIException.HttpError || error.statusCode !in listOf(401, 403)) {
            Button(onClick = onRetry) {
                Text("Retry")
            }
        }
    }
}

/**
 * Empty state view when no ad is available
 */
@Composable
private fun EmptyView() {
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

