//
//  sipbookApp.swift
//  sipbook
//
//  Created on 9/30/25.
//

import SwiftUI
import SwiftData

@main
struct sipbookApp: App {
    //init() {
    //    let apiKey = Bundle.main.object(forInfoDictionaryKey: "API_NINJAS_KEY") as? String ?? "Missing"
    //    print("Loaded API Key:", apiKey)
    //}
    
    
    /*    var sharedModelContainer: ModelContainer = {
            let schema = Schema([
                SavedDrink.self
            ])
            let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

            do {
                return try ModelContainer(for: schema, configurations: [modelConfiguration])
            } catch {
                fatalError("Could not create ModelContainer: \(error)")
            }
        }()
     */

    var body: some Scene {
        WindowGroup {
            ContentView() // title page
        }
        .modelContainer(for: [SavedDrink.self])
    }
}
