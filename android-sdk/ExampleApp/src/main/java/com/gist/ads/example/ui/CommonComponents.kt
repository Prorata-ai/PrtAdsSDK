package com.gist.ads.example.ui

import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import com.gist.ads.example.Config

/**
 * Reusable dropdown for API version selection
 */
@Composable
fun ApiVersionDropdown(
    selectedVersion: String,
    onVersionSelected: (String) -> Unit,
    modifier: Modifier = Modifier
) {
    var expanded by remember { mutableStateOf(false) }
    
    ExposedDropdownMenuBox(
        expanded = expanded,
        onExpandedChange = { expanded = !expanded }
    ) {
        OutlinedTextField(
            value = Config.AVAILABLE_API_VERSIONS.find { it.first == selectedVersion }?.second ?: selectedVersion,
            onValueChange = {},
            readOnly = true,
            label = { Text("API Version") },
            trailingIcon = { ExposedDropdownMenuDefaults.TrailingIcon(expanded = expanded) },
            modifier = modifier.fillMaxWidth().menuAnchor()
        )
        
        ExposedDropdownMenu(
            expanded = expanded,
            onDismissRequest = { expanded = false }
        ) {
            Config.AVAILABLE_API_VERSIONS.forEach { (version, label) ->
                DropdownMenuItem(
                    text = { Text(label) },
                    onClick = {
                        onVersionSelected(version)
                        expanded = false
                    }
                )
            }
        }
    }
}

/**
 * Reusable dropdown for query selection
 */
@Composable
fun QueryDropdown(
    selectedQuery: String,
    onQuerySelected: (String) -> Unit,
    label: String = "Query",
    queries: List<String> = Config.SAMPLE_QUERIES,
    modifier: Modifier = Modifier
) {
    var expanded by remember { mutableStateOf(false) }
    
    ExposedDropdownMenuBox(
        expanded = expanded,
        onExpandedChange = { expanded = !expanded }
    ) {
        OutlinedTextField(
            value = selectedQuery,
            onValueChange = {},
            readOnly = true,
            label = { Text(label) },
            trailingIcon = { ExposedDropdownMenuDefaults.TrailingIcon(expanded = expanded) },
            modifier = modifier.fillMaxWidth().menuAnchor()
        )
        
        ExposedDropdownMenu(
            expanded = expanded,
            onDismissRequest = { expanded = false }
        ) {
            queries.forEach { query ->
                DropdownMenuItem(
                    text = { Text(query) },
                    onClick = {
                        onQuerySelected(query)
                        expanded = false
                    }
                )
            }
        }
    }
}

/**
 * Reusable dropdown for geographic region selection
 */
@Composable
fun GeoDropdown(
    selectedGeo: String,
    onGeoSelected: (String) -> Unit,
    modifier: Modifier = Modifier
) {
    var expanded by remember { mutableStateOf(false) }
    
    ExposedDropdownMenuBox(
        expanded = expanded,
        onExpandedChange = { expanded = !expanded }
    ) {
        OutlinedTextField(
            value = Config.AVAILABLE_GEOS.find { it.first == selectedGeo }?.second ?: selectedGeo,
            onValueChange = {},
            readOnly = true,
            label = { Text("Region") },
            trailingIcon = { ExposedDropdownMenuDefaults.TrailingIcon(expanded = expanded) },
            modifier = modifier.fillMaxWidth().menuAnchor()
        )
        
        ExposedDropdownMenu(
            expanded = expanded,
            onDismissRequest = { expanded = false }
        ) {
            Config.AVAILABLE_GEOS.forEach { (code, name) ->
                DropdownMenuItem(
                    text = { Text("$name ($code)") },
                    onClick = {
                        onGeoSelected(code)
                        expanded = false
                    }
                )
            }
        }
    }
}

/**
 * Reusable section title text component
 */
@Composable
fun SectionTitle(text: String, modifier: Modifier = Modifier) {
    Text(
        text = text,
        style = MaterialTheme.typography.titleSmall,
        modifier = modifier
    )
}

/**
 * Reusable info card for displaying key-value pairs
 */
@Composable
fun InfoCard(
    title: String,
    items: List<Pair<String, String>>,
    containerColor: Color = MaterialTheme.colorScheme.primaryContainer,
    contentColor: Color = MaterialTheme.colorScheme.onPrimaryContainer,
    modifier: Modifier = Modifier
) {
    Card(
        modifier = modifier.fillMaxWidth(),
        colors = CardDefaults.cardColors(containerColor = containerColor)
    ) {
        Column(
            modifier = Modifier.padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            Text(
                text = title,
                style = MaterialTheme.typography.titleSmall,
                color = contentColor
            )
            items.forEach { (key, value) ->
                Text(
                    text = "$key: $value",
                    style = MaterialTheme.typography.bodySmall,
                    color = contentColor
                )
            }
        }
    }
}

/**
 * Reusable card wrapper for ad preview with consistent styling
 */
@Composable
fun AdPreviewCard(
    modifier: Modifier = Modifier,
    content: @Composable () -> Unit
) {
    Card(
        modifier = modifier
            .fillMaxWidth()
            .height(250.dp),
        elevation = CardDefaults.cardElevation(defaultElevation = 4.dp)
    ) {
        content()
    }
}
