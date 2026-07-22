package com.gist.ads.sdk.models

import org.junit.Assert.*
import org.junit.Test

class AdTagLoadStateTest {

    @Test
    fun `Loading instances are equal`() {
        assertEquals(AdTagLoadState.Loading, AdTagLoadState.Loading)
    }

    @Test
    fun `Loaded is equal when heightPx matches`() {
        assertEquals(AdTagLoadState.Loaded(250.0), AdTagLoadState.Loaded(250.0))
    }

    @Test
    fun `Loaded is not equal when heightPx differs`() {
        assertNotEquals(AdTagLoadState.Loaded(250.0), AdTagLoadState.Loaded(300.0))
    }

    @Test
    fun `Loaded defaults heightPx to null`() {
        assertNull(AdTagLoadState.Loaded().heightPx)
    }

    @Test
    fun `NoFill instances are equal`() {
        assertEquals(AdTagLoadState.NoFill, AdTagLoadState.NoFill)
    }

    @Test
    fun `Failed is equal when message matches`() {
        assertEquals(AdTagLoadState.Failed("boom"), AdTagLoadState.Failed("boom"))
    }

    @Test
    fun `Failed is not equal when message differs`() {
        assertNotEquals(AdTagLoadState.Failed("boom"), AdTagLoadState.Failed("bang"))
    }

    @Test
    fun `different subtypes are not equal`() {
        assertFalse((AdTagLoadState.Loading as AdTagLoadState) == AdTagLoadState.NoFill)
        assertFalse((AdTagLoadState.NoFill as AdTagLoadState) == AdTagLoadState.Loaded())
    }
}
