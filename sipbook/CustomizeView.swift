//
//  CustomizeView.swift
//  sipbook
//
//  Created on 10/6/25.
//
//  Show this view when the user selects a preset drink
//  Show original recipe from Cocktail API

import SwiftUI
import SwiftData

// add enums for pickers
enum Spirit: String, CaseIterable, Identifiable {
    case vodka = "Vodka"
    case gin = "Gin"
    case rum = "Rum"
    case tequila = "Tequila"
    case whiskey = "Whiskey"
    var id: String {rawValue}
    var label: String {rawValue}
}

// NABase = non-alcoholic base
enum NABase: String, CaseIterable, Identifiable {
    case sodaWater = "Soda Water"
    case tonic = "Tonic"
    case gingerBeer = "Ginger Beer"
    case lemonade = "Lemonade"
    case icedTea = "Iced Tea"
    case juice = "Juice"
    var id: String {rawValue}
    var label: String {rawValue}
}

enum Rim: String, CaseIterable, Identifiable {
    case none = "None"
    case salt = "Salt Rim"
    case sugar = "Sugar Rim"
    case tajin = "Tajin Rim"
    var id: String {rawValue}
    var label: String {rawValue}
}

// MAIN VIEW
struct CustomizeView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let preset: PresetDrink
    
    // for API data
    @State private var ingredients: [String] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    @State private var customName: String = ""
    @State private var notes: String = ""
    @State private var showSaveAlert = false
    @State private var alertMessage = ""
    
    // number of shots and base
    @State private var shots: Int = 1
    @State private var spiritOptions: [String] = [
        "Vodka", "Gin", "Rum", "Tequila", "Whiskey"
    ]
    //@State private var spiritChoice: String = "Tequila"
    @State private var naBaseOptions: [String] = [
        "Soda Water", "Tonic", "Ginger Beer", "Lemonade", "Iced Tea", "Juice"
    ]
    //@State private var naBaseChoice: String = "Soda Water"
    
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
    
    @State private var selectedSpirits: Set<String> = []
    // counting shots per spirit chosen
    @State private var shotsPerSpirit: [String : Int] = [:]
    @State private var selectedBases: Set<String> = []
    // counting parts per item (mixer, liquer, NA base) chosen
    @State private var partsPerBase: [String: Int] = [:]
    @State private var partsPerMixer: [String: Int] = [:]
    @State private var partsPerLiqueur: [String: Int] = [:]
    @State private var selectedMixers: Set<String> = []
    @State private var selectedLiqueurs: Set<String> = []
    @State private var selectedGarnishes: Set<String> = []
    
    // single picker for rim
    @State private var rim: Rim = .none

    
    // CUSTOMIZING PAGE
    var body: some View {
        ZStack {
            Color(hex: "#282728")
                .ignoresSafeArea()
            
            Form {
                // separated sections by private extensions
                nameSection
                originalRecipeSection
                baseSection
                mixersSection
                if preset.kind == .cocktail {
                    liqueursSection
                }
                rimGarnishSection
                notesSection
                
                
                // section to add save button at bottom of form
                Section {
                    HStack {
                        Spacer()
                        Button {
                            saveDrink()
                        } label: {
                            Label("Save", systemImage: "plus.circle.fill")
                                .frame(maxWidth: .infinity, alignment: .center)
                                .font(.headline)
                                .foregroundColor(Color(hex: "#0D0E10"))
                        }
                        Spacer()
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(.clear)
            // tracks changes in item selections
            .onChange(of: selectedSpirits, initial: false) { oldValue, newValue in syncShotsWithSelection()
            }
            .onChange(of: selectedBases, initial: false) { oldValue, newValue in syncPartsWithBase()
            }
            .onChange(of: selectedMixers, initial: false) { oldValue, newValue in syncPartsWithMixer()
            }
            .onChange(of: selectedLiqueurs, initial: false) { oldValue, newValue in syncPartsWithLiqueur()
            }
        }
        .navigationTitle(preset.name)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await loadOnce()
            syncShotsWithSelection()
            syncPartsWithBase()
            syncPartsWithMixer()
            syncPartsWithLiqueur()
        }
        // set up alert pop up when drink is saved
        .alert("Save Drink", isPresented: $showSaveAlert) {
            Button("OK") {
                // bring user back to preset drink page after saving
                dismiss()
            }
        } message: {
            Text(alertMessage)
        }
    }
}


// split sections for fast type-checking
private extension CustomizeView {
    
    var nameSection: some View {
        Section {
            TextField("Drink name", text: $customName)
                .font(.system(size: 25, weight: .bold, design: .rounded))
                .foregroundColor(Color(hex: "#0D0E10"))
                .textInputAutocapitalization(.words)
        }
    }
    
    var originalRecipeSection: some View {
        Section {
                // check if API is loading data for cocktail or mocktail
                if preset.kind != .cocktail {
                    Text("Mocktail selected - skipping API")
                        .foregroundStyle(.secondary)
                } else if isLoading {
                    ProgressView("Loading...")
                } else if let err = errorMessage {
                    Text("Error: \(err)")
                        .foregroundColor(.red)
                } else if ingredients.isEmpty {
                    Text("No data yet")
                        .foregroundColor(.white)
                } else {
                    Text("Original Ingredients:")
                        .font(.subheadline).bold()
                        .foregroundColor(Color(hex: "#0D0E10"))
                    Text(ingredients.joined(separator: "\n"))
                        .font(.system(.body))
                        .foregroundColor(Color(hex: "#0D0E10"))
                }
            }
    }
    
    var baseSection: some View {
        // BASE SECTION
        Section(header: Text("Base")
            .foregroundColor(Color(hex: "#F8FAFA"))) {
                if preset.kind == .cocktail {
                    AddablePicker(
                        title: "Spirit",
                        selections: $selectedSpirits,
                        options: $spiritOptions
                    )
                    .foregroundStyle(.black)
                    // one stepper per selected spirit
                    ForEach(selectedSpirits.sorted(), id: \.self) { spirit in
                        Stepper("Shots of \(spirit): \(shotsPerSpirit[spirit, default: 1])", value: bindingForSpiritShots(spirit), in: 0...10)
                    }
                    .foregroundStyle(Color(hex: "#0D0E10"))
                } else {
                    AddablePicker(
                        title: "Non-Alcoholic Base",
                        selections: $selectedBases,
                        options: $naBaseOptions
                    )
                    .foregroundStyle(Color(hex: "#0D0E10"))
                    // one stepper per selected NA base
                    ForEach(selectedBases.sorted(), id: \.self) {
                        base in
                        Stepper("Parts of \(base): \(partsPerBase[base, default: 1])", value: bindingForBaseParts(base), in: 0...10)
                    }
                }
            }
    }
    
    var mixersSection: some View {
        // MIXERS SECTION
        Section(header: Text("Mixers")
            .foregroundColor(Color(hex: "#F8FAFA"))) {
                AddablePicker(
                    title: "Mixers",
                    selections: $selectedMixers,
                    options: $mixerOptions
                )
                .foregroundStyle(Color(hex: "#0D0E10"))
                // one stepper per selected mixer
                ForEach(selectedMixers.sorted(), id: \.self) {
                    mixer in
                    Stepper("Parts of \(mixer): \(partsPerMixer[mixer, default: 1])", value: bindingForMixerParts(mixer), in: 0...10)
                }
            }
    }
    
    var liqueursSection: some View {
        // LIQUEURS SECTION (show for cocktails only)
        Section(header: Text("Liqueurs")
            .foregroundColor(Color(hex: "#F8FAFA"))) {
                AddablePicker(
                    title: "Liqueurs",
                    selections: $selectedLiqueurs,
                    options: $liqueurOptions
                )
                .foregroundStyle(Color(hex: "#0D0E10"))
                // one stepper per selected liqueur
                ForEach(selectedLiqueurs.sorted(), id: \.self) {
                    liqueur in
                    Stepper("Parts of \(liqueur): \(partsPerLiqueur[liqueur, default: 1])", value: bindingForLiqueurParts(liqueur), in: 0...10)
                }
        }
    }
            
    
    var rimGarnishSection: some View {
        // RIMS and GARNISHES SECTION
        Section(header: Text("Rim & Garnish")
            .foregroundColor(Color(hex: "#F8FAFA"))) {
                Picker("Rim", selection: $rim) {
                    ForEach(Rim.allCases) { r in
                        Text(r.rawValue).tag(r)
                    }
                }
                AddablePicker(
                    title: "Garnishes",
                    selections: $selectedGarnishes,
                    options: $garnishOptions
                )
                .foregroundStyle(Color(hex: "#0D0E10"))
            }
    }
    
    var notesSection: some View {
        // NOTES SECTION
        Section(header: Text("Notes")
            .foregroundColor(Color(hex: "#F8FAFA"))) {
                VStack {
                    TextField("Additional notes", text: $notes, axis: .vertical)
                }
        }
    }
    
}


// HELPER FUNCTIONS
private extension CustomizeView {
    
    // functions to bind selected item names to shot/part counter
    func bindingForSpiritShots(_ spirit: String) -> Binding<Int> {
        Binding(
            get: { shotsPerSpirit[spirit] ?? 1 },
            set: { newVal in shotsPerSpirit[spirit] = newVal }
        )
    }

    func bindingForBaseParts(_ base: String) -> Binding<Int> {
        Binding(
            get: { partsPerBase[base] ?? 1 },
            set: { newVal in partsPerBase[base] = newVal }
        )
    }

    func bindingForMixerParts(_ mixer: String) -> Binding<Int> {
        Binding(
            get: { partsPerMixer[mixer] ?? 1 },
            set: { newVal in partsPerMixer[mixer] = newVal }
        )
    }
    
    func bindingForLiqueurParts(_ liqueur: String) -> Binding<Int> {
        Binding(
            get: { partsPerLiqueur[liqueur] ?? 1 },
            set: { newVal in partsPerLiqueur[liqueur] = newVal }
        )
    }
    
    // function to align selected spirits with shot counters
    func syncShotsWithSelection() {
        // add defaults for selected spirits
        for s in selectedSpirits where shotsPerSpirit[s] == nil {
            shotsPerSpirit[s] = 1
        }
        // remove entries for deselected spirits
        for key in shotsPerSpirit.keys where !selectedSpirits.contains(key) {
            shotsPerSpirit.removeValue(forKey: key)
        }
    }

    // functions to align selected mixers, liqueurs, NA base with part counters
    func syncPartsWithBase() {
        // add defaults for selected bases
        for p in selectedBases where partsPerBase[p] == nil {
            partsPerBase[p] = 1
        }
        
        for key in partsPerBase.keys where !selectedBases.contains(key) {
            partsPerBase.removeValue(forKey: key)
        }
    }
    
    func syncPartsWithMixer() {
        // add defaults for selected mixers
        for p in selectedMixers where partsPerMixer[p] == nil {
            partsPerMixer[p] = 1
        }
        
        for key in partsPerMixer.keys where !selectedMixers.contains(key) {
            partsPerMixer.removeValue(forKey: key)
        }
    }
    
    func syncPartsWithLiqueur() {
        // add defaults for selected liqueurs
        for p in selectedLiqueurs where partsPerLiqueur[p] == nil {
            partsPerLiqueur[p] = 1
        }
        
        for key in partsPerLiqueur.keys where !selectedLiqueurs.contains(key) {
            partsPerLiqueur.removeValue(forKey: key)
        }
    }
    
    // function to save customized drink
    func saveDrink () {
        // validate custom name
        let finalName = customName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            ? preset.name
            : customName
        
        // create model from current UI state
        let drink = SavedDrink(
            name: finalName,
            kindRaw: preset.kind.rawValue,  // string value
            notes: notes,
            spirits: Array(selectedSpirits.sorted()),
            shotsPerSpirit: shotsPerSpirit,
            naBases: Array(selectedBases.sorted()),
            partsPerBase: partsPerBase,
            mixers: Array(selectedMixers.sorted()),
            partsPerMixer: partsPerMixer,
            liqueurs: Array(selectedLiqueurs.sorted()),
            partsPerLiqueur: partsPerLiqueur,
            rim: rim.rawValue,  // string value
            garnishes: Array(selectedGarnishes.sorted()),
            createdAt: Date(),
            updatedAt: Date()
        )
        
        modelContext.insert(drink)
        do {
            try modelContext.save()
            alertMessage = "Your custom drink \"\(finalName)\" was saved!"
            showSaveAlert = true
        } catch {
            alertMessage = "Failed to save: \(error.localizedDescription)"
            showSaveAlert = true
        }
    }
    
    // function for loading data from Cocktail API
    func loadOnce() async {
        // only fetch data for cocktails
        guard preset.kind == .cocktail else {
            errorMessage = "Skipping API (mocktail)"
            return
        }
        // don't refetch if already loaded
        guard !isLoading && ingredients.isEmpty else { return }

        isLoading = true
        defer { isLoading = false }
        errorMessage = nil

        do {
            let results = try await CocktailService.shared.searchByName(preset.name)
    
            // try exact name match first or take first result
            let best = results.first {
                $0.name.compare(preset.name, options: .caseInsensitive) == .orderedSame
            } ?? results.first
    
            if let best {
                ingredients = best.ingredients
        
                // print to console for debugging
                //print("API OK for \(preset.name)")
                //print("Ingredients:", best.ingredients)
            } else {
                errorMessage = "No recipe found from API"
            }
        } catch {
            errorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
            //print("API error:", errorMessage ?? "")
        }
    }
}

// reusable mock for previews
extension PresetDrink {
    static let preview = PresetDrink(name: "Margarita", kind: .cocktail)
}

#Preview {
    CustomizeView(preset: .preview)
}
