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
    // page to see a live filled ad. An arbitrary or empty URL will most
    // likely surface the no-fill passback view below.
    @State private var pageURL = ""
    @State private var selectedSize: AdSize = .mediumRectangle
    @State private var selectedEnvironment: GistAdControl.APIEnvironment = .integration
    @State private var refreshTrigger = UUID()

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
                    Text("Staging").tag(GistAdControl.APIEnvironment.staging)
                    Text("Integration").tag(GistAdControl.APIEnvironment.integration)
                    Text("Production").tag(GistAdControl.APIEnvironment.production)
                }
                .pickerStyle(.segmented)
                .onChange(of: selectedEnvironment) {
                    refreshTrigger = UUID()
                }
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
