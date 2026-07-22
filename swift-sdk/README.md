# Gist Ads SDK for Swift

A native Swift SDK for integrating Gist AI Search Ads into your iOS and macOS applications. This SDK provides a simple, SwiftUI-native way to display contextual ads based on search queries.

## Features

- ✨ **SwiftUI Native** - Built with SwiftUI for seamless integration
- 🚀 **Easy Integration** - Simple API with minimal configuration
- 🎨 **Customizable** - Support for different ad types and configurations
- 🌐 **WebKit Rendering** - Embeds the real `adtag.js` script in a `WKWebView`; the SDK is a thin wrapper that makes no API calls of its own
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

### With Ad Sizes

Like display ads, search ads are rendered by `adtag.js` into a slot sized
from an `AdSize` list (mirrors `sizes` in `defineSlot`). Defaults to
`[.dynamic]` (fluid layout, no fixed dimensions) if omitted:

```swift
GistAdControl(
    publisherID: "your-publisher-id",
    publisherKey: "your-publisher-key",
    query: "running shoes",
    sizes: [.mediumRectangle, .leaderboard]
)
```

### How Search Ads Are Rendered

Like `GistDisplayAdControl`, `GistAdControl` is a thin wrapper around
embedding the real production `adtag.js` script in a `WKWebView`: it builds
a small bootstrap HTML document that calls
`defineSlot({ id, api_key, geo }, slotId, sizes, adTypes)` ->
`slot.definePrompt(query)` -> `displayAd(slotId)`, exactly mirroring how a
publisher's own webpage would embed the tag directly for search, and loads
that into the WebView. The SDK makes no API calls of its own -- `adtag.js`
makes its own JSONP request to the Search API and renders the result
directly into the slot's DOM (no iframe), so as the tag and backend evolve,
this control keeps working without needing to track along.

**Security note:** unlike display ads, search ads are gated by a secret
`publisherKey`. Because `adtag.js` makes its own request from inside the
WebView, `publisherKey` becomes visible in the loaded HTML/JS source and is
sent as a public `publisher_key` query parameter -- the same exposure a
publisher already accepts by embedding the JS tag on a public webpage.
Native apps lose the extra protection of keeping the key server-side/
header-only, which the SDK had before this change.

(An earlier revision called the Search API natively via `AdAPIService` and
wrapped the response's `iframeUrl` in an `<iframe>`, and supported an
`apiVersion` parameter to select between the v1/v2 request body shapes.
Both have been removed: `adtag.js`'s own request is hardcoded to the v2
shape, so there is no version to select once the SDK is a pure embed.)

## Objective-C / UIKit Usage

The SDK also provides a UIKit wrapper (`GistAdView`) that is fully compatible with Objective-C projects. This allows you to use the SDK in both Swift and Objective-C codebases.

> **Note:** `GistAdView` doesn't yet expose a settable `sizes` property (it always uses `[.dynamic]` internally) or an `answer` property -- these are only available on `GistAdControl` (SwiftUI) for now. Exposing them on the Objective-C surface is a documented follow-up.

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

- (void)adViewDidReceiveNoFill:(GistAdView *)adView {
    NSLog(@"No ad available for this slot");
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

## Display Ads

In addition to search ads, the SDK supports contextual **display ads** --
image/text/CTA ads targeted by publisher ID + page URL + size, mirroring the
web ad tag's `defineSlot({id, url}, slotId, sizes)` -> `displayAd(slotId)`
flow. Display ads are a separate feature from search ads (`GistAdControl`)
and use a different control, `GistDisplayAdControl`.

Key differences from search ads:

- **No publisher key required.** Display ads are targeted by publisher ID +
  page URL only, so `GistDisplayAdControl` doesn't take a `publisherKey`
  parameter.
- **Sized, not queried.** Instead of a search `query`, you provide the
  current page URL and one or more standard IAB ad sizes.
- **Real no-fill passback.** You can supply your own SwiftUI view to show
  when no ad is available, instead of a fixed empty state.
- **Targeted by `pageURL` alone.** The backend crawls `pageURL` to infer
  relevance, the same way it would for a real webpage. There is currently no
  way to supply additional targeting signal for screens with no crawlable
  URL (e.g. a purely native screen) -- see "How Display Ads Are Rendered"
  below for why.

### Basic Usage (SwiftUI)

```swift
import SwiftUI
import GistAdsSDK

struct ContentView: View {
    var body: some View {
        GistDisplayAdControl(
            publisherID: "your-publisher-id",
            pageURL: "https://www.example.com/articles/best-hiking-boots",
            sizes: [.mediumRectangle]
        )
        .frame(height: 250)
    }
}
```

### Ad Sizes

`AdSize` provides the standard IAB sizes supported by the display ad server:

| Case | Dimensions |
|------|------------|
| `.leaderboard` | 728x90 |
| `.superLeaderboard` | 970x90 |
| `.mediumRectangle` | 300x250 |
| `.mobileBanner` | 320x50 |
| `.billboard` | 970x250 |
| `.largeRectangle` | 300x600 |
| `.skyscraper` | 160x600 |
| `.dynamic` | fluid layout, no fixed dimensions |

You can pass more than one size to let the server choose the best fit:

```swift
GistDisplayAdControl(
    publisherID: "your-publisher-id",
    pageURL: pageURL,
    sizes: [.leaderboard, .mediumRectangle]
)
```

### No-Fill Passback

When the server has no ad available for a slot, `GistDisplayAdControl` calls
a `passback` view builder you provide -- mirroring the web tag's
`definePassbackFunction`, you get full control over the fallback content
instead of a hard-coded empty state:

```swift
GistDisplayAdControl(
    publisherID: "your-publisher-id",
    pageURL: pageURL,
    sizes: [.mediumRectangle],
    passback: {
        Text("Check out our newsletter instead!")
            .font(.caption)
            .foregroundColor(.secondary)
    }
)
```

If you don't provide a `passback`, a minimal built-in "No ad available" view
is shown instead.

### Callbacks

`GistDisplayAdControl` supports the same `onAdLoaded`, `onAdClicked`, and
`onContentHeightChanged` callbacks as `GistAdControl`:

```swift
GistDisplayAdControl(
    publisherID: "your-publisher-id",
    pageURL: pageURL,
    sizes: [.mediumRectangle],
    onAdLoaded: {
        print("Display ad loaded")
    },
    onAdClicked: { url in
        print("Display ad clicked: \(url)")
    },
    onContentHeightChanged: { height in
        // Resize your container to match the actual ad content size
    }
)
```

### Environment Configuration

Like `GistAdControl`, `GistDisplayAdControl` supports `.staging`,
`.integration`, and `.production` environments:

```swift
GistDisplayAdControl(
    publisherID: "your-publisher-id",
    pageURL: pageURL,
    sizes: [.mediumRectangle],
    environment: .staging
)
```

The `adtag.js` bundle loaded for each environment reuses the same host (and
overrides) as search ads' iframe base URL, since it's one bundle serving
both ad types:

- `GIST_ADS_STAGING_IFRAME_URL`
- `GIST_ADS_INTEGRATION_IFRAME_URL`
- `GIST_ADS_PRODUCTION_IFRAME_URL`

### How Display Ads Are Rendered

`GistDisplayAdControl` is a thin wrapper around embedding the real
production `adtag.js` script in a `WKWebView`: it builds a small bootstrap
HTML document that calls `defineSlot({ id, url }, slotId, sizes)` ->
`displayAd(slotId)`, exactly mirroring how a publisher's own webpage would
embed the tag directly, and loads that into the WebView. The SDK makes no
API calls of its own -- `adtag.js` owns the entire ad request, response
parsing, and rendering, the same as it would on a real webpage, so as the
tag and backend evolve, this control keeps working without needing to
track along. Bridge callbacks (`adRendered`/passback) report the result
back to `GistDisplayAdControl`'s SwiftUI state.

(An earlier revision fetched ads natively to support a `context` targeting
parameter for screens with no crawlable URL. That was removed: `adtag.js`'s
own request has no field for arbitrary targeting data, so supporting it
required a native-fetch special case that defeated the purpose of embedding
the tag. If your app needs contextual targeting for native screens, please
reach out -- this is being tracked as a follow-up.)

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
| `answer` | `String?` | `nil` | Optional answer text, passed via `slot.defineAnswer(...)` |
| `adTypes` | `[AdType]?` | `nil` | Array of ad types to filter (nil = all types) |
| `sizes` | `[AdSize]` | `[.dynamic]` | One or more supported ad sizes (mirrors `sizes` in `defineSlot`) |
| `environment` | `GistAdControl.APIEnvironment` | `.production` | API environment (staging, integration, or production) |
| `theme` | `String` | `"system"` | `"light"`, `"dark"`, or `"system"` |
| `onAdLoaded` | `(() -> Void)?` | `nil` | Callback when ad successfully loads |
| `onAdClicked` | `((URL) -> Void)?` | `nil` | Callback when user clicks an ad link (defaults to opening in browser) |
| `onContentHeightChanged` | `((CGFloat) -> Void)?` | `nil` | Callback when ad content height is determined |
| `passback` | `@ViewBuilder () -> some View` | built-in "No ad available" view | View shown when no ad is available (no-fill) |

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

The environment parameter controls which `adtag.js` host the SDK embeds (see "Overriding Iframe Base URLs" below); neither ad type calls a Search/Display REST API directly anymore, so there is no separate base-URL override for that.

### Overriding Iframe Base URLs

The SDK allows you to override the `adtag.js` script host for each environment, which is useful for testing against staging/integration ad tag servers. This URL is shared by both search and display ads (`adtag.js` is one bundle serving both, distinguished by whether `api_key` is passed to `defineSlot`) and automatically matches the `environment` setting on `GistAdControl` / `GistDisplayAdControl`.

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

- Basic search ad integration
- Dynamic query updates
- Ad type filtering
- Geographic location selection
- Error handling
- Display ad integration with a custom no-fill passback view (see the "Display Ads" tab, presented as a peer to "Search Ads")

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

## Requirements

- iOS 15.0+ / macOS 12.0+
- Xcode 14.0+
- Swift 5.9+

## Architecture

The SDK is organized into several components:

### Models

- `AdType` - Enum for supported ad types, shared by search and display ads
- `AdSize` - Enum for standard IAB ad sizes, shared by search and display ads
- `AdTagLoadState` - Event-derived load state shared by `GistDisplayAdControl` and `GistAdControl` (`.loading`/`.loaded`/`.noFill`/`.failed`)

### Views

- `GistAdControl` - Main public SwiftUI view for search ads (Swift/SwiftUI projects)
- `GistDisplayAdControl` - Main public SwiftUI view for display ads (Swift/SwiftUI projects)
- `GistAdView` - UIKit UIView wrapper for search ads (Objective-C/UIKit projects)
- `AdTagBridgeWebView` - Internal WebKit wrapper that embeds the real `adtag.js` script, shared by search and display ads

### Utils

- `SearchAdBootstrapHTML` - Builds the bootstrap HTML that loads `adtag.js` and drives `defineSlot`/`definePrompt`/`displayAd` for search ads
- `DisplayAdBootstrapHTML` - Builds the bootstrap HTML that loads `adtag.js` and drives `defineSlot`/`displayAd` for display ads

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

### Version 1.0.5

- Search ads now embed the real production `adtag.js` script in a `WKWebView` and drive it via `defineSlot({id, api_key, geo}, slotId, sizes, adTypes)` -> `slot.definePrompt(query)`/`slot.defineAnswer(answer)` -> `displayAd(slotId)`, instead of the SDK calling the Search API and wrapping the response's `iframeUrl` in an `<iframe>`
- `GistAdControl` and `GistAdView` are now thin wrappers that make no API calls of their own -- `adtag.js` owns the entire ad request (its own JSONP GET to the Search API), response parsing, and rendering
- Added a public `sizes: [AdSize]` parameter to `GistAdControl` (default `[.dynamic]`), since `defineSlot` requires a non-empty `sizes` array
- Added a `passback` view builder to `GistAdControl` (mirrors `GistDisplayAdControl`) and an `adViewDidReceiveNoFill:` delegate method to `GistAdViewDelegate`, giving proper no-fill handling instead of surfacing no-fill as an error
- Removed the `apiVersion` parameter from `GistAdControl`/`GistAdView`/`GistAdControl.withAdTypes(...)`: `adtag.js`'s own search request is hardcoded to the v2 body shape, so there is no version to select once the SDK is a pure embed
- Removed `AdAPIService`, `AdAPIError`, `SearchRequestV1`/`SearchRequestV2`/`SearchResponse`, and `IframeHTMLGenerator` (superseded by the embedded tag's own request and rendering)
- **Security note:** `publisherKey` is now sent as a public `publisher_key` query parameter in the tag's own JSONP request (visible in loaded HTML/JS) instead of a hidden `Publisher-Key` HTTP header in a native POST -- the same exposure a publisher already accepts by embedding the JS tag on a public webpage
- Renamed `DisplayAdBridgeWebView`/`DisplayAdLoadState` to `AdTagBridgeWebView`/`AdTagLoadState` to reflect that they're now shared by both search and display ads; also added `target="_blank"` link interception to the shared bridge (previously display-only) so search ad clicks work the same way

### Version 1.0.4

- Display ads now embed the real production `adtag.js` script in a `WKWebView` and drive it via `defineSlot`/`displayAd`, instead of the SDK calling the Display Ad API and rendering raw fields itself
- `GistDisplayAdControl` is now a thin wrapper that makes no API calls of its own -- `adtag.js` owns the entire ad request, response parsing, and rendering
- Added `target="_blank"` link interception (`WKUIDelegate.createWebViewWith`) for display ad clicks
- Removed the `context` parameter: `adtag.js`'s own request has no field for arbitrary targeting data, so supporting it would require a native-fetch special case that defeats the purpose of embedding the tag (this is being tracked as a follow-up if contextual targeting for native screens is needed)
- Removed `DisplayAdAPIService`, `DisplayAPIConstants`, `DisplayAdHTMLGenerator`, and `DisplayAdResponse` (superseded by the embedded tag's own rendering; no longer needed now that the SDK makes no API calls)
- `GistDisplayAdControl`'s `environment` parameter is now `GistAdControl.APIEnvironment` (the same type used by search ads) instead of its own duplicate enum

### Version 1.0.3

- Added `GistDisplayAdControl` for contextual display ads (`defineSlot`/`displayAd` pattern), with standard IAB ad sizes and no-fill passback support
- Added first-party `context` parameter to `GistDisplayAdControl` for passing publisher-provided targeting data to the Display Ad API

### Version 1.0.2

- Added system modes for ad display
- Improved documentation

### Version 1.0.1

- Added ad click handling, content height detection, and ad loaded callbacks to both UIKit (`GistAdView`) and SwiftUI (`GistAdControl`) components
- Refactored to reduce code duplication

### Version 1.0.0

- Initial release
- SwiftUI ad control component
- Support for image and image/text ad types
- iOS and macOS support
- Example app included
