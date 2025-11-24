//
//  ContentView.swift
//  GistAdsExample
//
//  Example UI showing different ways to use the Gist Ad Control
//

import SwiftUI
import GistAdsSDK

struct ContentView: View {
    // Configuration - Replace with your actual credentials
    private let publisherID = "your-publisher-id"
    private let publisherKey = "your-publisher-key"
    
    // State for dynamic queries
    @State private var searchQuery = "best wireless headphones"
    @State private var selectedGeo = "US"
    @State private var selectedAdTypes: Set<AdType> = [.image, .imageText]
    @State private var refreshTrigger = UUID()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    headerSection
                    
                    // Configuration Section
                    configurationSection
                    
                    // Ad Preview Section
                    adPreviewSection
                    
                    // Examples Section
                    examplesSection
                }
                .padding()
            }
            .navigationTitle("Prorata Ads Demo")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(spacing: 8) {
            Image(systemName: "sparkles")
                .font(.system(size: 50))
                .foregroundColor(.blue)
            
            Text("Gist AI Search Ads")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Native ad integration for AI-powered search")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical)
    }
    
    // MARK: - Configuration Section
    
    private var configurationSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Configuration")
                .font(.headline)
            
            // Query Input
            VStack(alignment: .leading, spacing: 8) {
                Text("Search Query")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                TextField("Enter search query...", text: $searchQuery)
                    .textFieldStyle(.roundedBorder)
                    .autocapitalization(.none)
            }
            
            // Geographic Location
            VStack(alignment: .leading, spacing: 8) {
                Text("Geographic Location")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Picker("Geo", selection: $selectedGeo) {
                    Text("United States").tag("US")
                    Text("United Kingdom").tag("GB")
                    Text("Canada").tag("CA")
                    Text("Australia").tag("AU")
                }
                .pickerStyle(.segmented)
            }
            
            // Ad Types
            VStack(alignment: .leading, spacing: 8) {
                Text("Ad Types")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                ForEach(AdType.allCases, id: \.self) { adType in
                    Toggle(adType.displayName, isOn: Binding(
                        get: { selectedAdTypes.contains(adType) },
                        set: { isOn in
                            if isOn {
                                selectedAdTypes.insert(adType)
                            } else {
                                selectedAdTypes.remove(adType)
                            }
                        }
                    ))
                }
            }
            
            // Refresh Button
            Button(action: {
                refreshTrigger = UUID()
            }) {
                HStack {
                    Image(systemName: "arrow.clockwise")
                    Text("Reload Ad")
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    // MARK: - Ad Preview Section
    
    private var adPreviewSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Live Ad Preview")
                .font(.headline)
            
            if !searchQuery.isEmpty {
                GistAdControl(
                    publisherID: publisherID,
                    publisherKey: publisherKey,
                    query: searchQuery,
                    geo: selectedGeo,
                    adTypes: selectedAdTypes.isEmpty ? nil : Array(selectedAdTypes)
                )
                .frame(height: 250)
                .background(Color.white)
                .cornerRadius(12)
                .shadow(radius: 2)
                .id(refreshTrigger)
            } else {
                emptyQueryView
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private var emptyQueryView: some View {
        VStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.largeTitle)
                .foregroundColor(.gray)
            
            Text("Enter a search query to see ads")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 250)
        .background(Color.white)
        .cornerRadius(12)
    }
    
    // MARK: - Examples Section
    
    private var examplesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Example Queries")
                .font(.headline)
            
            Text("Try these popular search queries:")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            ForEach(exampleQueries, id: \.self) { query in
                Button(action: {
                    searchQuery = query
                    refreshTrigger = UUID()
                }) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                        Text(query)
                        Spacer()
                        Image(systemName: "arrow.right")
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(8)
                }
                .buttonStyle(.plain)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private let exampleQueries = [
        "best wireless headphones",
        "affordable laptops for students",
        "top rated running shoes",
        "smart home devices 2024",
        "healthy meal delivery services"
    ]
}

// MARK: - Preview

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

