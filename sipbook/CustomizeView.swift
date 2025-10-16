//
//  CustomizeView.swift
//  sipbook
//
//  Created on 10/6/25.
//

import SwiftUI

struct CustomizeView: View {
    let preset: PresetDrink
    
    // CUSTOMIZING PAGE
    var body: some View {
        ZStack {
            Color(hex: "#282728")
                .ignoresSafeArea()
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
