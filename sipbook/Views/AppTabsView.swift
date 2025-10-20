//
//  AppTabsView.swift
//  sipbook
//
//  Created by Christine Bonoan on 10/5/25.
//  This has all the options in the tab bar.

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
        .tint(Color(hex: "#C5C6C8"))
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    AppTabsView()
}
