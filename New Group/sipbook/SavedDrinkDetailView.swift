//
//  SavedDrinkDetailView.swift
//  sipbook
//
//  Created by Christine Bonoan on 10/19/25.
//
//  In this view, user can read and (optionally) edit their creations

import SwiftUI
import SwiftData

struct SavedDrinkDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var isEditing = false
    
    // bind drink from SwiftData model
    @Bindable var drink: SavedDrink
    
    // options that match CustomizeView
    @State private var spiritOptions: [String] = [
        "Vodka", "Gin", "Rum", "Tequila", "Whiskey"
    ]
    @State private var naBaseOptions: [String] = [
        "Soda Water", "Tonic", "Ginger Beer", "Lemonade", "Iced Tea", "Juice"
    ]
    // mixers, liqueurs, garnishes
    @State private var mixerOptions: [String] = [
        "Lime Juice", "Lemon Juice", "Simple Syrup", "Pineapple", "Orange", "Cranberry"
    ]
    @State private var liqueurOptions: [String] = [
        "Triple Sec", "Aperol", "Amaretto", "Midori", "Peach Schnapps", "Coffee Liqueur"
    ]
    @State private var garnishOptions: [String] = [
        "Lime", "Lemon Twist", "Lime/Lemon Wedge", "Orange Peel", "Mint", "Cherry"
    ]
    
    // enum for rim (SwiftData model stores it as String)
    enum Rim: String, CaseIterable, Identifiable {
        case none = "None"
        case salt = "Salt Rim"
        case sugar = "Sugar Rim"
        case tajin = "Tajin Rim"
        var id: String {rawValue}
    }
    
    var isCocktail: Bool {
        drink.kindRaw.lowercased() == "cocktail"
    }
    
    
    var body: some View {
        ZStack {
            Color(hex: "#282728")
                .ignoresSafeArea()
            Form {
                basicsSection
                baseSection
                mixersSection
                if isCocktail {
                    liqueursSection
                }
                rimGarnishSection
                notesSection
                
                // only show save button in edit mode
                if isEditing {
                    Section {
                        Button {
                            saveChanges()
                            isEditing = false
                        } label: {
                            Label("Save Changes", systemImage: "tray.and.arrow.down.fill")
                                .frame(maxWidth: .infinity, alignment: .center)
                                .font(.headline)
                                .foregroundColor(Color(hex: "#0D0E10"))
                        }
                        .buttonStyle(.borderless)
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(.clear)
            .navigationTitle(drink.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    // toggle between edit and view mode
                    Button(isEditing ? "Done" : "Edit") {
                        isEditing.toggle()
                        if !isEditing {
                            // should autosave if you leave edit mode with "Done"
                            saveChanges()
                        }
                    }
                }
            }
            // sync shots and parts count dictionaries immediately as they are changed by user
            .onChange(of: drink.spirits, initial: false) { oldValue, newValue in syncShotsWithSelection()
            }
            .onChange(of: drink.naBases, initial: false) { oldValue, newValue in syncPartsWithBase()
            }
            .onChange(of: drink.mixers, initial: false) { oldValue, newValue in syncPartsWithMixer()
            }
            .onChange(of: drink.liqueurs, initial: false) { oldValue, newValue in syncPartsWithLiqueur()
            }
            .onAppear {
                // have valid defaulys when the view opens
                syncShotsWithSelection()
                syncPartsWithBase()
                syncPartsWithMixer()
                syncPartsWithLiqueur()
            }
        }
    }
}

// separated for type-check restraints
private extension SavedDrinkDetailView {
    var basicsSection: some View {
        Section {
            if isEditing {
                TextField("Name", text: $drink.name)
                    .textInputAutocapitalization(.words)
                    .font(.system(size: 25, weight: .bold, design: .rounded))
                    .foregroundColor(Color(hex: "#0D0E10"))
            } else {
                Text(drink.name).font(.headline)
            }
        }
    }
    
    // binding data from original creation to edit creation page
    // BASE/NA-BASE SECTION
    var baseSection: some View {
        Section(header: Text("Base")
            .foregroundColor(Color(hex: "#F8FAFA")))  {
            if isEditing {
                if isCocktail {
                    AddablePicker(
                        title: "Spirits",
                        selections: Binding(
                            get: { Set(drink.spirits) },
                            set: { drink.spirits = Array($0).sorted() }
                        ),
                        options: $spiritOptions
                    )
                    .foregroundColor(Color(hex: "#0D0E10"))
                } else {
                    AddablePicker(
                        title: "Base",
                        selections: Binding(
                            get: { Set(drink.naBases) },
                            set: { drink.naBases = Array($0).sorted() }
                        ),
                        options: $naBaseOptions
                    )
                    .foregroundColor(Color(hex: "#0D0E10"))
                }
            } else {
                if isCocktail, !drink.spirits.isEmpty {
                    Text("Spirits: " + drink.spirits.joined(separator: ", "))
                        .foregroundColor(Color(hex: "#0D0E10"))
                } else if !isCocktail, !drink.naBases.isEmpty {
                    Text("Bases: " + drink.naBases.joined(separator: ", "))
                        .foregroundColor(Color(hex: "#0D0E10"))
                } else {
                    Text("No base ingredients")
                        .foregroundStyle(.secondary)
                        .foregroundColor(Color(hex: "#0D0E10"))
                }
            }
            
            // per ingredient counter (shots or parts)
            if isCocktail {
                ForEach(drink.spirits.sorted(), id: \.self) {
                    spirit in
                    Stepper("Shots of \(spirit): \(drink.shotsPerSpirit[spirit, default: 1])",
                            value: bindingForSpiritShots(spirit), in: 0...10
                    )
                    .disabled(!isEditing)
                }
            } else {
                ForEach(drink.naBases.sorted(), id: \.self) {
                    base in
                    Stepper("Parts of \(base): \(drink.partsPerBase[base, default: 1])",
                            value: bindingForBaseParts(base), in: 0...10
                    )
                    .disabled(!isEditing)
                }
            }
        }
    }
    
    // MIXERS SECTION
    var mixersSection: some View {
        Section(header: Text("Mixers")
            .foregroundColor(Color(hex: "#F8FAFA")))  {
            if isEditing {
                AddablePicker(
                    title: "Mixers",
                    selections: Binding(
                        get: { Set(drink.mixers) },
                        set: { drink.mixers = Array($0).sorted() }
                    ),
                    options: $mixerOptions
                )
                .foregroundColor(Color(hex: "#0D0E10"))
            } else if !drink.mixers.isEmpty {
                Text("Mixers: " + drink.mixers.joined(separator: ", "))
                    .foregroundColor(Color(hex: "#0D0E10"))
            } else {
                Text("No mixers")
                    .foregroundStyle(.secondary)
                    .foregroundColor(Color(hex: "#0D0E10"))
            }
            
            // per ingredient counter
            ForEach(drink.mixers.sorted(), id: \.self) {
                p in
                Stepper("Parts of \(p): \(drink.partsPerMixer[p, default: 1])",
                        value: bindingForMixerParts(p), in: 0...10
                )
                .disabled(!isEditing)
            }
        }
    }
    
    // LIQUEURS SECTION
    var liqueursSection: some View {
        Section(header: Text("Liqueurs")
            .foregroundColor(Color(hex: "#F8FAFA")))  {
            if isEditing {
                AddablePicker(
                    title: "Liqueurs",
                    selections: Binding(
                        get: { Set(drink.liqueurs) },
                        set: { drink.liqueurs = Array($0).sorted() }
                    ),
                    options: $liqueurOptions
                )
                .foregroundColor(Color(hex: "#0D0E10"))
            } else if !drink.liqueurs.isEmpty {
                Text("Liqueurs: " + drink.liqueurs.joined(separator: ", "))
                    .foregroundColor(Color(hex: "#0D0E10"))
            } else {
                Text("No liqueurs")
                    .foregroundStyle(.secondary)
                    .foregroundColor(Color(hex: "#0D0E10"))
            }
            
            // per ingredient counter
            ForEach(drink.liqueurs.sorted(), id: \.self) {
                p in
                Stepper("Parts of \(p): \(drink.partsPerLiqueur[p, default: 1])",
                        value: bindingForLiqueurParts(p), in: 0...10
                )
                .disabled(!isEditing)
            }
        }
    }
    
    // RIM AND GARNISH SECTION
    var rimGarnishSection: some View {
        Section(header: Text("Rim & Garnish")
            .foregroundColor(Color(hex: "#F8FAFA")))  {
            if isEditing {
                Picker("Rim", selection: Binding (
                    get: { Rim(rawValue: drink.rim) ?? .none },
                    set: { drink.rim = $0.rawValue }
                )) {
                    ForEach(Rim.allCases) { r in Text(r.rawValue).tag(r) }
                }
                .pickerStyle(.menu)
                .foregroundColor(Color(hex: "#0D0E10"))
                
                AddablePicker(
                    title: "Garnishes",
                    selections: Binding (
                        get: { Set(drink.garnishes) },
                        set: { drink.garnishes = Array($0).sorted() }
                    ),
                    options: $garnishOptions
                )
                .foregroundColor(Color(hex: "#0D0E10"))
            } else {
                Text("Rim: \(drink.rim)")
                if !drink.garnishes.isEmpty {
                    Text("Garnishes: " + drink.garnishes.joined(separator: ", "))
                        .foregroundColor(Color(hex: "#0D0E10"))
                } else {
                    Text("No garnishes")
                        .foregroundStyle(.secondary)
                        .foregroundColor(Color(hex: "#0D0E10"))
                }
            }
        }
    }
    
    // NOTES SECTION
    var notesSection: some View {
        Section(header: Text("Notes")
            .foregroundColor(Color(hex: "#F8FAFA")))  {
            if isEditing {
                TextField("Additional notes", text: $drink.notes, axis: .vertical)
                    .foregroundColor(Color(hex: "#0D0E10"))
            } else if !drink.notes.isEmpty {
                Text(drink.notes)
                    .foregroundColor(Color(hex: "#0D0E10"))
            } else {
                Text("-")
                    .foregroundStyle(.secondary)
                    .foregroundColor(Color(hex: "#0D0E10"))
            }
        }
    }
}

private extension SavedDrinkDetailView {
    
    // helpers binded to dictionaries so steppers can update their counts
    // numbers of shots and parts default at 1 or are binded to original creation value
    func bindingForSpiritShots(_ spirit: String) -> Binding<Int> {
        Binding(
            get: { drink.shotsPerSpirit[spirit] ?? 1 },
            set: { drink.shotsPerSpirit[spirit] = $0 }
        )
    }
    
    func bindingForBaseParts(_ base: String) -> Binding<Int> {
        Binding(
            get: { drink.partsPerBase[base] ?? 1 },
            set: { drink.partsPerBase[base] = $0 }
        )
    }
    
    func bindingForMixerParts(_ mixer: String) -> Binding<Int> {
        Binding(
            get: { drink.partsPerMixer[mixer] ?? 1 },
            set: { drink.partsPerMixer[mixer] = $0 }
        )
    }
    
    func bindingForLiqueurParts(_ liqueur: String) -> Binding<Int> {
        Binding(
            get: { drink.partsPerLiqueur[liqueur] ?? 1 },
            set: { drink.partsPerLiqueur[liqueur] = $0}
        )
    }
    
    // sync helpers for syncing counters to ingredient selections
    func syncShotsWithSelection() {
        for s in drink.spirits where drink.shotsPerSpirit[s] == nil {
            drink.shotsPerSpirit[s] = 1
        }
        for k in Array(drink.shotsPerSpirit.keys) where !drink.spirits.contains(k) {
            drink.shotsPerSpirit.removeValue(forKey: k)
        }
    }
    
    func syncPartsWithBase() {
        for p in drink.naBases where drink.partsPerBase[p] == nil {
            drink.partsPerBase[p] = 1
        }
        for k in Array(drink.partsPerBase.keys) where !drink.naBases.contains(k) {
            drink.partsPerBase.removeValue(forKey: k)
        }
    }
    
    func syncPartsWithMixer() {
        for p in drink.mixers where drink.partsPerMixer[p] == nil {
            drink.partsPerMixer[p] = 1
        }
        for k in Array(drink.partsPerMixer.keys) where !drink.mixers.contains(k) {
            drink.partsPerMixer.removeValue(forKey: k)
        }
    }

    func syncPartsWithLiqueur() {
        for p in drink.liqueurs where drink.partsPerLiqueur[p] == nil {
            drink.partsPerLiqueur[p] = 1
        }
        for k in Array(drink.partsPerLiqueur.keys) where !drink.liqueurs.contains(k) {
            drink.partsPerLiqueur.removeValue(forKey: k)
        }
    }
    
    // function to save changes after editing
    func saveChanges() {
        drink.updatedAt = Date()
        do {
            try modelContext.save()
        } catch {
            print("Save failed: \(error.localizedDescription)")
        }
    }
}

