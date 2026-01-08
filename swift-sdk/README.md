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

### Requirements

Before installing, ensure your project meets these requirements:

- **iOS 15.0+** deployment target (or macOS 12.0+)
- **Xcode 14.0+**
- **Swift 5.9+**

### Method 1: Using Xcode (Recommended)

This is the easiest method for most iOS projects:

1. **Open your iOS project** in Xcode

2. **Select your project** in the Project Navigator (the top-level blue icon)

3. **Select your app target** in the main editor area

4. **Go to the "Package Dependencies" tab** (or "Swift Packages" in older Xcode versions)

5. **Click the "+" button** at the bottom left (or use **File → Add Packages...** from the menu)

6. **Enter the package URL** in the search field:

   ```
   https://github.com/Prorata-ai/PrtAdsSDK.git
   ```

7. **Click "Add Package"** - Xcode will fetch the package

8. **Select the version**:
   - Choose **"Up to Next Major Version"** with `1.0.0`
   - Or select a specific version/tag from the dropdown

9. **Select the product**:
   - Check **"GistAdsSDK"** in the product list
   - Choose your target(s) under **"Add to Target"** (usually your app target)

10. **Click "Add Package"** to complete the installation

The package will now appear in your project's Package Dependencies and be available for import.

### Method 2: Using Package.swift

If your project uses a `Package.swift` file (Swift Package Manager projects):

1. **Open your `Package.swift` file**

2. **Add the dependency** to the `dependencies` array:

```swift
dependencies: [
    .package(url: "https://github.com/Prorata-ai/PrtAdsSDK.git", from: "1.0.0")
]
```

1. **Add the product to your target's dependencies**:

```swift
.target(
    name: "YourTarget",
    dependencies: [
        .product(name: "GistAdsSDK", package: "PrtAdsSDK")
    ]
)
```

1. **Resolve packages**:
   - In Xcode: **File → Packages → Resolve Package Versions**
   - Or run: `swift package resolve` from terminal

### Troubleshooting

**Package not found?**

- Ensure you're connected to the internet
- Verify the repository URL is correct: `https://github.com/Prorata-ai/PrtAdsSDK.git`
- Check that the version tag `1.0.0` exists in the repository

**Version not found?**

- Verify the tag exists: `git ls-remote --tags https://github.com/Prorata-ai/PrtAdsSDK.git`
- Try using a different version requirement (e.g., `.upToNextMajor(from: "1.0.0")`)

**Build errors after adding?**

- Ensure your deployment target is iOS 15.0+ (check in Build Settings)
- Clean build folder: **Product → Clean Build Folder** (⇧⌘K)
- Verify the package resolved correctly in Package Dependencies

**Import errors?**

- Make sure you've added the package to your target (step 9 in Method 1)
- Check that `import GistAdsSDK` is spelled correctly
- Try restarting Xcode if the package was just added

## Quick Start

After installing the package, you can start using it immediately:

### 1. Import the SDK

Add the import statement at the top of your Swift file:

```swift
import GistAdsSDK
```

### 2. Basic Usage (SwiftUI)

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

### 3. Basic Usage (UIKit)

```swift
import UIKit
import GistAdsSDK

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let adView = GistAdView(frame: CGRect(x: 0, y: 0, width: 320, height: 250))
        adView.publisherID = "your-publisher-id"
        adView.publisherKey = "your-publisher-key"
        adView.query = "best wireless headphones"
        adView.geo = "US"
        
        view.addSubview(adView)
        adView.loadAd()
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

## Objective-C / UIKit Usage

The SDK also provides a UIKit wrapper (`GistAdView`) that is fully compatible with Objective-C projects. This allows you to use the SDK in both Swift and Objective-C codebases.

### Basic Usage (Objective-C)

```objc
@import GistAdsSDK;

// In your view controller
- (void)viewDidLoad {
    [super viewDidLoad];
    
    GistAdView *adView = [[GistAdView alloc] initWithFrame:CGRectMake(0, 0, 320, 250)];
    adView.publisherID = @"your-publisher-id";
    adView.publisherKey = @"your-publisher-key";
    adView.query = @"best wireless headphones";
    adView.geo = @"US";
    adView.delegate = self;
    
    [self.view addSubview:adView];
    [adView loadAd];
}
```

### With Delegate (Objective-C)

```objc
@interface MyViewController () <GistAdViewDelegate>
@property (nonatomic, strong) GistAdView *adView;
@end

@implementation MyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.adView = [[GistAdView alloc] initWithFrame:CGRectMake(0, 0, 320, 250)];
    self.adView.publisherID = @"your-publisher-id";
    self.adView.publisherKey = @"your-publisher-key";
    self.adView.query = @"running shoes";
    self.adView.geo = @"US";
    self.adView.environment = GistAdEnvironmentProduction;
    self.adView.delegate = self;
    
    [self.view addSubview:self.adView];
    [self.adView loadAd];
}

#pragma mark - GistAdViewDelegate

- (void)adViewDidStartLoading:(GistAdView *)adView {
    NSLog(@"Ad started loading");
}

- (void)adViewDidLoad:(GistAdView *)adView {
    NSLog(@"Ad loaded successfully");
}

- (void)adView:(GistAdView *)adView didFailWithError:(NSError *)error {
    NSLog(@"Ad failed to load: %@", error.localizedDescription);
}

@end
```

### With Ad Type Filtering (Objective-C)

```objc
// Filter to only show image and text/image ads
NSArray<NSNumber *> *adTypes = @[
    @(GistAdTypeImage),
    @(GistAdTypeTextImage)
];
adView.adTypes = adTypes;
```

### Swift Usage with UIKit

You can also use `GistAdView` in Swift UIKit projects:

```swift
import GistAdsSDK

class MyViewController: UIViewController {
    var adView: GistAdView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        adView = GistAdView(frame: CGRect(x: 0, y: 0, width: 320, height: 250))
        adView.publisherID = "your-publisher-id"
        adView.publisherKey = "your-publisher-key"
        adView.query = "best wireless headphones"
        adView.geo = "US"
        adView.delegate = self
        adView.environment = .production
        
        view.addSubview(adView)
        adView.loadAd()
    }
}

extension MyViewController: GistAdViewDelegate {
    func adViewDidStartLoading(_ adView: GistAdView) {
        print("Ad started loading")
    }
    
    func adViewDidLoad(_ adView: GistAdView) {
        print("Ad loaded successfully")
    }
    
    func adView(_ adView: GistAdView, didFailWithError error: Error) {
        print("Ad failed: \(error.localizedDescription)")
    }
}
```

## Ad Click Handling

The SDK intercepts clicks on external URLs within ads and provides callbacks so you can handle them appropriately (e.g., open in Safari, in-app browser, or custom handling).

### SwiftUI (GistAdControl)

```swift
GistAdControl(
    publisherID: "your-publisher-id",
    publisherKey: "your-publisher-key",
    query: "best wireless headphones",
    onAdClicked: { url in
        // Handle the clicked URL
        print("Ad clicked: \(url)")
        // Default behavior if not provided: opens in Safari
    }
)
```

### UIKit / Objective-C (GistAdView)

```swift
// Swift
extension MyViewController: GistAdViewDelegate {
    func adView(_ adView: GistAdView, didClickURL url: URL) {
        // Handle the clicked URL
        UIApplication.shared.open(url)
    }
}
```

```objc
// Objective-C
- (void)adView:(GistAdView *)adView didClickURL:(NSURL *)url {
    // Handle the clicked URL
    [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
}
```

If the delegate method is not implemented, the URL will automatically open in Safari.

## Content Height Detection

The SDK reports the actual rendered height of ad content, allowing you to dynamically resize the ad container to eliminate gaps between the ad and surrounding content.

### SwiftUI (GistAdControl)

```swift
struct AdContainerView: View {
    @State private var adHeight: CGFloat = 250  // Default height
    
    var body: some View {
        GistAdControl(
            publisherID: "your-publisher-id",
            publisherKey: "your-publisher-key",
            query: "best wireless headphones",
            onContentHeightChanged: { height in
                // Update the container height to match ad content
                adHeight = height
            }
        )
        .frame(height: adHeight)
    }
}
```

### UIKit / Objective-C (GistAdView)

```swift
// Swift
extension MyViewController: GistAdViewDelegate {
    func adView(_ adView: GistAdView, didLoadWithContentHeight height: CGFloat) {
        // Update your constraint or frame
        adViewHeightConstraint.constant = height
        view.layoutIfNeeded()
    }
}
```

```objc
// Objective-C
- (void)adView:(GistAdView *)adView didLoadWithContentHeight:(CGFloat)height {
    // Update your constraint or frame
    self.adViewHeightConstraint.constant = height;
    [self.view layoutIfNeeded];
}
```

## Theme Support

The SDK supports light and dark mode for ad content, automatically detecting the system theme or allowing manual override.

### Automatic System Detection (Default)

By default, ads automatically match your device's light/dark theme:

```swift
GistAdControl(
    publisherID: "your-publisher-id",
    publisherKey: "your-publisher-key",
    query: "wireless headphones"
    // theme: "system" is the default
)
```

The SDK uses SwiftUI's `@Environment(\.colorScheme)` to detect the system theme and passes `"light"` or `"dark"` to the ad iframe.

### Manual Theme Override

Force a specific theme regardless of system settings:

```swift
// Force light mode
GistAdControl(
    publisherID: "your-publisher-id",
    publisherKey: "your-publisher-key",
    query: "running shoes",
    theme: "light"
)

// Force dark mode
GistAdControl(
    publisherID: "your-publisher-id",
    publisherKey: "your-publisher-key",
    query: "smart watch",
    theme: "dark"
)
```

### How It Works

The SDK passes a `pr_theme` parameter to the ad iframe:

- **`"system"`** (default) - Detects device theme with `@Environment(\.colorScheme)` and passes `"light"` or `"dark"` to the iframe
- **`"light"`** - Forces light mode in the iframe
- **`"dark"`** - Forces dark mode in the iframe

The iframe content adapts using CSS `color-scheme` and invert filters to match the selected theme.

### Example with Theme Picker

```swift
struct AdWithThemePicker: View {
    @State private var selectedTheme = "system"
    
    var body: some View {
        VStack(spacing: 16) {
            // Theme picker
            Picker("Theme", selection: $selectedTheme) {
                Text("System").tag("system")
                Text("Light").tag("light")
                Text("Dark").tag("dark")
            }
            .pickerStyle(.segmented)
            
            // Ad with selected theme
            GistAdControl(
                publisherID: "your-publisher-id",
                publisherKey: "your-publisher-key",
                query: "wireless headphones",
                theme: selectedTheme
            )
            .frame(height: 250)
        }
        .padding()
    }
}
```

### UIKit / Objective-C Support

```swift
// Swift
let adView = GistAdView(
    publisherID: "your-publisher-id",
    publisherKey: "your-publisher-key",
    query: "laptops",
    theme: .dark  // Use GistAdTheme enum
)
```

```objc
// Objective-C
GistAdView *adView = [[GistAdView alloc] initWithPublisherID:@"your-publisher-id"
                                                  publisherKey:@"your-publisher-key"
                                                         query:@"laptops"
                                                         theme:GistAdThemeDark];
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
| `onAdLoaded` | `(() -> Void)?` | `nil` | Callback when ad successfully loads |
| `onAdClicked` | `((URL) -> Void)?` | `nil` | Callback when user clicks an ad link (defaults to opening in browser) |
| `onContentHeightChanged` | `((CGFloat) -> Void)?` | `nil` | Callback when ad content height is determined |

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

### Overriding Iframe Base URLs

The SDK allows you to override iframe base URLs for each environment, which is useful for testing against staging/integration ad tag servers. The iframe base URL automatically matches the `GistAdControl` environment setting.

**Environment Variables:**

- `GIST_ADS_STAGING_IFRAME_URL` - Overrides staging environment iframe base URL
- `GIST_ADS_INTEGRATION_IFRAME_URL` - Overrides integration environment iframe base URL
- `GIST_ADS_PRODUCTION_IFRAME_URL` - Overrides production environment iframe base URL

**Default Iframe Base URLs:**

- Staging: `https://tp-at.staging.prorata.ai`
- Integration: `https://tp-at.integration.prorata.ai`
- Production: `https://tp-at.prorata.ai`

**Setting Iframe Base URL Environment Variables:**

**Option 1: Xcode Scheme**

1. Product → Scheme → Edit Scheme...
2. Run → Arguments → Environment Variables
3. Add the variable name and value (e.g., `GIST_ADS_STAGING_IFRAME_URL` = `https://custom-staging.example.com`)

**Option 2: Terminal**

```bash
export GIST_ADS_STAGING_IFRAME_URL="https://custom-staging.example.com"
export GIST_ADS_INTEGRATION_IFRAME_URL="https://custom-integration.example.com"
```

**Option 3: Build-time Constants**
Edit `Constants.swift` in the SDK source to change default iframe base URLs.

If no environment variable is set, the SDK uses the default iframe base URLs defined internally for each environment.

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

- `GistAdControl` - Main public SwiftUI view (Swift/SwiftUI projects)
- `GistAdView` - UIKit UIView wrapper (Objective-C/UIKit projects)
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

- Email: <support@gist.com>
- Documentation: [Integration Guide](INTEGRATION_GUIDE.md)

## License

Copyright © 2026 Gist. All rights reserved.

## Changelog

### Version 1.0.0

- Initial release
- SwiftUI ad control component
- Support for image and image/text ad types
- iOS and macOS support
- Example app included
