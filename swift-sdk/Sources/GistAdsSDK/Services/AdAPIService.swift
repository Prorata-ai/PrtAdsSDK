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
    
    init(baseURL: String, publisherID: String, publisherKey: String) {
        self.baseURL = baseURL
        self.publisherID = publisherID
        self.publisherKey = publisherKey
    }
    
    /// Fetch ads from the search API
    /// - Parameters:
    ///   - query: The search query text
    ///   - geo: Geographic location (e.g., "US", "GB")
    ///   - adTypes: Optional array of ad types to filter
    /// - Returns: HTML string containing the ad iframe
    func fetchAd(query: String, geo: String, adTypes: [AdType]?) async throws -> String {
        // Construct the API endpoint
        guard let url = URL(string: "\(baseURL)/v1/search") else {
            throw AdAPIError.invalidURL
        }
        
        // Create request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(publisherID, forHTTPHeaderField: "Publisher-ID")
        request.setValue(publisherKey, forHTTPHeaderField: "Publisher-Key")
        
        // Build request body
        let adTypeStrings = adTypes?.map { $0.rawValue }
        let searchRequest = SearchRequest(
            text: query,
            geo: geo,
            auctionType: "native",
            adType: adTypeStrings
        )
        
        request.httpBody = try JSONEncoder().encode(searchRequest)
        
        // Make the request
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // Check response status
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AdAPIError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            throw AdAPIError.httpError(statusCode: httpResponse.statusCode)
        }
        
        // The API returns ad HTML/JSON - convert to string
        guard let htmlString = String(data: data, encoding: .utf8) else {
            throw AdAPIError.invalidData
        }
        
        // Check if we got a NO_AD response
        if htmlString.contains("\"ads\":[]") || htmlString.contains("NO_AD") {
            throw AdAPIError.noAdsAvailable
        }
        
        return htmlString
    }
}

/// Errors that can occur during API operations
enum AdAPIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case invalidData
    case httpError(statusCode: Int)
    case noAdsAvailable
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid API URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .invalidData:
            return "Unable to parse response data"
        case .httpError(let statusCode):
            return "HTTP error: \(statusCode)"
        case .noAdsAvailable:
            return "No ads available for this query"
        }
    }
}

