//
//  AdTagLoadState.swift
//  GistAdsSDK
//
//  State for GistDisplayAdControl and GistAdControl, factored out of the
//  SwiftUI views so it's a plain, testable value type shared by both ad
//  types. Since both controls embed `adtag.js` via `AdTagBridgeWebView`
//  rather than making their own network call, this state isn't derived from
//  a single `Result<String, Error>` -- the WebView is mounted immediately
//  and this state is driven by bridge events (`adRendered`/passback) or
//  WebView-level load failures arriving over time. See
//  GistDisplayAdControl.swift / GistAdControl.swift.
//

import Foundation

/// The possible states an ad-tag-embedding control can be in for a single slot.
enum AdTagLoadState: Equatable {
    /// The bridge WebView is mounted and waiting for the embedded ad tag to
    /// either render an ad or invoke its passback function.
    case loading
    /// The ad tag reported `adRendered`. `height` is the measured content
    /// height in points, if available.
    case loaded(height: Double?)
    /// The ad tag invoked its passback function -- covers both a genuine
    /// no-fill and any in-tag render/network error, which the tag does not
    /// distinguish from the outside (see file header notes in
    /// DisplayAdBootstrapHTML.swift / SearchAdBootstrapHTML.swift).
    case noFill
    /// A native-level failure preparing or loading the slot: either the
    /// bootstrap HTML couldn't be built (e.g. empty `sizes`), or the WebView
    /// itself failed to load (e.g. `adtag.js` 404s, no network).
    case failed(String)
}
