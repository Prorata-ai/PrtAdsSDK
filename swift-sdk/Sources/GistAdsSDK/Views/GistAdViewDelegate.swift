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
    
    /// Called when the ad tag reports no ad is available for this slot
    /// (no-fill), as opposed to a native-level or WebView load failure.
    /// - Parameter adView: The ad view that received no fill
    @objc optional func adViewDidReceiveNoFill(_ adView: GistAdView)
    
    /// Called when the user clicks an ad link that navigates to an external URL
    /// If this method is not implemented, the URL will be opened in Safari by default.
    /// - Parameters:
    ///   - adView: The ad view where the click occurred
    ///   - url: The destination URL that was clicked
    @objc optional func adView(_ adView: GistAdView, didClickURL url: URL)
    
    /// Called when the ad content has loaded and the actual content height is known
    /// Use this to resize your ad container to match the actual ad content size.
    /// - Parameters:
    ///   - adView: The ad view that loaded
    ///   - height: The actual content height in points
    @objc optional func adView(_ adView: GistAdView, didLoadWithContentHeight height: CGFloat)
}

#endif // os(iOS)

