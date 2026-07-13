package com.gist.ads.sdk.models

import com.gist.ads.sdk.services.DisplayAdAPIException
import org.junit.Assert.*
import org.junit.Test

class DisplayAdLoadStateTest {

    @Test
    fun `success result transitions to Loaded`() {
        val result = Result.success("<html>ad</html>")

        val state = DisplayAdLoadState.from(result)

        assertTrue(state is DisplayAdLoadState.Loaded)
        assertEquals("<html>ad</html>", (state as DisplayAdLoadState.Loaded).html)
    }

    @Test
    fun `NoFill error transitions to NoFill`() {
        val result = Result.failure<String>(DisplayAdAPIException.NoFill)

        val state = DisplayAdLoadState.from(result)

        assertTrue(state is DisplayAdLoadState.NoFill)
    }

    @Test
    fun `other error transitions to Failed with message`() {
        val result = Result.failure<String>(DisplayAdAPIException.InvalidSizes)

        val state = DisplayAdLoadState.from(result)

        assertTrue(state is DisplayAdLoadState.Failed)
        assertEquals(
            "At least one AdSize must be provided",
            (state as DisplayAdLoadState.Failed).message
        )
    }

    @Test
    fun `non-DisplayAdAPIException error transitions to Failed`() {
        val result = Result.failure<String>(RuntimeException("boom"))

        val state = DisplayAdLoadState.from(result)

        assertTrue(state is DisplayAdLoadState.Failed)
        assertEquals("boom", (state as DisplayAdLoadState.Failed).message)
    }
}
