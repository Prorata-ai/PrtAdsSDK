//
//  DisplayAdDemoView.swift
//  ProrataAdsExample
//
//  Example UI showing GistDisplayAdControl: contextual display ads targeted
//  by publisher ID + page URL + size, with a custom no-fill passback view.
//

import SwiftUI
import GistAdsSDK

struct DisplayAdDemoView: View {
    // Configuration - Replace with your actual publisher ID.
    // Unlike search ads, display ads don't require a publisher key.
    private let publisherID = "your-publisher-id"

    // Left blank on purpose -- enter the URL of a real, publicly crawlable
    // page (or a context below) to see a live filled ad. An arbitrary or
    // empty URL will most likely surface the no-fill passback view below.
    @State private var pageURL = ""
    @State private var selectedSize: AdSize = .mediumRectangle
    @State private var selectedEnvironment: GistDisplayAdControl.APIEnvironment = .integration
    @State private var refreshTrigger = UUID()

    // Native screens have no crawlable HTML for the backend to infer
    // relevance from via `pageURL` alone (unlike a real webpage), so
    // `context` lets the app hand over that signal explicitly instead --
    // see the contract notes at the top of DisplayAdAPIService.swift.
    @State private var contextCategory = ""
    @State private var contextKeywords = ""

    /// Builds the `context` dictionary sent to `GistDisplayAdControl`, or
    /// `nil` if the user hasn't entered anything.
    private var context: [String: Any]? {
        var result: [String: Any] = [:]
        if !contextCategory.trimmingCharacters(in: .whitespaces).isEmpty {
            result["category"] = contextCategory
        }
        let keywords = contextKeywords
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
        if !keywords.isEmpty {
            result["keywords"] = keywords
        }
        return result.isEmpty ? nil : result
    }

    private let availableSizes: [AdSize] = [
        .leaderboard, .superLeaderboard, .mediumRectangle,
        .mobileBanner, .billboard, .largeRectangle, .skyscraper, .dynamic
    ]

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    headerSection
                    configurationSection
                    adPreviewSection
                }
                .padding()
            }
            .navigationTitle("Display Ads")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: 8) {
            Image(systemName: "rectangle.on.rectangle")
                .font(.system(size: 50))
                .foregroundColor(.blue)

            Text("Gist Display Ads")
                .font(.title2)
                .fontWeight(.bold)

            Text("Contextual ads targeted by publisher ID + page URL")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical)
    }

    // MARK: - Configuration

    private var configurationSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Configuration")
                .font(.headline)

            VStack(alignment: .leading, spacing: 8) {
                Text("Page URL")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                TextField("https://example.com/article", text: $pageURL)
                    .textFieldStyle(.roundedBorder)
                    .autocapitalization(.none)
                    .keyboardType(.URL)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Ad Size")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Picker("Size", selection: $selectedSize) {
                    ForEach(availableSizes, id: \.self) { size in
                        Text(size.displayName).tag(size)
                    }
                }
                .pickerStyle(.menu)
                .onChange(of: selectedSize) {
                    refreshTrigger = UUID()
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Environment")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Picker("Environment", selection: $selectedEnvironment) {
                    Text("Staging").tag(GistDisplayAdControl.APIEnvironment.staging)
                    Text("Integration").tag(GistDisplayAdControl.APIEnvironment.integration)
                    Text("Production").tag(GistDisplayAdControl.APIEnvironment.production)
                }
                .pickerStyle(.segmented)
                .onChange(of: selectedEnvironment) {
                    refreshTrigger = UUID()
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Context (optional)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text("Native screens have no crawlable HTML, so this hands the backend explicit signal instead of relying on Page URL alone.")
                    .font(.caption2)
                    .foregroundColor(.secondary)

                TextField("Category, e.g. \"technology\"", text: $contextCategory)
                    .textFieldStyle(.roundedBorder)
                    .autocapitalization(.none)

                TextField("Keywords, comma-separated", text: $contextKeywords)
                    .textFieldStyle(.roundedBorder)
                    .autocapitalization(.none)
            }

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

    // MARK: - Ad Preview

    private var adPreviewSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Live Ad Preview")
                .font(.headline)

            // The custom `passback` view builder is shown whenever the
            // server has no ad to fill this slot -- mirroring the web tag's
            // `definePassbackFunction`, callers get full control over the
            // fallback UI instead of a hard-coded empty state.
            GistDisplayAdControl(
                publisherID: publisherID,
                pageURL: pageURL,
                sizes: [selectedSize],
                environment: selectedEnvironment,
                context: context,
                passback: {
                    VStack(spacing: 8) {
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.title)
                            .foregroundColor(.gray)
                        Text("No ad available right now")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text("(custom passback content goes here)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            )
            .frame(height: previewHeight)
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(radius: 2)
            .id(refreshTrigger)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }

    private var previewHeight: CGFloat {
        CGFloat(selectedSize.height ?? 250)
    }
}

// MARK: - Preview

struct DisplayAdDemoView_Previews: PreviewProvider {
    static var previews: some View {
        DisplayAdDemoView()
    }
}
