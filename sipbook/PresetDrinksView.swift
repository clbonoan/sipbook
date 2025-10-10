//
//  PresetDrinksView.swift
//  sipbook
//
//  Created by Christine Bonoan on 10/5/25.
//

import SwiftUI

// define shared types
// will be using this for the search bar and picker
// CaseIterable lets you iterate over all cases of the enum
// Identifiable lets you use the enum as the identifier for the picker’s selections
enum DrinkKind: String, CaseIterable, Identifiable { case coffee = "Coffee"
    case tea = "Tea"
    var id: String {rawValue} }

struct PresetDrink: Identifiable, Hashable {
    let id = UUID()
    let name = String()
    //let kind = DrinkKind
}

struct PresetDrinksView: View {
    @State private var searchText = ""
    @State private var selectedKind: DrinkKind = .coffee
    
    // make two columns and x rows
    private let columns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]
    
    
    // HOME PAGE
    var body: some View {
        ZStack {
            Color(hex: "#333131")
                .ignoresSafeArea()
            ScrollView {
                VStack {
                    Spacer()
                    Text("What drink will you make today?")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(Color(hex: "#F2E6D4"))
                    Spacer()
 
                    // search bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(Color(hex: "#333131"))
                            .padding(.leading)
                        TextField("Search", text: $searchText)
                            .foregroundColor(Color(hex: "#333131"))
                            .padding()
                            //.font(.system(size: 14, weight: .regular, design: .rounded))
                    }
                    .padding(.horizontal, -5)
                    .padding(.vertical, -10)
                    .background(Color(hex: "F2E6D4"))
                    .cornerRadius(10)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 2)
                    .padding()
                    
                    Picker("Category", selection: $selectedKind) {
                        Text("Coffee").tag(DrinkKind.coffee)
                        Text("Tea").tag(DrinkKind.tea)
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    
                    
                }
            }
        }
        
        
    }
}

#Preview {
    PresetDrinksView()
}
