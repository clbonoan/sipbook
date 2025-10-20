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
    @State private var showConfirmed = false
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
            .alert("Successfully Deleted", isPresented: $showConfirmed) {
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
            showConfirmed = true
            // debug
            print("All saved data cleared")
        } catch {
            print("Failed to clear data: \(error.localizedDescription)")
        }
    }
}

#Preview {
    SettingsView()
}
