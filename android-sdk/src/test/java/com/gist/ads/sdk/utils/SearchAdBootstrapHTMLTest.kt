package com.gist.ads.sdk.utils

import com.gist.ads.sdk.models.AdSize
import com.gist.ads.sdk.models.AdType
import org.junit.Assert.*
import org.junit.Test

/**
 * Unit tests for [SearchAdBootstrapHTML]: string assertions on the
 * generated bootstrap document's `defineSlot`/`definePrompt`/`defineAnswer`/
 * `definePassbackFunction`/script-src content, without needing a live
 * WebView. Mirrors DisplayAdBootstrapHTMLTest.kt.
 */
class SearchAdBootstrapHTMLTest {

    private fun generate(
        publisherId: String = "pub-123",
        publisherKey: String = "key-abc",
        query: String = "best running shoes",
        geo: String = "US",
        answer: String? = null,
        adTypes: List<AdType>? = null,
        sizes: List<AdSize> = listOf(AdSize.DYNAMIC),
        slotId: String = "slot-abc",
        passbackFunctionName: String = "prPassbackFn",
        adTagScriptUrl: String = "https://tp-at.staging.prorata.ai/adtag.js"
    ): String = SearchAdBootstrapHTML.generate(
        publisherId = publisherId,
        publisherKey = publisherKey,
        query = query,
        geo = geo,
        answer = answer,
        adTypes = adTypes,
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
    fun `calls defineSlot with publisherId apiKey and geo`() {
        val html = generate(publisherId = "pub-123", publisherKey = "key-abc", geo = "US")
        assertTrue(html.contains("""defineSlot({ id: "pub-123", api_key: "key-abc", geo: "US" }, "slot-abc""""))
    }

    @Test
    fun `defineSlot never includes url field`() {
        // Search slots are valid without `url` (defineSlot accepts either
        // `url` or `api_key`) -- confirm we never emit one.
        val html = generate()
        assertFalse(html.contains("url:"))
    }

    @Test
    fun `calls definePrompt with query`() {
        val html = generate(query = "best running shoes")
        assertTrue(html.contains("""slot.definePrompt("best running shoes")"""))
    }

    @Test
    fun `defaults defineAnswer to query when answer is null`() {
        // The ad tag docs mark `answer` as required for search ads, so we
        // always call defineAnswer, falling back to the query (matching the
        // pre-embed native SDK's request body default) when not provided.
        val html = generate(query = "best running shoes", answer = null)
        assertTrue(html.contains("""slot.defineAnswer("best running shoes")"""))
    }

    @Test
    fun `defaults defineAnswer to query when answer is blank`() {
        val html = generate(query = "best running shoes", answer = "   ")
        assertTrue(html.contains("""slot.defineAnswer("best running shoes")"""))
    }

    @Test
    fun `includes defineAnswer when provided`() {
        val html = generate(answer = "running shoes for beginners")
        assertTrue(html.contains("""slot.defineAnswer("running shoes for beginners")"""))
    }

    @Test
    fun `omits adTypes argument when null`() {
        val html = generate(adTypes = null)
        assertTrue(html.contains("undefined);"))
    }

    @Test
    fun `includes adTypes array when provided`() {
        val html = generate(adTypes = listOf(AdType.TEXT, AdType.IMAGE))
        assertTrue(html.contains("""["text", "image"]"""))
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

    // Validation

    @Test(expected = SearchAdBootstrapException.InvalidSizes::class)
    fun `throws InvalidSizes for empty sizes`() {
        generate(sizes = emptyList())
    }

    @Test(expected = SearchAdBootstrapException.EmptyQuery::class)
    fun `throws EmptyQuery for blank query`() {
        generate(query = "   ")
    }

    // Escaping / injection safety

    @Test
    fun `query with quote and script tag is escaped`() {
        val html = generate(query = """shoes"><script>alert(1)</script>""")
        assertFalse(html.contains("""definePrompt("shoes"><script>alert(1)</script>")"""))
        assertFalse(html.contains("</script>alert"))
    }

    @Test
    fun `publisherKey with backslash and quote is escaped`() {
        val html = generate(publisherKey = """key\"abc""")
        assertTrue(html.contains("""api_key: "key\\\"abc""""))
    }
}
