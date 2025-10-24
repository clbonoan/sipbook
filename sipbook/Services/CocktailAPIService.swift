//
//  CocktailAPIService.swift
//  sipbook
//
//  Created by Christine Bonoan on 10/17/25.
//  This gives us what data we need from the API for the cocktail ingredients

import Foundation

// data model for cocktails
struct CocktailAPIService: Codable, Hashable {
    let name: String
    let ingredients: [String]
}

// error handling with custom descriptions for each error
// LocalizedError returns a string describing the error (errorDescription)
enum CocktailAPIError: Error, LocalizedError {
    // different types of errors
    case missingKey
    case badURL
    case http(Int)
    case decode(Error)
    case noData
    
    var errorDescription: String? {
        switch self {
        case .missingKey: 
            // key setup error
            "missing API_NINJAS_KEY"
        case .badURL: 
            // incorrect URL
            "invalid request URL"
        case .http(let c): 
            // status code returns
            "server error (\(c))"
        case .decode(let e): 
            // JSON decoding fails
            "parse error: (\(e.localizedDescription))"
        case .noData: 
            // missing or invalid data
            "empty response"
        }
    }
}

// call API from https://api-ninjas.com/api/cocktail
final class CocktailService {
    static let shared = CocktailService()
    private init() {}
    
    // read API key from Info.plist (information property list)
    private var apiKey: String {
        Bundle.main.object(forInfoDictionaryKey: "API_NINJAS_KEY") as? String ?? ""
    }
    
    // search for cocktail by name using API
    func searchByName(_ name: String) async throws -> [CocktailAPIService] {
        // check if API key exists
        guard !apiKey.isEmpty else { throw CocktailAPIError.missingKey }
        
        // request URL with drink name for query
        // appends ! to say that url string is valid and should not be nonexistent
        var q = URLComponents(string: "https://api.api-ninjas.com/v1/cocktail")!
        // add ?name= when querying
        q.queryItems = [URLQueryItem(name: "name", value: name)]
        
        // http request
        var req = URLRequest(url: q.url!)
        req.setValue(apiKey, forHTTPHeaderField: "X-Api-Key")
        
        // asynchronous request
        let (data, resp) = try await URLSession.shared.data(for: req)
        
        // validate http reponse
        guard let http = resp as? HTTPURLResponse else {
            throw CocktailAPIError.noData
        }
        
        // status code must be between 200 to 299 for successful response
        guard (200...299).contains(http.statusCode) else {
            throw CocktailAPIError.http(http.statusCode)
        }
        
        // decode JSON into CocktailAPIService
        do {
            return try JSONDecoder().decode([CocktailAPIService].self, from: data)
        } catch {
            throw CocktailAPIError.decode(error)
        }
    }
}

