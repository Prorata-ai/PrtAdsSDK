package com.gist.ads.example.screens

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.gist.ads.example.Config
import com.gist.ads.sdk.ui.GistAdControl

/**
 * Basic example demonstrating simple ad integration
 */
@Composable
fun BasicExampleScreen() {
    var selectedQuery by remember { mutableStateOf(Config.SAMPLE_QUERIES[0]) }
    var expanded by remember { mutableStateOf(false) }
    
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
            expanded = expanded,
            onExpandedChange = { expanded = !expanded }
        ) {
            OutlinedTextField(
                value = selectedQuery,
                onValueChange = {},
                readOnly = true,
                label = { Text("Query") },
                trailingIcon = { ExposedDropdownMenuDefaults.TrailingIcon(expanded = expanded) },
                modifier = Modifier
                    .fillMaxWidth()
                    .menuAnchor()
            )
            
            ExposedDropdownMenu(
                expanded = expanded,
                onDismissRequest = { expanded = false }
            ) {
                Config.SAMPLE_QUERIES.forEach { query ->
                    DropdownMenuItem(
                        text = { Text(query) },
                        onClick = {
                            selectedQuery = query
                            expanded = false
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
                enableLogging = BuildConfig.DEBUG
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
                    text = "Ad Types: All",
                    style = MaterialTheme.typography.bodySmall,
                    color = MaterialTheme.colorScheme.onPrimaryContainer
                )
            }
        }
    }
}

