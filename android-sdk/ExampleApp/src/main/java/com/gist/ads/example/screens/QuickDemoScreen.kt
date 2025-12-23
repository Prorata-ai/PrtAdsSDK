package com.gist.ads.example.screens

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowForward
import androidx.compose.material.icons.filled.Refresh
import androidx.compose.material.icons.filled.Search
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import com.gist.ads.example.BuildConfig
import com.gist.ads.example.Config
import com.gist.ads.sdk.models.AdType
import com.gist.ads.sdk.ui.GistAdControl
import java.util.UUID

/**
 * Quick Demo Screen - Single-page demo matching Swift SDK style
 * Shows all configuration options and live preview in one unified view
 */
@Composable
fun QuickDemoScreen() {
    var searchQuery by remember { mutableStateOf("best wireless headphones") }
    var selectedGeo by remember { mutableStateOf("US") }
    var selectedApiVersion by remember { mutableStateOf(Config.DEFAULT_API_VERSION) }
    var imageEnabled by remember { mutableStateOf(true) }
    var textImageEnabled by remember { mutableStateOf(true) }
    var textEnabled by remember { mutableStateOf(true) }
    var refreshTrigger by remember { mutableStateOf(UUID.randomUUID()) }
    
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
        verticalArrangement = Arrangement.spacedBy(24.dp)
    ) {
        // Header
        HeaderSection()
        
        // Configuration Section
        ConfigurationSection(
            searchQuery = searchQuery,
            onSearchQueryChange = { searchQuery = it },
            selectedGeo = selectedGeo,
            onGeoChange = { selectedGeo = it; refreshTrigger = UUID.randomUUID() },
            imageEnabled = imageEnabled,
            onImageEnabledChange = { imageEnabled = it },
            textImageEnabled = textImageEnabled,
            onTextImageEnabledChange = { textImageEnabled = it },
            textEnabled = textEnabled,
            onTextEnabledChange = { textEnabled = it },
            selectedApiVersion = selectedApiVersion,
            onApiVersionChange = { selectedApiVersion = it; refreshTrigger = UUID.randomUUID() },
            onRefresh = { refreshTrigger = UUID.randomUUID() }
        )
        
        // Ad Preview Section
        AdPreviewSection(
            searchQuery = searchQuery,
            selectedGeo = selectedGeo,
            adTypes = adTypes,
            selectedApiVersion = selectedApiVersion,
            refreshTrigger = refreshTrigger
        )
        
        // Example Queries Section
        ExampleQueriesSection(
            onQuerySelected = { 
                searchQuery = it
                refreshTrigger = UUID.randomUUID()
            }
        )
    }
}

@Composable
private fun HeaderSection() {
    Column(
        modifier = Modifier.fillMaxWidth(),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.spacedBy(8.dp)
    ) {
        Icon(
            imageVector = Icons.Default.Search,
            contentDescription = null,
            modifier = Modifier.size(50.dp),
            tint = MaterialTheme.colorScheme.primary
        )
        
        Text(
            text = "Gist AI Search Ads",
            style = MaterialTheme.typography.headlineMedium,
            color = MaterialTheme.colorScheme.onSurface
        )
        
        Text(
            text = "Native ad integration for AI-powered search",
            style = MaterialTheme.typography.bodyMedium,
            color = MaterialTheme.colorScheme.onSurfaceVariant,
            textAlign = TextAlign.Center
        )
    }
}

@Composable
private fun ConfigurationSection(
    searchQuery: String,
    onSearchQueryChange: (String) -> Unit,
    selectedGeo: String,
    onGeoChange: (String) -> Unit,
    imageEnabled: Boolean,
    onImageEnabledChange: (Boolean) -> Unit,
    textImageEnabled: Boolean,
    onTextImageEnabledChange: (Boolean) -> Unit,
    textEnabled: Boolean,
    onTextEnabledChange: (Boolean) -> Unit,
    selectedApiVersion: String,
    onApiVersionChange: (String) -> Unit,
    onRefresh: () -> Unit
) {
    Card(
        modifier = Modifier.fillMaxWidth(),
        colors = CardDefaults.cardColors(
            containerColor = MaterialTheme.colorScheme.surfaceVariant
        )
    ) {
        Column(
            modifier = Modifier.padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            Text(
                text = "Configuration",
                style = MaterialTheme.typography.titleLarge
            )
            
            // Search Query
            Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                Text(
                    text = "Search Query",
                    style = MaterialTheme.typography.labelMedium,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
                OutlinedTextField(
                    value = searchQuery,
                    onValueChange = onSearchQueryChange,
                    modifier = Modifier.fillMaxWidth(),
                    placeholder = { Text("Enter search query...") },
                    singleLine = true
                )
            }
            
            // Geographic Location
            Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                Text(
                    text = "Geographic Location",
                    style = MaterialTheme.typography.labelMedium,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    listOf("US", "GB", "CA", "AU").forEach { geo ->
                        FilterChip(
                            selected = selectedGeo == geo,
                            onClick = { onGeoChange(geo) },
                            label = { Text(geo) },
                            modifier = Modifier.weight(1f)
                        )
                    }
                }
            }
            
            // Ad Types
            Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                Text(
                    text = "Ad Types",
                    style = MaterialTheme.typography.labelMedium,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
                
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Checkbox(
                        checked = imageEnabled,
                        onCheckedChange = onImageEnabledChange
                    )
                    Text("Image", modifier = Modifier.weight(1f))
                }
                
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Checkbox(
                        checked = textImageEnabled,
                        onCheckedChange = onTextImageEnabledChange
                    )
                    Text("Text/Image", modifier = Modifier.weight(1f))
                }
                
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Checkbox(
                        checked = textEnabled,
                        onCheckedChange = onTextEnabledChange
                    )
                    Text("Text", modifier = Modifier.weight(1f))
                }
            }
            
            // API Version
            Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                Text(
                    text = "API Version",
                    style = MaterialTheme.typography.labelMedium,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    FilterChip(
                        selected = selectedApiVersion == "v1",
                        onClick = { onApiVersionChange("v1") },
                        label = { Text("v1") },
                        modifier = Modifier.weight(1f)
                    )
                    FilterChip(
                        selected = selectedApiVersion == "v2",
                        onClick = { onApiVersionChange("v2") },
                        label = { Text("v2") },
                        modifier = Modifier.weight(1f)
                    )
                }
            }
            
            // Refresh Button
            Button(
                onClick = onRefresh,
                modifier = Modifier.fillMaxWidth()
            ) {
                Icon(
                    imageVector = Icons.Default.Refresh,
                    contentDescription = null,
                    modifier = Modifier.size(20.dp)
                )
                Spacer(modifier = Modifier.width(8.dp))
                Text("Reload Ad")
            }
        }
    }
}

@Composable
private fun AdPreviewSection(
    searchQuery: String,
    selectedGeo: String,
    adTypes: List<AdType>?,
    selectedApiVersion: String,
    refreshTrigger: UUID
) {
    Card(
        modifier = Modifier.fillMaxWidth(),
        colors = CardDefaults.cardColors(
            containerColor = MaterialTheme.colorScheme.surfaceVariant
        )
    ) {
        Column(
            modifier = Modifier.padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(12.dp)
        ) {
            Text(
                text = "Live Ad Preview",
                style = MaterialTheme.typography.titleLarge
            )
            
            if (searchQuery.isNotBlank()) {
                Card(
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(250.dp),
                    colors = CardDefaults.cardColors(
                        containerColor = MaterialTheme.colorScheme.surface
                    )
                ) {
                    GistAdControl(
                        publisherId = Config.PUBLISHER_ID,
                        publisherKey = Config.PUBLISHER_KEY,
                        query = searchQuery,
                        geo = selectedGeo,
                        adTypes = adTypes,
                        apiVersion = selectedApiVersion,
                        enableLogging = BuildConfig.DEBUG,
                        modifier = Modifier
                            .fillMaxSize()
                            .then(Modifier) // Force recomposition on refreshTrigger change
                    )
                }
            } else {
                EmptyQueryView()
            }
        }
    }
}

@Composable
private fun EmptyQueryView() {
    Card(
        modifier = Modifier
            .fillMaxWidth()
            .height(250.dp),
        colors = CardDefaults.cardColors(
            containerColor = MaterialTheme.colorScheme.surface
        )
    ) {
        Box(
            modifier = Modifier.fillMaxSize(),
            contentAlignment = Alignment.Center
        ) {
            Column(
                horizontalAlignment = Alignment.CenterHorizontally,
                verticalArrangement = Arrangement.spacedBy(12.dp)
            ) {
                Icon(
                    imageVector = Icons.Default.Search,
                    contentDescription = null,
                    modifier = Modifier.size(48.dp),
                    tint = MaterialTheme.colorScheme.onSurfaceVariant.copy(alpha = 0.5f)
                )
                Text(
                    text = "Enter a search query to see ads",
                    style = MaterialTheme.typography.bodyMedium,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
            }
        }
    }
}

@Composable
private fun ExampleQueriesSection(
    onQuerySelected: (String) -> Unit
) {
    Card(
        modifier = Modifier.fillMaxWidth(),
        colors = CardDefaults.cardColors(
            containerColor = MaterialTheme.colorScheme.surfaceVariant
        )
    ) {
        Column(
            modifier = Modifier.padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            Text(
                text = "Example Queries",
                style = MaterialTheme.typography.titleLarge
            )
            
            Text(
                text = "Try these popular search queries:",
                style = MaterialTheme.typography.bodyMedium,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
            
            Config.EXAMPLE_QUERIES.forEach { query ->
                OutlinedCard(
                    onClick = { onQuerySelected(query) },
                    modifier = Modifier.fillMaxWidth()
                ) {
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(16.dp),
                        horizontalArrangement = Arrangement.SpaceBetween,
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Row(
                            horizontalArrangement = Arrangement.spacedBy(12.dp),
                            verticalAlignment = Alignment.CenterVertically,
                            modifier = Modifier.weight(1f)
                        ) {
                            Icon(
                                imageVector = Icons.Default.Search,
                                contentDescription = null,
                                tint = MaterialTheme.colorScheme.primary
                            )
                            Text(
                                text = query,
                                style = MaterialTheme.typography.bodyMedium
                            )
                        }
                        Icon(
                            imageVector = Icons.Default.ArrowForward,
                            contentDescription = null,
                            tint = MaterialTheme.colorScheme.onSurfaceVariant
                        )
                    }
                }
            }
        }
    }
}
