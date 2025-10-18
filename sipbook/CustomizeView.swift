//
//  CustomizeView.swift
//  sipbook
//
//  Created on 10/6/25.
//
//  Show this view when the user selects a preset drink
//  Show original recipe from Cocktail API

import SwiftUI

struct CustomizeView: View {
    let preset: PresetDrink
    
    @State private var ingredients: [String] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    // CUSTOMIZING PAGE
    var body: some View {
        ZStack {
            Color(hex: "#282728")
                .ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Testing API for: \(preset.name)")
                        .font(.headline)
                        .foregroundColor(Color(hex: "#F8FAFA"))
                    
                    // check if API is loading data
                    if isLoading {
                        ProgressView("Loading...")
                    } else if let err = errorMessage {
                        Text("Error: \(err)")
                            .foregroundColor(.red)
                    } else if ingredients.isEmpty {
                        Text("No data yet")
                            .foregroundColor(.white)
                    } else {
                        Text("Ingredients:")
                            .font(.subheadline).bold()
                            .foregroundColor(Color(hex: "#F8FAFA"))
                        Text(ingredients.joined(separator: "\n"))
                            .font(.system(.body, design: .monospaced))
                            .foregroundColor(Color(hex: "#F8FAFA"))
                    }
                    Spacer()
                }
                .padding()
                // fetch data when open
                .task { await loadOnce() }
                .navigationTitle(preset.name)
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
    
    // function for loading data from Cocktail API
    private func loadOnce() async {
        // only fetch data for cocktails
        guard preset.kind == .cocktail else {
            errorMessage = "Skipping API (mocktail)"
            return
        }
        // don't refetch if already loaded
        guard !isLoading && ingredients.isEmpty else { return }
        
        isLoading = true
        defer { isLoading = false }
        errorMessage = nil
        
        do {
            let results = try await CocktailService.shared.searchByName(preset.name)
            
            // try exact name match first or take first result
            let best = results.first {
                $0.name.compare(preset.name, options: .caseInsensitive) == .orderedSame
            } ?? results.first
            
            if let best {
                ingredients = best.ingredients
                
                // print to console for debugging
                print("API OK for \(preset.name)")
                print("Ingredients:", best.ingredients)
            } else {
                errorMessage = "No recipe found from API"
            }
        } catch {
            errorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
            print("API error:", errorMessage ?? "")
        }
    }
}

// reusable mock for previews
extension PresetDrink {
    static let preview = PresetDrink(name: "Margarita", kind: .cocktail)
}

#Preview {
    CustomizeView(preset: .preview)
}
