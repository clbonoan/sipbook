//
//  SettingsView.swift
//  sipbook
//
//  Created by Christine Bonoan on 10/5/25.
//  This is the settings page that lets user delete their saved data and/or share it

import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var drinks:[SavedDrink]
    @State private var showConfirmed = false
    @State private var showSuccess = false
    @State private var deletedCount = 0
    
    
    // SETTINGS PAGE
    var body: some View {
        ZStack {
            Color(hex: "#282728")
                .ignoresSafeArea()
            
            Form {
                // option to delete all saved creations
                Section {
                    Button(role: .destructive) {
                        showConfirmed = true
                    } label: {
                        Label("Clear all saved data", systemImage: "trash")
                            .font(.headline)
                            .foregroundColor(Color(hex: "#0D0E10"))
                    }
                }
                
                // option to share all creations
                Section{
                    let shareMessage = drinks.map{drink -> String in
                        var message = "NAME: \(drink.name)\n"
                        
                        //Base:
                        if !drink.spirits.isEmpty {
                            let baseList = drink.spirits.map { spirit in
                                let count = drink.shotsPerSpirit[spirit] ?? 1
                                return "\(spirit) (\(shotLabel(for: count)))"
                            }.joined(separator: ", ")
                            message += "BASE: \(baseList)\n"
                        } else {
                            message += "BASE: None\n"
                        }
                        
                        //Mixer:
                        if !drink.mixers.isEmpty {
                            let mixerList = drink.mixers.map { mixer in
                                let count = drink.partsPerMixer[mixer] ?? 1
                                return "\(mixer) (\(partLabel(for: count)))"
                            }.joined(separator: ", ")
                            message += "MIXER: \(mixerList)\n"
                        } else {
                            message += "MIXER: None\n"
                        }
                        
                        //Liqueur:
                        if !drink.liqueurs.isEmpty {
                            let liqueurList = drink.liqueurs.map { liqueur in
                                let count = drink.partsPerLiqueur[liqueur] ?? 1
                                return "\(liqueur) (\(partLabel(for: count)))"
                            }.joined(separator: ", ")
                            message += "LIQUEUR: \(liqueurList)\n"
                        } else {
                            message += "LIQUEUR: None\n"
                        }
                        
                        //Rim & Garnishes:
                        message += "RIM: \(drink.rim)\n"
                        if !drink.garnishes.isEmpty {
                            let garnishText = drink.garnishes.joined(separator: ", ")
                            message += "GARNISH: \(garnishText)\n"
                        } else {
                            message += "GARNISH: None\n"
                        }
                        
                        //Notes:
                        if !drink.notes.isEmpty {
                            message += "NOTES: \(drink.notes)\n"
                        } else {
                            message += "NOTES: None\n"
                        }
                        
                        return message + "\n-----------------------------------------\n"
                    }.joined(separator: "\n")
                    
                    
                    let LastMessage = """
                        Check out my creations from SipBook! Hope you like it :)\n
                        \(shareMessage)
                        """
                    
                    // Share button
                    ShareLink(
                        item: LastMessage,
                        subject: Text ("My SipBook Creations"),
                    ) {
                        Label("Share all creations", systemImage:"square.and.arrow.up")
                            .font(.headline)
                            .foregroundColor(Color(hex: "#0D0E10"))
                    }
                }
            }
                
            .scrollContentBackground(.hidden)
            .background(.clear)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            
            // show alert for deleting data
            .alert("Clear all saved data?", isPresented: $showConfirmed) {
                Button("Cancel", role: .cancel) { }
                Button("Delete All", role: .destructive) {
                    clearAllSavedData()
                }
            } message: {
                Text("This will permanently delete all your saved creations")
            }
            
            // show alert that data was deleted
            .alert("Successfully Deleted", isPresented: $showSuccess) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Deleted \(deletedCount) creation\(deletedCount == 1 ? "" : "s")")
            }
        }
    }
    
    private func clearAllSavedData() {
        do {
            // fetch all SavedDrink items
            let fetchDescriptor = FetchDescriptor<SavedDrink>()
            let allDrinks = try modelContext.fetch(fetchDescriptor)
            
            // count how many saved drinks will be deleted
            deletedCount = allDrinks.count
            
            for drink in allDrinks {
                modelContext.delete(drink)
            }
            
            // save changes
            try modelContext.save()
            
            // alert that drinks were deleted
            showSuccess = true
            // debug
            // print("All saved data cleared")
        } catch {
            print("Failed to clear data: \(error.localizedDescription)")
        }
    }
    
    // shot and part label for share view
    // return 1 shot or 2 shots
    private func shotLabel(for count: Int) -> String {
        "\(count) shot" + (count == 1 ? "" : "s")
    }
    
    private func partLabel(for count: Int) -> String {
        "\(count) part" + (count == 1 ? "" : "s")
    }
}

#Preview {
    SettingsView()
}
