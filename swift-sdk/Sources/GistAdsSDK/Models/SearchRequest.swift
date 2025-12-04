//
//  SearchRequest.swift
//  GistAdsSDK
//
//  Models for API requests and responses
//

import Foundation

/// Request model for v1/search endpoint
struct SearchRequestV1: Codable {
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

/// Request model for v2/search endpoint
struct SearchRequestV2: Codable {
  let prompt: String
  let answer: String
  let geo: String
  let auctionType: String
  let adType: [String]?
  let text: String?

  enum CodingKeys: String, CodingKey {
    case prompt
    case answer
    case geo
    case auctionType = "auction_type"
    case adType = "ad_type"
    case text
  }

  // Custom encoding to omit nil adType and text
  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(prompt, forKey: .prompt)
    try container.encode(answer, forKey: .answer)
    try container.encode(geo, forKey: .geo)
    try container.encode(auctionType, forKey: .auctionType)
    // Only encode adType if it's not nil
    if let adType = adType {
      try container.encode(adType, forKey: .adType)
    }
    // Only encode text if it's not nil
    if let text = text {
      try container.encode(text, forKey: .text)
    }
  }
}

/// Factory function to create appropriate search request based on API version
/// - Parameters:
///   - version: API version string (e.g., "v1", "v2")
///   - query: The search query text
///   - geo: Geographic location (e.g., "US", "GB")
///   - adTypes: Optional array of ad type strings
///   - answer: Optional answer string for v2 (defaults to query if nil)
/// - Returns: Codable request model appropriate for the version
func createSearchRequest(
  version: String,
  query: String,
  geo: String,
  adTypes: [String]?,
  answer: String? = nil
) -> Codable {
  switch version {
  case APIConstants.apiVersionV1:
    return SearchRequestV1(
      text: query,
      geo: geo,
      auctionType: APIConstants.auctionType,
      adType: adTypes
    )
  case APIConstants.apiVersionV2:
    return SearchRequestV2(
      prompt: query,
      answer: answer ?? query,
      geo: geo,
      auctionType: APIConstants.auctionType,
      adType: adTypes,
      text: query
    )
  default:
    // For future versions, default to v2 behavior
    return SearchRequestV2(
      prompt: query,
      answer: answer ?? query,
      geo: geo,
      auctionType: APIConstants.auctionType,
      adType: adTypes,
      text: query
    )
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
