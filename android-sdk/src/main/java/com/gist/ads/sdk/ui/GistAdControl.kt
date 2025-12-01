package com.gist.ads.sdk.ui

import androidx.compose.foundation.layout.*
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Warning
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
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
 * @param modifier Modifier for styling the ad control
 * @param enableLogging Enable API request/response logging for debugging
 */
@Composable
fun GistAdControl(
    publisherId: String,
    publisherKey: String,
    query: String,
    geo: String = "US",
    adTypes: List<AdType>? = null,
    modifier: Modifier = Modifier,
    enableLogging: Boolean = false
) {
    // State management
    var adContent by remember { mutableStateOf<String?>(null) }
    var isLoading by remember { mutableStateOf(false) }
    var error by remember { mutableStateOf<AdAPIException?>(null) }
    
    // API service
    val apiService = remember(publisherId, publisherKey, enableLogging) {
        AdAPIService(
            baseUrl = API_BASE_URL,
            publisherId = publisherId,
            publisherKey = publisherKey,
            enableLogging = enableLogging
        )
    }
    
    val scope = rememberCoroutineScope()
    
    // Load ad when component is first composed or when key params change
    LaunchedEffect(query, geo, adTypes) {
        if (query.isNotBlank()) {
            isLoading = true
            error = null
            
            try {
                val content = apiService.fetchAd(
                    query = query,
                    geo = geo,
                    adTypes = adTypes
                )
                adContent = content
                error = null
            } catch (e: AdAPIException) {
                error = e
                adContent = null
            } finally {
                isLoading = false
            }
        }
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
                            isLoading = true
                            error = null
                            
                            try {
                                val content = apiService.fetchAd(
                                    query = query,
                                    geo = geo,
                                    adTypes = adTypes
                                )
                                adContent = content
                                error = null
                            } catch (e: AdAPIException) {
                                error = e
                                adContent = null
                            } finally {
                                isLoading = false
                            }
                        }
                    }
                )
            }
            adContent != null -> {
                AdWebView(
                    htmlContent = adContent!!,
                    modifier = Modifier.fillMaxWidth()
                )
            }
            else -> {
                EmptyView()
            }
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
        
        Text(
            text = "Unable to load ad",
            style = MaterialTheme.typography.titleMedium,
            color = MaterialTheme.colorScheme.onSurface
        )
        
        Spacer(modifier = Modifier.height(8.dp))
        
        Text(
            text = error.message ?: "Unknown error",
            style = MaterialTheme.typography.bodySmall,
            color = MaterialTheme.colorScheme.onSurfaceVariant
        )
        
        Spacer(modifier = Modifier.height(16.dp))
        
        Button(onClick = onRetry) {
            Text("Retry")
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

/**
 * Production API endpoint - managed internally
 */
private const val API_BASE_URL = "https://tp-srch-api.gist.ai"

