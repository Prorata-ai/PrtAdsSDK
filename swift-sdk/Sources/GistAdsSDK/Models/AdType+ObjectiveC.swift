//
//  AdType+ObjectiveC.swift
//  GistAdsSDK
//
//  Objective-C compatible ad type enum and conversion helpers
//

import Foundation

/// Objective-C compatible ad type enum
@objc public enum GistAdType: Int {
    case image = 0
    case textImage = 1
    case text = 2
    
    /// Convert to Swift AdType
    internal var swiftAdType: AdType {
        switch self {
        case .image:
            return .image
        case .textImage:
            return .textImage
        case .text:
            return .text
        }
    }
    
    /// Create from Swift AdType
    internal init(_ adType: AdType) {
        switch adType {
        case .image:
            self = .image
        case .textImage:
            self = .textImage
        case .text:
            self = .text
        }
    }
}

/// Helper extension for converting between Objective-C and Swift ad types
extension AdType {
    /// Convert to Objective-C GistAdType
    internal var objcAdType: GistAdType {
        return GistAdType(self)
    }
}

/// Helper for converting NSArray of GistAdType to Swift array
internal func convertAdTypes(_ objcAdTypes: [NSNumber]?) -> [AdType]? {
    guard let objcAdTypes = objcAdTypes, !objcAdTypes.isEmpty else {
        return nil
    }
    
    return objcAdTypes.compactMap { number in
        guard let adType = GistAdType(rawValue: number.intValue) else {
            return nil
        }
        return adType.swiftAdType
    }
}

/// Helper for converting Swift array to NSArray of NSNumber
internal func convertAdTypes(_ swiftAdTypes: [AdType]?) -> [NSNumber]? {
    guard let swiftAdTypes = swiftAdTypes, !swiftAdTypes.isEmpty else {
        return nil
    }
    
    return swiftAdTypes.map { NSNumber(value: $0.objcAdType.rawValue) }
}

