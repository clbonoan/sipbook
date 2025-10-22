//
//  SettingsView.swift
//  sipbook
//
//  Created by Christine Bonoan on 10/5/25.
//  This is the settings page that lets user delete their saved data

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
                Section {
                    Button(role: .destructive) {
                        showConfirmed = true
                    } label: {
                        Label("Clear all saved data", systemImage: "trash")
                            .font(.headline)
                            .foregroundColor(Color(hex: "#0D0E10"))
                    }
                }
                //The add on
                Section{
                    let shareMessage = drinks.map{drink -> String in
                        var message = "\u{1F378}\(drink.name)\n"
                        //Base:
                        if !drink.spirits.isEmpty {
                            let baseList = drink.spirits.map { spirit in
                                " \u{2022}\(spirit) (\(drink.shotsPerSpirit[spirit] ?? 1), shots)"
                            }.joined(separator: ", ")
                            message += " Base: \(baseList)\n"
                        }
                        //Mixer:
                        if !drink.mixers.isEmpty {
                            let mixerList = drink.mixers.map { mixer in
                                "\u{2022}\(mixer) (\(drink.partsPerMixer[mixer] ?? 1), parts)"
                            }.joined(separator: ", ")
                            message += " Mixer: \(mixerList)\n"
                        }
                        //Liqueur:
                        if !drink.liqueurs.isEmpty {
                            let liqueurList = drink.liqueurs.map { liqueur in
                                "\u{2022}\(liqueur)(\(drink.partsPerLiqueur[liqueur] ?? 1), parts)"
                            }.joined(separator: ", ")
                            message += " Liqueurs: \(liqueurList)\n"
                        }
                        //Rim & Garnishes:
                        if !drink.garnishes.isEmpty {
                            message += " Rim & Garnishes: \(drink.garnishes)\n"
                        }
                        //Notes:
                        if !drink.notes.isEmpty {
                            message += " Notes: \(drink.notes)\n"
                        }
                        
                        return message + "\n----------------------------------\n"
                    }.joined(separator: "\n")
                    let LastMessage = """
                        Check out my creations from SipBook!\u{1F378} Hope you like it :)
                        \(shareMessage)
                        """
                    //ShareButton
                    ShareLink(
                        item: LastMessage,
                        subject: Text ("My SipBook Creations\u{1F378}"),
                        message:Text ("Check out my drink list made in SipBook") //Preview
                    ){
                            Label("\u{1F378} Share All Creations \u{1F378}", systemImage:"square.and.arrow.up")
                                .font(.headline)
                                .foregroundColor(.black)
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
}

#Preview {
    SettingsView()
}
