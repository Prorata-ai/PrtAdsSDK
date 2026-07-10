//
//  DisplayAdResponse.swift
//  GistAdsSDK
//
//  Models for the Display Ad API (`/decision`) response.
//
//  Shape discovered by reading adtag.js's own `parseResponse` /
//  `convertAdResponseJson`, then confirmed field-for-field against the live
//  OpenAPI schema (see the contract notes at the top of
//  DisplayAdAPIService.swift for the full write-up):
//
//  - A filled response contains raw ad fields (adId, adUrl, adHeadline,
//    adText, adCTA, adImage, adName, templateId, ...) -- there is no
//    `iframeUrl`. Note the field is `adCTA` (all-caps CTA), not `adCta`.
//  - The response may either be wrapped in `{"selection": [...]}` (matching
//    the search API's convention, which this SDK's `SearchResponse` already
//    models) or be a single flat ad object at the root. adtag.js handles
//    both: `"selection" in e ? e.selection[0] : e`.
//  - A no-fill response is `{}` (HTTP 200, empty JSON object) -- confirmed
//    live against staging/integration/production. adtag.js treats the
//    absence of `adId` as "no ad".
//

import Foundation

/// A single display ad's raw fields, as returned by the `/decision` endpoint.
///
/// Only the fields needed for basic image/text/CTA ads (v1 scope) are
/// modeled. Richer template types (questions, conversational, etc.) that the
/// web tag also supports are intentionally out of scope -- see PAA-5351.
public struct DisplayAdItem: Codable, Equatable {
    /// Presence of this field is how a filled response is distinguished
    /// from a no-fill.
    public let adId: String?
    /// Click-through destination URL.
    public let adUrl: String?
    /// Headline / title text.
    public let adHeadline: String?
    /// Supporting body text.
    public let adText: String?
    /// Call-to-action button text (e.g. "Shop Now").
    public let adCta: String?
    /// Creative image URL.
    public let adImage: String?
    /// Advertiser / brand name.
    public let adName: String?
    /// Template alias describing which creative layout this ad uses
    /// (e.g. "image", "text/image", "text").
    public let templateId: String?

    /// The live API returns `adCTA` (all-caps CTA), not `adCta`.
    enum CodingKeys: String, CodingKey {
        case adId, adUrl, adHeadline, adText, adImage, adName, templateId
        case adCta = "adCTA"
    }

    public init(
        adId: String? = nil,
        adUrl: String? = nil,
        adHeadline: String? = nil,
        adText: String? = nil,
        adCta: String? = nil,
        adImage: String? = nil,
        adName: String? = nil,
        templateId: String? = nil
    ) {
        self.adId = adId
        self.adUrl = adUrl
        self.adHeadline = adHeadline
        self.adText = adText
        self.adCta = adCta
        self.adImage = adImage
        self.adName = adName
        self.templateId = templateId
    }
}

/// Top-level response from the `/decision` endpoint.
///
/// Decoding never throws for a well-formed no-fill (`{}`) or filled body --
/// `ad` is simply `nil` when there's no fill. This mirrors the tolerant
/// parsing adtag.js itself does.
public struct DisplayAdResponse: Decodable, Equatable {
    public let ad: DisplayAdItem?

    public init(ad: DisplayAdItem?) {
        self.ad = ad
    }

    public init(from decoder: Decoder) throws {
        // Prefer the `{"selection": [...]}` shape used by the search API,
        // in case the display endpoint adopts the same convention.
        if let wrapped = try? SelectionWrapper(from: decoder),
           let first = wrapped.selection?.first {
            self.ad = first
            return
        }

        // Fall back to treating the body as a single flat ad object,
        // matching adtag.js's `"selection" in e ? e.selection[0] : e`.
        let flat = try DisplayAdItem(from: decoder)
        self.ad = flat.adId != nil ? flat : nil
    }

    private struct SelectionWrapper: Decodable {
        let selection: [DisplayAdItem]?
    }
}
