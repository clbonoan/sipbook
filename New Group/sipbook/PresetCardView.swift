//
//  PresetCardView.swift
//  sipbook
//
//  Created by Christine Bonoan on 10/19/25.
//
//  This is a reusable card view for the drinks' photos.

import SwiftUI

struct PresetCardView: View {
    
    let preset: PresetDrink

    var body: some View {
        VStack(spacing: 8) {
            // image slot for drink - size of box in grid changes with image size
            if let name = preset.imageName, UIImage(named: name) != nil {
                Image(name)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 100)     
                    .padding(.top, 15)
            } else {
                // placeholder keeps the same height even without an image
                Spacer().frame(height: 72)
            }

            // text slot for drink
            Text(preset.name)
                .font(.headline)
                .foregroundColor(Color(hex: "#F8FAFA"))
                .multilineTextAlignment(.center)
                .lineLimit(2)
                // fit to scale text within grid
                .minimumScaleFactor(0.5)
                .frame(height: 38)         // enough for up to 2 lines
                .padding(.horizontal, 8)

            // space underneath text
            Spacer(minLength: 0)
        }
        
        // image/card
        .frame(maxWidth: .infinity, minHeight: 140) // every tile same size
        .background(Color.white.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .contentShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

}
