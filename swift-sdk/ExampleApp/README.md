# Gist Ads SDK - Example App

This example app demonstrates how to integrate the Gist Ads SDK into an iOS application.

## Features

- ✅ Live ad preview with real-time updates
- ✅ Configuration UI for testing different parameters
- ✅ Ad type filtering (image, image/text)
- ✅ Geographic targeting selection
- ✅ Environment configuration (staging, integration, production)
- ✅ Example queries for testing
- ✅ Error handling demonstration

## Setup

1. Open `GistAdsExample.xcodeproj` in Xcode
2. Update credentials in `ContentView.swift`:

```swift
private let publisherID = "your-publisher-id"
private let publisherKey = "your-publisher-key"
```

3. Build and run the app

## Usage

The app provides a complete UI to test the Gist Ad Control:

### Configuration Panel

- **Search Query**: Enter any search query to fetch relevant ads
- **Geographic Location**: Select US, GB, CA, or AU
- **Ad Types**: Toggle between image and image/text ads
- **Reload Button**: Force refresh the ad

### Live Preview

- Shows the ad in real-time as you change settings
- Displays loading states
- Handles errors gracefully
- Shows "no ad available" when appropriate

### Example Queries

Quick access buttons for common search queries:

- "best wireless headphones"
- "affordable laptops for students"
- "top rated running shoes"
- "smart home devices 2024"
- "healthy meal delivery services"

## Code Structure

```
GistAdsExample/
├── GistAdsExampleApp.swift    # App entry point
└── ContentView.swift           # Main UI with ad integration
```

## Key Implementation Details

### Basic Integration

```swift
import GistAdsSDK

GistAdControl(
    publisherID: "your-publisher-id",
    publisherKey: "your-publisher-key",
    query: searchQuery
)
.frame(height: 250)
```

### Dynamic Updates

```swift
@State private var searchQuery = ""

// Ad refreshes automatically when query changes
GistAdControl(
    publisherID: publisherID,
    publisherKey: publisherKey,
    query: searchQuery
)
.id(searchQuery)  // Forces refresh
```

### With Filters

```swift
GistAdControl(
    publisherID: publisherID,
    publisherKey: publisherKey,
    query: searchQuery,
    geo: selectedGeo,
    adTypes: [.image, .textImage],
    environment: .production  // Optional: .staging, .integration, or .production (default)
)
```

### Environment Configuration

You can test with different API environments by specifying the `environment` parameter:

```swift
// Production (default)
GistAdControl(
    publisherID: publisherID,
    publisherKey: publisherKey,
    query: searchQuery,
    environment: .production
)

// Staging for development
GistAdControl(
    publisherID: publisherID,
    publisherKey: publisherKey,
    query: searchQuery,
    environment: .staging
)

// Integration for QA
GistAdControl(
    publisherID: publisherID,
    publisherKey: publisherKey,
    query: searchQuery,
    environment: .integration
)
```

**Note:** The environment parameter controls which API endpoint is used. Use staging or integration for testing, and production for release builds.

### API Version Configuration

The SDK supports both v1 and v2 API endpoints. By default, v2 is used. You can switch versions using the `GIST_ADS_API_VERSION` environment variable.

**Testing with v1:**

1. In Xcode: Product → Scheme → Edit Scheme...
2. Run → Arguments → Environment Variables
3. Add: `GIST_ADS_API_VERSION` = `v1`
4. Run the app

**Testing with v2 (Default):**

- Omit the environment variable, or set `GIST_ADS_API_VERSION` = `v2`

**Version Differences:**

- **v1**: Returns JSON with `selection` array
- **v2**: Returns JSON with `selection` array, generates iframe HTML (default)

**Note:** The SDK architecture is extensible and supports future API versions. Simply set the `GIST_ADS_API_VERSION` environment variable to the desired version string (e.g., "v3", "v4").

## Requirements

- iOS 15.0+
- Xcode 14.0+
- Valid Gist publisher credentials

## Learn More

- [SDK Documentation](../README.md)
- [Integration Guide](../INTEGRATION_GUIDE.md)
- [Quick Start](../QUICK_START.md)
