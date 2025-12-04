//
//  AdAPIService.swift
//  GistAdsSDK
//
//  Service for communicating with Gist Ads API
//

import Foundation

/// API service for fetching ads from Gist Search API
class AdAPIService {
    
    private let baseURL: String
    private let publisherID: String
    private let publisherKey: String
    private let apiVersion: String
    
    init(baseURL: String, publisherID: String, publisherKey: String, apiVersion: String? = nil) {
        self.baseURL = baseURL
        self.publisherID = publisherID
        self.publisherKey = publisherKey
        self.apiVersion = apiVersion ?? APIConstants.apiVersion()
    }
    
    /// Fetch ads from the search API
    /// - Parameters:
    ///   - query: The search query text
    ///   - geo: Geographic location (e.g., "US", "GB")
    ///   - adTypes: Optional array of ad types to filter
    ///   - answer: Optional answer string for v2 (defaults to query if nil)
    /// - Returns: HTML string containing the ad iframe
    func fetchAd(query: String, geo: String, adTypes: [AdType]?, answer: String? = nil) async throws -> String {
        // Construct the API endpoint using URL(string:relativeTo:) for safer construction
        guard let base = URL(string: baseURL) else {
            throw AdAPIError.invalidURL
        }
        let endpoint = APIConstants.searchEndpoint(for: apiVersion)
        guard let url = URL(string: endpoint, relativeTo: base) else {
            throw AdAPIError.invalidURL
        }
        
        // Create request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(publisherID, forHTTPHeaderField: "Publisher-ID")
        request.setValue(publisherKey, forHTTPHeaderField: "Publisher-Key")
        
        // Build request body using factory function
        let adTypeStrings = adTypes?.map { $0.rawValue }
        let searchRequest = createSearchRequest(
            version: apiVersion,
            query: query,
            geo: geo,
            adTypes: adTypeStrings,
            answer: answer
        )
        
        let requestBody = try JSONEncoder().encode(searchRequest)
        request.httpBody = requestBody
        
        // Make the request
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // Check response status
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AdAPIError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            throw AdAPIError.httpError(statusCode: httpResponse.statusCode, response: data)
        }
        
        // Handle response based on API version
        return try handleResponse(version: apiVersion, data: data)
    }
    
    /// Handle API response based on version
    /// - Parameters:
    ///   - version: API version string
    ///   - data: Response data
    /// - Returns: HTML string containing the ad
    private func handleResponse(version: String, data: Data) throws -> String {
        // Both v1 and v2 use the same JSON format with selection array
        return try parseJSONResponse(data: data)
    }
    
    /// Parse JSON response and extract iframe URL
    /// - Parameter data: Response data containing JSON
    /// - Returns: HTML string containing the ad iframe
    private func parseJSONResponse(data: Data) throws -> String {
        let searchResponse: SearchResponse
        do {
            searchResponse = try JSONDecoder().decode(SearchResponse.self, from: data)
        } catch {
            throw AdAPIError.invalidData(underlying: error)
        }
        
        // Check if we have a selection with ads
        guard let selection = searchResponse.selection, !selection.isEmpty else {
            throw AdAPIError.noAdsAvailable
        }
        
        // Extract iframeUrl from first selection item
        guard let firstAd = selection.first,
              let iframeUrl = firstAd.iframeUrl,
              !iframeUrl.isEmpty else {
            throw AdAPIError.missingIframeUrl
        }

        // Generate iframe HTML using utility
        return IframeHTMLGenerator.generate(iframeUrl: iframeUrl)
    }
}

/// Errors that can occur during API operations
enum AdAPIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case invalidData(underlying: Error)
    case httpError(statusCode: Int, response: Data?)
    case noAdsAvailable
    case missingIframeUrl
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid API URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .invalidData(let underlying):
            return "Unable to parse response data: \(underlying.localizedDescription)"
        case .httpError(let statusCode, _):
            return "HTTP error: \(statusCode)"
        case .noAdsAvailable:
            return "No ads available for this query"
        case .missingIframeUrl:
            return "Ad response missing iframe URL"
        }
    }
}

