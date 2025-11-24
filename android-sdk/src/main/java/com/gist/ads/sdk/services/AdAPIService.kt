package com.gist.ads.sdk.services

import com.gist.ads.sdk.models.AdType
import com.gist.ads.sdk.models.SearchRequest
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
     * @return HTML string containing the ad content
     * @throws AdAPIException if the request fails
     */
    suspend fun fetchAd(
        query: String,
        geo: String,
        adTypes: List<AdType>?
    ): String = withContext(Dispatchers.IO) {
        try {
            // Build request body
            val adTypeStrings = adTypes?.map { it.value }
            val searchRequest = SearchRequest(
                text = query,
                geo = geo,
                auctionType = "native",
                adType = adTypeStrings
            )
            
            val jsonBody = gson.toJson(searchRequest)
            val requestBody = jsonBody.toRequestBody("application/json".toMediaType())
            
            // Build HTTP request
            val request = Request.Builder()
                .url("$baseUrl/v1/search")
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
            
            // Check for NO_AD response
            if (responseBody.contains("\"ads\":[]") || responseBody.contains("NO_AD")) {
                throw AdAPIException.NoAdsAvailable
            }
            
            responseBody
            
        } catch (e: IOException) {
            throw AdAPIException.NetworkError(e)
        } catch (e: AdAPIException) {
            throw e
        } catch (e: Exception) {
            throw AdAPIException.UnknownError(e)
        }
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
    data class NetworkError(val error: Throwable) : AdAPIException("Network error", error)
    data class UnknownError(val error: Throwable) : AdAPIException("Unknown error", error)
}


