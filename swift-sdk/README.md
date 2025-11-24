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
    adTypes: [.image, .imageText]
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

## Ad Types

The SDK supports the following ad types for AI Search:

- **`.image`** - Image-only ads
- **`.imageText`** - Combined image and text ads

```swift
// All ad types (default)
GistAdControl(..., adTypes: nil)

// Only image ads
GistAdControl(..., adTypes: [.image])

// Both image and image/text ads
GistAdControl(..., adTypes: [.image, .imageText])
```

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

- iOS 15.0+ / macOS 12.0+
- Xcode 14.0+
- Swift 5.9+

## Architecture

The SDK is organized into several components:

### Models
- `AdType` - Enum for supported ad types
- `SearchRequest` - API request model
- `SearchResponse` - API response model

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
