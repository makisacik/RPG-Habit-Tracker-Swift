//
//  CustomizationComponents.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 7.01.2025.
//

import SwiftUI

// MARK: - Progress View

struct CustomizationProgressView: View {
    let currentStep: Int
    let totalSteps: Int
    let theme: Theme

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Step \(currentStep + 1) of \(totalSteps + 1)")
                    .font(.appFont(size: 14, weight: .medium))
                    .foregroundColor(theme.textColor.opacity(0.7))

                Spacer()
            }

            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(theme.textColor.opacity(0.2))
                        .frame(height: 8)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(theme.accentColor)
                        .frame(width: geometry.size.width * CGFloat(currentStep + 1) / CGFloat(totalSteps + 1), height: 8)
                        .animation(.easeInOut(duration: 0.3), value: currentStep)
                }
            }
            .frame(height: 8)
        }
    }
}

// MARK: - Step View

struct CustomizationStepView: View {
    let step: CustomizationStep
    let selectedCustomization: CharacterCustomization
    let onSelectionChanged: (CharacterCustomization) -> Void
    let theme: Theme

    private let assetManager = CharacterAssetManager.shared

    var body: some View {
        VStack(spacing: 20) {
            // Step title
            Text(step.title)
                .font(.appFont(size: 24, weight: .bold))
                .foregroundColor(theme.textColor)
                .multilineTextAlignment(.center)

            // Character preview
            CharacterFullPreview(
                customization: selectedCustomization,
                size: 150
            )

            // Options grid
            CustomizationOptionsGrid(
                step: step,
                selectedCustomization: selectedCustomization,
                onSelectionChanged: onSelectionChanged,
                theme: theme
            )
        }
    }
}


// MARK: - Options Grid

struct CustomizationOptionsGrid: View {
    let step: CustomizationStep
    let selectedCustomization: CharacterCustomization
    let onSelectionChanged: (CharacterCustomization) -> Void
    let theme: Theme

    private let assetManager = CharacterAssetManager.shared

    var body: some View {
        let options = getOptionsForStep()

        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3), spacing: 12) {
            ForEach(options, id: \.id) { option in
                CustomizationOptionCard(
                    option: option,
                    isSelected: isOptionSelected(option),
                    onTap: {
                        selectOption(option)
                    },
                    theme: theme
                )
            }
        }
    }

    private func getOptionsForStep() -> [CustomizationOption] {
        let allAssets = assetManager.getAvailableAssets(for: step.category)

        return allAssets.map { asset in
            CustomizationOption(
                id: asset.id,
                name: asset.name,
                imageName: asset.imageName,
                previewImage: asset.previewImage,
                isPremium: asset.category.isGearCategory && asset.rarity != AssetRarity.common,
                isUnlocked: asset.isUnlocked
            )
        }
    }

    private func isOptionSelected(_ option: CustomizationOption) -> Bool {
        return getSelectedValue(for: step.category) == option.id
    }

    private func getSelectedValue(for category: AssetCategory) -> String? {
        return selectedCustomization.getValue(for: category)
    }

    private func selectOption(_ option: CustomizationOption) {
        var updatedCustomization = selectedCustomization
        updateCustomizationForCategory(&updatedCustomization, option: option)
        onSelectionChanged(updatedCustomization)
    }

    private func updateCustomizationForCategory(_ customization: inout CharacterCustomization, option: CustomizationOption) {
        customization.setValue(option.id, for: step.category)
    }
}

// MARK: - Option Card

struct CustomizationOptionCard: View {
    let option: CustomizationOption
    let isSelected: Bool
    let onTap: () -> Void
    let theme: Theme

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                // Option image
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(theme.cardBackgroundColor)
                        .frame(width: 80, height: 80)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(isSelected ? theme.accentColor : theme.borderColor.opacity(0.3), lineWidth: isSelected ? 3 : 1)
                        )
                        .shadow(color: theme.shadowColor, radius: 4, x: 0, y: 2)

                    if !option.previewImage.isEmpty {
                        Image(option.previewImage)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 50)
                    } else {
                        Image(systemName: "person.fill")
                            .font(.system(size: 30))
                            .foregroundColor(theme.textColor.opacity(0.5))
                    }

                    // Premium indicator
                    if option.isPremium {
                        VStack {
                            HStack {
                                Spacer()
                                Image(systemName: "crown.fill")
                                    .font(.system(size: 12))
                                    .foregroundColor(.yellow)
                                    .padding(4)
                                    .background(Circle().fill(.black.opacity(0.7)))
                            }
                            Spacer()
                        }
                    }
                }

                // Option name
                Text(option.name)
                    .font(.appFont(size: 12, weight: .medium))
                    .foregroundColor(theme.textColor)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .opacity(option.isUnlocked ? 1.0 : 0.5)
    }
}

// MARK: - Navigation Buttons

struct CustomizationNavigationButtons: View {
    let canGoBack: Bool
    let canGoForward: Bool
    let onBack: () -> Void
    let onForward: () -> Void
    let theme: Theme

    var body: some View {
        HStack {
            // Back button
            if canGoBack {
                Button(action: onBack) {
                    HStack(spacing: 8) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .medium))
                        Text("Back")
                            .font(.appFont(size: 16, weight: .medium))
                    }
                    .foregroundColor(theme.textColor)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .fill(theme.primaryColor.opacity(0.8))
                    )
                }
            }

            Spacer()

            // Next button
            Button(action: onForward) {
                HStack(spacing: 8) {
                    Text("Next")
                        .font(.appFont(size: 16, weight: .medium))
                    Image(systemName: "chevron.right")
                        .font(.system(size: 16, weight: .medium))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 25)
                        .fill(canGoForward ? theme.accentColor : theme.accentColor.opacity(0.5))
                )
            }
            .disabled(!canGoForward)
        }
    }
}

// MARK: - Customization Option Model

struct CustomizationOption {
    let id: String
    let name: String
    let imageName: String
    let previewImage: String
    let isPremium: Bool
    let isUnlocked: Bool

    init(id: String, name: String, imageName: String, previewImage: String? = nil, isPremium: Bool, isUnlocked: Bool) {
        self.id = id
        self.name = name
        self.imageName = imageName
        self.previewImage = previewImage ?? "\(imageName)_preview"
        self.isPremium = isPremium
        self.isUnlocked = isUnlocked
    }
}
