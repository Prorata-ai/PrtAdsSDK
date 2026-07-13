package com.gist.ads.sdk.models

import com.google.gson.GsonBuilder
import org.junit.Assert.*
import org.junit.Test

class DisplayAdResponseTest {

    private val gson = GsonBuilder()
        .registerTypeAdapter(DisplayAdResponse::class.java, DisplayAdResponse.Deserializer)
        .create()

    @Test
    fun `parses flat ad object at root`() {
        val json = """
        {
            "adId": "ad-123",
            "adUrl": "https://example.com/landing",
            "adHeadline": "Great Deal",
            "adCTA": "Shop Now"
        }
        """.trimIndent()

        val response = gson.fromJson(json, DisplayAdResponse::class.java)

        assertNotNull(response.ad)
        assertEquals("ad-123", response.ad?.adId)
        assertEquals("https://example.com/landing", response.ad?.adUrl)
        assertEquals("Great Deal", response.ad?.adHeadline)
        assertEquals("Shop Now", response.ad?.adCta)
    }

    @Test
    fun `parses selection-wrapped ad object`() {
        val json = """
        {
            "selection": [
                { "adId": "ad-456", "adHeadline": "Wrapped Ad" }
            ]
        }
        """.trimIndent()

        val response = gson.fromJson(json, DisplayAdResponse::class.java)

        assertNotNull(response.ad)
        assertEquals("ad-456", response.ad?.adId)
        assertEquals("Wrapped Ad", response.ad?.adHeadline)
    }

    @Test
    fun `empty object is treated as no-fill`() {
        val response = gson.fromJson("{}", DisplayAdResponse::class.java)

        assertNull(response.ad)
    }

    @Test
    fun `empty selection array is treated as no-fill`() {
        val json = """{ "selection": [] }"""

        val response = gson.fromJson(json, DisplayAdResponse::class.java)

        assertNull(response.ad)
    }

    @Test
    fun `flat object without adId is treated as no-fill`() {
        val json = """{ "adHeadline": "No id here" }"""

        val response = gson.fromJson(json, DisplayAdResponse::class.java)

        assertNull(response.ad)
    }

    @Test
    fun `adCTA all-caps field maps to adCta property`() {
        val json = """{ "adId": "ad-1", "adCTA": "Buy Now" }"""

        val response = gson.fromJson(json, DisplayAdResponse::class.java)

        assertEquals("Buy Now", response.ad?.adCta)
    }
}
