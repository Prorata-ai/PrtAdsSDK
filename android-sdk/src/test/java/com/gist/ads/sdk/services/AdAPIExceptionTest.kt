package com.gist.ads.sdk.services

import org.junit.Assert.*
import org.junit.Test
import java.io.IOException

class AdAPIExceptionTest {
    
    @Test
    fun `InvalidUrl has correct message`() {
        // Act
        val exception = AdAPIException.InvalidUrl
        
        // Assert
        assertEquals("Invalid API URL configured", exception.message)
    }
    
    @Test
    fun `HttpError 401 has authentication failed message`() {
        // Act
        val exception = AdAPIException.HttpError(401)
        
        // Assert
        assertEquals(401, exception.statusCode)
        assertTrue(exception.message!!.contains("Authentication failed"))
        assertTrue(exception.message!!.contains("Invalid publisher credentials"))
    }
    
    @Test
    fun `HttpError 403 has access forbidden message`() {
        // Act
        val exception = AdAPIException.HttpError(403)
        
        // Assert
        assertEquals(403, exception.statusCode)
        assertTrue(exception.message!!.contains("Access forbidden"))
        assertTrue(exception.message!!.contains("publisher permissions"))
    }
    
    @Test
    fun `HttpError 404 has endpoint not found message`() {
        // Act
        val exception = AdAPIException.HttpError(404)
        
        // Assert
        assertEquals(404, exception.statusCode)
        assertTrue(exception.message!!.contains("API endpoint not found"))
        assertTrue(exception.message!!.contains("SDK version compatibility"))
    }
    
    @Test
    fun `HttpError 429 has rate limit message`() {
        // Act
        val exception = AdAPIException.HttpError(429)
        
        // Assert
        assertEquals(429, exception.statusCode)
        assertTrue(exception.message!!.contains("Rate limit exceeded"))
        assertTrue(exception.message!!.contains("Too many requests"))
    }
    
    @Test
    fun `HttpError 500 has server error message`() {
        // Act
        val exception = AdAPIException.HttpError(500)
        
        // Assert
        assertEquals(500, exception.statusCode)
        assertTrue(exception.message!!.contains("Server error"))
        assertTrue(exception.message!!.contains("try again later"))
    }
    
    @Test
    fun `HttpError 503 has service unavailable message`() {
        // Act
        val exception = AdAPIException.HttpError(503)
        
        // Assert
        assertEquals(503, exception.statusCode)
        assertTrue(exception.message!!.contains("Service temporarily unavailable"))
    }
    
    @Test
    fun `HttpError with unknown status code has generic message`() {
        // Act
        val exception = AdAPIException.HttpError(999)
        
        // Assert
        assertEquals(999, exception.statusCode)
        assertTrue(exception.message!!.contains("HTTP error 999"))
        assertTrue(exception.message!!.contains("Request failed"))
    }
    
    @Test
    fun `NoAdsAvailable has descriptive message`() {
        // Act
        val exception = AdAPIException.NoAdsAvailable
        
        // Assert
        assertTrue(exception.message!!.contains("No ads available"))
        assertTrue(exception.message!!.contains("No matching ads found"))
        assertTrue(exception.message!!.contains("query and location"))
    }
    
    @Test
    fun `MissingIframeUrl has descriptive message`() {
        // Act
        val exception = AdAPIException.MissingIframeUrl
        
        // Assert
        assertTrue(exception.message!!.contains("Invalid ad response"))
        assertTrue(exception.message!!.contains("Missing iframe URL"))
    }
    
    @Test
    fun `NetworkError wraps underlying exception`() {
        // Arrange
        val ioException = IOException("Connection timeout")
        
        // Act
        val exception = AdAPIException.NetworkError(ioException)
        
        // Assert
        assertTrue(exception.message!!.contains("Network error"))
        assertTrue(exception.message!!.contains("Connection timeout"))
        assertEquals(ioException, exception.cause)
    }
    
    @Test
    fun `NetworkError with null message has fallback`() {
        // Arrange
        val ioException = IOException()
        
        // Act
        val exception = AdAPIException.NetworkError(ioException)
        
        // Assert
        assertTrue(exception.message!!.contains("Unable to connect to ad server"))
    }
    
    @Test
    fun `InvalidData has descriptive message`() {
        // Act
        val exception = AdAPIException.InvalidData
        
        // Assert
        assertTrue(exception.message!!.contains("Invalid response format"))
        assertTrue(exception.message!!.contains("Unable to parse"))
    }
    
    @Test
    fun `UnknownError wraps underlying exception`() {
        // Arrange
        val runtimeException = RuntimeException("Unexpected error")
        
        // Act
        val exception = AdAPIException.UnknownError(runtimeException)
        
        // Assert
        assertTrue(exception.message!!.contains("Unexpected error"))
        assertTrue(exception.message!!.contains("Unexpected error"))
        assertEquals(runtimeException, exception.cause)
    }
    
    @Test
    fun `UnknownError with null message has fallback`() {
        // Arrange
        val runtimeException = RuntimeException()
        
        // Act
        val exception = AdAPIException.UnknownError(runtimeException)
        
        // Assert
        assertTrue(exception.message!!.contains("Unknown error occurred"))
    }
    
    @Test
    fun `all exception types are AdAPIException instances`() {
        // Assert
        assertTrue(AdAPIException.InvalidUrl is AdAPIException)
        assertTrue(AdAPIException.HttpError(401) is AdAPIException)
        assertTrue(AdAPIException.NoAdsAvailable is AdAPIException)
        assertTrue(AdAPIException.MissingIframeUrl is AdAPIException)
        assertTrue(AdAPIException.NetworkError(IOException()) is AdAPIException)
        assertTrue(AdAPIException.InvalidData is AdAPIException)
        assertTrue(AdAPIException.UnknownError(RuntimeException()) is AdAPIException)
    }
}
