package com.gist.ads.sdk.utils

import com.gist.ads.sdk.models.DisplayAdItem
import org.junit.Assert.*
import org.junit.Test

class DisplayAdHTMLGeneratorTest {

    // --- Escaping ---

    @Test
    fun `headline quotes are escaped in alt attribute`() {
        val ad = DisplayAdItem(adHeadline = "Best \"Deals\" Today", adImage = "https://example.com/img.jpg")
        val result = DisplayAdHTMLGenerator.generate(ad, "light")

        assertTrue(result.contains("alt=\"Best &quot;Deals&quot; Today\""))
        assertFalse(result.contains("alt=\"Best \"Deals\" Today\""))
    }

    @Test
    fun `headline ampersand and brackets are escaped in text content`() {
        val ad = DisplayAdItem(adHeadline = "A & B <script>")
        val result = DisplayAdHTMLGenerator.generate(ad, "light")

        assertTrue(result.contains("<div class=\"pr-display-ad-headline\">A &amp; B &lt;script&gt;</div>"))
    }

    @Test
    fun `click URL quotes are escaped`() {
        val ad = DisplayAdItem(adUrl = "https://example.com/ad?q=\"x\"")
        val result = DisplayAdHTMLGenerator.generate(ad, "light")

        assertTrue(result.contains("href=\"https://example.com/ad?q=&quot;x&quot;\""))
    }

    // --- Structure ---

    @Test
    fun `click URL defaults to hash when adUrl is null`() {
        val ad = DisplayAdItem(adHeadline = "Headline")
        val result = DisplayAdHTMLGenerator.generate(ad, "light")

        assertTrue(result.contains("href=\"#\""))
    }

    @Test
    fun `image block omitted when adImage is null or empty`() {
        val ad = DisplayAdItem(adHeadline = "Headline", adImage = "")
        val result = DisplayAdHTMLGenerator.generate(ad, "light")

        assertFalse(result.contains("<img"))
    }

    @Test
    fun `image block included when adImage present`() {
        val ad = DisplayAdItem(adHeadline = "Headline", adImage = "https://example.com/img.jpg")
        val result = DisplayAdHTMLGenerator.generate(ad, "light")

        assertTrue(result.contains("<img class=\"pr-display-ad-image\" src=\"https://example.com/img.jpg\""))
    }

    @Test
    fun `does not include target attribute`() {
        val ad = DisplayAdItem(adUrl = "https://example.com/ad")
        val result = DisplayAdHTMLGenerator.generate(ad, "light")

        assertFalse(result.contains("target="))
    }

    @Test
    fun `theme is included as data attribute`() {
        val ad = DisplayAdItem(adUrl = "https://example.com/ad")
        val result = DisplayAdHTMLGenerator.generate(ad, "dark")

        assertTrue(result.contains("data-pr-theme=\"dark\""))
    }

    @Test
    fun `headline falls back to adName when headline is null`() {
        val ad = DisplayAdItem(adName = "Acme Corp")
        val result = DisplayAdHTMLGenerator.generate(ad, "light")

        assertTrue(result.contains("<div class=\"pr-display-ad-headline\">Acme Corp</div>"))
    }
}
