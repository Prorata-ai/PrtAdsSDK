# Gist Ads SDK for Android

A native Android SDK for integrating Gist AI Search Ads into your Android applications. This SDK provides a simple, Jetpack Compose-native way to display contextual ads based on search queries.

## Features

- ✨ **Jetpack Compose Native** - Built with Compose for seamless integration
- 🚀 **Easy Integration** - Simple API with minimal configuration
- 🎨 **Customizable** - Support for different ad types and configurations
- 🌐 **WebView Rendering** - Uses Android WebView for secure ad display
- 🔒 **Type Safe** - Fully typed Kotlin API with compile-time safety
- 📱 **Modern Android** - Supports Android 7.0+ (API 24+)

## Installation

### Gradle (build.gradle.kts)

Add the dependency to your app's `build.gradle.kts`:

```kotlin
dependencies {
    implementation("com.gist.ads:sdk:1.0.0")
}
```

Or if using Groovy (build.gradle):

```groovy
dependencies {
    implementation 'com.gist.ads:sdk:1.0.0'
}
```

### Maven

```xml
<dependency>
    <groupId>com.gist.ads</groupId>
    <artifactId>sdk</artifactId>
    <version>1.0.0</version>
</dependency>
```

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

### With Ad Type Filtering

```kotlin
import com.gist.ads.sdk.models.AdType

GistAdControl(
    publisherId = "your-publisher-id",
    publisherKey = "your-publisher-key",
    query = "running shoes",
    geo = "US",
    adTypes = listOf(AdType.IMAGE, AdType.IMAGE_TEXT)
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

## Ad Types

The SDK supports the following ad types for AI Search:

- **`AdType.IMAGE`** - Image-only ads
- **`AdType.IMAGE_TEXT`** - Combined image and text ads

```kotlin
// All ad types (default)
GistAdControl(..., adTypes = null)

// Only image ads
GistAdControl(..., adTypes = listOf(AdType.IMAGE))

// Both image and image/text ads
GistAdControl(..., adTypes = listOf(AdType.IMAGE, AdType.IMAGE_TEXT))
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
- `AdType` - Enum for supported ad types
- `SearchRequest` - API request model
- `SearchResponse` - API response model

### Services
- `AdAPIService` - Handles API communication with OkHttp
- `AdAPIException` - Error types for API operations

### UI Components
- `GistAdControl` - Main public Composable
- `AdWebView` - Internal WebView wrapper for rendering

## Permissions

The SDK requires the following permissions (automatically included):

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
```

## Best Practices

1. **Secure Credentials** - Store publisher ID and key securely, don't hardcode in production
2. **Handle Empty States** - Always check for blank queries before displaying ads
3. **Optimize Refreshes** - Use proper state management to control when ads refresh
4. **Responsive Heights** - Set appropriate heights based on ad type and screen size
5. **Error Monitoring** - Monitor error states for debugging
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

- Basic ad integration
- Dynamic query updates
- Ad type filtering
- Geographic location selection
- Error handling
- Custom styling

See the [ExampleApp](ExampleApp/) directory for the full implementation.

## Support

For issues, questions, or feature requests:

- Email: support@gist.com
- Documentation: [Integration Guide](INTEGRATION_GUIDE.md)
- Quick Start: [Quick Start Guide](QUICK_START.md)

## License

Copyright © 2024 Gist. All rights reserved.

See [LICENSE](LICENSE) for details.

## Changelog

### Version 1.0.0
- Initial release
- Jetpack Compose ad control component
- Support for image and image/text ad types
- Android 7.0+ support
- Example app included

