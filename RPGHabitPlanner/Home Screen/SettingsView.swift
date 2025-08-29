//
//  SettingsView.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 12.08.2025.
//

import SwiftUI
import StoreKit

struct SettingsView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var localizationManager: LocalizationManager
    @Environment(\.colorScheme) private var systemScheme

    @State private var isDark = false
    @State private var showLanguageSettings = false

    var body: some View {
        let theme = themeManager.activeTheme

        ZStack {
            theme.backgroundColor
                .ignoresSafeArea()

            List {
                // Section("appearance".localized) {
                //     // Light/Dark toggle
                //     Toggle(isOn: $isDark.animation(.easeInOut(duration: 0.2))) {
                //         VStack(alignment: .leading, spacing: 4) {
                //             Text("dark_mode".localized)
                //                 .font(.appFont(size: 16, weight: .semibold))
                //                 .foregroundColor(theme.textColor)
                //             Text("switch_between_light_and_dark_themes".localized)
                //                 .font(.appFont(size: 14))
                //                 .foregroundColor(theme.textColor.opacity(0.7))
                //         }
                //     }
                //     .toggleStyle(MoonSunToggleStyle(theme: theme))
                //     .onChange(of: isDark) { newValue in
                //         // Switch explicitly to light/dark
                //         themeManager.setTheme(newValue ? .dark : .light)
                //     }
                // }
                // .listRowBackground(theme.cardBackgroundColor)

                Section("general".localized) {
                    // Language Setting
                    Button {
                        showLanguageSettings = true
                    } label: {
                        HStack {
                            Label("language".localized, systemImage: "globe")
                                .font(.appFont(size: 16, weight: .medium))
                                .foregroundColor(theme.textColor)
                            Spacer()
                            Text(localizationManager.currentLanguage.displayName)
                                .font(.appFont(size: 14))
                                .foregroundColor(theme.textColor.opacity(0.7))
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(theme.textColor.opacity(0.5))
                        }
                    }
                }
                .listRowBackground(theme.cardBackgroundColor)

                #if DEBUG
                // Development features section
                Section("Development") {
                    Button {
                        addTestCurrency()
                    } label: {
                        HStack {
                            Label("Add Test Currency", systemImage: "plus.circle.fill")
                                .font(.appFont(size: 16, weight: .medium))
                                .foregroundColor(theme.warningColor)
                            Spacer()
                        }
                    }

                    Button {
                        resetTutorial()
                    } label: {
                        HStack {
                            Label("Reset Tutorial", systemImage: "arrow.clockwise")
                                .font(.appFont(size: 16, weight: .medium))
                                .foregroundColor(theme.accentColor)
                            Spacer()
                        }
                    }
                }
                .listRowBackground(theme.cardBackgroundColor)
                #endif
            }
            .scrollContentBackground(.hidden)
        }
        .navigationTitle("settings".localized)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            switch themeManager.currentTheme {
            case .dark:   isDark = true
            case .light:  isDark = false
            case .system: isDark = (systemScheme == .dark)
            }
        }
        .onChange(of: systemScheme) { _ in
            if themeManager.currentTheme == .system {
                themeManager.applyTheme(using: systemScheme)
                isDark = (systemScheme == .dark)
            }
        }
        .sheet(isPresented: $showLanguageSettings) {
            LanguageSettingsView()
                .environmentObject(themeManager)
                .environmentObject(localizationManager)
        }
    }

    private func requestAppReview() {
        if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
            SKStoreReviewController.requestReview(in: scene)
        }
    }

    private func addTestCurrency() {
        CurrencyManager.shared.addCoins(5000) { error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ Failed to add coins: \(error.localizedDescription)")
                } else {
                    print("✅ Successfully added 5000 coins")
                }
            }
        }
        CurrencyManager.shared.addGems(500) { error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ Failed to add gems: \(error.localizedDescription)")
                } else {
                    print("✅ Successfully added 500 gems")
                }
            }
        }
    }

    private func resetTutorial() {
        UserDefaults.standard.set(false, forKey: "hasSeenHomeTutorial")
        print("✅ Tutorial reset successfully")
    }
}

struct MoonSunToggleStyle: ToggleStyle {
    let theme: Theme

    func makeBody(configuration: Configuration) -> some View {
        Button {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.9)) {
                configuration.isOn.toggle()
            }
        } label: {
            HStack(spacing: 12) {
                configuration.label
                Spacer()

                ZStack {
                    Capsule()
                        .fill(theme.surfaceColor)
                        .overlay(
                            Capsule()
                                .stroke(theme.borderColor, lineWidth: 1)
                        )
                        .frame(width: 72, height: 36)

                    HStack {
                        Image(systemName: "moon.fill")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(theme.textColor)
                            .opacity(configuration.isOn ? 1 : 0.35)
                        Spacer()
                        Image(systemName: "sun.max.fill")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(theme.textColor)
                            .opacity(configuration.isOn ? 0.35 : 1)
                    }
                    .padding(.horizontal, 10)

                    HStack {
                        if configuration.isOn { Spacer() }
                        Circle()
                            .fill(theme.primaryColor)
                            .overlay(
                                Circle().stroke(theme.borderColor, lineWidth: 1)
                            )
                            .frame(width: 30, height: 30)
                            .shadow(color: theme.shadowColor, radius: 1, y: 1)
                        if !configuration.isOn { Spacer() }
                    }
                    .padding(.horizontal, 3)
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
