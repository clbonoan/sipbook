//
//  MocktailService.swift
//  sipbook
//
//  Created by Christine Bonoan on 10/20/25.
//  This gives us the data from the mocktails.json file for mocktail ingredients

import Foundation

// data model from JSON file
struct Mocktail: Codable {
    let name: String
    let ingredients: [String]
}

// in place of API; MocktailServiceImpl loads mocktail.json
enum MocktailService {
    static let shared = MocktailServiceImpl()
}

// define what service does
protocol MocktailServing {
    func searchByName(_ name: String) async throws -> [Mocktail]
}

// load JSON file and searches it for data
final class MocktailServiceImpl: MocktailServing {
    private var cache: [Mocktail] = []
    private var byName: [String: Mocktail] = [:]
    private var isLoaded = false
    
    func searchByName(_ name: String) async throws -> [Mocktail] {
        try await load()
        
        // search exact name
        if let exact = byName[name.lowercased()] {
            return [exact]
        }
        // else search by name contains
        let n = name.lowercased()
        let contain = cache.filter { $0.name.lowercased().contains(n)}
        return contain
    }
    
    private func load() async throws {
        guard !isLoaded else { return }
        guard let url = Bundle.main.url(forResource: "mocktails", withExtension: "json") else {
            throw NSError(domain: "MocktailService", code: 1, userInfo:
            [NSLocalizedDescriptionKey: "Missing mocktails.json file."])
        }
        
        let data = try Data(contentsOf: url)
        let decoded = try JSONDecoder().decode([Mocktail].self, from: data)
        
        cache = decoded
        byName = Dictionary(uniqueKeysWithValues: decoded.map { ($0.name.lowercased(), $0) })
        
        isLoaded = true
    }
}
