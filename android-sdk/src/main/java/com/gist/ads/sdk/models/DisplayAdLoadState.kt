package com.gist.ads.sdk.models

import com.gist.ads.sdk.services.DisplayAdAPIException

/**
 * Pure state-derivation logic for `GistDisplayAdControl`, factored out of the
 * composable so it can be unit tested without needing to render a UI.
 */
sealed class DisplayAdLoadState {
    object Loading : DisplayAdLoadState()
    data class Loaded(val html: String) : DisplayAdLoadState()
    object NoFill : DisplayAdLoadState()
    data class Failed(val message: String) : DisplayAdLoadState()

    companion object {
        /**
         * Derive the resulting state from a `DisplayAdAPIService.fetchAd` outcome.
         * @return [Loaded] on success, [NoFill] for a no-fill response, or
         *   [Failed] for any other error.
         */
        fun from(result: Result<String>): DisplayAdLoadState {
            return result.fold(
                onSuccess = { content -> Loaded(content) },
                onFailure = { error ->
                    if (error is DisplayAdAPIException.NoFill) {
                        NoFill
                    } else {
                        Failed(error.message ?: "Unknown error")
                    }
                }
            )
        }
    }
}
