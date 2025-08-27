//
//  TitleSelectionStepView.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 5.08.2025.
//

import SwiftUI

struct TitleSelectionStepView: View {
    @ObservedObject var coordinator: OnboardingCoordinator
    let theme: Theme
    @State private var showTitlePicker = false

    var body: some View {
        VStack(spacing: 40) {
            Spacer()

            // Header
            VStack(spacing: 16) {
                Text("chooseYourTitle".localized)
                    .font(.appFont(size: 32, weight: .bold))
                    .foregroundColor(theme.textColor)

                Text("selectTitleDescription".localized)
                    .font(.appFont(size: 16))
                    .foregroundColor(theme.textColor.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }

            // Title selection
            VStack(spacing: 16) {
                // Current title display
                VStack(spacing: 8) {
                    HStack {
                        Group {
                            if coordinator.selectedTitle.icon.hasPrefix("icon_") {
                                Image(coordinator.selectedTitle.icon)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 20, height: 20)
                                    .foregroundColor(theme.accentColor)
                            } else {
                                Image(systemName: coordinator.selectedTitle.icon)
                                    .font(.system(size: 20))
                                    .foregroundColor(theme.accentColor)
                            }
                        }
                        
                        Text(coordinator.selectedTitle.displayName)
                            .font(.appFont(size: 20, weight: .bold))
                            .foregroundColor(theme.textColor)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(theme.cardBackgroundColor)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(theme.accentColor.opacity(0.3), lineWidth: 2)
                            )
                    )
                    
                    Text(coordinator.selectedTitle.description)
                        .font(.appFont(size: 14))
                        .foregroundColor(theme.textColor.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }

                // Title picker button
                Button(action: {
                    showTitlePicker = true
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "chevron.down")
                            .font(.system(size: 16))
                        Text("selectDifferentTitle".localized)
                            .font(.appFont(size: 16, weight: .medium))
                    }
                    .foregroundColor(theme.textColor)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .fill(theme.accentColor.opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: 25)
                                    .stroke(theme.accentColor.opacity(0.3), lineWidth: 1)
                            )
                    )
                }

                // Random title button
                Button(action: {
                    coordinator.selectedTitle = CharacterTitleManager.shared.getRandomTitle()
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "dice.fill")
                            .font(.system(size: 16))
                        Text("randomTitle".localized)
                            .font(.appFont(size: 16, weight: .medium))
                    }
                    .foregroundColor(theme.textColor)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .fill(theme.accentColor.opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: 25)
                                    .stroke(theme.accentColor.opacity(0.3), lineWidth: 1)
                            )
                    )
                }
            }
            .padding(.horizontal, 20)

            Spacer()
        }
        .padding(.horizontal, 20)
        .sheet(isPresented: $showTitlePicker) {
            TitlePickerView(coordinator: coordinator, theme: theme)
        }
    }
}

// MARK: - Title Picker View

struct TitlePickerView: View {
    @ObservedObject var coordinator: OnboardingCoordinator
    let theme: Theme
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 12) {
                    Text("chooseYourTitle".localized)
                        .font(.appFont(size: 24, weight: .bold))
                        .foregroundColor(theme.textColor)
                    
                    Text("chooseFromAvailableTitles".localized)
                        .font(.appFont(size: 16))
                        .foregroundColor(theme.textColor.opacity(0.7))
                }
                .padding(.top, 20)
                .padding(.horizontal, 20)

                // Title list
                ScrollView {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2), spacing: 12) {
                        ForEach(CharacterTitle.allCases, id: \.self) { title in
                            TitleCardView(
                                title: title,
                                isSelected: coordinator.selectedTitle == title,
                                theme: theme
                            ) {
                                coordinator.selectedTitle = title
                                dismiss()
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
            }
            .background(theme.backgroundColor)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("cancel".localized) {
                        dismiss()
                    }
                    .foregroundColor(theme.accentColor)
                }
            }
        }
    }
}

// MARK: - Title Card View

struct TitleCardView: View {
    let title: CharacterTitle
    let isSelected: Bool
    let theme: Theme
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 12) {
                // Icon
                Group {
                    if title.icon.hasPrefix("icon_") {
                        Image(title.icon)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                            .foregroundColor(isSelected ? .white : theme.accentColor)
                    } else {
                        Image(systemName: title.icon)
                            .font(.system(size: 24))
                            .foregroundColor(isSelected ? .white : theme.accentColor)
                    }
                }
                .frame(width: 50, height: 50)
                .background(
                    Circle()
                        .fill(isSelected ? theme.accentColor : theme.accentColor.opacity(0.1))
                )

                // Title name
                Text(title.displayName)
                    .font(.appFont(size: 16, weight: .bold))
                    .foregroundColor(isSelected ? .white : theme.textColor)
                    .multilineTextAlignment(.center)

                // Description
                Text(title.description)
                    .font(.appFont(size: 12))
                    .foregroundColor(isSelected ? .white.opacity(0.8) : theme.textColor.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
            }
            .padding(16)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? theme.accentColor : theme.cardBackgroundColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? theme.accentColor : theme.borderColor.opacity(0.3), lineWidth: isSelected ? 2 : 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}
