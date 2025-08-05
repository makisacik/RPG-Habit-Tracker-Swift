//
//  InventoryView.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 5.08.2025.
//

import SwiftUI

struct InventoryView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @State private var items: [ItemEntity] = []
    @State private var selectedItem: ItemEntity?
    
    private let columns: [GridItem] = Array(repeating: GridItem(.flexible(), spacing: 6), count: 6)
    
    var body: some View {
        let theme = themeManager.activeTheme
        
        ZStack {
            theme.backgroundColor
                .ignoresSafeArea()
                .onTapGesture {
                    selectedItem = nil
                }
            
            VStack(spacing: 10) {
                Text("Inventory")
                    .font(.appFont(size: 22, weight: .black))
                    .foregroundColor(.white)
                    .padding(.vertical, 6)
                    .padding(.horizontal, 14)
                    .background(RoundedRectangle(cornerRadius: 6).fill(Color.purple.opacity(0.8)))
                
                LazyVGrid(columns: columns, spacing: 6) {
                    ForEach(0..<18, id: \.self) { index in
                        let item = index < items.count ? items[index] : nil
                        InventorySlotView(iconName: item?.iconName)
                            .onTapGesture {
                                if let item = item {
                                    withAnimation(.easeInOut) {
                                        selectedItem = item
                                    }
                                } else {
                                    selectedItem = nil
                                }
                            }
                            .overlay(
                                infoBubble(for: item)
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
        .onAppear {
            items = InventoryManager.shared.fetchInventory()
        }
    }
    
    @ViewBuilder
    private func infoBubble(for item: ItemEntity?) -> some View {
        if let selectedItem = selectedItem,
           let current = item,
           current == selectedItem {
            VStack(alignment: .center, spacing: 4) {
                Text(current.name ?? "Unknown")
                    .font(.appFont(size: 14, weight: .black))
                    .foregroundColor(.brown)
                    .multilineTextAlignment(.center)

                Text(current.info ?? "")
                    .font(.appFont(size: 12))
                    .foregroundColor(.brown.opacity(0.9))
                    .multilineTextAlignment(.center)
            }
            .padding(10)
            .frame(minWidth: 120, maxWidth: 180)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.yellow.opacity(0.9))
                    .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
            )
            .fixedSize(horizontal: false, vertical: true)
            .offset(y: -70)
            .transition(.scale.combined(with: .opacity))
        }
    }
}

struct InventorySlotView: View {
    let iconName: String?
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 4)
                .strokeBorder(Color.white.opacity(0.4), lineWidth: 1.5)
                .background(RoundedRectangle(cornerRadius: 4).fill(Color.purple.opacity(0.3)))
                .aspectRatio(1, contentMode: .fit)
            
            if let iconName = iconName {
                Image(iconName)
                    .resizable()
                    .scaledToFit()
                    .padding(6)
            }
        }
    }
}
