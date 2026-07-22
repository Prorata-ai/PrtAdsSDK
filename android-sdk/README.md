# Gist Ads SDK for Android

A native Android SDK for integrating Gist AI Search Ads into your Android applications. This SDK provides a simple, Jetpack Compose-native way to display contextual ads based on search queries.

## Features

- ✨ **Jetpack Compose Native** - Built with Compose for seamless integration
- 🚀 **Easy Integration** - Simple API with minimal configuration
- 🎨 **Customizable** - Support for different ad types and configurations
- 🌐 **WebView Rendering** - Uses Android WebView for secure ad display
- 🔒 **Type Safe** - Fully typed Kotlin API with compile-time safety
- 📱 **Modern Android** - Supports Android 7.0+ (API 24+)
- 🌍 **Multi-Environment** - Staging, Integration, and Production environments
- 📢 **Event Callbacks** - Track ad loads, clicks, and content height changes
- 🎯 **Three Ad Types** - Image, Text/Image, and Text ads
- 🖼️ **Display Ads** - Contextual display ads targeted by publisher ID + page URL + size, embedding the real `adtag.js` script directly

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
       implementation("com.github.Prorata-ai:PrtAdsSDK:1.0.4")
   }
   ```

3. **Sync Gradle** and start using the SDK!

**Version Options:**

- `1.0.4` - Specific release version (recommended)
- `main-SNAPSHOT` - Latest development version
- `abc1234` - Specific commit hash

**Notes:**

- Replace `1.0.4` with the desired version tag from [GitHub Releases](https://github.com/Prorata-ai/PrtAdsSDK/releases)
- JitPack automatically builds the SDK on first request (may take 1-2 minutes)
- View build status: <https://jitpack.io/#Prorata-ai/PrtAdsSDK>

### Method 2: Maven Central (Coming Soon)

Once published to Maven Central, installation will be even simpler:

```kotlin
dependencies {
    implementation("com.gist.ads:sdk:1.0.4")
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

### With Ad Sizes

Like display ads, search ads are rendered by `adtag.js` into a slot sized from an `AdSize` list (mirrors `sizes` in `defineSlot`). Defaults to `listOf(AdSize.DYNAMIC)` (fluid layout, no fixed dimensions) if omitted:

```kotlin
import com.gist.ads.sdk.models.AdSize

GistAdControl(
    publisherId = "your-publisher-id",
    publisherKey = "your-publisher-key",
    query = "running shoes",
    sizes = listOf(AdSize.MEDIUM_RECTANGLE, AdSize.LEADERBOARD)
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
| `answer` | `String?` | `null` | Optional answer text (mirrors `slot.defineAnswer(...)`) |
| `adTypes` | `List<AdType>?` | `null` | List of ad types to filter (null = all types) |
| `sizes` | `List<AdSize>` | `listOf(AdSize.DYNAMIC)` | One or more supported ad sizes (mirrors `sizes` in `defineSlot`) |
| `environment` | `APIConstants.Environment` | `PRODUCTION` | API environment (STAGING, INTEGRATION, PRODUCTION) |
| `modifier` | `Modifier` | `Modifier` | Compose modifier for styling |
| `theme` | `String` | `"system"` | Theme preference - "light", "dark", or "system" |
| `onAdLoaded` | `(() -> Unit)?` | `null` | Callback when ad successfully loads |
| `onAdClicked` | `((String) -> Unit)?` | `null` | Callback when user clicks ad (if null, opens in browser) |
| `onContentHeightChanged` | `((Float) -> Unit)?` | `null` | Callback when ad content height changes |
| `passback` | `(@Composable () -> Unit)?` | `null` | Composable shown when no ad is available (no-fill), mirroring the web tag's `definePassbackFunction`. Defaults to a simple "No ad available" text when not provided |

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

### How Search Ads Are Rendered

Like `GistDisplayAdControl`, `GistAdControl` is a thin wrapper around embedding the real production `adtag.js` script in a `WebView`: it builds a small bootstrap HTML document that calls `defineSlot({ id, api_key, geo }, slotId, sizes, adTypes)` -> `slot.definePrompt(query)` -> `displayAd(slotId)`, exactly mirroring how a publisher's own webpage would embed the tag directly for search, and loads that into the `WebView`. The SDK makes no API calls of its own -- `adtag.js` makes its own JSONP request to the Search API and renders the result directly into the slot's DOM (no iframe), so as the tag and backend evolve, this control keeps working without needing to track along.

**Security note:** unlike display ads, search ads are gated by a secret `publisherKey`. Because `adtag.js` makes its own request from inside the `WebView`, `publisherKey` becomes visible in the loaded HTML/JS source and is sent as a public `publisher_key` query parameter -- the same exposure a publisher already accepts by embedding the JS tag on a public webpage. Native apps lose the extra protection of keeping the key server-side/header-only, which the SDK had before this change.

(An earlier revision called the Search API natively via `AdAPIService` and rendered the response's `iframeUrl` in an `AdWebView`, and supported an `apiVersion` parameter to select between the v1/v2 request body shapes. Both have been removed: `adtag.js`'s own request is hardcoded to the v2 shape, so there is no version to select once the SDK is a pure embed.)

## Display Ads

`GistDisplayAdControl` renders contextual display ads targeted by publisher ID + page URL + size, mirroring the web tag's `defineSlot({id, url}, slotId, sizes)` -> `displayAd(slotId)` flow. Unlike `GistAdControl` (search ads, gated by a secret publisher key), display ads only require a publisher ID -- no publisher key is needed.

```kotlin
import com.gist.ads.sdk.ui.GistDisplayAdControl
import com.gist.ads.sdk.models.AdSize

GistDisplayAdControl(
    publisherId = "pub-12345",
    pageUrl = "https://example.com/articles/ai-trends",
    sizes = listOf(AdSize.MEDIUM_RECTANGLE),
    modifier = Modifier.fillMaxWidth().height(250.dp)
)
```

### Required Parameters (Display Ads)

| Parameter | Type | Description |
|-----------|------|-------------|
| `publisherId` | `String` | Your publisher ID credential (no publisher key required) |
| `pageUrl` | `String` | The current page/context URL to target the ad against (mirrors `url` in `defineSlot`) |
| `sizes` | `List<AdSize>` | One or more supported ad sizes (mirrors `sizes` in `defineSlot`) |

### Optional Parameters (Display Ads)

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `environment` | `APIConstants.Environment` | `PRODUCTION` | API environment (STAGING, INTEGRATION, PRODUCTION) -- same type used by search ads |
| `theme` | `String` | `"system"` | Theme preference - "light", "dark", or "system" |
| `modifier` | `Modifier` | `Modifier` | Compose modifier for styling |
| `onAdLoaded` | `(() -> Unit)?` | `null` | Callback when ad successfully loads |
| `onAdClicked` | `((String) -> Unit)?` | `null` | Callback when user clicks ad (if null, opens in browser) |
| `onContentHeightChanged` | `((Float) -> Unit)?` | `null` | Callback when ad content height changes |
| `passback` | `(@Composable () -> Unit)?` | `null` | Composable shown when no ad is available (no-fill), mirroring the web tag's `definePassbackFunction`. Defaults to a simple "No ad available" text when not provided |

### Ad Sizes

`AdSize` mirrors the standard IAB sizes documented for the web ad tag's `defineSlot`:

- `AdSize.LEADERBOARD` (728x90)
- `AdSize.SUPER_LEADERBOARD` (970x90)
- `AdSize.MEDIUM_RECTANGLE` (300x250)
- `AdSize.MOBILE_BANNER` (320x50)
- `AdSize.BILLBOARD` (970x250)
- `AdSize.LARGE_RECTANGLE` (300x600)
- `AdSize.SKYSCRAPER` (160x600)
- `AdSize.DYNAMIC` (fluid layout)

### No-Fill Passback

When the server has no ad to serve, `GistDisplayAdControl` shows the `passback` composable instead, giving you full control over the fallback UI:

```kotlin
GistDisplayAdControl(
    publisherId = "pub-12345",
    pageUrl = "https://example.com/articles/ai-trends",
    sizes = listOf(AdSize.MEDIUM_RECTANGLE),
    passback = {
        Text("Check out our newsletter instead!")
    }
)
```

> **Note:** display ads are targeted by `pageUrl` alone, which the backend crawls to infer relevance the same way it would for a real webpage. There is currently no way to supply additional targeting signal for screens with no crawlable URL (e.g. a purely native screen) -- see "How Display Ads Are Rendered" below for why.

### How Display Ads Are Rendered

`GistDisplayAdControl` is a thin wrapper around embedding the real production `adtag.js` script in an Android `WebView`: it builds a small bootstrap HTML document that calls `defineSlot({ id, url }, slotId, sizes)` -> `displayAd(slotId)`, exactly mirroring how a publisher's own webpage would embed the tag directly, and loads that into the `WebView`. The SDK makes no API calls of its own -- `adtag.js` owns the entire ad request, response parsing, and rendering, the same as it would on a real webpage, so as the tag and backend evolve, this control keeps working without needing to track along. Bridge callbacks (`adRendered`/passback, via `@JavascriptInterface`) report the result back to `GistDisplayAdControl`'s Compose state, and the tag's `target="_blank"` ad links are intercepted via `WebChromeClient.onCreateWindow` out of the box.

(An earlier revision fetched ads natively to support a `context` targeting parameter for screens with no crawlable URL. That was removed: `adtag.js`'s own request has no field for arbitrary targeting data, so supporting it required a native-fetch special case that defeated the purpose of embedding the tag. If your app needs contextual targeting for native screens, please reach out -- this is being tracked as a follow-up.)

The `adtag.js` bundle loaded for each environment reuses the same host (and system-property overrides) as search ads' iframe base URL, since it's one bundle serving both ad types -- see [Environment Configuration](#environment-configuration) below.

## Environment Configuration

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

### Overriding the Ad Tag Script Host

You can override the `adtag.js` script host per environment using system properties, which is useful for testing against staging/integration ad tag servers. This is shared by both search and display ads (`adtag.js` is one bundle serving both, distinguished by whether `api_key` is passed to `defineSlot`):

```kotlin
System.setProperty("gist.ads.staging.iframe.url", "https://custom-staging.example.com")
System.setProperty("gist.ads.integration.iframe.url", "https://custom-integration.example.com")
System.setProperty("gist.ads.production.iframe.url", "https://custom-production.example.com")
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

## Requirements

- Android 7.0+ (API level 24+)
- Kotlin 1.9+
- Jetpack Compose BOM 2024.01.00+
- Gradle 8.0+

## Architecture

The SDK is organized into several components:

### Models

- `AdType` - Enum for supported ad types (IMAGE, TEXT_IMAGE, TEXT)
- `AdSize` - Enum for supported ad sizes (leaderboard, medium rectangle, dynamic, etc.), shared by search and display ads
- `AdTagLoadState` - Event-derived load state shared by `GistDisplayAdControl` and `GistAdControl` (`Loading`/`Loaded`/`NoFill`/`Failed`)

### UI Components

- `GistAdControl` - Main public Composable for search ads
- `GistDisplayAdControl` - Main public Composable for display ads
- `AdTagBridgeWebView` - Internal WebView wrapper that embeds the real `adtag.js` script, shared by both search and display ads

### Utilities

- `SearchAdBootstrapHTML` - Builds the bootstrap HTML that loads `adtag.js` and drives `defineSlot`/`definePrompt`/`displayAd` for search ads
- `DisplayAdBootstrapHTML` - Builds the bootstrap HTML that loads `adtag.js` and drives `defineSlot`/`displayAd` for display ads
- `APIConstants` - Centralized ad-tag-script host configuration for both search and display ads

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

4. **Responsive Heights** - Set appropriate heights based on ad type and screen size

   ```kotlin
   GistAdControl(
       ...,
       modifier = Modifier
           .fillMaxWidth()
           .height(250.dp)
   )
   ```

5. **Error Monitoring** - Monitor error states for debugging (SDK handles UI automatically)

6. **Lifecycle Awareness** - The component handles lifecycle automatically with Compose

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

### WebView Issues

- Ensure WebView is updated on the device
- Check JavaScript is enabled (enabled by default in SDK)
- Verify no content blockers are interfering
- Check internet permission in `AndroidManifest.xml` and network connectivity on device/emulator -- `adtag.js` makes its own request to the ad server from inside the WebView, so no native network permission beyond `INTERNET` is required

## Example App

The SDK includes a complete example app demonstrating:

- **Basic Integration** - Simple ad display with query selection
- **Dynamic Search** - Real-time search with debouncing
- **Ad Filtering** - Filter by ad type (Image, Text/Image, Text)
- **Geographic Targeting** - Select different regions
- **Ad Size Selection** - Switch between IAB ad sizes and dynamic layout
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

#### 4. Display Ads Screen

- Page URL input
- Ad size dropdown and environment picker
- Custom no-fill passback view

#### 5. Settings Screen

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

Copyright © 2026 Gist. All rights reserved.

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

### Version 1.0.4

- Search ads now embed the real production `adtag.js` script in a `WebView` and drive it via `defineSlot({ id, api_key, geo }, slotId, sizes, adTypes)` -> `slot.definePrompt(query)` -> `displayAd(slotId)`, instead of the SDK calling the Search API and rendering the response's `iframeUrl` itself
- `GistAdControl` is now a thin wrapper that makes no API calls of its own -- `adtag.js` owns the entire ad request (its own JSONP GET to the Search API), response parsing, and rendering
- Added a public `sizes: List<AdSize>` parameter to `GistAdControl` (default `listOf(AdSize.DYNAMIC)`), since `defineSlot` requires a non-empty `sizes` array
- Added a public `answer: String?` parameter (mirrors `slot.defineAnswer(...)`) and a `passback` composable parameter, mirroring `GistDisplayAdControl`'s no-fill handling, giving callers full control over the fallback UI instead of a hard-coded error/empty state
- Removed the `apiVersion`, `customBaseUrl`, `customIframeUrl`, `enableLogging`, and `onError` parameters from `GistAdControl`: `adtag.js`'s own search request is hardcoded to the v2 body shape and makes no native network call, so there is no version, base URL, or error to select/observe once the SDK is a pure embed
- Removed `AdAPIService`, `AdAPIException`, `SearchRequest`, `SearchResponse`, and `IframeHTMLGenerator` (superseded by the embedded tag's own rendering; no longer needed now that the SDK makes no API calls)
- Renamed `DisplayAdBridgeWebView` -> `AdTagBridgeWebView` and `DisplayAdLoadState` -> `AdTagLoadState`, now shared by both `GistDisplayAdControl` and `GistAdControl`
- **Security note:** unlike display ads, search ads are gated by a secret `publisherKey`, which now becomes visible in the loaded HTML/JS source and is sent as a public `publisher_key` query parameter by `adtag.js` -- the same exposure a publisher already accepts by embedding the JS tag on a public webpage. Native apps lose the extra protection of keeping the key server-side/header-only, which the SDK had before this change
- **Behavior change:** a blank `query` now throws `SearchAdBootstrapException.EmptyQuery`, which `GistAdControl` surfaces as a `Failed` state with a retry button. Previously, a blank query silently failed to load with no UI change and no error state -- if you were relying on that no-op as a "not ready yet" sentinel to suppress loading, guard the call site (e.g. don't render `GistAdControl` until `query` is non-blank) instead

### Version 1.0.3

- Display ads now embed the real production `adtag.js` script in a `WebView` and drive it via `defineSlot`/`displayAd`, instead of the SDK calling the Display Ad API and rendering raw fields itself
- `GistDisplayAdControl` is now a thin wrapper that makes no API calls of its own -- `adtag.js` owns the entire ad request, response parsing, and rendering
- Added `target="_blank"` link interception (`WebChromeClient.onCreateWindow`) for display ad clicks
- Removed the `context` parameter: `adtag.js`'s own request has no field for arbitrary targeting data, so supporting it would require a native-fetch special case that defeats the purpose of embedding the tag (this is being tracked as a follow-up if contextual targeting for native screens is needed)
- Removed `DisplayAdAPIService`, `DisplayAdAPIException`, `DisplayAPIConstants`, `DisplayAdHTMLGenerator`, and `DisplayAdResponse` (superseded by the embedded tag's own rendering; no longer needed now that the SDK makes no API calls)
- `GistDisplayAdControl`'s `environment` parameter is now `APIConstants.Environment` (the same type used by search ads) instead of its own duplicate `DisplayAPIConstants.Environment`
- **Behavior change:** a blank `pageUrl` now throws `DisplayAdBootstrapException.EmptyPageUrl`, which `GistDisplayAdControl` surfaces as a `Failed` state with a retry button, instead of silently embedding an empty `url: ""` in the `defineSlot` call (which would otherwise produce an undiagnosable no-fill). Always pass a non-blank `pageUrl`

### Version 1.0.2

- Added `GistDisplayAdControl` for contextual display ads (`defineSlot`/`displayAd` pattern), with standard IAB ad sizes and no-fill passback support
- Added first-party `context` parameter to `GistDisplayAdControl` for passing publisher-provided targeting data to the Display Ad API

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
