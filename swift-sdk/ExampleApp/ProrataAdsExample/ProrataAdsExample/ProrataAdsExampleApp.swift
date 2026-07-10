//
//  GistAdsExampleApp.swift
//  GistAdsExample
//
//  Example app demonstrating Gist AI Search Ads and Display Ads integration
//

import SwiftUI

@main
struct GistAdsExampleApp: App {
    var body: some Scene {
        WindowGroup {
            // Search ads and display ads are peer features of the SDK, so
            // they're presented as equal tabs rather than one being nested
            // behind the other.
            TabView {
                ContentView()
                    .tabItem {
                        Label("Search Ads", systemImage: "magnifyingglass")
                    }

                DisplayAdDemoView()
                    .tabItem {
                        Label("Display Ads", systemImage: "rectangle.on.rectangle")
                    }
            }
        }
    }
}