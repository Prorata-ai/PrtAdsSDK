//
//  GistAdViewDelegate.swift
//  GistAdsSDK
//
//  Delegate protocol for GistAdView callbacks
//

#if os(iOS)
import Foundation

/// Delegate protocol for GistAdView to notify about ad loading state
@objc public protocol GistAdViewDelegate: AnyObject {
    /// Called when the ad view starts loading
    /// - Parameter adView: The ad view that started loading
    @objc optional func adViewDidStartLoading(_ adView: GistAdView)
    
    /// Called when the ad view successfully loads an ad
    /// - Parameter adView: The ad view that loaded
    @objc optional func adViewDidLoad(_ adView: GistAdView)
    
    /// Called when the ad view fails to load an ad
    /// - Parameters:
    ///   - adView: The ad view that failed
    ///   - error: The error that occurred
    @objc optional func adView(_ adView: GistAdView, didFailWithError error: Error)
}

#endif // os(iOS)

