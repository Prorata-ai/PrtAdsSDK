package com.gist.ads.sdk.services

import com.gist.ads.sdk.models.AdSize
import kotlinx.coroutines.test.runTest
import okhttp3.mockwebserver.MockResponse
import okhttp3.mockwebserver.MockWebServer
import org.junit.After
import org.junit.Assert.*
import org.junit.Before
import org.junit.Test

class DisplayAdAPIServiceTest {

    private lateinit var mockWebServer: MockWebServer
    private lateinit var apiService: DisplayAdAPIService

    @Before
    fun setup() {
        mockWebServer = MockWebServer()
        mockWebServer.start()

        apiService = DisplayAdAPIService(
            baseUrl = mockWebServer.url("/").toString().trimEnd('/'),
            publisherId = "test-publisher-id"
        )
    }

    @After
    fun tearDown() {
        mockWebServer.shutdown()
    }

    @Test
    fun `fetchAd successfully parses a flat ad response`() = runTest {
        val mockResponse = """
        {
            "adId": "ad-1",
            "adUrl": "https://example.com/landing",
            "adHeadline": "Great Deal",
            "adCTA": "Shop Now"
        }
        """.trimIndent()

        mockWebServer.enqueue(
            MockResponse()
                .setResponseCode(200)
                .setBody(mockResponse)
                .addHeader("Content-Type", "application/json")
        )

        val result = apiService.fetchAd(
            pageUrl = "https://example.com/article",
            sizes = listOf(AdSize.MEDIUM_RECTANGLE),
            theme = "light"
        )

        assertTrue(result.contains("Great Deal"))
        assertTrue(result.contains("Shop Now"))
        assertTrue(result.contains("https://example.com/landing"))

        val request = mockWebServer.takeRequest()
        assertEquals("GET", request.method)
        assertNull(request.getHeader("Publisher-Key"))
        assertNull(request.getHeader("Publisher-ID"))

        val requestUrl = request.requestUrl!!
        assertEquals("test-publisher-id", requestUrl.queryParameter("publisher"))
        assertEquals("https://example.com/article", requestUrl.queryParameter("url"))
        assertEquals("[[300,250]]", requestUrl.queryParameter("ad_size"))
        assertEquals("json", requestUrl.queryParameter("format"))
        assertNull(requestUrl.queryParameter("data"))
        assertEquals("/decision", requestUrl.encodedPath)
    }

    @Test
    fun `fetchAd throws NoFill on empty object response`() = runTest {
        mockWebServer.enqueue(
            MockResponse()
                .setResponseCode(200)
                .setBody("{}")
        )

        try {
            apiService.fetchAd(
                pageUrl = "https://example.com/article",
                sizes = listOf(AdSize.MEDIUM_RECTANGLE),
                theme = "system"
            )
            fail("Expected DisplayAdAPIException.NoFill to be thrown")
        } catch (e: DisplayAdAPIException.NoFill) {
            // Expected
        }
    }

    @Test
    fun `fetchAd throws HttpError on 500 server error`() = runTest {
        mockWebServer.enqueue(
            MockResponse().setResponseCode(500)
        )

        try {
            apiService.fetchAd(
                pageUrl = "https://example.com/article",
                sizes = listOf(AdSize.MEDIUM_RECTANGLE),
                theme = "system"
            )
            fail("Expected DisplayAdAPIException.HttpError to be thrown")
        } catch (e: DisplayAdAPIException.HttpError) {
            assertEquals(500, e.statusCode)
        }
    }

    @Test
    fun `fetchAd throws InvalidData on malformed JSON`() = runTest {
        mockWebServer.enqueue(
            MockResponse()
                .setResponseCode(200)
                .setBody("{ invalid json")
        )

        try {
            apiService.fetchAd(
                pageUrl = "https://example.com/article",
                sizes = listOf(AdSize.MEDIUM_RECTANGLE),
                theme = "system"
            )
            fail("Expected DisplayAdAPIException.InvalidData to be thrown")
        } catch (e: DisplayAdAPIException.InvalidData) {
            // Expected
        }
    }

    @Test(expected = DisplayAdAPIException.InvalidSizes::class)
    fun `buildRequest throws InvalidSizes when sizes is empty`() {
        apiService.buildRequest(pageUrl = "https://example.com", sizes = emptyList())
    }

    @Test
    fun `buildRequest omits data param when context is null`() {
        val request = apiService.buildRequest(
            pageUrl = "https://example.com",
            sizes = listOf(AdSize.MEDIUM_RECTANGLE),
            context = null
        )

        assertNull(request.url.queryParameter("data"))
    }

    @Test
    fun `buildRequest omits data param when context is empty`() {
        val request = apiService.buildRequest(
            pageUrl = "https://example.com",
            sizes = listOf(AdSize.MEDIUM_RECTANGLE),
            context = emptyMap()
        )

        assertNull(request.url.queryParameter("data"))
    }

    @Test
    fun `buildRequest encodes context into data param`() {
        val request = apiService.buildRequest(
            pageUrl = "https://example.com",
            sizes = listOf(AdSize.MEDIUM_RECTANGLE),
            context = mapOf("category" to "technology")
        )

        assertEquals("""{"category":"technology"}""", request.url.queryParameter("data"))
    }

    @Test
    fun `fetchAd sends context as data param`() = runTest {
        mockWebServer.enqueue(
            MockResponse()
                .setResponseCode(200)
                .setBody("""{"adId": "ad-1", "adHeadline": "Baby Gear"}""")
        )

        apiService.fetchAd(
            pageUrl = "https://example.com/article",
            sizes = listOf(AdSize.MEDIUM_RECTANGLE),
            theme = "system",
            context = mapOf("category" to "baby stroller")
        )

        val request = mockWebServer.takeRequest()
        assertEquals(
            """{"category":"baby stroller"}""",
            request.requestUrl!!.queryParameter("data")
        )
    }

    @Test(expected = DisplayAdAPIException.InvalidContext::class)
    fun `encodeContextParam throws InvalidContext for non-JSON values`() {
        DisplayAdAPIService.encodeContextParam(mapOf("callback" to { }))
    }

    @Test
    fun `encodeContextParam encodes nested values`() {
        val json = DisplayAdAPIService.encodeContextParam(
            mapOf("category" to "technology", "keywords" to listOf("AI", "ML"))
        )

        assertEquals("""{"category":"technology","keywords":["AI","ML"]}""", json)
    }
}
