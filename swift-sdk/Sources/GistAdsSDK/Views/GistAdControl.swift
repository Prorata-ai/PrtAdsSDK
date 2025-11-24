//
//  GistAdControl.swift
//  GistAdsSDK
//
//  Main ad control for displaying Gist AI Search ads
//

import SwiftUI

/// Main control for displaying Gist AI Search ads
public struct GistAdControl: View {
    
    // MARK: - Configuration Properties
    
    private let publisherID: String
    private let publisherKey: String
    private let query: String
    private let geo: String
    private let adTypes: [AdType]?
    
    // MARK: - State
    
    @State private var adContent: String?
    @State private var isLoading = false
    @State private var error: Error?
    
    private let apiService: AdAPIService
    
    // MARK: - Internal Configuration
    
    // Production API endpoint - managed internally
    private static let apiBaseURL = "https://ads-api.gist.com"
    
    // MARK: - Initialization
    
    /// Initialize the Gist ad control
    /// - Parameters:
    ///   - publisherID: Your publisher ID
    ///   - publisherKey: Your publisher API key
    ///   - query: The search query to fetch ads for
    ///   - geo: Geographic location code (e.g., "US", "GB")
    ///   - adTypes: Optional array of ad types to filter (defaults to all types)
    public init(
        publisherID: String,
        publisherKey: String,
        query: String,
        geo: String = "US",
        adTypes: [AdType]? = nil
    ) {
        self.publisherID = publisherID
        self.publisherKey = publisherKey
        self.query = query
        self.geo = geo
        self.adTypes = adTypes
        
        self.apiService = AdAPIService(
            baseURL: Self.apiBaseURL,
            publisherID: publisherID,
            publisherKey: publisherKey
        )
    }
    
    // MARK: - Body
    
    public var body: some View {
        ZStack {
            if isLoading {
                ProgressView("Loading ad...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let error = error {
                errorView(error: error)
            } else if let adContent = adContent {
                AdWebView(htmlContent: adContent)
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: 100, maxHeight: 300)
            } else {
                emptyView
            }
        }
        .task {
            await loadAd()
        }
    }
    
    // MARK: - Views
    
    private var emptyView: some View {
        Text("No ad available")
            .foregroundColor(.secondary)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func errorView(error: Error) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundColor(.orange)
            
            Text("Unable to load ad")
                .font(.headline)
            
            Text(error.localizedDescription)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Retry") {
                Task {
                    await loadAd()
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Methods
    
    /// Load ad from API
    private func loadAd() async {
        isLoading = true
        error = nil
        
        do {
            let content = try await apiService.fetchAd(
                query: query,
                geo: geo,
                adTypes: adTypes
            )
            
            await MainActor.run {
                self.adContent = content
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.error = error
                self.isLoading = false
            }
        }
    }
    
    /// Reload the ad with current configuration
    public func reload() async {
        await loadAd()
    }
}

// MARK: - Convenience Initializers

extension GistAdControl {
    /// Initialize with specific ad types
    public static func withAdTypes(
        publisherID: String,
        publisherKey: String,
        query: String,
        geo: String = "US",
        adTypes: [AdType]
    ) -> GistAdControl {
        GistAdControl(
            publisherID: publisherID,
            publisherKey: publisherKey,
            query: query,
            geo: geo,
            adTypes: adTypes
        )
    }
}

