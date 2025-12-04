# Gist Ads SDK

Native SDKs for integrating Gist AI Search Ads into your iOS and Android applications. Display contextual ads based on search queries with simple, modern UI components.

## 📦 Available SDKs

### iOS / macOS (Swift)
- **Location**: [`swift-sdk/`](swift-sdk/)
- **Framework**: SwiftUI
- **Min Version**: iOS 15.0+, macOS 12.0+
- **Language**: Swift 5.9+

### Android
- **Location**: [`android-sdk/`](android-sdk/)
- **Framework**: Jetpack Compose
- **Min Version**: Android 7.0+ (API 24+)
- **Language**: Kotlin 1.9+

## ✨ Features

| Feature | iOS/macOS | Android |
|---------|-----------|---------|
| Native UI Framework | SwiftUI | Jetpack Compose |
| Easy Integration | ✅ | ✅ |
| Ad Type Filtering | ✅ | ✅ |
| Geographic Targeting | ✅ | ✅ |
| WebView Rendering | ✅ | ✅ |
| Type-Safe API | ✅ | ✅ |
| Error Handling | ✅ | ✅ |
| Debug Logging | ✅ | ✅ |
| Example App | ✅ | ✅ |

## 🚀 Quick Start

### iOS/macOS (Swift)

```swift
import SwiftUI
import GistAdsSDK

struct ContentView: View {
    var body: some View {
        GistAdControl(
            publisherID: "your-publisher-id",
            publisherKey: "your-publisher-key",
            query: "wireless headphones",
            geo: "US"
        )
        .frame(height: 250)
    }
}
```

**Installation** (Swift Package Manager):
```swift
dependencies: [
    .package(url: "https://github.com/your-org/gist-ads-sdk-swift.git", from: "1.0.0")
]
```

📚 **Full Documentation**: [swift-sdk/README.md](swift-sdk/README.md)

---

### Android (Kotlin)

```kotlin
import androidx.compose.runtime.Composable
import com.gist.ads.sdk.ui.GistAdControl

@Composable
fun MyScreen() {
    GistAdControl(
        publisherId = "your-publisher-id",
        publisherKey = "your-publisher-key",
        query = "wireless headphones",
        geo = "US",
        modifier = Modifier
            .fillMaxWidth()
            .height(250.dp)
    )
}
```

**Installation** (Gradle):
```kotlin
dependencies {
    implementation("com.gist.ads:sdk:1.0.0")
}
```

📚 **Full Documentation**: [android-sdk/README.md](android-sdk/README.md)

## 🎯 Core Concepts

### Required Configuration

Both SDKs require the same credentials:

| Parameter | Description | Example |
|-----------|-------------|---------|
| `publisherID` / `publisherId` | Your publisher ID credential | `"pub_12345"` |
| `publisherKey` | Your publisher API key | `"key_abcdef..."` |
| `query` | Search query for relevant ads | `"wireless headphones"` |

### Optional Configuration

| Parameter | Default | Description |
|-----------|---------|-------------|
| `geo` | `"US"` | Geographic location code (US, GB, CA, etc.) |
| `adTypes` | `nil` (all) | Filter specific ad types (IMAGE, IMAGE_TEXT) |

### Supported Ad Types

- **IMAGE** - Image-only advertisements
- **IMAGE_TEXT** - Combined image and text advertisements

### Supported Regions

🇺🇸 US · 🇬🇧 GB · 🇨🇦 CA · 🇦🇺 AU · 🇩🇪 DE · 🇫🇷 FR · 🇯🇵 JP · 🇮🇳 IN

## 📱 Example Applications

Both SDKs include fully functional example applications:

### iOS Example App
- **Location**: `swift-sdk/ExampleApp/`
- Features: Basic integration, dynamic search, ad filtering, settings
- Open `ProrataAdsExample.xcodeproj` in Xcode

### Android Example App
- **Location**: `android-sdk/ExampleApp/`
- Features: Basic integration, dynamic search, ad filtering, settings
- Open in Android Studio or run: `./gradlew :ExampleApp:installDebug`

## 🏗️ Architecture

Both SDKs follow similar architecture patterns:

```
SDK Components:
├── Models          # Data structures (AdType, SearchRequest, SearchResponse)
├── Services        # API communication layer
└── UI Components   # Native UI controls (SwiftUI / Compose)
```

### API Integration

Both SDKs communicate with the same backend:

- **Endpoint**: `https://tp-srch-api.gist.ai/v1/search`
- **Method**: POST
- **Headers**: `Publisher-ID`, `Publisher-Key`
- **Format**: JSON

## 📖 Documentation Structure

### Swift SDK (`swift-sdk/`)
- `README.md` - Main documentation
- `QUICK_START.md` - 5-minute setup guide
- `INTEGRATION_GUIDE.md` - Detailed integration
- `USAGE_EXAMPLES.md` - Code examples
- `ExampleApp/` - Working demo app

### Android SDK (`android-sdk/`)
- `README.md` - Main documentation
- `QUICK_START.md` - 5-minute setup guide
- `INTEGRATION_GUIDE.md` - Detailed integration
- `USAGE_EXAMPLES.md` - Code examples
- `ExampleApp/` - Working demo app

## 🔧 Advanced Usage

### Dynamic Search with Debouncing

**Swift**:
```swift
@State private var searchQuery = ""

TextField("Search...", text: $searchQuery)

if !searchQuery.isEmpty {
    GistAdControl(
        publisherID: "your-id",
        publisherKey: "your-key",
        query: searchQuery
    )
    .id(searchQuery) // Force refresh on change
}
```

**Android**:
```kotlin
var searchText by remember { mutableStateOf("") }
var debouncedQuery by remember { mutableStateOf("") }

LaunchedEffect(searchText) {
    delay(500) // Debounce
    debouncedQuery = searchText
}

TextField(value = searchText, onValueChange = { searchText = it })

if (debouncedQuery.isNotBlank()) {
    GistAdControl(
        publisherId = "your-id",
        publisherKey = "your-key",
        query = debouncedQuery
    )
}
```

### Ad Type Filtering

**Swift**:
```swift
GistAdControl(
    publisherID: "your-id",
    publisherKey: "your-key",
    query: "laptops",
    adTypes: [.image, .imageText]
)
```

**Android**:
```kotlin
GistAdControl(
    publisherId = "your-id",
    publisherKey = "your-key",
    query = "laptops",
    adTypes = listOf(AdType.IMAGE, AdType.IMAGE_TEXT)
)
```

## 🛠️ Development

### Prerequisites

**Swift SDK**:
- Xcode 14.0+
- Swift 5.9+
- iOS 15+ / macOS 12+ deployment target

**Android SDK**:
- Android Studio Arctic Fox+
- Kotlin 1.9+
- Gradle 8.0+
- JDK 17

### Building from Source

**Swift**:
```bash
cd swift-sdk
swift build
# Or open Package.swift in Xcode
```

**Android**:
```bash
cd android-sdk
./gradlew build
# Or open in Android Studio
```

## 🔐 Security Best Practices

1. **Never hardcode credentials** in production code
2. **Use environment variables** or secure configuration
3. **Store keys in**:
   - iOS: Keychain or `.xcconfig` files (gitignored)
   - Android: `local.properties` or BuildConfig (gitignored)
4. **Enable HTTPS** for all API communications (enforced by SDK)

### Example: Secure Configuration

**Swift** (`.xcconfig`):
```
GIST_PUBLISHER_ID = your-publisher-id
GIST_PUBLISHER_KEY = your-publisher-key
```

**Android** (`gradle.properties`):
```properties
gistPublisherId=your-publisher-id
gistPublisherKey=your-publisher-key
```

## 🧪 Testing

Both SDKs include:
- Unit tests for models and business logic
- Integration tests for API communication
- UI tests for components
- Example apps for manual testing

Run tests:
```bash
# Swift
swift test

# Android
./gradlew test
```

## 📊 Performance

- **Lightweight**: Minimal dependencies
- **Efficient**: Async/await (Swift) and Coroutines (Android)
- **Cached**: Smart caching of API responses
- **Responsive**: Native rendering for smooth UI

## 🐛 Troubleshooting

### Common Issues

**Ads not loading?**
- Verify credentials are correct
- Check network connectivity
- Ensure query is not empty
- Review API logs (enable debug mode)

**Build errors?**
- Swift: Ensure minimum deployment target
- Android: Verify Gradle sync completed
- Check all dependencies are resolved

### Debug Mode

**Swift**:
```swift
GistAdControl(...) // Logging automatic in debug builds
```

**Android**:
```kotlin
GistAdControl(
    ...,
    enableLogging = BuildConfig.DEBUG
)
```

## 📄 License

Copyright © 2024 Gist. All rights reserved.

See platform-specific LICENSE files for details.

## 🤝 Support

- **Email**: support@gist.com
- **Swift Documentation**: [swift-sdk/README.md](swift-sdk/README.md)
- **Android Documentation**: [android-sdk/README.md](android-sdk/README.md)

## 🗺️ Roadmap

### Coming Soon
- Video ad support
- Banner ad sizes
- Ad caching and preloading
- Analytics integration
- A/B testing capabilities

## 📈 Version

- **Swift SDK**: 1.0.0
- **Android SDK**: 1.0.0

See individual CHANGELOG files for version history:
- [swift-sdk/CHANGELOG.md](swift-sdk/CHANGELOG.md)
- [android-sdk/CHANGELOG.md](android-sdk/CHANGELOG.md)

---

## Getting Started

Choose your platform:

- **📱 iOS/macOS** → [swift-sdk/README.md](swift-sdk/README.md)
- **🤖 Android** → [android-sdk/README.md](android-sdk/README.md)

Or explore the example apps:

- **Swift** → [swift-sdk/ExampleApp/](swift-sdk/ExampleApp/)
- **Android** → [android-sdk/ExampleApp/](android-sdk/ExampleApp/)

