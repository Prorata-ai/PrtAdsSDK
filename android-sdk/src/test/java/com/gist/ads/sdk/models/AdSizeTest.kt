package com.gist.ads.sdk.models

import org.junit.Assert.*
import org.junit.Test

class AdSizeTest {

    @Test
    fun `leaderboard has correct dimensions`() {
        assertEquals(728, AdSize.LEADERBOARD.width)
        assertEquals(90, AdSize.LEADERBOARD.height)
    }

    @Test
    fun `superLeaderboard has correct dimensions`() {
        assertEquals(970, AdSize.SUPER_LEADERBOARD.width)
        assertEquals(90, AdSize.SUPER_LEADERBOARD.height)
    }

    @Test
    fun `mediumRectangle has correct dimensions`() {
        assertEquals(300, AdSize.MEDIUM_RECTANGLE.width)
        assertEquals(250, AdSize.MEDIUM_RECTANGLE.height)
    }

    @Test
    fun `mobileBanner has correct dimensions`() {
        assertEquals(320, AdSize.MOBILE_BANNER.width)
        assertEquals(50, AdSize.MOBILE_BANNER.height)
    }

    @Test
    fun `billboard has correct dimensions`() {
        assertEquals(970, AdSize.BILLBOARD.width)
        assertEquals(250, AdSize.BILLBOARD.height)
    }

    @Test
    fun `largeRectangle has correct dimensions`() {
        assertEquals(300, AdSize.LARGE_RECTANGLE.width)
        assertEquals(600, AdSize.LARGE_RECTANGLE.height)
    }

    @Test
    fun `skyscraper has correct dimensions`() {
        assertEquals(160, AdSize.SKYSCRAPER.width)
        assertEquals(600, AdSize.SKYSCRAPER.height)
    }

    @Test
    fun `dynamic has null dimensions`() {
        assertNull(AdSize.DYNAMIC.width)
        assertNull(AdSize.DYNAMIC.height)
    }

    @Test
    fun `displayName is human readable`() {
        assertEquals("Medium Rectangle (300x250)", AdSize.MEDIUM_RECTANGLE.displayName)
        assertEquals("Dynamic", AdSize.DYNAMIC.displayName)
    }

    @Test
    fun `jsonValue returns width and height`() {
        assertEquals(listOf(300, 250), AdSize.MEDIUM_RECTANGLE.jsonValue())
    }

    @Test
    fun `jsonValue for dynamic returns 0x0`() {
        assertEquals(listOf(0, 0), AdSize.DYNAMIC.jsonValue())
    }

    @Test
    fun `encodeSizesParam encodes a single size`() {
        val json = AdSize.encodeSizesParam(listOf(AdSize.MEDIUM_RECTANGLE))
        assertEquals("[[300,250]]", json)
    }

    @Test
    fun `encodeSizesParam encodes multiple sizes`() {
        val json = AdSize.encodeSizesParam(listOf(AdSize.MEDIUM_RECTANGLE, AdSize.LEADERBOARD))
        assertEquals("[[300,250],[728,90]]", json)
    }

    @Test
    fun `encodeSizesParam encodes dynamic as 0x0`() {
        val json = AdSize.encodeSizesParam(listOf(AdSize.DYNAMIC))
        assertEquals("[[0,0]]", json)
    }

    @Test
    fun `encodeSizesParam encodes empty list`() {
        val json = AdSize.encodeSizesParam(emptyList())
        assertEquals("[]", json)
    }
}
