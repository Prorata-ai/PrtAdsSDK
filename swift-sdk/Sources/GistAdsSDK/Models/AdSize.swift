//
//  AdSize.swift
//  GistAdsSDK
//
//  Standard IAB ad sizes supported by the Gist Display Ad API, matching the
//  `sizes` argument the web tag passes to `prtag.defineSlot(config, id, sizes)`.
//

import Foundation

/// Standard IAB display ad sizes, plus "dynamic" for fluid layouts.
///
/// These mirror the sizes documented for the web ad tag's `defineSlot`
/// (see "Supported Sizes" in the ad tag docs).
public enum AdSize: Hashable, CaseIterable, Sendable {
    case leaderboard
    case superLeaderboard
    case mediumRectangle
    case mobileBanner
    case billboard
    case largeRectangle
    case skyscraper
    case dynamic

    /// Pixel width, or `nil` for `.dynamic` (which has no fixed dimensions).
    public var width: Int? {
        switch self {
        case .leaderboard: return 728
        case .superLeaderboard: return 970
        case .mediumRectangle: return 300
        case .mobileBanner: return 320
        case .billboard: return 970
        case .largeRectangle: return 300
        case .skyscraper: return 160
        case .dynamic: return nil
        }
    }

    /// Pixel height, or `nil` for `.dynamic` (which has no fixed dimensions).
    public var height: Int? {
        switch self {
        case .leaderboard: return 90
        case .superLeaderboard: return 90
        case .mediumRectangle: return 250
        case .mobileBanner: return 50
        case .billboard: return 250
        case .largeRectangle: return 600
        case .skyscraper: return 600
        case .dynamic: return nil
        }
    }

    public var displayName: String {
        switch self {
        case .leaderboard: return "Leaderboard (728x90)"
        case .superLeaderboard: return "Super Leaderboard (970x90)"
        case .mediumRectangle: return "Medium Rectangle (300x250)"
        case .mobileBanner: return "Mobile Banner (320x50)"
        case .billboard: return "Billboard (970x250)"
        case .largeRectangle: return "Large Rectangle (300x600)"
        case .skyscraper: return "Skyscraper (160x600)"
        case .dynamic: return "Dynamic"
        }
    }
}

extension AdSize {
    /// JSON-serializable representation matching what the display ad server
    /// expects for a single size entry in the `ad_size` query parameter:
    /// `[width, height]`, with `[0, 0]` conventionally meaning "dynamic"
    /// (confirmed against the live OpenAPI schema: "Use 0x0 for dynamic").
    var jsonValue: Any {
        [width ?? 0, height ?? 0]
    }

    /// Encode a list of sizes into the JSON string expected by the display
    /// ad server's `ad_size` query parameter, e.g. `[[300,250]]` or
    /// `[[0,0]]` for dynamic.
    /// - Throws: If the sizes cannot be serialized to JSON (should not
    ///   happen for the value types produced by `jsonValue`).
    static func encodeSizesParam(_ sizes: [AdSize]) throws -> String {
        let values = sizes.map { $0.jsonValue }
        let data = try JSONSerialization.data(withJSONObject: values)
        return String(data: data, encoding: .utf8) ?? "[]"
    }
}
