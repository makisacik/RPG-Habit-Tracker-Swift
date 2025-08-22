//
//  CustomizationStepView.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 7.01.2025.
//

import SwiftUI

// MARK: - Customization Step View

struct LegacyCustomizationStepView: View {
    let title: String
    let category: AssetCategory
    let selectedAsset: AssetItem?
    let availableAssets: [AssetItem]
    let onAssetSelected: (AssetItem) -> Void

    @EnvironmentObject var themeManager: ThemeManager
    @State private var selectedIndex: Int = 0

    var body: some View {
        let theme = themeManager.activeTheme

        VStack(spacing: 16) {
            // Step title
            Text(title)
                .font(.appFont(size: 20, weight: .bold))
                .foregroundColor(theme.textColor)

            // Asset preview
            AssetPreviewView(
                asset: selectedAsset ?? availableAssets.first,
                size: 120
            )

            // Asset selection carousel
            CustomizationCarousel(
                assets: availableAssets,
                selectedIndex: $selectedIndex
            ) { asset in
                    onAssetSelected(asset)
            }

            // Asset info
            if let asset = selectedAsset {
                VStack(spacing: 4) {
                    Text(asset.name)
                        .font(.appFont(size: 16, weight: .medium))
                        .foregroundColor(theme.textColor)

                    HStack {
                        RarityBadge(rarity: asset.rarity)

                        if asset.price > 0 {
                            HStack(spacing: 4) {
                                Image(systemName: "dollarsign.circle.fill")
                                    .foregroundColor(.yellow)
                                Text("\(asset.price)")
                                    .font(.appFont(size: 14))
                                    .foregroundColor(theme.textColor)
                            }
                        }
                    }
                }
            }
        }
        .onAppear {
            if let selectedAsset = selectedAsset,
               let index = availableAssets.firstIndex(of: selectedAsset) {
                selectedIndex = index
            }
        }
    }
}

// MARK: - Asset Preview View

struct AssetPreviewView: View {
    let asset: AssetItem?
    let size: CGFloat

    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        let theme = themeManager.activeTheme

        ZStack {
            // Background circle
            Circle()
                .fill(theme.primaryColor)
                .frame(width: size + 20, height: size + 20)
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)

            // Rarity glow effect
            if let asset = asset, asset.rarity != .common {
                Circle()
                    .stroke(asset.rarity.glowColor, lineWidth: 3)
                    .frame(width: size + 24, height: size + 24)
                    .blur(radius: 2)
            }

            // Asset image
            if let asset = asset, !asset.imageName.isEmpty {
                if let image = UIImage(named: asset.imageName) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: size, height: size)
                        .clipShape(Circle())
                } else {
                    Rectangle()
                        .fill(theme.backgroundColor.opacity(0.3))
                        .overlay(
                            Image(systemName: "photo")
                                .foregroundColor(theme.textColor.opacity(0.5))
                        )
                        .frame(width: size, height: size)
                        .clipShape(Circle())
                }
            } else {
                // Fallback for color-based assets (like skin/hair colors)
                Circle()
                    .fill(getAssetColor(asset))
                    .frame(width: size, height: size)
                    .overlay(
                        Circle()
                            .stroke(theme.textColor.opacity(0.2), lineWidth: 2)
                    )
            }
        }
    }

    private func getAssetColor(_ asset: AssetItem?) -> Color {
        guard let asset = asset else { return .gray }

        switch asset.category {
        case .hairColor:
            if let hairColor = HairColor(rawValue: asset.id) {
                return hairColor.color
            }
        default:
            break
        }

        return asset.rarity.color.opacity(0.3)
    }
}

// MARK: - Customization Carousel

struct CustomizationCarousel: View {
    let assets: [AssetItem]
    @Binding var selectedIndex: Int
    let onSelectionChanged: (AssetItem) -> Void

    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        let theme = themeManager.activeTheme

        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(Array(assets.enumerated()), id: \.element.id) { index, asset in
                        AssetCarouselCard(
                            asset: asset,
                            isSelected: index == selectedIndex
                        ) {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    selectedIndex = index
                                    onSelectionChanged(asset)
                                }
                        }
                        .id(index)
                    }
                }
                .padding(.horizontal)
            }
            .onChange(of: selectedIndex) { newIndex in
                withAnimation(.easeInOut(duration: 0.3)) {
                    proxy.scrollTo(newIndex, anchor: .center)
                }
            }
        }
    }
}

// MARK: - Asset Carousel Card

struct AssetCarouselCard: View {
    let asset: AssetItem
    let isSelected: Bool
    let onTap: () -> Void

    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        let theme = themeManager.activeTheme

        VStack(spacing: 8) {
            ZStack {
                // Selection indicator
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? asset.rarity.borderColor : Color.clear, lineWidth: 3)
                    .frame(width: 72, height: 72)

                // Asset preview
                AssetPreviewView(asset: asset, size: 60)
            }

            // Asset name
            Text(asset.name)
                .font(.appFont(size: 12, weight: isSelected ? .bold : .medium))
                .foregroundColor(isSelected ? theme.textColor : theme.textColor.opacity(0.7))
                .lineLimit(1)
                .frame(width: 70)
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isSelected ? asset.rarity.color.opacity(0.2) : theme.primaryColor.opacity(0.5))
                .animation(.easeInOut(duration: 0.2), value: isSelected)
        )
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
        .onTapGesture {
            onTap()
        }
    }
}

// MARK: - Rarity Badge

struct RarityBadge: View {
    let rarity: AssetRarity

    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(rarity.color)
                .frame(width: 8, height: 8)

            Text(rarity.rawValue)
                .font(.appFont(size: 12, weight: .medium))
                .foregroundColor(rarity.color)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(rarity.color.opacity(0.2))
                .overlay(
                    Capsule()
                        .stroke(rarity.borderColor, lineWidth: 1)
                )
        )
    }
}
