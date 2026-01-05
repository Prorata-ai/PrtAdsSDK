# Gist Ads SDK for Android

A native Android SDK for integrating Gist AI Search Ads into your Android applications. This SDK provides a simple, Jetpack Compose-native way to display contextual ads based on search queries.

## Features

- ✨ **Jetpack Compose Native** - Built with Compose for seamless integration
- 🚀 **Easy Integration** - Simple API with minimal configuration
- 🎨 **Customizable** - Support for different ad types and configurations
- 🌐 **WebView Rendering** - Uses Android WebView for secure ad display
- 🔒 **Type Safe** - Fully typed Kotlin API with compile-time safety
- 📱 **Modern Android** - Supports Android 7.0+ (API 24+)
- 🔄 **API Versioning** - Support for V1 and V2 API endpoints
- 🌍 **Multi-Environment** - Staging, Integration, and Production environments
- 📢 **Event Callbacks** - Track ad loads, clicks, and content height changes
- 🎯 **Three Ad Types** - Image, Text/Image, and Text ads

## Installation

### Prerequisites

Before installing, ensure your project meets these requirements:

- **Android 7.0+** (API level 24+)
- **Kotlin 1.9+**
- **Jetpack Compose BOM 2024.01.00+**
- **Gradle 8.0+**

### Method 1: JitPack (Recommended - Easiest)

JitPack builds directly from GitHub, no manual publishing required!

1. **Add JitPack repository** to your `settings.gradle.kts`:

   ```kotlin
   dependencyResolutionManagement {
       repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
       repositories {
           google()
           mavenCentral()
           maven { url = uri("https://jitpack.io") }  // Add this
       }
   }
   ```

2. **Add the dependency** to your app's `build.gradle.kts`:

   ```kotlin
   dependencies {
       implementation("com.github.Prorata-ai:PrtAdsSDK:1.0.1")
   }
   ```

3. **Sync Gradle** and start using the SDK!

**Version Options:**

- `1.0.1` - Specific release version (recommended)
- `main-SNAPSHOT` - Latest development version
- `abc1234` - Specific commit hash

**Notes:**

- Replace `1.0.1` with the desired version tag from [GitHub Releases](https://github.com/Prorata-ai/PrtAdsSDK/releases)
- JitPack automatically builds the SDK on first request (may take 1-2 minutes)
- View build status: <https://jitpack.io/#Prorata-ai/PrtAdsSDK>

### Method 2: Maven Central (Coming Soon)

Once published to Maven Central, installation will be even simpler:

```kotlin
dependencies {
    implementation("com.gist.ads:sdk:1.0.1")
}
```

**Status:** SDK is configured and ready for Maven Central. Publishing requires:

- Sonatype OSSRH account setup
- GPG signing keys
- See [PUBLISHING.md](PUBLISHING.md) for maintainer instructions

### Method 3: Local Development

For local development or testing unreleased changes:

1. **Clone the repository**:

   ```bash
   # From your project root
   git clone https://github.com/Prorata-ai/PrtAdsSDK.git
   ```

2. **Include the SDK module** in your `settings.gradle.kts`:

   ```kotlin
   include(":PrtAdsSDK:android-sdk")
   project(":PrtAdsSDK:android-sdk").name = "gist-ads-sdk"
   ```

3. **Add the dependency** to your app's `build.gradle.kts`:

   ```kotlin
   dependencies {
       implementation(project(":gist-ads-sdk"))
   }
   ```

4. **Sync Gradle** and rebuild your project

## Quick Start

### Basic Usage

```kotlin
import androidx.compose.runtime.Composable
import com.gist.ads.sdk.ui.GistAdControl

@Composable
fun MyScreen() {
    GistAdControl(
        publisherId = "your-publisher-id",
        publisherKey = "your-publisher-key",
        query = "best wireless headphones",
        geo = "US"
    )
}
```

### With API Version Selection

```kotlin
GistAdControl(
    publisherId = "your-publisher-id",
    publisherKey = "your-publisher-key",
    query = "best wireless headphones",
    geo = "US",
    apiVersion = "v2"  // or "v1"
)
```

### With Ad Type Filtering

```kotlin
import com.gist.ads.sdk.models.AdType

GistAdControl(
    publisherId = "your-publisher-id",
    publisherKey = "your-publisher-key",
    query = "running shoes",
    geo = "US",
    adTypes = listOf(AdType.IMAGE, AdType.TEXT_IMAGE)
)
```

### With Event Callbacks

```kotlin
GistAdControl(
    publisherId = "your-publisher-id",
    publisherKey = "your-publisher-key",
    query = "wireless headphones",
    onAdLoaded = {
        println("Ad loaded successfully!")
    },
    onContentHeightChanged = { height ->
        println("Ad content height: ${height}px")
    }
    // Note: onAdClicked is optional - if not provided, ads open in browser automatically
)
```

## Configuration

### Required Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `publisherId` | `String` | Your publisher ID credential |
| `publisherKey` | `String` | Your publisher API key |
| `query` | `String` | Search query to fetch relevant ads for |

### Optional Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `geo` | `String` | `"US"` | Geographic location code (e.g., "US", "GB", "CA") |
| `adTypes` | `List<AdType>?` | `null` | List of ad types to filter (null = all types) |
| `modifier` | `Modifier` | `Modifier` | Compose modifier for styling |
| `enableLogging` | `Boolean` | `false` | Enable API request/response logging |
| `environment` | `APIConstants.Environment` | `PRODUCTION` | API environment (STAGING, INTEGRATION, PRODUCTION) |
| `apiVersion` | `String` | `"v2"` | API version to use ("v1" or "v2") |
| `customBaseUrl` | `String?` | `null` | Override base URL for API requests |
| `customIframeUrl` | `String?` | `null` | Override iframe base URL |
| `onAdLoaded` | `(() -> Unit)?` | `null` | Callback when ad successfully loads |
| `onAdClicked` | `((String) -> Unit)?` | `null` | Callback when user clicks ad (if null, opens in browser) |
| `onContentHeightChanged` | `((Float) -> Unit)?` | `null` | Callback when ad content height changes |

## Ad Types

The SDK supports three ad types for AI Search:

- **`AdType.IMAGE`** - Image-only ads
- **`AdType.TEXT_IMAGE`** - Combined image and text ads  
- **`AdType.TEXT`** - Text-only ads

```kotlin
// All ad types (default)
GistAdControl(..., adTypes = null)

// Only image ads
GistAdControl(..., adTypes = listOf(AdType.IMAGE))

// Image and text/image ads
GistAdControl(..., adTypes = listOf(AdType.IMAGE, AdType.TEXT_IMAGE))

// All three types explicitly
GistAdControl(..., adTypes = listOf(AdType.IMAGE, AdType.TEXT_IMAGE, AdType.TEXT))
```

## API Versioning

The SDK supports multiple API versions with different request/response formats:

### V2 (Default - Recommended)

```kotlin
GistAdControl(
    publisherId = "your-publisher-id",
    publisherKey = "your-publisher-key",
    query = "wireless headphones",
    apiVersion = "v2"  // Default, can be omitted
)
```

**V2 Request Format:**

```json
{
  "prompt": "search query",
  "answer": "search query",
  "geo": "US",
  "auction_type": "native",
  "ad_type": ["image", "text/image", "text"]
}
```

### V1 (Legacy Support)

```kotlin
GistAdControl(
    publisherId = "your-publisher-id",
    publisherKey = "your-publisher-key",
    query = "wireless headphones",
    apiVersion = "v1"
)
```

**V1 Request Format:**

```json
{
  "text": "search query",
  "geo": "US",
  "auction_type": "native",
  "ad_type": ["image", "text/image", "text"]
}
```

### Environment Configuration

The SDK supports three environments for different development stages:

```kotlin
import com.gist.ads.sdk.Constants.APIConstants

// Production (default)
GistAdControl(
    ...,
    environment = APIConstants.Environment.PRODUCTION
)

// Integration (for QA testing)
GistAdControl(
    ...,
    environment = APIConstants.Environment.INTEGRATION
)

// Staging (for development)
GistAdControl(
    ...,
    environment = APIConstants.Environment.STAGING
)
```

### Overriding Base URLs

You can override default URLs using system properties or custom parameters:

**System Properties (set at app startup):**

```kotlin
System.setProperty("gist.ads.staging.url", "https://custom-staging.example.com")
System.setProperty("gist.ads.integration.url", "https://custom-integration.example.com")
System.setProperty("gist.ads.production.url", "https://custom-production.example.com")
System.setProperty("gist.ads.api.version", "v1")  // Override default version
```

**Custom Parameters (per ad control):**

```kotlin
GistAdControl(
    ...,
    customBaseUrl = "https://custom-api.example.com",
    customIframeUrl = "https://custom-iframe.example.com"
)
```

## Event Callbacks

The SDK provides three event callbacks for tracking ad lifecycle:

### onAdLoaded

Called when an ad successfully loads:

```kotlin
GistAdControl(
    ...,
    onAdLoaded = {
        println("✅ Ad loaded successfully!")
        // Update analytics, hide loading indicators, etc.
    }
)
```

### onAdClicked

Called when a user clicks on an ad. **If not provided, ads automatically open in the default browser:**

```kotlin
// Option 1: Handle clicks yourself
GistAdControl(
    ...,
    onAdClicked = { url ->
        println("🔗 Ad clicked: $url")
        // Open in custom in-app browser, log analytics, etc.
        val intent = Intent(Intent.ACTION_VIEW, Uri.parse(url))
        context.startActivity(intent)
    }
)

// Option 2: Let SDK handle (opens in browser automatically)
GistAdControl(
    ...
    // Don't provide onAdClicked - default behavior applies
)
```

### onContentHeightChanged

Called when the ad content height is measured, allowing dynamic sizing:

```kotlin
var adHeight by remember { mutableStateOf(250.dp) }

GistAdControl(
    ...,
    onContentHeightChanged = { heightPx ->
        // Convert pixels to dp and update container height
        adHeight = with(LocalDensity.current) { heightPx.toDp() }
    },
    modifier = Modifier.height(adHeight)
)
```

## Theme Support

The SDK supports light and dark mode for ad content, automatically detecting the system theme or allowing manual override.

### Automatic System Detection (Default)

By default, ads automatically match your device's light/dark theme:

```kotlin
GistAdControl(
    publisherId = "your-publisher-id",
    publisherKey = "your-publisher-key",
    query = "wireless headphones"
    // theme = "system" is the default
)
```

### Manual Theme Override

Force a specific theme regardless of system settings:

```kotlin
// Force light mode
GistAdControl(
    ...,
    theme = "light"
)

// Force dark mode
GistAdControl(
    ...,
    theme = "dark"
)
```

### How It Works

The SDK passes a `pr_theme` parameter to the ad iframe:

- **`"system"`** (default) - Detects device theme with `isSystemInDarkTheme()` and passes `"light"` or `"dark"` to the iframe
- **`"light"`** - Forces light mode in the iframe
- **`"dark"`** - Forces dark mode in the iframe

The iframe content will adapt using CSS `color-scheme` and invert filters to match the selected theme.

### Example with Theme Picker

```kotlin
@Composable
fun AdWithThemePicker() {
    var selectedTheme by remember { mutableStateOf("system") }
    
    Column {
        // Theme picker
        Row {
            FilterChip(
                selected = selectedTheme == "system",
                onClick = { selectedTheme = "system" },
                label = { Text("System") }
            )
            FilterChip(
                selected = selectedTheme == "light",
                onClick = { selectedTheme = "light" },
                label = { Text("Light") }
            )
            FilterChip(
                selected = selectedTheme == "dark",
                onClick = { selectedTheme = "dark" },
                label = { Text("Dark") }
            )
        }
        
        // Ad with selected theme
        GistAdControl(
            publisherId = "your-publisher-id",
            publisherKey = "your-publisher-key",
            query = "wireless headphones",
            theme = selectedTheme
        )
    }
}
```

## Advanced Usage

### Dynamic Query Updates

```kotlin
@Composable
fun SearchScreen() {
    var searchQuery by remember { mutableStateOf("") }
    
    Column {
        TextField(
            value = searchQuery,
            onValueChange = { searchQuery = it },
            placeholder = { Text("Search...") }
        )
        
        if (searchQuery.isNotBlank()) {
            GistAdControl(
                publisherId = "your-publisher-id",
                publisherKey = "your-publisher-key",
                query = searchQuery,
                modifier = Modifier
                    .fillMaxWidth()
                    .height(250.dp)
            )
        }
    }
}
```

### Error Handling

The ad control automatically handles errors and displays appropriate UI:

- **Loading state** - Shows circular progress indicator
- **Error state** - Shows error message with retry button
- **No ads** - Shows "No ad available" message

### Custom Styling

```kotlin
GistAdControl(
    publisherId = "your-publisher-id",
    publisherKey = "your-publisher-key",
    query = "wireless headphones",
    modifier = Modifier
        .fillMaxWidth()
        .height(250.dp)
        .background(Color.White)
        .clip(RoundedCornerShape(12.dp))
        .shadow(4.dp)
        .padding(16.dp)
)
```

### Enable Debugging

```kotlin
GistAdControl(
    ...,
    enableLogging = true  // Enables HTTP request/response logging
)
```

## API Integration

The SDK communicates with the Gist Ads API automatically. The API endpoint is managed internally by the SDK.

### Request Format

```json
{
  "text": "search query",
  "geo": "US",
  "auction_type": "native",
  "ad_type": ["image", "image/text"]
}
```

### Headers

- `Publisher-ID` - Authentication
- `Publisher-Key` - Authorization
- `Content-Type` - application/json

## Requirements

- Android 7.0+ (API level 24+)
- Kotlin 1.9+
- Jetpack Compose BOM 2024.01.00+
- Gradle 8.0+

## Architecture

The SDK is organized into several components:

### Models

- `AdType` - Enum for supported ad types (IMAGE, TEXT_IMAGE, TEXT)
- `SearchRequest` - API request models (V1 and V2 variants)
- `SearchResponse` - API response model

### Services

- `AdAPIService` - Handles API communication with OkHttp
- `AdAPIException` - Error types for API operations

### UI Components

- `GistAdControl` - Main public Composable
- `AdWebView` - Internal WebView wrapper for rendering

### Utilities

- `IframeHTMLGenerator` - Generates HTML for ad iframes
- `APIConstants` - Centralized API configuration

## Permissions

The SDK requires the following permissions (automatically included):

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
```

## Best Practices

1. **Secure Credentials** - Store publisher ID and key securely, don't hardcode in production

   ```kotlin
   // Good: Use BuildConfig or local.properties
   publisherId = BuildConfig.GIST_PUBLISHER_ID
   
   // Bad: Hardcoded credentials
   publisherId = "pub_12345"
   ```

2. **Handle Empty States** - Always check for blank queries before displaying ads

   ```kotlin
   if (query.isNotBlank()) {
       GistAdControl(query = query, ...)
   }
   ```

3. **Optimize Refreshes** - Use proper state management to control when ads refresh

   ```kotlin
   var query by remember { mutableStateOf("") }
   
   LaunchedEffect(query) {
       delay(500)  // Debounce
       debouncedQuery = query
   }
   ```

4. **Enable Debug Logging** - Use `enableLogging = BuildConfig.DEBUG` to see API details in development

   ```kotlin
   GistAdControl(
       ...,
       enableLogging = BuildConfig.DEBUG  // Only logs in debug builds
   )
   ```

5. **Responsive Heights** - Set appropriate heights based on ad type and screen size

   ```kotlin
   GistAdControl(
       ...,
       modifier = Modifier
           .fillMaxWidth()
           .height(250.dp)
   )
   ```

6. **Error Monitoring** - Monitor error states for debugging (SDK handles UI automatically)

7. **Lifecycle Awareness** - The component handles lifecycle automatically with Compose

## Troubleshooting

### No Ads Showing

- Verify your publisher credentials are correct
- Ensure the query is not blank
- Verify ad types are appropriate for your content
- Check network connectivity

### Build Errors

- Ensure you're using Android SDK 24+
- Check Kotlin version is 1.9+
- Verify Compose BOM is included
- Sync Gradle files

### Network Errors

- Check internet permission in AndroidManifest.xml
- Ensure HTTPS is used for production
- Verify network connectivity on device/emulator

### WebView Issues

- Ensure WebView is updated on the device
- Check JavaScript is enabled (enabled by default in SDK)
- Verify no content blockers are interfering

## Example App

The SDK includes a complete example app demonstrating:

- **Basic Integration** - Simple ad display with query selection
- **Dynamic Search** - Real-time search with debouncing
- **Ad Filtering** - Filter by ad type (Image, Text/Image, Text)
- **Geographic Targeting** - Select different regions
- **API Version Switching** - Switch between V1 and V2
- **Event Callbacks** - Track ad loads, clicks, and height changes
- **Custom Styling** - Material 3 themed UI

See the [ExampleApp](ExampleApp/) directory for the full implementation.

### Running the Example App

1. **Configure credentials** in `ExampleApp/src/main/java/com/gist/ads/example/Config.kt`:

   ```kotlin
   const val PUBLISHER_ID = "your-publisher-id"
   const val PUBLISHER_KEY = "your-publisher-key"
   ```

2. **Build and install**:

   ```bash
   cd android-sdk
   ./gradlew :ExampleApp:installDebug
   ```

3. **Or open in Android Studio** and run the ExampleApp module

### Example App Features

#### 1. Basic Screen

- Predefined query selection
- API version switcher
- Event callback demonstration
- Configuration display

#### 2. Search Screen

- Dynamic text search field
- 500ms debounce delay
- Quick suggestion chips
- Real-time ad updates

#### 3. Filters Screen

- Ad type toggles (Image, Text/Image, Text)
- Geographic region selector
- Live configuration preview

#### 4. Settings Screen

- SDK version information
- API configuration display
- Feature list

## Support

For issues, questions, or feature requests:

- Email: <support@gist.com>
- Documentation: [Integration Guide](INTEGRATION_GUIDE.md)
- Quick Start: [Quick Start Guide](QUICK_START.md)
- Publishing: [Publishing Guide](PUBLISHING.md) (for SDK maintainers)

## License

Copyright © 2024 Gist. All rights reserved.

See [LICENSE](LICENSE) for details.

## For SDK Maintainers

### Publishing the SDK

See [PUBLISHING.md](PUBLISHING.md) for complete instructions on:

- Publishing to JitPack (recommended - easiest)
- Publishing to Maven Central (professional distribution)
- Version management and release process

### Configuration

- **Publishing config**: `sdk.gradle.kts`
- **JitPack config**: `../jitpack.yml`
- **Credentials template**: `gradle.properties.template`

## Changelog

### Version 1.0.1

- Enhanced error handling with `onError` callback
- Improved error messages with detailed context
- Dark mode support with automatic theme detection
- Manual theme override (light/dark/system)
- Theme parameter passed to iframe via `pr_theme`
- Clean build with no deprecation warnings
- Comprehensive unit tests (40 tests)
- Bug fixes and stability improvements

### Version 1.0.0

- Initial release
- Jetpack Compose ad control component
- Support for image and image/text ad types
- Android 7.0+ support
- Example app included
