package com.gist.ads.sdk.services

import com.gist.ads.sdk.models.AdType
import io.mockk.coEvery
import io.mockk.mockk
import kotlinx.coroutines.test.runTest
import okhttp3.mockwebserver.MockResponse
import okhttp3.mockwebserver.MockWebServer
import org.junit.After
import org.junit.Assert.*
import org.junit.Before
import org.junit.Test

class AdAPIServiceTest {
    
    private lateinit var mockWebServer: MockWebServer
    private lateinit var apiService: AdAPIService
    
    @Before
    fun setup() {
        mockWebServer = MockWebServer()
        mockWebServer.start()
        
        apiService = AdAPIService(
            baseUrl = mockWebServer.url("/").toString().trimEnd('/'),
            publisherId = "test-publisher-id",
            publisherKey = "test-publisher-key",
            apiVersion = "v2",
            enableLogging = false
        )
    }
    
    @After
    fun tearDown() {
        mockWebServer.shutdown()
    }
    
    @Test
    fun `fetchAd successfully parses V2 JSON response with theme`() = runTest {
        // Arrange
        val mockResponse = """
        {
            "selection": [
                {
                    "iframeUrl": "https://example.com/ad"
                }
            ]
        }
        """.trimIndent()
        
        mockWebServer.enqueue(
            MockResponse()
                .setResponseCode(200)
                .setBody(mockResponse)
                .addHeader("Content-Type", "application/json")
        )
        
        // Act
        val result = apiService.fetchAd(
            query = "test query",
            geo = "US",
            adTypes = listOf(AdType.IMAGE),
            theme = "dark"
        )
        
        // Assert
        assertTrue(result.contains("https://example.com/ad"))
        assertTrue(result.contains("pr_theme=dark"))
        assertTrue(result.contains("<iframe"))
        
        val request = mockWebServer.takeRequest()
        assertEquals("test-publisher-id", request.getHeader("Publisher-ID"))
        assertEquals("test-publisher-key", request.getHeader("Publisher-Key"))
        assertTrue(request.getHeader("Content-Type")!!.startsWith("application/json"))
    }
    
    @Test
    fun `fetchAd appends theme with ampersand when URL has query params`() = runTest {
        // Arrange
        val mockResponse = """
        {
            "selection": [
                {
                    "iframeUrl": "https://example.com/ad?existing=param"
                }
            ]
        }
        """.trimIndent()
        
        mockWebServer.enqueue(
            MockResponse()
                .setResponseCode(200)
                .setBody(mockResponse)
        )
        
        // Act
        val result = apiService.fetchAd(
            query = "test",
            geo = "US",
            adTypes = null,
            theme = "light"
        )
        
        // Assert
        assertTrue(result.contains("existing=param&pr_theme=light"))
    }
    
    @Test
    fun `fetchAd throws HttpError on 401 authentication failure`() = runTest {
        // Arrange
        mockWebServer.enqueue(
            MockResponse().setResponseCode(401)
        )
        
        // Act & Assert
        try {
            apiService.fetchAd(
                query = "test",
                geo = "US",
                adTypes = null,
                theme = "system"
            )
            fail("Expected AdAPIException.HttpError to be thrown")
        } catch (e: AdAPIException.HttpError) {
            assertEquals(401, e.statusCode)
        }
    }
    
    @Test
    fun `fetchAd throws HttpError on 404 not found`() = runTest {
        // Arrange
        mockWebServer.enqueue(
            MockResponse().setResponseCode(404)
        )
        
        // Act & Assert
        try {
            apiService.fetchAd(
                query = "test",
                geo = "US",
                adTypes = null,
                theme = "system"
            )
            fail("Expected AdAPIException.HttpError to be thrown")
        } catch (e: AdAPIException.HttpError) {
            assertEquals(404, e.statusCode)
        }
    }
    
    @Test
    fun `fetchAd throws HttpError on 500 server error`() = runTest {
        // Arrange
        mockWebServer.enqueue(
            MockResponse().setResponseCode(500)
        )
        
        // Act & Assert
        try {
            apiService.fetchAd(
                query = "test",
                geo = "US",
                adTypes = null,
                theme = "system"
            )
            fail("Expected AdAPIException.HttpError to be thrown")
        } catch (e: AdAPIException.HttpError) {
            assertEquals(500, e.statusCode)
        }
    }
    
    @Test
    fun `fetchAd throws InvalidData on malformed JSON`() = runTest {
        // Arrange
        mockWebServer.enqueue(
            MockResponse()
                .setResponseCode(200)
                .setBody("{ invalid json")
        )
        
        // Act & Assert
        try {
            apiService.fetchAd(
                query = "test",
                geo = "US",
                adTypes = null,
                theme = "system"
            )
            fail("Expected AdAPIException.InvalidData to be thrown")
        } catch (e: AdAPIException.InvalidData) {
            // Expected
        }
    }
    
    @Test
    fun `fetchAd throws NoAdsAvailable when selection is empty`() = runTest {
        // Arrange
        val mockResponse = """
        {
            "selection": []
        }
        """.trimIndent()
        
        mockWebServer.enqueue(
            MockResponse()
                .setResponseCode(200)
                .setBody(mockResponse)
        )
        
        // Act & Assert
        try {
            apiService.fetchAd(
                query = "test",
                geo = "US",
                adTypes = null,
                theme = "system"
            )
            fail("Expected AdAPIException.NoAdsAvailable to be thrown")
        } catch (e: AdAPIException.NoAdsAvailable) {
            // Expected
        }
    }
    
    @Test
    fun `fetchAd throws NoAdsAvailable when selection is null`() = runTest {
        // Arrange
        val mockResponse = """
        {
            "selection": null
        }
        """.trimIndent()
        
        mockWebServer.enqueue(
            MockResponse()
                .setResponseCode(200)
                .setBody(mockResponse)
        )
        
        // Act & Assert
        try {
            apiService.fetchAd(
                query = "test",
                geo = "US",
                adTypes = null,
                theme = "system"
            )
            fail("Expected AdAPIException.NoAdsAvailable to be thrown")
        } catch (e: AdAPIException.NoAdsAvailable) {
            // Expected
        }
    }
    
    @Test
    fun `fetchAd throws MissingIframeUrl when iframeUrl is missing`() = runTest {
        // Arrange
        val mockResponse = """
        {
            "selection": [
                {
                    "someOtherField": "value"
                }
            ]
        }
        """.trimIndent()
        
        mockWebServer.enqueue(
            MockResponse()
                .setResponseCode(200)
                .setBody(mockResponse)
        )
        
        // Act & Assert
        try {
            apiService.fetchAd(
                query = "test",
                geo = "US",
                adTypes = null,
                theme = "system"
            )
            fail("Expected AdAPIException.MissingIframeUrl to be thrown")
        } catch (e: AdAPIException.MissingIframeUrl) {
            // Expected
        }
    }
    
    @Test
    fun `fetchAd includes adTypes in request body`() = runTest {
        // Arrange
        val mockResponse = """
        {
            "selection": [
                {
                    "iframeUrl": "https://example.com/ad"
                }
            ]
        }
        """.trimIndent()
        
        mockWebServer.enqueue(
            MockResponse()
                .setResponseCode(200)
                .setBody(mockResponse)
        )
        
        // Act
        apiService.fetchAd(
            query = "test query",
            geo = "US",
            adTypes = listOf(AdType.IMAGE, AdType.TEXT),
            theme = "system"
        )
        
        // Assert
        val request = mockWebServer.takeRequest()
        val requestBody = request.body.readUtf8()
        assertTrue(requestBody.contains("image"))
        assertTrue(requestBody.contains("text"))
    }
    
    @Test
    fun `fetchAd sends correct API version endpoint`() = runTest {
        // Arrange
        val mockResponse = """
        {
            "selection": [
                {
                    "iframeUrl": "https://example.com/ad"
                }
            ]
        }
        """.trimIndent()
        
        mockWebServer.enqueue(
            MockResponse()
                .setResponseCode(200)
                .setBody(mockResponse)
        )
        
        // Act
        apiService.fetchAd(
            query = "test",
            geo = "US",
            adTypes = null,
            theme = "system"
        )
        
        // Assert
        val request = mockWebServer.takeRequest()
        assertTrue(request.path!!.contains("/v2/search"))
    }
}
