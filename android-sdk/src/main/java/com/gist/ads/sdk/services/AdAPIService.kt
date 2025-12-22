package com.gist.ads.sdk.services

import com.gist.ads.sdk.APIConstants
import com.gist.ads.sdk.models.AdType
import com.gist.ads.sdk.models.SearchResponse
import com.gist.ads.sdk.models.createSearchRequest
import com.gist.ads.sdk.utils.IframeHTMLGenerator
import com.google.gson.Gson
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import okhttp3.MediaType.Companion.toMediaType
import okhttp3.OkHttpClient
import okhttp3.Request
import okhttp3.RequestBody.Companion.toRequestBody
import okhttp3.logging.HttpLoggingInterceptor
import java.io.IOException
import java.util.concurrent.TimeUnit

/**
 * API service for fetching ads from Gist Search API
 */
class AdAPIService(
    private val baseUrl: String,
    private val publisherId: String,
    private val publisherKey: String,
    private val apiVersion: String = APIConstants.defaultApiVersion(),
    enableLogging: Boolean = false
) {
    private val client: OkHttpClient
    private val gson = Gson()
    
    init {
        val builder = OkHttpClient.Builder()
            .connectTimeout(30, TimeUnit.SECONDS)
            .readTimeout(30, TimeUnit.SECONDS)
            .writeTimeout(30, TimeUnit.SECONDS)
        
        if (enableLogging) {
            val loggingInterceptor = HttpLoggingInterceptor().apply {
                level = HttpLoggingInterceptor.Level.BODY
            }
            builder.addInterceptor(loggingInterceptor)
        }
        
        client = builder.build()
    }
    
    /**
     * Fetch ads from the search API
     * @param query The search query text
     * @param geo Geographic location (e.g., "US", "GB")
     * @param adTypes Optional list of ad types to filter
     * @param answer Optional answer string for v2 (defaults to query if null)
     * @return HTML string containing the ad iframe
     * @throws AdAPIException if the request fails
     */
    suspend fun fetchAd(
        query: String,
        geo: String,
        adTypes: List<AdType>?,
        answer: String? = null
    ): String = withContext(Dispatchers.IO) {
        try {
            // Build request body using factory function
            val adTypeStrings = adTypes?.map { it.value }
            val searchRequest = createSearchRequest(
                version = apiVersion,
                query = query,
                geo = geo,
                adTypes = adTypeStrings,
                answer = answer
            )
            
            val jsonBody = gson.toJson(searchRequest)
            val requestBody = jsonBody.toRequestBody("application/json".toMediaType())
            
            // Build HTTP request with dynamic endpoint
            val endpoint = "$baseUrl${APIConstants.searchEndpoint(apiVersion)}"
            val request = Request.Builder()
                .url(endpoint)
                .post(requestBody)
                .addHeader("Content-Type", "application/json")
                .addHeader("Publisher-ID", publisherId)
                .addHeader("Publisher-Key", publisherKey)
                .build()
            
            // Execute request
            val response = client.newCall(request).execute()
            
            if (!response.isSuccessful) {
                throw AdAPIException.HttpError(response.code)
            }
            
            val responseBody = response.body?.string()
                ?: throw AdAPIException.InvalidData
            
            // Parse JSON response and extract iframe URL
            parseJSONResponse(responseBody)
            
        } catch (e: IOException) {
            throw AdAPIException.NetworkError(e)
        } catch (e: AdAPIException) {
            throw e
        } catch (e: Exception) {
            throw AdAPIException.UnknownError(e)
        }
    }
    
    /**
     * Parse JSON response and extract iframe URL
     * @param data Response data containing JSON
     * @return HTML string containing the ad iframe
     */
    private fun parseJSONResponse(data: String): String {
        val searchResponse: SearchResponse
        try {
            searchResponse = gson.fromJson(data, SearchResponse::class.java)
        } catch (e: Exception) {
            throw AdAPIException.InvalidData
        }
        
        // Check if we have a selection with ads
        val selection = searchResponse.selection
        if (selection.isNullOrEmpty()) {
            throw AdAPIException.NoAdsAvailable
        }
        
        // Extract iframeUrl from first selection item
        val firstAd = selection.first()
        val iframeUrl = firstAd.iframeUrl
        
        if (iframeUrl.isNullOrEmpty()) {
            throw AdAPIException.MissingIframeUrl
        }
        
        // Generate iframe HTML using utility
        return IframeHTMLGenerator.generate(iframeUrl)
    }
}

/**
 * Errors that can occur during API operations
 */
sealed class AdAPIException(message: String, cause: Throwable? = null) : Exception(message, cause) {
    object InvalidUrl : AdAPIException("Invalid API URL")
    object InvalidResponse : AdAPIException("Invalid response from server")
    object InvalidData : AdAPIException("Unable to parse response data")
    data class HttpError(val statusCode: Int) : AdAPIException("HTTP error: $statusCode")
    object NoAdsAvailable : AdAPIException("No ads available for this query")
    object MissingIframeUrl : AdAPIException("Ad response missing iframe URL")
    data class NetworkError(val error: Throwable) : AdAPIException("Network error", error)
    data class UnknownError(val error: Throwable) : AdAPIException("Unknown error", error)
}


