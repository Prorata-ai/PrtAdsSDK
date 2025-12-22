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
import com.gist.ads.sdk.models.AdType
import com.gist.ads.sdk.ui.GistAdControl

/**
 * Example demonstrating ad type filtering and geo targeting
 */
@Composable
fun FilterExampleScreen() {
    var selectedQuery by remember { mutableStateOf(Config.SAMPLE_QUERIES[0]) }
    var selectedGeo by remember { mutableStateOf(Config.DEFAULT_GEO) }
    var selectedApiVersion by remember { mutableStateOf(Config.DEFAULT_API_VERSION) }
    
    var imageEnabled by remember { mutableStateOf(true) }
    var textImageEnabled by remember { mutableStateOf(true) }
    var textEnabled by remember { mutableStateOf(true) }
    
    // Build ad types list
    val adTypes = buildList {
        if (imageEnabled) add(AdType.IMAGE)
        if (textImageEnabled) add(AdType.TEXT_IMAGE)
        if (textEnabled) add(AdType.TEXT)
    }.ifEmpty { null }
    
    Column(
        modifier = Modifier
            .fillMaxSize()
            .verticalScroll(rememberScrollState())
            .padding(16.dp),
        verticalArrangement = Arrangement.spacedBy(16.dp)
    ) {
        Text(
            text = "Filters & Targeting",
            style = MaterialTheme.typography.headlineMedium
        )
        
        Text(
            text = "Filter by ad type and target specific geographic regions.",
            style = MaterialTheme.typography.bodyMedium,
            color = MaterialTheme.colorScheme.onSurfaceVariant
        )
        
        Divider()
        
        // Query selector
        SectionTitle("Query")
        
        QueryDropdown(
            selectedQuery = selectedQuery,
            onQuerySelected = { selectedQuery = it },
            label = "Select query"
        )
        
        Divider()
        
        // Ad type filters
        SectionTitle("Ad Types")
        
        Card(
            modifier = Modifier.fillMaxWidth()
        ) {
            Column(
                modifier = Modifier.padding(16.dp),
                verticalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween
                ) {
                    Text("Image Ads")
                    Switch(
                        checked = imageEnabled,
                        onCheckedChange = { imageEnabled = it }
                    )
                }
                
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween
                ) {
                    Text("Text/Image Ads")
                    Switch(
                        checked = textImageEnabled,
                        onCheckedChange = { textImageEnabled = it }
                    )
                }
                
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween
                ) {
                    Text("Text Ads")
                    Switch(
                        checked = textEnabled,
                        onCheckedChange = { textEnabled = it }
                    )
                }
                
                if (!imageEnabled && !textImageEnabled && !textEnabled) {
                    Text(
                        text = "⚠️ At least one ad type should be selected",
                        style = MaterialTheme.typography.bodySmall,
                        color = MaterialTheme.colorScheme.error
                    )
                }
            }
        }
        
        Divider()
        
        // Geographic targeting
        SectionTitle("Geographic Targeting")
        
        GeoDropdown(
            selectedGeo = selectedGeo,
            onGeoSelected = { selectedGeo = it }
        )
        
        Divider()
        
        // API Version selector
        SectionTitle("API Version")
        
        ApiVersionDropdown(
            selectedVersion = selectedApiVersion,
            onVersionSelected = { selectedApiVersion = it }
        )
        
        Divider()
        
        // Ad display
        SectionTitle("Ad Preview")
        
        AdPreviewCard {
            GistAdControl(
                publisherId = Config.PUBLISHER_ID,
                publisherKey = Config.PUBLISHER_KEY,
                query = selectedQuery,
                geo = selectedGeo,
                adTypes = adTypes,
                apiVersion = selectedApiVersion,
                enableLogging = BuildConfig.DEBUG,
                onAdLoaded = {
                    println("FilterExample: Ad loaded - Query: $selectedQuery, Geo: $selectedGeo")
                },
                onAdClicked = { url ->
                    println("FilterExample: Ad clicked - $url")
                },
                onContentHeightChanged = { height ->
                    println("FilterExample: Content height - ${height}px")
                }
            )
        }
        
        Divider()
        
        // Configuration display
        InfoCard(
            title = "Current Configuration",
            items = listOf(
                "Query" to selectedQuery,
                "Region" to (Config.AVAILABLE_GEOS.find { it.first == selectedGeo }?.second ?: selectedGeo),
                "Ad Types" to (if (adTypes == null) "All" else adTypes.joinToString(", ") { it.displayName })
            )
        )
    }
}

