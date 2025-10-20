//
//  SavedCreationsView.swift
//  sipbook
//
//  Created by Christine Bonoan on 10/5/25.
//
//  Shows list of saved creations as well as lets you delete creations

import SwiftUI
import SwiftData

struct SavedCreationsView: View {
    @Environment(\.modelContext) private var modelContext
    
    // get SavedDrink objects from SwiftData; newest gets pulled first
    @Query(sort: [SortDescriptor(\SavedDrink.updatedAt, order: .reverse)])
    private var drinks: [SavedDrink]
    
    // SAVED CREATIONS PAGE
    var body: some View {
        ZStack {
            Color(hex: "#282728")
                .ignoresSafeArea()
            
            // use Group to combine multiple views (SavedDrinkDetailView and SavedDrinkRow)
            Group {
                if drinks.isEmpty {
                    ContentUnavailableView(
                        "No saved drinks",
                        systemImage: "tray",
                    )
                    .foregroundColor(Color(hex: "#F8FAFA"))
                } else {
                    List {
                        // show list of creations -> newest at top of list
                        ForEach(drinks) { drink in
                            NavigationLink {
                                SavedDrinkDetailView(drink: drink)
                            } label: {
                                SavedDrinkRow(drink: drink)
                            }
                        }
                        .onDelete(perform: delete)
                    }
                    .listStyle(.insetGrouped)
                    .scrollContentBackground(.hidden)
                    .background(.clear)
                    .listRowBackground(Color.clear)
                }
            }
            //.navigationTitle("Saved Creations")
            .navigationDestination(for: SavedDrink.self) { drink in
                SavedDrinkDetailView(drink: drink)
            }
        }
        //.toolbar { EditButton () }
    }
    
    // allow user to delete their creation (default is swiping left on item)
    private func delete(at offsets: IndexSet) {
        for i in offsets { modelContext.delete(drinks[i]) }
        try? modelContext.save()
    }
}

private struct SavedDrinkRow: View {
    let drink: SavedDrink
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(drink.name).font(.headline)
            HStack(spacing: 10) {
                Text(drink.kindRaw.capitalized)
                if !drink.spirits.isEmpty {
                    Text("- " + drink.spirits.joined(separator: ", "))
                }
                if !drink.naBases.isEmpty {
                    Text("- " + drink.naBases.joined(separator: ", "))
                }
            }
            .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    SavedCreationsView()
}
