package com.gist.ads.sdk.models

/**
 * State for `GistDisplayAdControl` and `GistAdControl`, factored out of the
 * composables so it's a plain, testable value type shared by both ad types.
 * Since both controls embed `adtag.js` via `AdTagBridgeWebView` rather than
 * making their own network call, this is not derived from a single
 * `Result<String>` returned by a network call -- the WebView is mounted
 * immediately and this state is driven by bridge events (`adRendered`/
 * passback) or WebView-level load failures arriving over time. See
 * GistDisplayAdControl.kt / GistAdControl.kt.
 */
sealed class AdTagLoadState {
    /**
     * The bridge WebView is mounted and waiting for the embedded ad tag to
     * either render an ad or invoke its passback function.
     */
    object Loading : AdTagLoadState()

    /**
     * The ad tag reported `adRendered`. [heightPx] is the measured content
     * height in pixels, if available.
     */
    data class Loaded(val heightPx: Double? = null) : AdTagLoadState()

    /**
     * The ad tag invoked its passback function -- covers both a genuine
     * no-fill and any in-tag render/network error, which the tag does not
     * distinguish from the outside (see the file header notes in
     * DisplayAdBootstrapHTML.kt / SearchAdBootstrapHTML.kt).
     */
    object NoFill : AdTagLoadState()

    /**
     * A native-level failure preparing or loading the slot: either the
     * bootstrap HTML couldn't be built (e.g. empty `sizes`), or the WebView
     * itself failed to load (e.g. `adtag.js` 404s, no network).
     */
    data class Failed(val message: String) : AdTagLoadState()
}
