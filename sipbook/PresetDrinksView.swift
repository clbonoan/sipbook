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
enum DrinkKind: String, CaseIterable, Identifiable { 
    case cocktail = "Cocktail"
    case mocktail = "Mocktail"
    var id: String {rawValue}
}

struct PresetDrink: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let kind: DrinkKind
    //let ingredients: [String]?
    
}

struct PresetDrinksView: View {
    @State private var searchText = ""
    @State private var selectedKind: DrinkKind = .cocktail
    
    // make two columns and x rows
    private let columns = [
        GridItem(.flexible(), spacing: 20),
        GridItem(.flexible(), spacing: 20)
    ]
    
    // presets
    private let allPresets: [PresetDrink] = [
        .init(name: "Margarita", kind: .cocktail),
        .init(name: "Mojito", kind: .cocktail),
        .init(name: "Moscow Mule", kind: .cocktail),
        .init(name: "Martini", kind: .cocktail),
        .init(name: "Whiskey Sour", kind: .cocktail),
        .init(name: "Daiquiri", kind: .cocktail),
        .init(name: "Shirley Temple", kind: .mocktail),
        .init(name: "Arnold Palmer", kind: .mocktail),
        .init(name: "Virgin Margarita", kind: .mocktail),
        .init(name: "Virgin Mojito", kind: .mocktail),
    ]
    
    // filter preset drinks based on category Cocktail or Mocktail
    // searched text by user should display matches
    private var filteredData: [PresetDrink] {
        // show only drinks based on category toggled
        let base = allPresets.filter {$0.kind == selectedKind}
        let q = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else { return base }
        // make filtered list based on case insensitive search
        return base.filter { $0.name.localizedCaseInsensitiveContains(q)}
    }
    
    // HOME PAGE
    var body: some View {
        ZStack {
            Color(hex: "#282728")
                .ignoresSafeArea()
            ScrollView {
                VStack {
                    Spacer()
                    Text("What drink will you make today?")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(Color(hex: "#F8FAFA"))
                    Spacer()
 
                    // search bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(Color(hex: "#282728"))
                            .padding(.leading)
                        TextField("Search", text: $searchText)
                            .foregroundColor(Color(hex: "#282728"))
                            .padding()
                            //.font(.system(size: 14, weight: .regular, design: .rounded))
                    }
                    .padding(.horizontal, -5)
                    .padding(.vertical, -10)
                    .background(Color(hex: "#F8FAFA"))
                    .cornerRadius(10)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 2)
                    .padding()
                    
                    // cocktail or mocktail toggle picker
                    Picker("Category", selection: $selectedKind) {
                        Text("Cocktail").tag(DrinkKind.cocktail)
                        Text("Mocktail").tag(DrinkKind.mocktail)
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, 50)
                    .padding(.bottom, 20)
                    
                    // grid with presets that are clickable
                    LazyVGrid (
                        columns: columns, alignment: .center, spacing: 20
                    ) {
                        // display each drink in allPresets
                        ForEach(filteredData) { preset in NavigationLink {
                                // go to customization view when drink preset is clicked
                                CustomizeView(preset: preset)
                            } label: {
                                VStack(spacing: 10) {
                                    Text(preset.name)
                                         .font(.headline)
                                        .foregroundColor(Color(hex: "#F8FAFA"))
                                        .multilineTextAlignment(.center)
                                        .lineLimit(2)
                                        .minimumScaleFactor(0.5)
                                }
                                .frame(maxWidth: .infinity, minHeight: 140)
                                .padding()
                                .background(Color.white.opacity(0.08))
                                .cornerRadius(10)
                            }
                        
                        }
                    }
                    
                    /*LazyVGrid(
                        columns: [
                            GridItem(.flexible(minimum: 50, maximum: .infinity), spacing: 20),
                            GridItem(.flexible(minimum: 50, maximum: .infinity)),
                        ],
                        alignment: .leading,
                        spacing: 20
                    ) {
                        ForEach(0..<8, id:\.self) { column in
                            Text("\(column)")
                                .frame(height: 200)
                                .frame(maxWidth: .infinity)
                                .background(Color(hex: "#818283"))
                                
                        }
                    }.padding(25)*/
                    .padding(.horizontal, 15)
                }
            }
        }
    }
    
}

#Preview {
    PresetDrinksView()
}
