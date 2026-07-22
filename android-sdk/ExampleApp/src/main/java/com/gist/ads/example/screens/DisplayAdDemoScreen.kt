package com.gist.ads.example.screens

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.PhotoLibrary
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.gist.ads.example.Config
import com.gist.ads.example.ui.AdSizeDropdown
import com.gist.ads.example.ui.SectionTitle
import com.gist.ads.sdk.APIConstants
import com.gist.ads.sdk.models.AdSize
import com.gist.ads.sdk.ui.GistDisplayAdControl
import java.util.UUID

/**
 * Example UI showing GistDisplayAdControl: contextual display ads targeted
 * by publisher ID + page URL + size, with a custom no-fill passback view.
 */
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun DisplayAdDemoScreen() {
    var pageUrl by remember { mutableStateOf("") }
    var selectedSize by remember { mutableStateOf(AdSize.MEDIUM_RECTANGLE) }
    var selectedEnvironment by remember { mutableStateOf(APIConstants.Environment.PRODUCTION) }
    var refreshTrigger by remember { mutableStateOf(UUID.randomUUID()) }

    val availableSizes = remember {
        listOf(
            AdSize.LEADERBOARD, AdSize.SUPER_LEADERBOARD, AdSize.MEDIUM_RECTANGLE,
            AdSize.MOBILE_BANNER, AdSize.BILLBOARD, AdSize.LARGE_RECTANGLE,
            AdSize.SKYSCRAPER, AdSize.DYNAMIC
        )
    }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .verticalScroll(rememberScrollState())
            .padding(16.dp),
        verticalArrangement = Arrangement.spacedBy(16.dp)
    ) {
        Text(
            text = "Gist Display Ads",
            style = MaterialTheme.typography.headlineMedium
        )

        Text(
            text = "Contextual ads targeted by publisher ID + page URL",
            style = MaterialTheme.typography.bodyMedium,
            color = MaterialTheme.colorScheme.onSurfaceVariant
        )

        HorizontalDivider()

        SectionTitle("Page URL:")

        OutlinedTextField(
            value = pageUrl,
            onValueChange = { pageUrl = it },
            placeholder = { Text("https://example.com/article") },
            singleLine = true,
            modifier = Modifier.fillMaxWidth()
        )

        SectionTitle("Ad Size:")

        AdSizeDropdown(
            selectedSize = selectedSize,
            sizes = availableSizes,
            onSizeSelected = {
                selectedSize = it
                refreshTrigger = UUID.randomUUID()
            }
        )

        SectionTitle("Environment:")

        val environments = remember { APIConstants.Environment.values().toList() }

        SingleChoiceSegmentedButtonRow(modifier = Modifier.fillMaxWidth()) {
            environments.forEachIndexed { index, environment ->
                SegmentedButton(
                    selected = selectedEnvironment == environment,
                    onClick = {
                        selectedEnvironment = environment
                        refreshTrigger = UUID.randomUUID()
                    },
                    shape = SegmentedButtonDefaults.itemShape(
                        index = index,
                        count = environments.size
                    )
                ) {
                    Text(environment.name.lowercase().replaceFirstChar { it.uppercase() })
                }
            }
        }

        Button(
            onClick = { refreshTrigger = UUID.randomUUID() },
            modifier = Modifier.fillMaxWidth()
        ) {
            Text("Reload Ad")
        }

        HorizontalDivider()

        SectionTitle("Live Ad Preview:")

        Card(modifier = Modifier.fillMaxWidth()) {
            key(refreshTrigger) {
                GistDisplayAdControl(
                    publisherId = Config.DISPLAY_PUBLISHER_ID,
                    pageUrl = pageUrl,
                    sizes = listOf(selectedSize),
                    environment = selectedEnvironment,
                    modifier = Modifier
                        .fillMaxWidth()
                        .height((selectedSize.height ?: 250).dp),
                    passback = {
                        Column(
                            modifier = Modifier
                                .fillMaxWidth()
                                .padding(24.dp),
                            horizontalAlignment = Alignment.CenterHorizontally,
                            verticalArrangement = Arrangement.Center
                        ) {
                            Icon(
                                imageVector = Icons.Default.PhotoLibrary,
                                contentDescription = "No ad",
                                tint = MaterialTheme.colorScheme.onSurfaceVariant
                            )
                            Spacer(modifier = Modifier.height(8.dp))
                            Text(
                                text = "No ad available right now",
                                style = MaterialTheme.typography.bodyMedium,
                                color = MaterialTheme.colorScheme.onSurfaceVariant
                            )
                            Text(
                                text = "(custom passback content goes here)",
                                style = MaterialTheme.typography.bodySmall,
                                color = MaterialTheme.colorScheme.onSurfaceVariant
                            )
                        }
                    }
                )
            }
        }
    }
}
