# Gist Ads SDK - Example App

This is a comprehensive example application demonstrating the features and capabilities of the Gist Ads SDK for Android.

## Overview

The example app showcases:

- ✨ Basic ad integration with predefined queries
- 🔍 Dynamic search with real-time ad updates and debouncing
- 🎛️ Ad type filtering (Image, Text/Image, Text)
- 🌍 Geographic targeting across multiple regions
- 🔄 API version switching (V1 and V2)
- 📢 Event callbacks (onAdLoaded, onContentHeightChanged)
- ⚙️ Configuration and settings display

## Setup

### 1. Configure Credentials

Open `Config.kt` and replace the placeholder values with your actual credentials:

```kotlin
object Config {
    const val PUBLISHER_ID = "your-publisher-id"  // Replace with your ID
    const val PUBLISHER_KEY = "your-publisher-key" // Replace with your key
}
```

### 2. Build and Run

**Using Gradle:**

```bash
# From android-sdk directory
./gradlew :ExampleApp:installDebug

# Then launch manually or use
./gradlew :ExampleApp:installDebug && adb shell am start -n com.gist.ads.example/.MainActivity
```

**Or open in Android Studio:**

1. Open the `android-sdk` directory in Android Studio
2. Select the `ExampleApp` run configuration
3. Click Run or press Shift+F10

## App Structure

### Screens

#### 1. Basic Example (`screens/BasicExampleScreen.kt`)

- **Purpose**: Demonstrates simple ad integration
- **Features**:
  - Query selection from predefined list
  - API version switcher (V1/V2)
  - Event callback demonstration
  - Real-time event tracking (ad loads, content height)
  - Configuration display card

**Key Code:**

```kotlin
GistAdControl(
    publisherId = Config.PUBLISHER_ID,
    publisherKey = Config.PUBLISHER_KEY,
    query = selectedQuery,
    apiVersion = selectedApiVersion,
    onAdLoaded = { adLoadedCount++ },
    onContentHeightChanged = { height -> contentHeight = height }
)
```

#### 2. Search Example (`screens/SearchExampleScreen.kt`)

- **Purpose**: Shows dynamic search integration
- **Features**:
  - Real-time search text field
  - 500ms debounced input
  - Search suggestion chips
  - API version selection
  - Live ad updates as you type

**Key Code:**

```kotlin
var searchText by remember { mutableStateOf("") }
var debouncedQuery by remember { mutableStateOf("") }

LaunchedEffect(searchText) {
    delay(500) // Debounce
    debouncedQuery = searchText
}

if (debouncedQuery.isNotBlank()) {
    GistAdControl(query = debouncedQuery, ...)
}
```

#### 3. Filter Example (`screens/FilterExampleScreen.kt`)

- **Purpose**: Demonstrates ad filtering and targeting
- **Features**:
  - Ad type toggles (Image, Text/Image, Text)
  - Geographic region selector (8 countries)
  - Query selection
  - API version switcher
  - Live configuration preview
  - Warning when no ad types selected

**Key Code:**

```kotlin
val adTypes = buildList {
    if (imageEnabled) add(AdType.IMAGE)
    if (textImageEnabled) add(AdType.TEXT_IMAGE)
    if (textEnabled) add(AdType.TEXT)
}.ifEmpty { null }

GistAdControl(
    adTypes = adTypes,
    geo = selectedGeo,
    ...
)
```

#### 4. Settings (`screens/SettingsScreen.kt`)

- **Purpose**: Display SDK configuration and info
- **Features**:
  - SDK version information
  - App configuration display (API version, environment)
  - Feature list
  - Documentation links
  - About information

### Reusable Components (`ui/CommonComponents.kt`)

The app includes several reusable UI components to reduce code duplication:

- **`ApiVersionDropdown`** - Dropdown for API version selection
- **`QueryDropdown`** - Dropdown for predefined query selection
- **`GeoDropdown`** - Dropdown for geographic region selection
- **`SectionTitle`** - Consistent section headers
- **`InfoCard`** - Display key-value configuration pairs
- **`AdPreviewCard`** - Container for ad display areas

### File Structure

```
ExampleApp/
├── MainActivity.kt              # Entry point
├── ExampleApp.kt               # Main app with bottom navigation
├── Config.kt                   # Configuration constants (CREDENTIALS HERE!)
├── screens/
│   ├── BasicExampleScreen.kt   # Basic ad integration demo
│   ├── SearchExampleScreen.kt  # Dynamic search demo
│   ├── FilterExampleScreen.kt  # Ad filtering demo
│   └── SettingsScreen.kt       # SDK info and settings
└── ui/
    ├── CommonComponents.kt     # Reusable UI components
    └── theme/
        ├── Theme.kt            # Material 3 theme
        └── Type.kt             # Typography definitions
```

## Key Features Demonstrated

### 1. Basic Integration

```kotlin
GistAdControl(
    publisherId = Config.PUBLISHER_ID,
    publisherKey = Config.PUBLISHER_KEY,
    query = "wireless headphones",
    geo = "US"
)
```

### 2. Dynamic Search with Debouncing

```kotlin
var searchText by remember { mutableStateOf("") }
var debouncedQuery by remember { mutableStateOf("") }

LaunchedEffect(searchText) {
    delay(500) // Debounce
    debouncedQuery = searchText
}

if (debouncedQuery.isNotBlank()) {
    GistAdControl(
        publisherId = Config.PUBLISHER_ID,
        publisherKey = Config.PUBLISHER_KEY,
        query = debouncedQuery
    )
}
```

### 3. Ad Type Filtering

```kotlin
val adTypes = buildList {
    if (imageEnabled) add(AdType.IMAGE)
    if (textImageEnabled) add(AdType.TEXT_IMAGE)
    if (textEnabled) add(AdType.TEXT)
}.ifEmpty { null }

GistAdControl(
    ...,
    adTypes = adTypes
)
```

### 4. Geographic Targeting

```kotlin
var selectedGeo by remember { mutableStateOf("US") }

GistAdControl(
    ...,
    geo = selectedGeo
)
```

### 5. API Version Switching

```kotlin
var selectedApiVersion by remember { mutableStateOf("v2") }

GistAdControl(
    ...,
    apiVersion = selectedApiVersion  // "v1" or "v2"
)
```

### 6. Event Callbacks

```kotlin
var adLoadedCount by remember { mutableStateOf(0) }
var contentHeight by remember { mutableStateOf<Float?>(null) }

GistAdControl(
    ...,
    onAdLoaded = {
        adLoadedCount++
        println("✅ Ad loaded! Total: $adLoadedCount")
    },
    onContentHeightChanged = { height ->
        contentHeight = height
        println("📏 Content height: ${height}px")
    }
    // Note: onAdClicked not provided - ads open in browser automatically
)
```

### 7. Debug Logging

```kotlin
GistAdControl(
    ...,
    enableLogging = BuildConfig.DEBUG // Enable in debug builds only
)
```

## Sample Queries

The app includes several sample queries for testing:

- **Wireless headphones** - Electronics category
- **Running shoes** - Sports/footwear
- **Laptop computers** - Technology
- **Coffee makers** - Home appliances
- **Smart watches** - Wearable tech
- **Digital cameras** - Photography
- **Fitness trackers** - Health/fitness
- **Tablet devices** - Mobile devices

These queries are defined in `Config.kt` and demonstrate different product categories.

## Supported Regions

The app supports 8 geographic regions:

| Flag | Code | Region |
|------|------|--------|
| 🇺🇸 | US | United States |
| 🇬🇧 | GB | United Kingdom |
| 🇨🇦 | CA | Canada |
| 🇦🇺 | AU | Australia |
| 🇩🇪 | DE | Germany |
| 🇫🇷 | FR | France |
| 🇯🇵 | JP | Japan |
| 🇮🇳 | IN | India |

## Supported Ad Types

The SDK and example app support three ad types:

| Type | Value | Description |
|------|-------|-------------|
| **Image** | `AdType.IMAGE` | Image-only ads with visual content |
| **Text/Image** | `AdType.TEXT_IMAGE` | Combined text and image ads |
| **Text** | `AdType.TEXT` | Text-only ads with no images |

Toggle these on/off in the **Filters** tab to see how different combinations work.

## Best Practices Demonstrated

1. **Credential Management**: Centralized configuration
2. **State Management**: Proper use of `remember` and `mutableStateOf`
3. **Performance**: Debouncing for search queries
4. **Error Handling**: SDK handles errors automatically
5. **Lifecycle**: LaunchedEffect for side effects
6. **UI/UX**: Material Design 3 components
7. **Navigation**: Bottom navigation with proper state handling

## Testing the App

### 1. Test Basic Integration

1. Open the **Basic** tab (first icon in bottom navigation)
2. Select different queries from the dropdown
3. Switch between V1 and V2 API versions
4. Observe ad loading and display
5. Check the Event Callbacks card for:
   - "Ads Loaded" count (increments each time)
   - "Content Height" measurement
   - "Ad Clicks" status

### 2. Test Dynamic Search

1. Open the **Search** tab (second icon - magnifying glass)
2. Select an API version (V1 or V2)
3. Type in the search field (e.g., "headphones")
4. Notice the 500ms debounce delay
   - Ad updates only after you stop typing for 500ms
5. Try the suggestion chips at the bottom
6. Clear the search to see the placeholder again

### 3. Test Filtering

1. Open the **Filters** tab (third icon - funnel)
2. Select a query from the dropdown
3. Toggle ad types:
   - Turn off all types → see warning message
   - Enable different combinations
4. Change geographic region
5. Switch API versions
6. Observe how filters affect the ad results
7. Check the configuration card at the bottom

### 4. View SDK Info

1. Open the **Settings** tab (fourth icon - gear)
2. Review:
   - SDK version (1.0.0)
   - API configuration (version, environment)
   - Feature list
   - About information

### 5. Test Ad Interactions

1. **Click on an ad** → Should open in Chrome/default browser automatically
2. **Scroll through screens** → Ads should remain stable
3. **Rotate device** → UI should adapt (if supported)
4. **Change query/filters** → Ad should reload automatically

## Troubleshooting

### No Ads Showing

1. **Check credentials** in `Config.kt`:

   ```kotlin
   const val PUBLISHER_ID = "your-actual-id"  // Not placeholder
   const val PUBLISHER_KEY = "your-actual-key"
   ```

2. **Verify internet connection** - Ensure device/emulator has connectivity

3. **Enable debug logging** and check logcat:

   ```kotlin
   GistAdControl(..., enableLogging = BuildConfig.DEBUG)
   ```

4. **Check logcat output**:

   ```bash
   adb logcat | grep -E "GistAds|BasicExample|SearchExample|FilterExample"
   ```

5. **Ensure query is not empty** - Type something in search fields

6. **Try different API versions** - Switch between V1 and V2

7. **Check ad types** - In Filters screen, ensure at least one type is enabled

### Build Errors

1. **Sync Gradle files**:
   - Android Studio: File → Sync Project with Gradle Files
   - Or: `./gradlew --refresh-dependencies`

2. **Check dependencies are resolved**:

   ```bash
   ./gradlew :ExampleApp:dependencies
   ```

3. **Clean and rebuild project**:

   ```bash
   ./gradlew clean
   ./gradlew :ExampleApp:assembleDebug
   ```

4. **Verify Android SDK is installed**:
   - Check SDK location in `local.properties`
   - Ensure API 24+ is installed

5. **Check Java version**:

   ```bash
   java -version  # Should be Java 17+
   ```

### Runtime Errors

1. **Check logcat** for error messages:

   ```bash
   adb logcat | grep -E "AndroidRuntime|Exception|Error"
   ```

2. **Verify permissions** in `AndroidManifest.xml`:

   ```xml
   <uses-permission android:name="android.permission.INTERNET" />
   ```

3. **Ensure WebView is updated** on device:
   - Settings → Apps → Android System WebView → Update

4. **Test on different device/emulator**:
   - Try API 30+ emulator (recommended)
   - Physical device often works better than emulator

5. **Clear app data and reinstall**:

   ```bash
   adb uninstall com.gist.ads.example
   ./gradlew :ExampleApp:installDebug
   ```

### Ad Click Not Working

**This is now fixed!** Ads should automatically open in the browser when clicked.

If issues persist:

1. Check default browser is set on device
2. Verify internet connectivity
3. Check logcat for navigation errors
4. Try clicking a different ad

### Performance Issues

1. **Debounce is working** - Search has 500ms delay (intentional)
2. **Reduce logging** - Set `enableLogging = false` for production
3. **Use release build** for testing performance:

   ```bash
   ./gradlew :ExampleApp:assembleRelease
   ```

## Logcat Filtering

To view SDK-related logs effectively:

### Filter by Package

```bash
# All app logs
adb logcat | grep "com.gist.ads.example"

# SDK-specific logs
adb logcat | grep "GistAds"
```

### Filter by Screen

```bash
# Basic screen events
adb logcat | grep "BasicExample"

# Search screen events
adb logcat | grep "SearchExample"

# Filter screen events
adb logcat | grep "FilterExample"
```

### Filter by Event Type

```bash
# Ad loading events
adb logcat | grep "✅"

# Ad click events (when custom onAdClicked is used)
adb logcat | grep "🔗"

# Height change events
adb logcat | grep "📏"
```

### Combined Filters

```bash
# All important events
adb logcat | grep -E "(✅|🔗|📏|BasicExample|SearchExample|FilterExample)"

# Recent logs only (last 50 lines)
adb logcat -d | grep "GistAds" | tail -50
```

### In Android Studio Logcat

1. **Open Logcat** panel (bottom of IDE)
2. **Select device** from dropdown
3. **Filter by**:
   - Package: `com.gist.ads`
   - Tag: `GistAds`
   - Level: Debug or Verbose
4. **Use search box** for specific terms

## Requirements

- **Android 7.0+** (API 24+)
- **Kotlin 1.9+**
- **Jetpack Compose**
- **Active internet connection**
- **Valid Gist Ads credentials**

## Best Practices Demonstrated

1. **Credential Management** - Centralized in `Config.kt`
2. **State Management** - Proper use of `remember` and `mutableStateOf`
3. **Performance** - Debouncing for search queries (500ms delay)
4. **Error Handling** - SDK handles errors automatically with retry UI
5. **Lifecycle** - `LaunchedEffect` for side effects and coroutines
6. **UI/UX** - Material Design 3 components throughout
7. **Navigation** - Bottom navigation with proper state handling
8. **Code Reusability** - Common components in `CommonComponents.kt`
9. **Debug Logging** - Conditional logging with `BuildConfig.DEBUG`
10. **Event Tracking** - Callbacks for ad lifecycle events

## Additional Resources

- **SDK Documentation**: `../README.md`
- **Quick Start Guide**: `../QUICK_START.md`
- **Integration Guide**: `../INTEGRATION_GUIDE.md`
- **API Reference**: Check source code documentation

## Support

For issues or questions:

- Email: <support@gist.com>
- Review SDK documentation
- Check example code for best practices

## License

Copyright © 2024 Gist. All rights reserved.
