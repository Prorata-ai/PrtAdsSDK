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
}

/// Response model for search endpoint
public struct SearchResponse: Codable {
    public let ads: [Ad]?
    public let message: String?
    
    public struct Ad: Codable {
        public let id: String?
        public let title: String?
        public let description: String?
        public let imageUrl: String?
        public let clickUrl: String?
        public let impressionUrl: String?
        
        enum CodingKeys: String, CodingKey {
            case id
            case title
            case description
            case imageUrl = "image_url"
            case clickUrl = "click_url"
            case impressionUrl = "impression_url"
        }
    }
}

