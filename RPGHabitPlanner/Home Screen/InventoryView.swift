//
//  InventoryView.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 5.08.2025.
//

import SwiftUI

struct InventoryView: View {
    @EnvironmentObject var themeManager: ThemeManager
    
    // Example items (just icons)
    let items: [String] = [
        "icon_viking_helmet", "icon_shield", "icon_key", "icon_potion_blue", "icon_potion_blue",
        "icon_potion_red", "icon_potion_red", "icon_potion_red", "icon_potion_red", "icon_potion_blue",
        "icon_key", "icon_sword", "icon_sword"
    ]
    
    let columns: [GridItem] = Array(repeating: GridItem(.flexible(), spacing: 6), count: 6)
    
    var body: some View {
        let theme = themeManager.activeTheme
        
        ZStack {
            theme.backgroundColor
                .ignoresSafeArea()
            
            VStack(spacing: 10) {
                Text("Inventory")
                    .font(.appFont(size: 22, weight: .black))
                    .foregroundColor(.white)
                    .padding(.vertical, 6)
                    .padding(.horizontal, 14)
                    .background(RoundedRectangle(cornerRadius: 6).fill(Color.purple.opacity(0.8)))
                
                LazyVGrid(columns: columns, spacing: 6) {
                    ForEach(0..<18, id: \.self) { index in
                        InventorySlotView(
                            iconName: index < items.count ? items[index] : nil
                        )
                    }
                }
                .padding(10)
                .background(RoundedRectangle(cornerRadius: 10).fill(Color.purple.opacity(0.6)))
            }
            .padding()
        }
        .navigationTitle("Inventory")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct InventorySlotView: View {
    let iconName: String?
    
    var body: some View {
        ZStack {
            // Slot background
            RoundedRectangle(cornerRadius: 4)
                .strokeBorder(Color.white.opacity(0.4), lineWidth: 1.5)
                .background(RoundedRectangle(cornerRadius: 4).fill(Color.purple.opacity(0.3)))
                .aspectRatio(1, contentMode: .fit) // Makes it square
            
            if let iconName = iconName {
                Image(iconName)
                    .resizable()
                    .scaledToFit()
                    .padding(6)
            }
        }
    }
}
