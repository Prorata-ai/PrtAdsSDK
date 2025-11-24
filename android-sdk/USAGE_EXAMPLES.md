# Usage Examples

Comprehensive examples for using the Gist Ads SDK in your Android application.

## Table of Contents

1. [Basic Usage](#basic-usage)
2. [Dynamic Search Integration](#dynamic-search-integration)
3. [Ad Type Filtering](#ad-type-filtering)
4. [Geographic Targeting](#geographic-targeting)
5. [Custom Styling](#custom-styling)
6. [Advanced Patterns](#advanced-patterns)
7. [Error Handling](#error-handling)
8. [Performance Optimization](#performance-optimization)

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

## Ad Type Filtering

### Filter Specific Ad Types

```kotlin
@Composable
fun FilteredAdsExample() {
    GistAdControl(
        publisherId = "your-publisher-id",
        publisherKey = "your-publisher-key",
        query = "laptops",
        adTypes = listOf(AdType.IMAGE, AdType.IMAGE_TEXT)
    )
}
```

### Dynamic Ad Type Selection

```kotlin
@Composable
fun DynamicFilterExample() {
    var showImages by remember { mutableStateOf(true) }
    var showImageText by remember { mutableStateOf(true) }
    
    val adTypes = buildList {
        if (showImages) add(AdType.IMAGE)
        if (showImageText) add(AdType.IMAGE_TEXT)
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
            Text("Image/Text Ads")
            Switch(
                checked = showImageText,
                onCheckedChange = { showImageText = it }
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

## Debug Mode

Enable logging for development:

```kotlin
@Composable
fun DebugAdExample() {
    GistAdControl(
        publisherId = "your-publisher-id",
        publisherKey = "your-publisher-key",
        query = "test products",
        enableLogging = BuildConfig.DEBUG // Only in debug builds
    )
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
    var imageTextEnabled by remember { mutableStateOf(true) }
    
    // Debounce
    LaunchedEffect(searchText) {
        delay(500)
        debouncedQuery = searchText
    }
    
    // Build ad types
    val adTypes = buildList {
        if (imageEnabled) add(AdType.IMAGE)
        if (imageTextEnabled) add(AdType.IMAGE_TEXT)
    }.ifEmpty { null }
    
    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(16.dp),
        verticalArrangement = Arrangement.spacedBy(16.dp)
    ) {
        // Search field
        OutlinedTextField(
            value = searchText,
            onValueChange = { searchText = it },
            modifier = Modifier.fillMaxWidth(),
            placeholder = { Text("Search...") }
        )
        
        // Filters
        Row {
            Switch(checked = imageEnabled, onCheckedChange = { imageEnabled = it })
            Text("Images")
            Spacer(modifier = Modifier.width(16.dp))
            Switch(checked = imageTextEnabled, onCheckedChange = { imageTextEnabled = it })
            Text("Image/Text")
        }
        
        // Region selector
        // (ExposedDropdownMenuBox implementation)
        
        // Ad
        if (debouncedQuery.isNotBlank()) {
            Card(
                modifier = Modifier
                    .fillMaxWidth()
                    .height(250.dp)
            ) {
                GistAdControl(
                    publisherId = BuildConfig.GIST_PUBLISHER_ID,
                    publisherKey = BuildConfig.GIST_PUBLISHER_KEY,
                    query = debouncedQuery,
                    geo = selectedGeo,
                    adTypes = adTypes,
                    enableLogging = BuildConfig.DEBUG
                )
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

**Need Help?** Contact support@gist.com

