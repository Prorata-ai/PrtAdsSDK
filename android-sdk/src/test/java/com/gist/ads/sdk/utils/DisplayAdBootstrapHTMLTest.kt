package com.gist.ads.sdk.utils

import com.gist.ads.sdk.models.AdSize
import org.junit.Assert.*
import org.junit.Test

/**
 * Unit tests for [DisplayAdBootstrapHTML]: string assertions on the
 * generated bootstrap document's `defineSlot`/`defineAdData`/
 * `definePassbackFunction`/script-src content, without needing a live
 * WebView (see the "Testing strategy" notes in the embed-adtag.js plan).
 */
class DisplayAdBootstrapHTMLTest {

    private fun generate(
        publisherId: String = "pub-123",
        pageUrl: String = "https://example.com/article",
        sizes: List<AdSize> = listOf(AdSize.MEDIUM_RECTANGLE),
        slotId: String = "slot-abc",
        passbackFunctionName: String = "prPassbackFn",
        adTagScriptUrl: String = "https://tp-at.staging.prorata.ai/adtag.js"
    ): String = DisplayAdBootstrapHTML.generate(
        publisherId = publisherId,
        pageUrl = pageUrl,
        sizes = sizes,
        slotId = slotId,
        passbackFunctionName = passbackFunctionName,
        adTagScriptUrl = adTagScriptUrl
    )

    // Structure

    @Test
    fun `generates slot div matching slotId`() {
        val html = generate(slotId = "slot-abc")
        assertTrue(html.contains("""<div id="slot-abc""""))
    }

    @Test
    fun `generates script tag for adTagScriptUrl`() {
        val html = generate(adTagScriptUrl = "https://tp-at.staging.prorata.ai/adtag.js")
        assertTrue(html.contains("""<script src="https://tp-at.staging.prorata.ai/adtag.js" defer></script>"""))
    }

    @Test
    fun `calls defineSlot with publisherId and pageUrl`() {
        val html = generate(publisherId = "pub-123", pageUrl = "https://example.com/article")
        assertTrue(html.contains("""defineSlot({ id: "pub-123", url: "https://example.com/article" }, "slot-abc""""))
    }

    @Test
    fun `calls defineSlot with encoded sizes`() {
        val html = generate(sizes = listOf(AdSize.MEDIUM_RECTANGLE, AdSize.LEADERBOARD))
        assertTrue(html.contains("[[300,250],[728,90]]"))
    }

    @Test
    fun `calls defineSlot with dynamic size as zero zero`() {
        val html = generate(sizes = listOf(AdSize.DYNAMIC))
        assertTrue(html.contains("[[0,0]]"))
    }

    @Test
    fun `defines passback function with given name`() {
        val html = generate(passbackFunctionName = "prPassbackFn")
        assertTrue(html.contains("""window["prPassbackFn"] = function()"""))
        assertTrue(html.contains("""slot.definePassbackFunction("prPassbackFn")"""))
    }

    @Test
    fun `calls displayAd with slotId`() {
        val html = generate(slotId = "slot-abc")
        assertTrue(html.contains("""window.prtag.displayAd("slot-abc")"""))
    }

    @Test
    fun `registers adRendered listener`() {
        val html = generate()
        assertTrue(html.contains("""addEventListener("adRendered""""))
    }

    @Test
    fun `never includes defineAdData`() {
        val html = generate()
        assertFalse(html.contains("defineAdData"))
    }

    // Validation

    @Test(expected = DisplayAdBootstrapException.InvalidSizes::class)
    fun `throws InvalidSizes for empty sizes`() {
        generate(sizes = emptyList())
    }

    // Escaping / injection safety

    @Test
    fun `pageUrl with quote is escaped in jsStringLiteral`() {
        val html = generate(pageUrl = """https://example.com/"><script>alert(1)</script>""")
        // The raw payload must never appear verbatim (would break out of the string literal / close the script tag).
        assertFalse(html.contains("""url: "https://example.com/"><script>alert(1)</script>""""))
        assertFalse(html.contains("</script>alert"))
    }

    @Test
    fun `publisherId with backslash and quote is escaped`() {
        val html = generate(publisherId = """pub\"123""")
        assertTrue(html.contains("""id: "pub\\\"123""""))
    }

    // jsStringLiteral / scriptSafeJson helpers directly

    @Test
    fun `jsStringLiteral escapes backslash and quote`() {
        assertEquals(""""a\\b\"c"""", jsStringLiteral("""a\b"c"""))
    }

    @Test
    fun `jsStringLiteral escapes less-than to defuse script close`() {
        assertEquals(""""\u003C/script>"""", jsStringLiteral("</script>"))
    }

    @Test
    fun `jsStringLiteral escapes line and paragraph separators`() {
        assertEquals("\"a\\u2028b\\u2029c\"", jsStringLiteral("a\u2028b\u2029c"))
    }

    @Test
    fun `scriptSafeJson escapes less-than`() {
        assertEquals("""{"a":"\u003C/script>"}""", scriptSafeJson("""{"a":"</script>"}"""))
    }
}
