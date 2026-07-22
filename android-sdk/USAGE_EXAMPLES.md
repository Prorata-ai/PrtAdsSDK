# Usage Examples

Comprehensive examples for using the Gist Ads SDK in your Android application.

## Table of Contents

1. [Basic Usage](#basic-usage)
2. [Display Ads](#display-ads)
3. [Search Ads with Sizes and No-Fill Passback](#search-ads-with-sizes-and-no-fill-passback)
4. [Dynamic Search Integration](#dynamic-search-integration)
5. [Event Callbacks](#event-callbacks)
6. [Theme Support](#theme-support)
7. [Ad Type Filtering](#ad-type-filtering)
8. [Geographic Targeting](#geographic-targeting)
9. [Custom Styling](#custom-styling)
10. [Advanced Patterns](#advanced-patterns)
11. [Error Handling](#error-handling)
12. [Performance Optimization](#performance-optimization)

---

## Basic Usage

### Simple Ad Display

The simplest way to display an ad:

```kotlin
@Composable
fun SimpleAdExample() {
    GistAdControl(
        publisherId = "your-publisher-id",
        publisherKey = "your-publisher-key",
        query = "wireless headphones"
    )
}
```

### Ad with Custom Height

```kotlin
@Composable
fun CustomHeightAdExample() {
    GistAdControl(
        publisherId = "your-publisher-id",
        publisherKey = "your-publisher-key",
        query = "running shoes",
        modifier = Modifier
            .fillMaxWidth()
            .height(300.dp)
    )
}
```

### Ad in a Card

```kotlin
@Composable
fun CardAdExample() {
    Card(
        modifier = Modifier
            .fillMaxWidth()
            .padding(16.dp),
        elevation = CardDefaults.cardElevation(defaultElevation = 4.dp)
    ) {
        GistAdControl(
            publisherId = "your-publisher-id",
            publisherKey = "your-publisher-key",
            query = "smart watches"
        )
    }
}
```

---

## Display Ads

### Display Ad in an Article

Display ads (`GistDisplayAdControl`) are targeted by publisher ID + page URL + size, mirroring the web tag's `defineSlot({id, url}, slotId, sizes)` -> `displayAd(slotId)` flow. The backend crawls `pageUrl` to infer relevance, the same way it would for a real webpage. See "How Display Ads Are Rendered" in the README for how this control embeds the real `adtag.js` script rather than calling any API itself:

```kotlin
import androidx.compose.foundation.layout.*
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.gist.ads.sdk.models.AdSize
import com.gist.ads.sdk.ui.GistDisplayAdControl

@Composable
fun ArticleWithDisplayAd() {
    Column {
        Text("Article content...")

        GistDisplayAdControl(
            publisherId = "pub-12345",
            pageUrl = "https://example.com/articles/ai-trends",
            sizes = listOf(AdSize.MEDIUM_RECTANGLE),
            modifier = Modifier
                .fillMaxWidth()
                .height(250.dp)
        )
    }
}
```

### Display Ad with Custom No-Fill Passback

```kotlin
@Composable
fun DisplayAdWithPassbackExample() {
    GistDisplayAdControl(
        publisherId = "pub-12345",
        pageUrl = "https://example.com/articles/ai-trends",
        sizes = listOf(AdSize.MEDIUM_RECTANGLE),
        passback = {
            Text("Check out our newsletter instead!")
        }
    )
}
```

---

## Search Ads with Sizes and No-Fill Passback

Like display ads, search ads are rendered by embedding `adtag.js` directly, so they need an explicit `sizes` list (defaults to `listOf(AdSize.DYNAMIC)`) and support a custom `passback` composable for when no ad is available:

```kotlin
import com.gist.ads.sdk.models.AdSize
import com.gist.ads.sdk.ui.GistAdControl

@Composable
fun SearchAdWithSizesExample() {
    GistAdControl(
        publisherId = "pub-12345",
        publisherKey = "key-67890",
        query = "wireless headphones",
        sizes = listOf(AdSize.MEDIUM_RECTANGLE, AdSize.LEADERBOARD),
        passback = {
            Text(
                "Check out our newsletter instead!",
                style = MaterialTheme.typography.bodySmall,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
        },
        modifier = Modifier.fillMaxWidth().height(250.dp)
    )
}
```

---

## Dynamic Search Integration

### Basic Search

```kotlin
@Composable
fun BasicSearchExample() {
    var searchQuery by remember { mutableStateOf("") }
    
    Column {
        OutlinedTextField(
            value = searchQuery,
            onValueChange = { searchQuery = it },
            modifier = Modifier.fillMaxWidth(),
            placeholder = { Text("Search...") }
        )
        
        if (searchQuery.isNotBlank()) {
            GistAdControl(
                publisherId = "your-publisher-id",
                publisherKey = "your-publisher-key",
                query = searchQuery
            )
        }
    }
}
```

### Search with Debouncing

Optimize API calls by debouncing search input:

```kotlin
@Composable
fun DebouncedSearchExample() {
    var searchText by remember { mutableStateOf("") }
    var debouncedQuery by remember { mutableStateOf("") }
    
    // Debounce search input
    LaunchedEffect(searchText) {
        delay(500) // 500ms delay
        debouncedQuery = searchText
    }
    
    Column {
        OutlinedTextField(
            value = searchText,
            onValueChange = { searchText = it },
            modifier = Modifier.fillMaxWidth(),
            placeholder = { Text("Search products...") }
        )
        
        if (debouncedQuery.isNotBlank()) {
            GistAdControl(
                publisherId = "your-publisher-id",
                publisherKey = "your-publisher-key",
                query = debouncedQuery
            )
        }
    }
}
```

### Search with Keyboard Actions

```kotlin
@Composable
fun KeyboardSearchExample() {
    var searchQuery by remember { mutableStateOf("") }
    val keyboardController = LocalSoftwareKeyboardController.current
    
    Column {
        OutlinedTextField(
            value = searchQuery,
            onValueChange = { searchQuery = it },
            modifier = Modifier.fillMaxWidth(),
            placeholder = { Text("Search...") },
            keyboardOptions = KeyboardOptions(imeAction = ImeAction.Search),
            keyboardActions = KeyboardActions(
                onSearch = {
                    keyboardController?.hide()
                }
            )
        )
        
        if (searchQuery.isNotBlank()) {
            GistAdControl(
                publisherId = "your-publisher-id",
                publisherKey = "your-publisher-key",
                query = searchQuery
            )
        }
    }
}
```

---

## Theme Support

The SDK automatically adapts ads to light and dark mode, with support for system detection and manual override.

### Automatic Theme Detection (Default)

By default, ads automatically match your device's theme:

```kotlin
@Composable
fun AutoThemeAdExample() {
    GistAdControl(
        publisherId = "your-publisher-id",
        publisherKey = "your-publisher-key",
        query = "wireless headphones"
        // theme = "system" is the default
    )
}
```

### Manual Theme Override

Force a specific theme for your ads:

```kotlin
@Composable
fun LightThemeAdExample() {
    GistAdControl(
        publisherId = "your-publisher-id",
        publisherKey = "your-publisher-key",
        query = "running shoes",
        theme = "light"  // Always show light theme
    )
}

@Composable
fun DarkThemeAdExample() {
    GistAdControl(
        publisherId = "your-publisher-id",
        publisherKey = "your-publisher-key",
        query = "smart watch",
        theme = "dark"  // Always show dark theme
    )
}
```

### Theme Picker UI

Let users choose their preferred ad theme:

```kotlin
@Composable
fun AdWithThemePicker() {
    var selectedTheme by remember { mutableStateOf("system") }
    
    Column(
        modifier = Modifier
            .fillMaxWidth()
            .padding(16.dp),
        verticalArrangement = Arrangement.spacedBy(16.dp)
    ) {
        // Theme selector
        Text(
            text = "Ad Theme",
            style = MaterialTheme.typography.labelMedium
        )
        
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            FilterChip(
                selected = selectedTheme == "system",
                onClick = { selectedTheme = "system" },
                label = { Text("System") },
                modifier = Modifier.weight(1f)
            )
            FilterChip(
                selected = selectedTheme == "light",
                onClick = { selectedTheme = "light" },
                label = { Text("Light") },
                modifier = Modifier.weight(1f)
            )
            FilterChip(
                selected = selectedTheme == "dark",
                onClick = { selectedTheme = "dark" },
                label = { Text("Dark") },
                modifier = Modifier.weight(1f)
            )
        }
        
        // Ad with selected theme
        GistAdControl(
            publisherId = "your-publisher-id",
            publisherKey = "your-publisher-key",
            query = "wireless headphones",
            theme = selectedTheme,
            modifier = Modifier
                .fillMaxWidth()
                .height(250.dp)
        )
    }
}
```

### Theme with State Persistence

Save theme preference across app restarts:

```kotlin
@Composable
fun PersistentThemeAd() {
    val context = LocalContext.current
    val sharedPrefs = context.getSharedPreferences("ad_prefs", Context.MODE_PRIVATE)
    var selectedTheme by remember { 
        mutableStateOf(sharedPrefs.getString("ad_theme", "system") ?: "system") 
    }
    
    fun saveTheme(theme: String) {
        selectedTheme = theme
        sharedPrefs.edit().putString("ad_theme", theme).apply()
    }
    
    Column {
        // Theme selector
        Row {
            listOf("system", "light", "dark").forEach { theme ->
                FilterChip(
                    selected = selectedTheme == theme,
                    onClick = { saveTheme(theme) },
                    label = { Text(theme.capitalize()) }
                )
            }
        }
        
        // Ad
        GistAdControl(
            publisherId = "your-publisher-id",
            publisherKey = "your-publisher-key",
            query = "laptops",
            theme = selectedTheme
        )
    }
}
```

---

## Ad Type Filtering

### Filter Specific Ad Types

```kotlin
@Composable
fun FilteredAdsExample() {
    GistAdControl(
        publisherId = "your-publisher-id",
        publisherKey = "your-publisher-key",
        query = "laptops",
        adTypes = listOf(AdType.IMAGE, AdType.TEXT_IMAGE, AdType.TEXT)
    )
}
```

### Dynamic Ad Type Selection with All Three Types

```kotlin
@Composable
fun DynamicFilterExample() {
    var showImages by remember { mutableStateOf(true) }
    var showTextImage by remember { mutableStateOf(true) }
    var showText by remember { mutableStateOf(true) }
    
    val adTypes = buildList {
        if (showImages) add(AdType.IMAGE)
        if (showTextImage) add(AdType.TEXT_IMAGE)
        if (showText) add(AdType.TEXT)
    }.ifEmpty { null }
    
    Column {
        // Filter controls
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween
        ) {
            Text("Image Ads")
            Switch(
                checked = showImages,
                onCheckedChange = { showImages = it }
            )
        }
        
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween
        ) {
            Text("Text/Image Ads")
            Switch(
                checked = showTextImage,
                onCheckedChange = { showTextImage = it }
            )
        }
        
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween
        ) {
            Text("Text Ads")
            Switch(
                checked = showText,
                onCheckedChange = { showText = it }
            )
        }
        
        if (adTypes == null) {
            Text(
                text = "⚠️ All ad types disabled",
                color = MaterialTheme.colorScheme.error
            )
        }
        
        Spacer(modifier = Modifier.height(16.dp))
        
        // Ad with filters
        GistAdControl(
            publisherId = "your-publisher-id",
            publisherKey = "your-publisher-key",
            query = "digital cameras",
            adTypes = adTypes
        )
    }
}
```

---

## Geographic Targeting

### Target Specific Region

```kotlin
@Composable
fun GeoTargetedAdExample() {
    GistAdControl(
        publisherId = "your-publisher-id",
        publisherKey = "your-publisher-key",
        query = "local services",
        geo = "GB" // United Kingdom
    )
}
```

### Dynamic Region Selection

```kotlin
@Composable
fun MultiRegionExample() {
    var selectedGeo by remember { mutableStateOf("US") }
    val regions = listOf("US", "GB", "CA", "AU", "DE")
    var expanded by remember { mutableStateOf(false) }
    
    Column {
        ExposedDropdownMenuBox(
            expanded = expanded,
            onExpandedChange = { expanded = !expanded }
        ) {
            OutlinedTextField(
                value = selectedGeo,
                onValueChange = {},
                readOnly = true,
                label = { Text("Region") },
                trailingIcon = {
                    ExposedDropdownMenuDefaults.TrailingIcon(expanded = expanded)
                },
                modifier = Modifier
                    .fillMaxWidth()
                    .menuAnchor()
            )
            
            ExposedDropdownMenu(
                expanded = expanded,
                onDismissRequest = { expanded = false }
            ) {
                regions.forEach { region ->
                    DropdownMenuItem(
                        text = { Text(region) },
                        onClick = {
                            selectedGeo = region
                            expanded = false
                        }
                    )
                }
            }
        }
        
        Spacer(modifier = Modifier.height(16.dp))
        
        GistAdControl(
            publisherId = "your-publisher-id",
            publisherKey = "your-publisher-key",
            query = "local restaurants",
            geo = selectedGeo
        )
    }
}
```

---

## Custom Styling

### Styled Card Ad

```kotlin
@Composable
fun StyledCardAdExample() {
    Surface(
        modifier = Modifier
            .fillMaxWidth()
            .padding(16.dp),
        shape = RoundedCornerShape(16.dp),
        shadowElevation = 8.dp,
        tonalElevation = 2.dp,
        color = MaterialTheme.colorScheme.surfaceVariant
    ) {
        GistAdControl(
            publisherId = "your-publisher-id",
            publisherKey = "your-publisher-key",
            query = "premium products",
            modifier = Modifier.padding(8.dp)
        )
    }
}
```

### Ad with Border

```kotlin
@Composable
fun BorderedAdExample() {
    Box(
        modifier = Modifier
            .fillMaxWidth()
            .border(
                width = 2.dp,
                color = MaterialTheme.colorScheme.primary,
                shape = RoundedCornerShape(8.dp)
            )
            .padding(4.dp)
    ) {
        GistAdControl(
            publisherId = "your-publisher-id",
            publisherKey = "your-publisher-key",
            query = "featured deals"
        )
    }
}
```

### Ad with Custom Background

```kotlin
@Composable
fun CustomBackgroundAdExample() {
    Box(
        modifier = Modifier
            .fillMaxWidth()
            .background(
                brush = Brush.verticalGradient(
                    colors = listOf(
                        MaterialTheme.colorScheme.primaryContainer,
                        MaterialTheme.colorScheme.surfaceVariant
                    )
                ),
                shape = RoundedCornerShape(12.dp)
            )
            .padding(16.dp)
    ) {
        GistAdControl(
            publisherId = "your-publisher-id",
            publisherKey = "your-publisher-key",
            query = "trending products"
        )
    }
}
```

---

## Advanced Patterns

### Ad in LazyColumn

```kotlin
@Composable
fun ListWithAdsExample() {
    LazyColumn {
        items(20) { index ->
            ListItem(
                headlineContent = { Text("Item $index") },
                supportingContent = { Text("Description") }
            )
            
            // Show ad every 5 items
            if (index % 5 == 4) {
                item {
                    GistAdControl(
                        publisherId = "your-publisher-id",
                        publisherKey = "your-publisher-key",
                        query = "sponsored content",
                        modifier = Modifier
                            .fillMaxWidth()
                            .height(200.dp)
                            .padding(vertical = 8.dp)
                    )
                }
            }
        }
    }
}
```

### Ad with Pull-to-Refresh

```kotlin
@Composable
fun PullToRefreshAdExample() {
    var refreshing by remember { mutableStateOf(false) }
    var adKey by remember { mutableStateOf(0) }
    
    SwipeRefresh(
        state = rememberSwipeRefreshState(refreshing),
        onRefresh = {
            refreshing = true
            adKey++ // Force ad refresh
            refreshing = false
        }
    ) {
        Column {
            Text("Pull to refresh ad")
            
            GistAdControl(
                publisherId = "your-publisher-id",
                publisherKey = "your-publisher-key",
                query = "latest products",
                modifier = Modifier.fillMaxWidth()
            )
        }
    }
}
```

### Ad in ViewModel Pattern

```kotlin
class AdViewModel : ViewModel() {
    private val _searchQuery = MutableStateFlow("")
    val searchQuery: StateFlow<String> = _searchQuery.asStateFlow()
    
    fun updateQuery(query: String) {
        _searchQuery.value = query
    }
}

@Composable
fun ViewModelAdExample(viewModel: AdViewModel = viewModel()) {
    val query by viewModel.searchQuery.collectAsState()
    
    Column {
        TextField(
            value = query,
            onValueChange = { viewModel.updateQuery(it) }
        )
        
        if (query.isNotBlank()) {
            GistAdControl(
                publisherId = "your-publisher-id",
                publisherKey = "your-publisher-key",
                query = query
            )
        }
    }
}
```

---

## Error Handling

The SDK handles errors automatically, but you can respond to different states:

### Monitor Loading State

```kotlin
@Composable
fun LoadingMonitorExample() {
    var isAdVisible by remember { mutableStateOf(false) }
    
    Column {
        if (!isAdVisible) {
            Text("Ad is loading...")
        }
        
        GistAdControl(
            publisherId = "your-publisher-id",
            publisherKey = "your-publisher-key",
            query = "products"
        )
    }
}
```

---

## Performance Optimization

### Conditional Ad Loading

```kotlin
@Composable
fun ConditionalAdExample() {
    var showAd by remember { mutableStateOf(false) }
    
    Column {
        Button(onClick = { showAd = !showAd }) {
            Text(if (showAd) "Hide Ad" else "Show Ad")
        }
        
        if (showAd) {
            GistAdControl(
                publisherId = "your-publisher-id",
                publisherKey = "your-publisher-key",
                query = "products"
            )
        }
    }
}
```

### Lazy Loading

```kotlin
@Composable
fun LazyLoadAdExample() {
    var isVisible by remember { mutableStateOf(false) }
    
    LaunchedEffect(Unit) {
        delay(1000) // Delay ad loading
        isVisible = true
    }
    
    if (isVisible) {
        GistAdControl(
            publisherId = "your-publisher-id",
            publisherKey = "your-publisher-key",
            query = "products"
        )
    }
}
```

---

## Complete Example

A comprehensive example combining multiple features:

```kotlin
@Composable
fun CompleteExample() {
    var searchText by remember { mutableStateOf("") }
    var debouncedQuery by remember { mutableStateOf("") }
    var selectedGeo by remember { mutableStateOf("US") }
    var imageEnabled by remember { mutableStateOf(true) }
    var textImageEnabled by remember { mutableStateOf(true) }
    var textEnabled by remember { mutableStateOf(true) }
    var adLoadCount by remember { mutableStateOf(0) }
    var adHeight by remember { mutableStateOf(250.dp) }
    val density = LocalDensity.current
    
    // Debounce
    LaunchedEffect(searchText) {
        delay(500)
        debouncedQuery = searchText
    }
    
    // Build ad types
    val adTypes = buildList {
        if (imageEnabled) add(AdType.IMAGE)
        if (textImageEnabled) add(AdType.TEXT_IMAGE)
        if (textEnabled) add(AdType.TEXT)
    }.ifEmpty { null }
    
    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(16.dp)
            .verticalScroll(rememberScrollState()),
        verticalArrangement = Arrangement.spacedBy(16.dp)
    ) {
        Text("Gist Ads Demo", style = MaterialTheme.typography.headlineMedium)
        
        // Search field
        OutlinedTextField(
            value = searchText,
            onValueChange = { searchText = it },
            modifier = Modifier.fillMaxWidth(),
            label = { Text("Search...") },
            placeholder = { Text("wireless headphones") }
        )
        
        // Ad type filters
        Text("Ad Types", style = MaterialTheme.typography.labelLarge)
        Row {
            Checkbox(checked = imageEnabled, onCheckedChange = { imageEnabled = it })
            Text("Images", modifier = Modifier.align(Alignment.CenterVertically))
            Spacer(modifier = Modifier.width(8.dp))
            Checkbox(checked = textImageEnabled, onCheckedChange = { textImageEnabled = it })
            Text("Text/Image", modifier = Modifier.align(Alignment.CenterVertically))
            Spacer(modifier = Modifier.width(8.dp))
            Checkbox(checked = textEnabled, onCheckedChange = { textEnabled = it })
            Text("Text", modifier = Modifier.align(Alignment.CenterVertically))
        }
        
        // Region selector
        Text("Region", style = MaterialTheme.typography.labelLarge)
        Row(
            modifier = Modifier.horizontalScroll(rememberScrollState()),
            horizontalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            listOf("US", "GB", "CA", "AU", "DE", "FR", "JP", "IN").forEach { region ->
                FilterChip(
                    selected = selectedGeo == region,
                    onClick = { selectedGeo = region },
                    label = { Text(region) }
                )
            }
        }
        
        Divider()
        
        // Ad display
        if (debouncedQuery.isNotBlank()) {
            Text("Ad Preview", style = MaterialTheme.typography.titleMedium)
            
            Card(
                modifier = Modifier.fillMaxWidth()
            ) {
                GistAdControl(
                    publisherId = BuildConfig.GIST_PUBLISHER_ID,
                    publisherKey = BuildConfig.GIST_PUBLISHER_KEY,
                    query = debouncedQuery,
                    geo = selectedGeo,
                    adTypes = adTypes,
                    onAdLoaded = {
                        adLoadCount++
                        println("✅ Ad #$adLoadCount loaded")
                    },
                    onContentHeightChanged = { heightPx ->
                        adHeight = with(density) { heightPx.toDp() }
                        println("📏 Height: $adHeight")
                    },
                    // onAdClicked not provided - opens in browser automatically
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(adHeight)
                )
            }
            
            // Stats
            Divider()
            Card(
                colors = CardDefaults.cardColors(
                    containerColor = MaterialTheme.colorScheme.secondaryContainer
                )
            ) {
                Column(modifier = Modifier.padding(16.dp)) {
                    Text("Stats", style = MaterialTheme.typography.titleSmall)
                    Text("Query: $debouncedQuery")
                    Text("Region: $selectedGeo")
                    Text("Types: ${adTypes?.joinToString { it.displayName } ?: "All"}")
                    Text("Loads: $adLoadCount")
                    Text("Height: ${adHeight.value.toInt()}dp")
                    Text("Clicks: Open in browser")
                }
            }
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
                        .padding(48.dp),
                    contentAlignment = Alignment.Center
                ) {
                    Text(
                        text = "Start typing to see ads",
                        style = MaterialTheme.typography.bodyLarge
                    )
                }
            }
        }
    }
}
```

---

## Additional Resources

- [README](README.md) - Full SDK documentation
- [Quick Start](QUICK_START.md) - Get started quickly
- [Integration Guide](INTEGRATION_GUIDE.md) - Detailed integration steps
- [Example App](ExampleApp/README.md) - Complete example application

---

**Need Help?** Contact <support@gist.com>
