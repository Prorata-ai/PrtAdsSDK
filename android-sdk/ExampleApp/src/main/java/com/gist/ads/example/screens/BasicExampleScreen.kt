package com.gist.ads.example.screens

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.gist.ads.example.BuildConfig
import com.gist.ads.example.Config
import com.gist.ads.example.ui.*
import com.gist.ads.sdk.ui.GistAdControl

/**
 * Basic example demonstrating simple ad integration
 */
@Composable
fun BasicExampleScreen() {
    var selectedQuery by remember { mutableStateOf(Config.SAMPLE_QUERIES[0]) }
    var selectedApiVersion by remember { mutableStateOf(Config.DEFAULT_API_VERSION) }
    
    // Callback state tracking
    var adLoadedCount by remember { mutableStateOf(0) }
    var lastClickedUrl by remember { mutableStateOf<String?>(null) }
    var contentHeight by remember { mutableStateOf<Float?>(null) }
    
    Column(
        modifier = Modifier
            .fillMaxSize()
            .verticalScroll(rememberScrollState())
            .padding(16.dp),
        verticalArrangement = Arrangement.spacedBy(16.dp)
    ) {
        Text(
            text = "Basic Ad Integration",
            style = MaterialTheme.typography.headlineMedium
        )
        
        Text(
            text = "This example shows a basic ad integration with a predefined query.",
            style = MaterialTheme.typography.bodyMedium,
            color = MaterialTheme.colorScheme.onSurfaceVariant
        )
        
        Divider()
        
        // Query selector
        SectionTitle("Select a query:")
        
        QueryDropdown(
            selectedQuery = selectedQuery,
            onQuerySelected = { selectedQuery = it }
        )
        
        // API Version selector
        SectionTitle("Select API version:")
        
        ApiVersionDropdown(
            selectedVersion = selectedApiVersion,
            onVersionSelected = { selectedApiVersion = it }
        )
        
        Divider()
        
        // Ad display
        SectionTitle("Ad Preview:")
        
        AdPreviewCard {
            GistAdControl(
                publisherId = Config.PUBLISHER_ID,
                publisherKey = Config.PUBLISHER_KEY,
                query = selectedQuery,
                geo = Config.DEFAULT_GEO,
                apiVersion = selectedApiVersion,
                enableLogging = BuildConfig.DEBUG,
                onAdLoaded = {
                    adLoadedCount++
                    println("✅ Ad loaded! Count: $adLoadedCount")
                },
                onAdClicked = { url ->
                    lastClickedUrl = url
                    println("🔗 Ad clicked: $url")
                    // Default: open in browser (happens automatically if we don't provide callback)
                },
                onContentHeightChanged = { height ->
                    contentHeight = height
                    println("📏 Content height: ${height}px")
                }
            )
        }
        
        Divider()
        
        // Info card
        InfoCard(
            title = "Configuration",
            items = listOf(
                "Query" to selectedQuery,
                "Geo" to Config.DEFAULT_GEO,
                "API Version" to selectedApiVersion,
                "Ad Types" to "All"
            )
        )
        
        Divider()
        
        // Event callbacks card
        InfoCard(
            title = "Event Callbacks",
            items = buildList {
                add("Ads Loaded" to "$adLoadedCount")
                add("Content Height" to "${contentHeight?.toInt() ?: "Not measured"}px")
                lastClickedUrl?.let { add("Last Click" to "${it.take(50)}...") }
            },
            containerColor = MaterialTheme.colorScheme.secondaryContainer,
            contentColor = MaterialTheme.colorScheme.onSecondaryContainer
        )
    }
}

