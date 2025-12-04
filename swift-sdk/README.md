# Gist Ads SDK for Swift

A native Swift SDK for integrating Gist AI Search Ads into your iOS and macOS applications. This SDK provides a simple, SwiftUI-native way to display contextual ads based on search queries.

## Features

- ✨ **SwiftUI Native** - Built with SwiftUI for seamless integration
- 🚀 **Easy Integration** - Simple API with minimal configuration
- 🎨 **Customizable** - Support for different ad types and configurations
- 🌐 **WebKit Rendering** - Uses WKWebView for secure iframe-based ad display
- 🔒 **Type Safe** - Fully typed Swift API with compile-time safety
- 📱 **Cross Platform** - Supports iOS 15+ and macOS 12+

## Installation

### Swift Package Manager

Add the package to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/your-org/gist-ads-sdk-swift.git", from: "1.0.0")
]
```

Or in Xcode:
1. File → Add Packages...
2. Enter the package URL
3. Select version and add to your target

## Quick Start

### Basic Usage

```swift
import SwiftUI
import GistAdsSDK

struct ContentView: View {
    var body: some View {
        GistAdControl(
            publisherID: "your-publisher-id",
            publisherKey: "your-publisher-key",
            query: "best wireless headphones",
            geo: "US"
        )
        .frame(height: 250)
    }
}
```

### With Ad Type Filtering

```swift
GistAdControl(
    publisherID: "your-publisher-id",
    publisherKey: "your-publisher-key",
    query: "running shoes",
    geo: "US",
    adTypes: [.image, .textImage]
)
```

## Configuration

### Required Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `publisherID` | `String` | Your publisher ID credential |
| `publisherKey` | `String` | Your publisher API key |
| `query` | `String` | Search query to fetch relevant ads for |

### Optional Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `geo` | `String` | `"US"` | Geographic location code (e.g., "US", "GB", "CA") |
| `adTypes` | `[AdType]?` | `nil` | Array of ad types to filter (nil = all types) |
| `environment` | `GistAdControl.Environment` | `.production` | API environment (staging, integration, or production) |

## Ad Types

The SDK supports the following ad types for AI Search:

- **`.image`** - Image-only ads
- **`.textImage`** - Combined text and image ads
- **`.text`** - Text-only ads

```swift
// All ad types (default)
GistAdControl(..., adTypes: nil)

// Only image ads
GistAdControl(..., adTypes: [.image])

// Both image and text/image ads
GistAdControl(..., adTypes: [.image, .textImage])
```

## Environment Configuration

The SDK supports multiple API environments for different stages of development and testing:

- **`.production`** - Production API endpoint (default)
- **`.integration`** - Integration environment for QA testing
- **`.staging`** - Staging environment for development

### Usage Examples

```swift
// Production (default) - no need to specify
GistAdControl(
    publisherID: "your-publisher-id",
    publisherKey: "your-publisher-key",
    query: "best wireless headphones"
)

// Explicitly use production
GistAdControl(
    publisherID: "your-publisher-id",
    publisherKey: "your-publisher-key",
    query: "best wireless headphones",
    environment: .production
)

// Use staging for development
GistAdControl(
    publisherID: "your-publisher-id",
    publisherKey: "your-publisher-key",
    query: "test query",
    environment: .staging
)

// Use integration for QA
GistAdControl(
    publisherID: "your-publisher-id",
    publisherKey: "your-publisher-key",
    query: "test query",
    environment: .integration
)
```

The environment parameter controls which API endpoint the SDK uses. Base URLs can be overridden via environment variables (see Overriding Base URLs section) or use the default values managed internally.

### Overriding Base URLs

The SDK allows you to override base URLs via environment variables for testing and development:

**Environment Variables:**
- `GIST_ADS_STAGING_URL` - Overrides staging environment base URL
- `GIST_ADS_INTEGRATION_URL` - Overrides integration environment base URL
- `GIST_ADS_PRODUCTION_URL` - Overrides production environment base URL

**Setting Environment Variables:**

**Option 1: Xcode Scheme**
1. Product → Scheme → Edit Scheme...
2. Run → Arguments → Environment Variables
3. Add the variable name and value

**Option 2: Terminal**
```bash
export GIST_ADS_PRODUCTION_URL="https://custom-api.example.com"
```

**Option 3: Build-time Constants**
Edit `Constants.swift` in the SDK source to change default URLs.

If no environment variable is set, the SDK uses the default URLs defined internally.

### Configuring View Heights

The SDK allows you to override default view heights via environment variables for customizing ad display dimensions:

**Environment Variables:**
- `GIST_ADS_DEFAULT_MIN_HEIGHT` - Overrides default minimum height (default: 100)
- `GIST_ADS_DEFAULT_MAX_HEIGHT` - Overrides default maximum height (default: 300)
- `GIST_ADS_IFRAME_MIN_HEIGHT` - Overrides iframe minimum height (default: 250)

**Setting Height Environment Variables:**

**Option 1: Xcode Scheme**
1. Product → Scheme → Edit Scheme...
2. Run → Arguments → Environment Variables
3. Add the variable name and numeric value (e.g., `GIST_ADS_DEFAULT_MIN_HEIGHT` = `150`)

**Option 2: Terminal**
```bash
export GIST_ADS_DEFAULT_MIN_HEIGHT="150"
export GIST_ADS_DEFAULT_MAX_HEIGHT="400"
```

**Option 3: Build-time Constants**
Edit `Constants.swift` in the SDK source to change default height values.

**Notes:**
- Values must be positive numbers (negative values fall back to defaults)
- Invalid values (non-numeric strings) fall back to defaults
- If no environment variable is set, the SDK uses the default height values defined internally

## Advanced Usage

### Dynamic Query Updates

```swift
struct SearchView: View {
    @State private var searchQuery = ""
    
    var body: some View {
        VStack {
            TextField("Search...", text: $searchQuery)
            
            if !searchQuery.isEmpty {
                GistAdControl(
                    publisherID: "your-publisher-id",
                    publisherKey: "your-publisher-key",
                    query: searchQuery
                )
                .frame(height: 250)
                .id(searchQuery) // Force refresh on query change
            }
        }
    }
}
```

### Error Handling

The ad control automatically handles errors and displays appropriate UI:

- **Loading state** - Shows progress indicator
- **Error state** - Shows error message with retry button
- **No ads** - Shows "No ad available" message

### Custom Styling

```swift
GistAdControl(...)
    .frame(height: 250)
    .background(Color.white)
    .cornerRadius(12)
    .shadow(radius: 4)
    .padding()
```

## Example App

The SDK includes a complete example app demonstrating:

- Basic ad integration
- Dynamic query updates
- Ad type filtering
- Geographic location selection
- Error handling

To run the example:

```bash
cd swift-sdk/ExampleApp
open GistAdsExample.xcodeproj
```

Update the credentials in `ContentView.swift`:

```swift
private let publisherID = "your-publisher-id"
private let publisherKey = "your-publisher-key"
```

## API Version Configuration

The SDK supports multiple API versions (v1 and v2) with extensible architecture for future versions. By default, the SDK uses **v2**.

### Switching API Versions

You can switch between API versions using the `GIST_ADS_API_VERSION` environment variable:

**In Xcode:**
1. Edit Scheme → Run → Arguments
2. Add Environment Variable: `GIST_ADS_API_VERSION` = `v1` or `v2`

**In Terminal:**
```bash
export GIST_ADS_API_VERSION=v1
```

**Supported Versions:**
- `v1` - Returns JSON with `selection` array
- `v2` - Returns JSON with `selection` array (default)
- Future versions (v3, v4, etc.) are supported via the extensible architecture

### Version Differences

**v1 Endpoint:**
- Request: `text`, `geo`, `auction_type`, `ad_type` (optional)
- Response: JSON with `selection` array containing `iframeUrl`

**v2 Endpoint:**
- Request: `prompt`, `answer`, `geo`, `auction_type`, `ad_type` (optional), `text` (optional)
- Response: JSON with `selection` array containing `iframeUrl`

## API Integration

The SDK communicates with the Gist Ads API automatically. The API endpoint is managed internally by the SDK based on the configured version.

### Request Format

**v1 Request:**
```json
{
  "text": "search query",
  "geo": "US",
  "auction_type": "native",
  "ad_type": ["image", "text/image", "text"]
}
```

**v2 Request:**
```json
{
  "prompt": "search query",
  "answer": "search query",
  "geo": "US",
  "auction_type": "native",
  "ad_type": ["image", "text/image", "text"],
  "text": "search query"
}
```

### Headers

- `Publisher-ID` - Authentication
- `Publisher-Key` - Authorization
- `Content-Type` - application/json

## Requirements

- iOS 15.0+ / macOS 12.0+
- Xcode 14.0+
- Swift 5.9+

## Architecture

The SDK is organized into several components:

### Models
- `AdType` - Enum for supported ad types
- `SearchRequestV1` - API request model for v1 endpoint
- `SearchRequestV2` - API request model for v2 endpoint
- `SearchResponse` - API response model for v2 endpoint

### Services
- `AdAPIService` - Handles API communication

### Views
- `GistAdControl` - Main public SwiftUI view
- `AdWebView` - Internal WebKit wrapper for rendering

## Best Practices

1. **Cache Credentials** - Store publisher ID and key securely, don't hardcode in production
2. **Handle Empty States** - Always check for empty queries before displaying ads
3. **Optimize Refreshes** - Use `.id()` modifier to control when ads refresh
4. **Responsive Heights** - Set appropriate frame heights based on ad type
5. **Error Monitoring** - Monitor error states for debugging

## Troubleshooting

### No Ads Showing

- Verify your publisher credentials are correct
- Ensure the query is not empty
- Verify ad types are appropriate for your content

### Compilation Errors

- Ensure you're using iOS 15+ or macOS 12+
- Check Swift version is 5.9+
- Clean build folder and rebuild

### Network Errors

- Check network permissions in Info.plist
- Ensure HTTPS is used for production

## Support

For issues, questions, or feature requests:

- Email: support@gist.com
- Documentation: [Integration Guide](INTEGRATION_GUIDE.md)

## License

Copyright © 2024 Gist. All rights reserved.

## Changelog

### Version 1.0.0
- Initial release
- SwiftUI ad control component
- Support for image and image/text ad types
- iOS and macOS support
- Example app included
