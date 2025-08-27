//
//  ItemDetailSheetComponents.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 6.08.2025.
//

import SwiftUI
import CoreData

// MARK: - Item Header View
struct ItemHeaderView: View {
    let item: ItemEntity
    let itemDefinition: Item?
    let theme: Theme

    var body: some View {
        VStack(spacing: 16) {
            // Item Icon
            ZStack {
                Circle()
                    .fill(theme.surfaceColor)
                    .frame(width: 120, height: 120)
                    .shadow(color: theme.shadowColor, radius: 8, x: 0, y: 4)

                if let previewImage = item.previewImage, !previewImage.isEmpty {
                    if UIImage(named: previewImage) != nil {
                        Image(previewImage)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                    } else if let iconName = item.iconName, !iconName.isEmpty, UIImage(named: iconName) != nil {
                        Image(iconName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                    } else {
                        Image(systemName: "questionmark.circle")
                            .font(.system(size: 60))
                            .foregroundColor(theme.textColor.opacity(0.5))
                    }
                } else if let iconName = item.iconName, !iconName.isEmpty, UIImage(named: iconName) != nil {
                    Image(iconName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                } else {
                    Image(systemName: "questionmark.circle")
                        .font(.system(size: 60))
                        .foregroundColor(theme.textColor.opacity(0.5))
                }

                // Rarity indicator
                if let rarity = getItemRarity() {
                    VStack {
                        HStack {
                            Spacer()
                            Circle()
                                .fill(rarity.uiColor)
                                .frame(width: 12, height: 12)
                                .overlay(
                                    Circle()
                                        .stroke(Color.white, lineWidth: 2)
                                )
                                .offset(x: 8, y: -8)
                        }
                        Spacer()
                    }
                }
            }

            // Item Name
            Text(item.localizedName)
                .font(.appFont(size: 24, weight: .bold))
                .foregroundColor(theme.textColor)
                .multilineTextAlignment(.center)

            // Item Type and Rarity
            HStack(spacing: 12) {
                if let definition = itemDefinition {
                    Text(definition.itemType.localizedName)
                        .font(.appFont(size: 14, weight: .medium))
                        .foregroundColor(theme.textColor)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(theme.accentColor.opacity(0.2))
                        )
                }

                if let rarity = getItemRarity() {
                    Text(rarity.rawValue.localized)
                        .font(.appFont(size: 14, weight: .medium))
                        .foregroundColor(rarity.uiColor)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(rarity.uiColor.opacity(0.2))
                        )
                }
            }
        }
    }

    private func getItemRarity() -> ItemRarity? {
        if let rarityString = item.rarity {
            return ItemRarity(rawValue: rarityString)
        }
        return itemDefinition?.rarity
    }
}

// MARK: - Compact Item Header View
struct CompactItemHeaderView: View {
    let item: Item
    let theme: Theme

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Left side: Image and Type
            VStack(spacing: 12) {
                // Item Icon
                ZStack {
                    Circle()
                        .fill(theme.surfaceColor)
                        .frame(width: 80, height: 80)
                        .shadow(color: theme.shadowColor, radius: 4, x: 0, y: 2)

                    if UIImage(named: item.previewImage) != nil {
                        Image(item.previewImage)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 50)
                    } else if UIImage(named: item.iconName) != nil {
                        Image(item.iconName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 50)
                    } else {
                        Image(systemName: "questionmark.circle")
                            .font(.system(size: 40))
                            .foregroundColor(theme.textColor.opacity(0.5))
                    }

                    // Rarity indicator
                    if let rarity = item.rarity {
                        VStack {
                            HStack {
                                Spacer()
                                Circle()
                                    .fill(rarity.uiColor)
                                    .frame(width: 10, height: 10)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.white, lineWidth: 1.5)
                                    )
                                    .offset(x: 6, y: -6)
                            }
                            Spacer()
                        }
                    }
                }

                // Item Type
                Text(item.itemType.localizedName)
                    .font(.appFont(size: 12, weight: .medium))
                    .foregroundColor(theme.textColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(theme.accentColor.opacity(0.2))
                    )
            }

            // Right side: Name, Rarity, and Description
            VStack(alignment: .leading, spacing: 8) {
                // Item Name
                Text(item.localizedName)
                    .font(.appFont(size: 20, weight: .bold))
                    .foregroundColor(theme.textColor)
                    .multilineTextAlignment(.leading)

                // Rarity
                if let rarity = item.rarity {
                    Text(rarity.rawValue.localized)
                        .font(.appFont(size: 12, weight: .medium))
                        .foregroundColor(rarity.uiColor)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(rarity.uiColor.opacity(0.2))
                        )
                }

                // Description
                Text(item.description)
                    .font(.appFont(size: 14))
                    .foregroundColor(theme.textColor.opacity(0.8))
                    .multilineTextAlignment(.leading)
                    .lineLimit(nil)
            }

            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(theme.surfaceColor.opacity(0.6))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(theme.borderColor.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

// MARK: - Item Details View
struct ItemDetailsView: View {
    let item: ItemEntity
    let theme: Theme

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("description".localized)
                .font(.appFont(size: 18, weight: .semibold))
                .foregroundColor(theme.textColor)

            Text(item.localizedDescription)
                .font(.appFont(size: 16))
                .foregroundColor(theme.textColor.opacity(0.8))
                .multilineTextAlignment(.leading)
                .lineLimit(nil)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(theme.surfaceColor.opacity(0.6))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(theme.borderColor.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

// MARK: - Item Effects View
struct ItemEffectsView: View {
    let effects: [ItemEffect]
    let theme: Theme

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("effects".localized)
                .font(.appFont(size: 18, weight: .semibold))
                .foregroundColor(theme.textColor)

            VStack(spacing: 8) {
                ForEach(effects, id: \.type) { effect in
                    HStack {
                        Image(systemName: effect.type.icon)
                            .font(.system(size: 16))
                            .foregroundColor(theme.accentColor)
                            .frame(width: 24)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(effect.type.localizedName)
                                .font(.appFont(size: 14, weight: .medium))
                                .foregroundColor(theme.textColor)

                            Text(effect.type.description)
                                .font(.appFont(size: 12))
                                .foregroundColor(theme.textColor.opacity(0.7))
                        }

                        Spacer()

                        Text(effect.displayValue)
                            .font(.appFont(size: 14, weight: .bold))
                            .foregroundColor(theme.accentColor)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(theme.surfaceColor.opacity(0.6))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(theme.borderColor.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

// MARK: - Usage Info View
struct UsageInfoView: View {
    let definition: Item
    let theme: Theme

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("usage_information".localized)
                .font(.appFont(size: 18, weight: .semibold))
                .foregroundColor(theme.textColor)

            VStack(alignment: .leading, spacing: 8) {
                if definition.itemType == .consumable {
                    HStack {
                        Image(systemName: "drop.fill")
                            .foregroundColor(.red)
                        Text("consumable_item".localized)
                            .font(.appFont(size: 14, weight: .medium))
                            .foregroundColor(theme.textColor)
                        Spacer()
                    }

                    Text("consumable_item_description".localized)
                        .font(.appFont(size: 14))
                        .foregroundColor(theme.textColor.opacity(0.7))
                } else if definition.itemType == .booster {
                    HStack {
                        Image(systemName: "bolt.fill")
                            .foregroundColor(.yellow)
                        Text("booster_item".localized)
                            .font(.appFont(size: 14, weight: .medium))
                            .foregroundColor(theme.textColor)
                        Spacer()
                    }

                    Text("booster_item_description".localized)
                        .font(.appFont(size: 14))
                        .foregroundColor(theme.textColor.opacity(0.7))
                } else if definition.itemType == .gear {
                    HStack {
                        Image("icon_shield")
                            .foregroundColor(.blue)
                        Text("equipment_item".localized)
                            .font(.appFont(size: 14, weight: .medium))
                            .foregroundColor(theme.textColor)
                        Spacer()
                    }

                    Text("equipment_item_description".localized)
                        .font(.appFont(size: 14))
                        .foregroundColor(theme.textColor.opacity(0.7))
                } else {
                    HStack {
                        Image(systemName: "star.fill")
                            .foregroundColor(.purple)
                        Text("collectible_item".localized)
                            .font(.appFont(size: 14, weight: .medium))
                            .foregroundColor(theme.textColor)
                        Spacer()
                    }

                    Text("collectible_item_description".localized)
                        .font(.appFont(size: 14))
                        .foregroundColor(theme.textColor.opacity(0.7))
                }
            }

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(theme.surfaceColor.opacity(0.6))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(theme.borderColor.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

// MARK: - Message Overlay Views
struct SuccessMessageOverlay: View {
    let theme: Theme
    let message: String

    init(theme: Theme, message: String = "item_used_successfully".localized) {
        self.theme = theme
        self.message = message
    }

    var body: some View {
        VStack {
            Spacer()
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                Text(message)
                    .font(.appFont(size: 16, weight: .medium))
                    .foregroundColor(theme.textColor)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(theme.surfaceColor)
                    .shadow(color: theme.shadowColor, radius: 8, x: 0, y: 4)
            )
            .padding()
        }
        .transition(.move(edge: .bottom).combined(with: .opacity))
        .zIndex(100)
    }
}

struct ErrorMessageOverlay: View {
    let errorMessage: String
    let theme: Theme

    var body: some View {
        VStack {
            Spacer()
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.red)
                Text(errorMessage)
                    .font(.appFont(size: 16, weight: .medium))
                    .foregroundColor(theme.textColor)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(theme.surfaceColor)
                    .shadow(color: theme.shadowColor, radius: 8, x: 0, y: 4)
            )
            .padding()
        }
        .transition(.move(edge: .bottom).combined(with: .opacity))
        .zIndex(100)
    }
}
