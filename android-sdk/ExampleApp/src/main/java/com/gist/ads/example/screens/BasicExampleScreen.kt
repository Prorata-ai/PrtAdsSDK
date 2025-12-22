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
import com.gist.ads.sdk.ui.GistAdControl

/**
 * Basic example demonstrating simple ad integration
 */
@Composable
fun BasicExampleScreen() {
    var selectedQuery by remember { mutableStateOf(Config.SAMPLE_QUERIES[0]) }
    var selectedApiVersion by remember { mutableStateOf(Config.DEFAULT_API_VERSION) }
    var queryExpanded by remember { mutableStateOf(false) }
    var apiVersionExpanded by remember { mutableStateOf(false) }
    
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
        Text(
            text = "Select a query:",
            style = MaterialTheme.typography.titleSmall
        )
        
        ExposedDropdownMenuBox(
            expanded = queryExpanded,
            onExpandedChange = { queryExpanded = !queryExpanded }
        ) {
            OutlinedTextField(
                value = selectedQuery,
                onValueChange = {},
                readOnly = true,
                label = { Text("Query") },
                trailingIcon = { ExposedDropdownMenuDefaults.TrailingIcon(expanded = queryExpanded) },
                modifier = Modifier
                    .fillMaxWidth()
                    .menuAnchor()
            )
            
            ExposedDropdownMenu(
                expanded = queryExpanded,
                onDismissRequest = { queryExpanded = false }
            ) {
                Config.SAMPLE_QUERIES.forEach { query ->
                    DropdownMenuItem(
                        text = { Text(query) },
                        onClick = {
                            selectedQuery = query
                            queryExpanded = false
                        }
                    )
                }
            }
        }
        
        // API Version selector
        Text(
            text = "Select API version:",
            style = MaterialTheme.typography.titleSmall
        )
        
        ExposedDropdownMenuBox(
            expanded = apiVersionExpanded,
            onExpandedChange = { apiVersionExpanded = !apiVersionExpanded }
        ) {
            OutlinedTextField(
                value = Config.AVAILABLE_API_VERSIONS.find { it.first == selectedApiVersion }?.second ?: selectedApiVersion,
                onValueChange = {},
                readOnly = true,
                label = { Text("API Version") },
                trailingIcon = { ExposedDropdownMenuDefaults.TrailingIcon(expanded = apiVersionExpanded) },
                modifier = Modifier
                    .fillMaxWidth()
                    .menuAnchor()
            )
            
            ExposedDropdownMenu(
                expanded = apiVersionExpanded,
                onDismissRequest = { apiVersionExpanded = false }
            ) {
                Config.AVAILABLE_API_VERSIONS.forEach { (version, label) ->
                    DropdownMenuItem(
                        text = { Text(label) },
                        onClick = {
                            selectedApiVersion = version
                            apiVersionExpanded = false
                        }
                    )
                }
            }
        }
        
        Divider()
        
        // Ad display
        Text(
            text = "Ad Preview:",
            style = MaterialTheme.typography.titleSmall
        )
        
        Card(
            modifier = Modifier
                .fillMaxWidth()
                .height(250.dp),
            elevation = CardDefaults.cardElevation(defaultElevation = 4.dp)
        ) {
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
        Card(
            modifier = Modifier.fillMaxWidth(),
            colors = CardDefaults.cardColors(
                containerColor = MaterialTheme.colorScheme.primaryContainer
            )
        ) {
            Column(
                modifier = Modifier.padding(16.dp),
                verticalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                Text(
                    text = "Configuration",
                    style = MaterialTheme.typography.titleSmall,
                    color = MaterialTheme.colorScheme.onPrimaryContainer
                )
                Text(
                    text = "Query: $selectedQuery",
                    style = MaterialTheme.typography.bodySmall,
                    color = MaterialTheme.colorScheme.onPrimaryContainer
                )
                Text(
                    text = "Geo: ${Config.DEFAULT_GEO}",
                    style = MaterialTheme.typography.bodySmall,
                    color = MaterialTheme.colorScheme.onPrimaryContainer
                )
                Text(
                    text = "API Version: $selectedApiVersion",
                    style = MaterialTheme.typography.bodySmall,
                    color = MaterialTheme.colorScheme.onPrimaryContainer
                )
                Text(
                    text = "Ad Types: All",
                    style = MaterialTheme.typography.bodySmall,
                    color = MaterialTheme.colorScheme.onPrimaryContainer
                )
            }
        }
        
        Divider()
        
        // Event callbacks card
        Card(
            modifier = Modifier.fillMaxWidth(),
            colors = CardDefaults.cardColors(
                containerColor = MaterialTheme.colorScheme.secondaryContainer
            )
        ) {
            Column(
                modifier = Modifier.padding(16.dp),
                verticalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                Text(
                    text = "Event Callbacks",
                    style = MaterialTheme.typography.titleSmall,
                    color = MaterialTheme.colorScheme.onSecondaryContainer
                )
                Text(
                    text = "Ads Loaded: $adLoadedCount",
                    style = MaterialTheme.typography.bodySmall,
                    color = MaterialTheme.colorScheme.onSecondaryContainer
                )
                Text(
                    text = "Content Height: ${contentHeight?.toInt() ?: "Not measured"}px",
                    style = MaterialTheme.typography.bodySmall,
                    color = MaterialTheme.colorScheme.onSecondaryContainer
                )
                lastClickedUrl?.let { url ->
                    Text(
                        text = "Last Click: ${url.take(50)}...",
                        style = MaterialTheme.typography.bodySmall,
                        color = MaterialTheme.colorScheme.onSecondaryContainer
                    )
                }
            }
        }
    }
}

