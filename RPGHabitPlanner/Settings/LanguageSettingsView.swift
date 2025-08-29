//
//  LanguageSettingsView.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 10.11.2024.
//

import SwiftUI

struct LanguageSettingsView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var localizationManager: LocalizationManager
    @Environment(\.dismiss) private var dismiss

    @State private var isChangingLanguage = false
    @State private var selectedLanguage: LocalizationManager.Language?

    var body: some View {
        let theme = themeManager.activeTheme

        NavigationView {
            ZStack {
                theme.backgroundColor.ignoresSafeArea()

                VStack(spacing: 20) {
                    // Header
                    VStack(spacing: 8) {
                        Text("language".localized)
                            .font(.appFont(size: 24, weight: .black))
                            .foregroundColor(theme.textColor)

                        Text("choose_your_preferred_language".localized)
                            .font(.appFont(size: 16))
                            .foregroundColor(theme.textColor.opacity(0.7))
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 20)

                    // Language Options
                    VStack(spacing: 12) {
                        ForEach(LocalizationManager.Language.allCases) { language in
                            LanguageOptionCard(
                                language: language,
                                isSelected: localizationManager.currentLanguage == language,
                                theme: theme
                            ) {
                                changeLanguage(to: language)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .disabled(isChangingLanguage)

                    Spacer()

                    // Info Text
                    VStack(spacing: 8) {
                        Text("language_changes_will_take_effect_immediately".localized)
                            .font(.appFont(size: 14))
                            .foregroundColor(theme.textColor.opacity(0.6))
                            .multilineTextAlignment(.center)

                        Text("some_system_elements_may_remain_in_previous_language".localized)
                            .font(.appFont(size: 12))
                            .foregroundColor(theme.textColor.opacity(0.5))
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }

                // Loading overlay
                if isChangingLanguage {
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.2)
                            .progressViewStyle(CircularProgressViewStyle(tint: theme.accentColor))

                        Text("updating_language".localized)
                            .font(.appFont(size: 16, weight: .medium))
                            .foregroundColor(theme.textColor)
                    }
                    .padding(24)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(theme.surfaceColor)
                            .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                    )
                }
            }
            .navigationTitle("language".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("done".localized) {
                        dismiss()
                    }
                    .font(.appFont(size: 16, weight: .black))
                    .foregroundColor(theme.textColor)
                    .disabled(isChangingLanguage)
                }
            }
        }
    }

    private func changeLanguage(to language: LocalizationManager.Language) {
        guard !isChangingLanguage else { return }

        isChangingLanguage = true
        selectedLanguage = language

        // Change the language
        localizationManager.changeLanguage(to: language)

        // Simulate a brief loading time to show the loading state
        // This gives time for the UI to update with the new language
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            isChangingLanguage = false
            selectedLanguage = nil
        }
    }
}

struct LanguageOptionCard: View {
    let language: LocalizationManager.Language
    let isSelected: Bool
    let theme: Theme
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Language Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(language.displayName)
                        .font(.appFont(size: 18, weight: .black))
                        .foregroundColor(theme.textColor)

                    Text(language.rawValue.uppercased())
                        .font(.appFont(size: 14))
                        .foregroundColor(theme.textColor.opacity(0.7))
                }

                Spacer()

                // Selection Indicator
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(theme.accentColor)
                } else {
                    Image(systemName: "circle")
                        .font(.title2)
                        .foregroundColor(theme.textColor.opacity(0.3))
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? theme.accentColor.opacity(0.1) : theme.secondaryColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? theme.accentColor : Color.clear, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}
