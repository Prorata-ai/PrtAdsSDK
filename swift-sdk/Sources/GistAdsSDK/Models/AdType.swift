//
//  AdType.swift
//  GistAdsSDK
//
//  Supported ad types for AI Search
//

import Foundation

/// Ad types supported by Gist AI Search
public enum AdType: String, Codable, CaseIterable {
    case image = "image"
    case imageText = "image/text"
    
    public var displayName: String {
        switch self {
        case .image:
            return "Image"
        case .imageText:
            return "Image/Text"
        }
    }
}

