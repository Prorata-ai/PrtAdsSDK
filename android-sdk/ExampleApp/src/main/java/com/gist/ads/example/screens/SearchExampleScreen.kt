package com.gist.ads.example.screens

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.text.KeyboardActions
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Clear
import androidx.compose.material.icons.filled.Search
import androidx.compose.material3.*
import androidx.compose.material3.HorizontalDivider
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalSoftwareKeyboardController
import androidx.compose.ui.text.input.ImeAction
import androidx.compose.ui.unit.dp
import com.gist.ads.example.Config
import com.gist.ads.example.ui.*
import com.gist.ads.sdk.ui.GistAdControl
import kotlinx.coroutines.delay

/**
 * Example demonstrating dynamic search integration with debouncing
 */
@Composable
fun SearchExampleScreen() {
    var searchText by remember { mutableStateOf("") }
    var debouncedQuery by remember { mutableStateOf("") }
    val keyboardController = LocalSoftwareKeyboardController.current
    
    // Debounce search input
    LaunchedEffect(searchText) {
        delay(500) // Wait 500ms after user stops typing
        debouncedQuery = searchText
    }
    
    Column(
        modifier = Modifier
            .fillMaxSize()
            .verticalScroll(rememberScrollState())
            .padding(16.dp),
        verticalArrangement = Arrangement.spacedBy(16.dp)
    ) {
        Text(
            text = "Dynamic Search",
            style = MaterialTheme.typography.headlineMedium
        )
        
        Text(
            text = "Type a search query to see ads update dynamically. The search is debounced for better performance.",
            style = MaterialTheme.typography.bodyMedium,
            color = MaterialTheme.colorScheme.onSurfaceVariant
        )
        
        HorizontalDivider()
        
        // Search field
        OutlinedTextField(
            value = searchText,
            onValueChange = { searchText = it },
            modifier = Modifier.fillMaxWidth(),
            label = { Text("Search for products...") },
            placeholder = { Text("e.g., wireless headphones") },
            leadingIcon = { Icon(Icons.Filled.Search, contentDescription = "Search") },
            trailingIcon = {
                if (searchText.isNotEmpty()) {
                    IconButton(onClick = { searchText = "" }) {
                        Icon(Icons.Filled.Clear, contentDescription = "Clear")
                    }
                }
            },
            singleLine = true,
            keyboardOptions = KeyboardOptions(imeAction = ImeAction.Search),
            keyboardActions = KeyboardActions(
                onSearch = {
                    keyboardController?.hide()
                }
            )
        )
        
        // Suggestion chips
        if (searchText.isEmpty()) {
            Text(
                text = "Try these searches:",
                style = MaterialTheme.typography.labelMedium,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
            
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                Config.SAMPLE_QUERIES.take(3).forEach { query ->
                    SuggestionChip(
                        onClick = { searchText = query },
                        label = { Text(query, style = MaterialTheme.typography.labelSmall) }
                    )
                }
            }
        }
        
        HorizontalDivider()
        
        // Ad display
        if (debouncedQuery.isNotBlank()) {
            Text(
                text = "Search Results for \"$debouncedQuery\"",
                style = MaterialTheme.typography.titleMedium
            )
            
            AdPreviewCard {
                GistAdControl(
                    publisherId = Config.PUBLISHER_ID,
                    publisherKey = Config.PUBLISHER_KEY,
                    query = debouncedQuery,
                    geo = Config.DEFAULT_GEO,
                    onAdLoaded = {
                        println("SearchExample: Ad loaded for query: $debouncedQuery")
                    },
                    // onAdClicked removed - ads will automatically open in browser when clicked
                    onContentHeightChanged = { height ->
                        println("SearchExample: Content height - ${height}px")
                    },
                    theme = "system"
                )
            }
            
            Spacer(modifier = Modifier.height(8.dp))
            
            // Placeholder for search results
            Text(
                text = "Search results would appear here...",
                style = MaterialTheme.typography.bodyMedium,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
        } else {
            Card(
                modifier = Modifier.fillMaxWidth(),
                colors = CardDefaults.cardColors(
                    containerColor = MaterialTheme.colorScheme.surfaceVariant
                )
            ) {
                Box(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(32.dp),
                    contentAlignment = androidx.compose.ui.Alignment.Center
                ) {
                    Text(
                        text = "Start typing to see ads",
                        style = MaterialTheme.typography.bodyLarge,
                        color = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                }
            }
        }
        
        HorizontalDivider()
        
        // Info
        Card(
            modifier = Modifier.fillMaxWidth(),
            colors = CardDefaults.cardColors(
                containerColor = MaterialTheme.colorScheme.tertiaryContainer
            )
        ) {
            Column(
                modifier = Modifier.padding(16.dp),
                verticalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                Text(
                    text = "💡 Tip",
                    style = MaterialTheme.typography.titleSmall,
                    color = MaterialTheme.colorScheme.onTertiaryContainer
                )
                Text(
                    text = "This demo uses a 500ms debounce delay to optimize API calls. The ad updates automatically as you type.",
                    style = MaterialTheme.typography.bodySmall,
                    color = MaterialTheme.colorScheme.onTertiaryContainer
                )
            }
        }
    }
}

