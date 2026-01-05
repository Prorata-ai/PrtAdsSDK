package com.gist.ads.example.screens

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.*
import androidx.compose.material3.HorizontalDivider
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
    var contentHeight by remember { mutableStateOf<Float?>(null) }
    var errorMessage by remember { mutableStateOf<String?>(null) }
    var errorCount by remember { mutableStateOf(0) }
    
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
        
        HorizontalDivider()
        
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
        
        HorizontalDivider()
        
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
                    errorMessage = null
                    println("✅ Ad loaded! Count: $adLoadedCount")
                },
                // onAdClicked removed - ads will automatically open in browser when clicked
                onContentHeightChanged = { height ->
                    contentHeight = height
                    println("📏 Content height: ${height}px")
                },
                onError = { exception ->
                    errorCount++
                    errorMessage = when (exception) {
                        is com.gist.ads.sdk.services.AdAPIException.HttpError ->
                            "Error ${exception.statusCode}: ${exception.message}"
                        else -> exception.message
                    }
                    println("❌ Ad error: ${exception.message}")
                },
                theme = "system"
            )
        }
        
        HorizontalDivider()
        
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
        
        HorizontalDivider()
        
        // Event callbacks card
        InfoCard(
            title = "Event Callbacks",
            items = listOf(
                "Ads Loaded" to "$adLoadedCount",
                "Errors" to "$errorCount",
                "Content Height" to "${contentHeight?.toInt() ?: "Not measured"}px",
                "Ad Clicks" to "Open automatically in browser",
                "Last Error" to (errorMessage ?: "None")
            ),
            containerColor = MaterialTheme.colorScheme.secondaryContainer,
            contentColor = MaterialTheme.colorScheme.onSecondaryContainer
        )
    }
}

