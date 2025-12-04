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
    case textImage = "text/image"
    case text = "text"
    
    public var displayName: String {
        switch self {
        case .image:
            return "Image"
        case .textImage:
            return "Text/Image"
        case .text:
            return "Text"
        }
    }
}

