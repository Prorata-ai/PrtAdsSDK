package com.gist.ads.example.screens

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.gist.ads.example.Config
import com.gist.ads.sdk.models.AdType
import com.gist.ads.sdk.ui.GistAdControl

/**
 * Example demonstrating ad type filtering and geo targeting
 */
@Composable
fun FilterExampleScreen() {
    var selectedQuery by remember { mutableStateOf(Config.SAMPLE_QUERIES[0]) }
    var queryExpanded by remember { mutableStateOf(false) }
    
    var selectedGeo by remember { mutableStateOf(Config.DEFAULT_GEO) }
    var geoExpanded by remember { mutableStateOf(false) }
    
    var imageEnabled by remember { mutableStateOf(true) }
    var imageTextEnabled by remember { mutableStateOf(true) }
    
    // Build ad types list
    val adTypes = buildList {
        if (imageEnabled) add(AdType.IMAGE)
        if (imageTextEnabled) add(AdType.IMAGE_TEXT)
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
        Text(
            text = "Query",
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
                label = { Text("Select query") },
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
        
        Divider()
        
        // Ad type filters
        Text(
            text = "Ad Types",
            style = MaterialTheme.typography.titleSmall
        )
        
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
                    Text("Image/Text Ads")
                    Switch(
                        checked = imageTextEnabled,
                        onCheckedChange = { imageTextEnabled = it }
                    )
                }
                
                if (!imageEnabled && !imageTextEnabled) {
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
        Text(
            text = "Geographic Targeting",
            style = MaterialTheme.typography.titleSmall
        )
        
        ExposedDropdownMenuBox(
            expanded = geoExpanded,
            onExpandedChange = { geoExpanded = !geoExpanded }
        ) {
            OutlinedTextField(
                value = Config.AVAILABLE_GEOS.find { it.first == selectedGeo }?.second ?: selectedGeo,
                onValueChange = {},
                readOnly = true,
                label = { Text("Region") },
                trailingIcon = { ExposedDropdownMenuDefaults.TrailingIcon(expanded = geoExpanded) },
                modifier = Modifier
                    .fillMaxWidth()
                    .menuAnchor()
            )
            
            ExposedDropdownMenu(
                expanded = geoExpanded,
                onDismissRequest = { geoExpanded = false }
            ) {
                Config.AVAILABLE_GEOS.forEach { (code, name) ->
                    DropdownMenuItem(
                        text = { Text("$name ($code)") },
                        onClick = {
                            selectedGeo = code
                            geoExpanded = false
                        }
                    )
                }
            }
        }
        
        Divider()
        
        // Ad display
        Text(
            text = "Ad Preview",
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
                geo = selectedGeo,
                adTypes = adTypes,
                enableLogging = BuildConfig.DEBUG
            )
        }
        
        Divider()
        
        // Configuration display
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
                    text = "Current Configuration",
                    style = MaterialTheme.typography.titleSmall,
                    color = MaterialTheme.colorScheme.onPrimaryContainer
                )
                Text(
                    text = "Query: $selectedQuery",
                    style = MaterialTheme.typography.bodySmall,
                    color = MaterialTheme.colorScheme.onPrimaryContainer
                )
                Text(
                    text = "Region: ${Config.AVAILABLE_GEOS.find { it.first == selectedGeo }?.second}",
                    style = MaterialTheme.typography.bodySmall,
                    color = MaterialTheme.colorScheme.onPrimaryContainer
                )
                Text(
                    text = "Ad Types: ${if (adTypes == null) "All" else adTypes.joinToString(", ") { it.displayName }}",
                    style = MaterialTheme.typography.bodySmall,
                    color = MaterialTheme.colorScheme.onPrimaryContainer
                )
            }
        }
    }
}

