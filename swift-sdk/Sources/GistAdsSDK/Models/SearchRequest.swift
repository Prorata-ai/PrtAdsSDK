//
//  SearchRequest.swift
//  GistAdsSDK
//
//  Models for API requests and responses
//

import Foundation

/// Request model for v1/search endpoint
struct SearchRequest: Codable {
  let text: String
  let geo: String
  let auctionType: String
  let adType: [String]?

  enum CodingKeys: String, CodingKey {
    case text
    case geo
    case auctionType = "auction_type"
    case adType = "ad_type"
  }

  // Custom encoding to omit nil adType
  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(text, forKey: .text)
    try container.encode(geo, forKey: .geo)
    try container.encode(auctionType, forKey: .auctionType)
    // Only encode adType if it's not nil
    if let adType = adType {
      try container.encode(adType, forKey: .adType)
    }
  }
}

/// Response model for search endpoint
public struct SearchResponse: Codable {
  public let selection: [AdSelection]?
  public let message: String?

  /// Ad selection from the API response
  public struct AdSelection: Codable {
    public let adId: String?
    public let iframeUrl: String?
    public let flightId: String?
    public let adName: String?
    public let adSource: String?
    public let render: String?

    enum CodingKeys: String, CodingKey {
      case adId
      case iframeUrl
      case flightId
      case adName
      case adSource
      case render
    }
  }
}
