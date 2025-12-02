# Usage Examples

This document provides real-world usage examples for the Gist Ads SDK.

## Table of Contents

1. [Basic Examples](#basic-examples)
2. [Environment Configuration Examples](#environment-configuration-examples)
3. [AI Search Integration](#ai-search-integration)
4. [E-commerce Integration](#e-commerce-integration)
5. [News & Content Apps](#news--content-apps)
6. [Multi-platform Apps](#multi-platform-apps)

---

## Basic Examples

### Simple Static Ad

```swift
import SwiftUI
import GistAdsSDK

struct ProductView: View {
    var body: some View {
        VStack {
            Text("Product Review: Wireless Headphones")
                .font(.title)
            
            Text("Content about headphones...")
            
            // Show relevant ad
            GistAdControl(
                
                publisherID: "pub-12345",
                publisherKey: "key-67890",
                query: "wireless headphones"
            )
            .frame(height: 250)
            .padding()
        }
    }
}
```

### Dynamic Search-Based Ads

```swift
struct SearchView: View {
    @State private var searchQuery = ""
    
    var body: some View {
        VStack {
            TextField("Search...", text: $searchQuery)
                .textFieldStyle(.roundedBorder)
                .padding()
            
            if !searchQuery.isEmpty {
                SearchResultsView(query: searchQuery)
                
                // Ad based on search
                GistAdControl(
                    
                    publisherID: Config.publisherID,
                    publisherKey: Config.publisherKey,
                    query: searchQuery,
                    geo: "US"
                )
                .frame(height: 250)
                .padding()
                .id(searchQuery) // Refresh when query changes
            }
        }
    }
}
```

---

## Environment Configuration Examples

The SDK supports multiple API environments for different stages of development. Use the `environment` parameter to switch between staging, integration, and production endpoints.

### Production Environment (Default)

```swift
// Production is the default - no need to specify
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
```

### Staging Environment

Use staging for development and testing:

```swift
GistAdControl(
    publisherID: "your-publisher-id",
    publisherKey: "your-publisher-key",
    query: "test query",
    environment: .staging
)
```

### Integration Environment

Use integration for QA and pre-production testing:

```swift
GistAdControl(
    publisherID: "your-publisher-id",
    publisherKey: "your-publisher-key",
    query: "test query",
    environment: .integration
)
```

### Environment-Based Configuration

```swift
struct ConfigurableAdView: View {
    let query: String
    @AppStorage("useStaging") private var useStaging = false
    
    var body: some View {
        GistAdControl(
            publisherID: Config.publisherID,
            publisherKey: Config.publisherKey,
            query: query,
            environment: useStaging ? .staging : .production
        )
        .frame(height: 250)
    }
}
```

### Build Configuration Based Environment

```swift
struct AdView: View {
    let query: String
    
    private var environment: GistAdControl.Environment {
        #if DEBUG
        return .staging
        #else
        return .production
        #endif
    }
    
    var body: some View {
        GistAdControl(
            publisherID: Config.publisherID,
            publisherKey: Config.publisherKey,
            query: query,
            environment: environment
        )
        .frame(height: 250)
    }
}
```

---

## AI Search Integration

### ChatGPT-Style Interface

```swift
struct AISearchView: View {
    @State private var messages: [Message] = []
    @State private var inputText = ""
    
    var body: some View {
        VStack {
            // Chat messages
            ScrollView {
                ForEach(messages) { message in
                    MessageBubble(message: message)
                    
                    // Show ad after AI response
                    if message.isAIResponse && message.shouldShowAd {
                        GistAdControl(
                            
                            publisherID: Config.publisherID,
                            publisherKey: Config.publisherKey,
                            query: message.query,
                            geo: getUserLocation()
                        )
                        .frame(height: 200)
                        .padding(.vertical, 8)
                    }
                }
            }
            
            // Input field
            HStack {
                TextField("Ask anything...", text: $inputText)
                Button("Send") { sendMessage() }
            }
            .padding()
        }
    }
    
    func getUserLocation() -> String {
        // Implement location detection
        return "US"
    }
}
```

### Perplexity-Style Search

```swift
struct PerplexityStyleView: View {
    @State private var query = ""
    @State private var searchResult: SearchResult?
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Search bar
                SearchBar(text: $query, onSubmit: performSearch)
                
                if let result = searchResult {
                    // AI Answer
                    AnswerCard(answer: result.answer)
                    
                    // Contextual Ad
                    GistAdControl(
                        
                        publisherID: Config.publisherID,
                        publisherKey: Config.publisherKey,
                        query: extractCommercialIntent(from: result),
                        geo: "US",
                        adTypes: [.image, .textImage]
                    )
                    .frame(height: 250)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // Sources
                    SourcesList(sources: result.sources)
                }
            }
            .padding()
        }
    }
    
    func extractCommercialIntent(from result: SearchResult) -> String {
        // Extract commercial keywords from answer
        // e.g., "best wireless headphones" from answer about headphones
        return result.commercialQuery ?? result.originalQuery
    }
}
```

---

## E-commerce Integration

### Product Search

```swift
struct ProductSearchView: View {
    @State private var searchText = ""
    @State private var products: [Product] = []
    
    var body: some View {
        VStack {
            SearchBar(text: $searchText)
            
            ScrollView {
                // Show ad at top of results
                if !searchText.isEmpty {
                    GistAdControl(
                        
                        publisherID: Config.publisherID,
                        publisherKey: Config.publisherKey,
                        query: searchText,
                        geo: "US",
                        adTypes: [.textImage]
                    )
                    .frame(height: 200)
                    .padding()
                }
                
                // Product grid
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))]) {
                    ForEach(products) { product in
                        ProductCard(product: product)
                    }
                }
            }
        }
    }
}
```

### Category Pages

```swift
struct CategoryView: View {
    let category: String
    @State private var products: [Product] = []
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text(category)
                    .font(.largeTitle)
                
                // Native ad matching category
                GistAdControl(
                    
                    publisherID: Config.publisherID,
                    publisherKey: Config.publisherKey,
                    query: category,
                    geo: "US"
                )
                .frame(height: 250)
                .padding()
                
                // Product list
                ForEach(products) { product in
                    ProductRow(product: product)
                }
            }
        }
        .onAppear {
            loadProducts()
        }
    }
}
```

---

## News & Content Apps

### Article View with In-Content Ads

```swift
struct ArticleView: View {
    let article: Article
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Article header
                Text(article.title)
                    .font(.title)
                
                // First few paragraphs
                ForEach(article.paragraphs.prefix(3)) { paragraph in
                    Text(paragraph.text)
                }
                
                // Mid-article ad
                GistAdControl(
                    
                    publisherID: Config.publisherID,
                    publisherKey: Config.publisherKey,
                    query: extractKeyTopics(from: article),
                    geo: getUserLocation()
                )
                .frame(height: 250)
                .padding(.vertical)
                
                // Remaining content
                ForEach(article.paragraphs.dropFirst(3)) { paragraph in
                    Text(paragraph.text)
                }
            }
            .padding()
        }
    }
    
    func extractKeyTopics(from article: Article) -> String {
        // Extract main topics from article for relevant ads
        return article.keywords.joined(separator: " ")
    }
}
```

### News Feed with Native Ads

```swift
struct NewsFeedView: View {
    @State private var articles: [Article] = []
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(Array(articles.enumerated()), id: \.1.id) { index, article in
                    ArticleCard(article: article)
                    
                    // Show ad every 5 articles
                    if (index + 1) % 5 == 0 {
                        GistAdControl(
                            
                            publisherID: Config.publisherID,
                            publisherKey: Config.publisherKey,
                            query: article.category,
                            geo: "US"
                        )
                        .frame(height: 200)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        .overlay(
                            Text("Sponsored")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(4),
                            alignment: .topTrailing
                        )
                    }
                }
            }
            .padding()
        }
    }
}
```

---

## Multi-platform Apps

### iOS and macOS Shared Code

```swift
struct AdContainer: View {
    let query: String
    
    var body: some View {
        GistAdControl(
            
            publisherID: Config.publisherID,
            publisherKey: Config.publisherKey,
            query: query,
            geo: "US"
        )
        .frame(height: adHeight)
        .padding(adPadding)
    }
    
    #if os(iOS)
    private var adHeight: CGFloat { 250 }
    private var adPadding: CGFloat { 16 }
    #elseif os(macOS)
    private var adHeight: CGFloat { 300 }
    private var adPadding: CGFloat { 24 }
    #endif
}
```

### Responsive Layout

```swift
struct ResponsiveAdView: View {
    let query: String
    @Environment(\.horizontalSizeClass) var sizeClass
    
    var body: some View {
        GeometryReader { geometry in
            GistAdControl(
                
                publisherID: Config.publisherID,
                publisherKey: Config.publisherKey,
                query: query
            )
            .frame(
                width: adWidth(for: geometry.size),
                height: adHeight(for: geometry.size)
            )
            .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
        }
    }
    
    private func adWidth(for size: CGSize) -> CGFloat {
        sizeClass == .compact ? size.width * 0.95 : min(600, size.width * 0.7)
    }
    
    private func adHeight(for size: CGSize) -> CGFloat {
        sizeClass == .compact ? 200 : 250
    }
}
```

---

## Advanced Patterns

### Ad Manager Service

```swift
class AdManager: ObservableObject {
    @Published var shouldShowAds = true
    
    private let baseURL: String
    private let publisherID: String
    private let publisherKey: String
    
    init() {
        self.baseURL = Config.apiURL
        self.publisherID = Config.publisherID
        self.publisherKey = Config.publisherKey
    }
    
    func adControl(for query: String, geo: String = "US") -> GistAdControl {
        GistAdControl(
            
            publisherID: publisherID,
            publisherKey: publisherKey,
            query: query,
            geo: geo
        )
    }
}

// Usage
struct ContentView: View {
    @StateObject private var adManager = AdManager()
    
    var body: some View {
        VStack {
            if adManager.shouldShowAds {
                adManager.adControl(for: "search query")
                    .frame(height: 250)
            }
        }
    }
}
```

### Ad Placement Strategy

```swift
struct ContentWithStrategicAds: View {
    let content: [ContentBlock]
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                ForEach(Array(content.enumerated()), id: \.1.id) { index, block in
                    ContentBlockView(block: block)
                    
                    // Strategic ad placement
                    if shouldShowAd(at: index) {
                        adView(for: block)
                    }
                }
            }
        }
    }
    
    private func shouldShowAd(at index: Int) -> Bool {
        // Show ads at strategic positions
        let positions = [2, 7, 15] // After specific content blocks
        return positions.contains(index)
    }
    
    private func adView(for block: ContentBlock) -> some View {
        GistAdControl(
            
            publisherID: Config.publisherID,
            publisherKey: Config.publisherKey,
            query: block.topic,
            geo: "US"
        )
        .frame(height: 250)
        .transition(.opacity)
    }
}
```

---

## Best Practices

### 1. Query Optimization

```swift
// Good: Specific, commercial intent
GistAdControl(..., query: "best wireless headphones 2024")

// Bad: Too vague
GistAdControl(..., query: "stuff")

// Good: Extract meaningful queries
func extractCommercialQuery(from text: String) -> String {
    // Use NLP or keyword extraction
    let keywords = KeywordExtractor.extract(from: text)
    return keywords.joined(separator: " ")
}
```

### 2. Error Handling

```swift
struct SafeAdView: View {
    let query: String
    @State private var showAd = true
    
    var body: some View {
        if showAd && !query.isEmpty {
            GistAdControl(
                
                publisherID: Config.publisherID,
                publisherKey: Config.publisherKey,
                query: query
            )
            .frame(height: 250)
        }
    }
}
```

### 3. Performance Optimization

```swift
struct OptimizedAdView: View {
    let query: String
    
    var body: some View {
        GistAdControl(
            
            publisherID: Config.publisherID,
            publisherKey: Config.publisherKey,
            query: query
        )
        .frame(height: 250)
        .id(query) // Only refresh when query changes
        .background(Color.white)
        .drawingGroup() // Optimize rendering
    }
}
```

---

For more examples, see the [Example App](./ExampleApp/) in this repository.

