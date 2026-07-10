//
//  DisplayAdLoadState.swift
//  GistAdsSDK
//
//  Pure state-derivation logic for GistDisplayAdControl, factored out of the
//  SwiftUI view so it can be unit tested without needing to render a view
//  hierarchy.
//

import Foundation

/// The possible states `GistDisplayAdControl` can be in while loading a display ad.
enum DisplayAdLoadState: Equatable {
    case loading
    case loaded(String)
    case noFill
    case failed(String)

    /// Derive the resulting state from a `DisplayAdAPIService.fetchAd` outcome.
    /// - Parameter result: The result of attempting to fetch and render an ad.
    /// - Returns: `.loaded` on success, `.noFill` for a no-fill response, or
    ///   `.failed` for any other error.
    static func from(result: Result<String, Error>) -> DisplayAdLoadState {
        switch result {
        case .success(let content):
            return .loaded(content)
        case .failure(let error):
            if case DisplayAdAPIError.noFill = error {
                return .noFill
            }
            return .failed(error.localizedDescription)
        }
    }
}
