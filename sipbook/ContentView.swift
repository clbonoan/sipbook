//
//  ContentView.swift
//  sipbook
//
//  Created on 9/30/25.
//

import SwiftUI
import SwiftData

// to use hex codes for colors
extension Color {
    init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)

        let r, g, b, a: Double
        switch hexSanitized.count {
        case 6: // RGB (no alpha)
            (r, g, b, a) = (
                Double((rgb >> 16) & 0xFF) / 255,
                Double((rgb >> 8) & 0xFF) / 255,
                Double(rgb & 0xFF) / 255,
                1.0
            )
        case 8: // RGBA
            (r, g, b, a) = (
                Double((rgb >> 24) & 0xFF) / 255,
                Double((rgb >> 16) & 0xFF) / 255,
                Double((rgb >> 8) & 0xFF) / 255,
                Double(rgb & 0xFF) / 255
            )
        default:
            (r, g, b, a) = (1, 1, 1, 1) // fallback white
        }

        self.init(.sRGB, red: r, green: g, blue: b, opacity: a)
    }
}

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]

    // TITLE PAGE
    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "#282728")
                    .ignoresSafeArea()
                VStack(spacing: 40) {
                    Text("Sip Book")
                        .font(.system(size: 56, weight: .bold, design: .rounded))
                        .foregroundColor(Color(hex: "#F8FAFA"))
                        .navigationBarBackButtonHidden(true)
                    NavigationLink(destination: AppTabsView()) {
                        Text("Get Started")
                            .font(.title2.bold())
                            .padding(.vertical, 14)
                            .padding(.horizontal, 20)
                            .background(Color(hex: "#F8FAFA"))
                            .foregroundColor(Color(hex: "#282728"))
                            .cornerRadius(10)
                            
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
