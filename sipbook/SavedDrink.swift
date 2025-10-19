//
//  SavedDrink.swift
//  sipbook
//
//  Created by Christine Bonoan on 10/18/25.
//

import SwiftData
import Foundation

@Model
final class SavedDrink {
    var id: UUID
    var name: String
    var kindRaw: String
    var notes: String
    
    var spirits: [String]
    var naBases: [String]
    var mixers: [String]
    var liqueurs: [String]
    var rim: String
    var garnishes: [String]
    
    var shotsPerSpirit: [String: Int]
    var partsPerBase: [String: Int]
    var partsPerMixer: [String: Int]
    var partsPerLiqueur: [String: Int]
    
    var createdAt: Date
    var updatedAt: Date
    
    init(
        id: UUID = UUID(),
        name: String,
        kindRaw: String,
        notes: String = "",
        spirits: [String] = [],
        shotsPerSpirit: [String:Int] = [:],
        naBases: [String] = [],
        partsPerBase: [String:Int] = [:],
        mixers: [String] = [],
        partsPerMixer: [String:Int] = [:],
        liqueurs: [String] = [],
        partsPerLiqueur: [String:Int] = [:],
        rim: String = "None",
        garnishes: [String] = [],
        createdAt: Date = .now,
        updatedAt: Date = .now
    ) {
        self.id = id
        self.name = name
        self.kindRaw = kindRaw
        self.notes = notes
        self.spirits = spirits
        self.shotsPerSpirit = shotsPerSpirit
        self.naBases = naBases
        self.partsPerBase = partsPerBase
        self.mixers = mixers
        self.partsPerMixer = partsPerMixer
        self.liqueurs = liqueurs
        self.partsPerLiqueur = partsPerLiqueur
        self.garnishes = garnishes
        self.rim = rim
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
        
    var isCocktail: Bool {
        kindRaw.lowercased() == "cocktail"
    }
}
