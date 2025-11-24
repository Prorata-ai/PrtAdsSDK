# Gist Ads SDK - Example App

This is a comprehensive example application demonstrating the features and capabilities of the Gist Ads SDK for Android.

## Overview

The example app showcases:

- ✨ Basic ad integration
- 🔍 Dynamic search with real-time ad updates
- 🎛️ Ad type filtering
- 🌍 Geographic targeting
- ⚙️ Configuration and settings

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

```bash
# From android-sdk directory
./gradlew :ExampleApp:installDebug

# Or open in Android Studio and run
```

## App Structure

### Screens

#### 1. Basic Example
- **Location**: `screens/BasicExampleScreen.kt`
- **Features**:
  - Simple ad display
  - Query selection from predefined list
  - Shows basic configuration

#### 2. Search Example
- **Location**: `screens/SearchExampleScreen.kt`
- **Features**:
  - Dynamic search field
  - Debounced search (500ms delay)
  - Search suggestions
  - Real-time ad updates

#### 3. Filter Example
- **Location**: `screens/FilterExampleScreen.kt`
- **Features**:
  - Ad type filtering (Image, Image/Text)
  - Geographic targeting
  - Live configuration display
  - Multiple region support

#### 4. Settings
- **Location**: `screens/SettingsScreen.kt`
- **Features**:
  - SDK version information
  - App configuration display
  - Feature list
  - Documentation links

### Architecture

```
ExampleApp/
├── MainActivity.kt           # Entry point
├── ExampleApp.kt            # Main app with navigation
├── Config.kt                # Configuration constants
├── screens/
│   ├── BasicExampleScreen.kt
│   ├── SearchExampleScreen.kt
│   ├── FilterExampleScreen.kt
│   └── SettingsScreen.kt
└── ui/
    └── theme/
        ├── Theme.kt         # Material 3 theme
        └── Type.kt          # Typography
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
    if (imageTextEnabled) add(AdType.IMAGE_TEXT)
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

### 5. Debug Logging

```kotlin
GistAdControl(
    ...,
    enableLogging = BuildConfig.DEBUG // Enable in debug builds
)
```

## Sample Queries

The app includes several sample queries for testing:

- Wireless headphones
- Running shoes
- Laptop computers
- Coffee makers
- Smart watches
- Digital cameras
- Fitness trackers
- Tablet devices

## Supported Regions

- 🇺🇸 United States (US)
- 🇬🇧 United Kingdom (GB)
- 🇨🇦 Canada (CA)
- 🇦🇺 Australia (AU)
- 🇩🇪 Germany (DE)
- 🇫🇷 France (FR)
- 🇯🇵 Japan (JP)
- 🇮🇳 India (IN)

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
- Open the **Basic** tab
- Select different queries from the dropdown
- Observe ad loading and display

### 2. Test Dynamic Search
- Open the **Search** tab
- Type in the search field
- Notice the debounced behavior (ads update 500ms after stopping typing)
- Try the suggestion chips

### 3. Test Filtering
- Open the **Filters** tab
- Toggle ad types on/off
- Change geographic region
- Observe how configuration affects ads

### 4. View SDK Info
- Open the **Settings** tab
- Review SDK version and configuration
- Check feature list and documentation

## Troubleshooting

### No Ads Showing

1. Check `Config.kt` has valid credentials
2. Verify internet connection
3. Enable debug logging and check logcat
4. Ensure query is not empty

### Build Errors

1. Sync Gradle files
2. Check dependencies are resolved
3. Clean and rebuild project
4. Verify Android SDK is installed

### Runtime Errors

1. Check logcat for error messages
2. Verify permissions in AndroidManifest.xml
3. Ensure WebView is updated on device
4. Test on a different device/emulator

## Logcat Filtering

To view SDK-related logs:

```bash
adb logcat | grep "GistAds"
```

Or in Android Studio Logcat, filter by package:
```
package:com.gist.ads
```

## Requirements

- Android 7.0+ (API 24+)
- Kotlin 1.9+
- Jetpack Compose
- Active internet connection
- Valid Gist Ads credentials

## Additional Resources

- **SDK Documentation**: `../README.md`
- **Quick Start Guide**: `../QUICK_START.md`
- **Integration Guide**: `../INTEGRATION_GUIDE.md`
- **API Reference**: Check source code documentation

## Support

For issues or questions:
- Email: support@gist.com
- Review SDK documentation
- Check example code for best practices

## License

Copyright © 2024 Gist. All rights reserved.

