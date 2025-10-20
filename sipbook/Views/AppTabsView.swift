//
//  AppTabsView.swift
//  sipbook
//
//  Created by Christine Bonoan on 10/5/25.
//
import SwiftUI

struct AppTabsView: View {
    var body: some View {
        TabView {
            // HOME PAGE - has preset drinks
            NavigationStack { PresetDrinksView() }
                .tabItem { Label("Home", systemImage: "house.fill") }
                
            // SAVED CREATIONS TAB
            NavigationStack { SavedCreationsView() }
                .tabItem { Label("Saved Creations", systemImage: "bookmark.fill") }
            
            // SETTINGS TAB
            NavigationStack { SettingsView() }
                .tabItem { Label("Settings", systemImage: "gearshape.fill") }
        }
        .tint(Color(hex: "#4F5052"))
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    AppTabsView()
}
