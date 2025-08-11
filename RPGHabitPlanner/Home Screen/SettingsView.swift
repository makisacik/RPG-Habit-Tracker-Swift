//
//  SettingsView.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 12.08.2025.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var localizationManager: LocalizationManager
    @Environment(\.colorScheme) private var systemScheme

    @State private var isDark = false
    @State private var showLanguageSettings = false

    var body: some View {
        List {
            Section("Appearance") {
                // Light/Dark toggle
                Toggle(isOn: $isDark.animation(.easeInOut(duration: 0.2))) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Dark Mode")
                            .font(.headline)
                        Text("Switch between light and dark themes")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                .toggleStyle(MoonSunToggleStyle())
                .onChange(of: isDark) { newValue in
                    // Switch explicitly to light/dark
                    themeManager.setTheme(newValue ? .dark : .light)
                }

                // System mode button
                Button {
                    themeManager.setTheme(.system)
                    isDark = (systemScheme == .dark)
                } label: {
                    HStack {
                        Label("Use System Appearance", systemImage: "circle.lefthalf.filled")
                        Spacer()
                        Text(themeManager.currentTheme == .system ? "On" : "Off")
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Section("General") {
                // Language Setting
                Button {
                    showLanguageSettings = true
                } label: {
                    HStack {
                        Label(String.language.localized, systemImage: "globe")
                        Spacer()
                        HStack(spacing: 4) {
                            Text(localizationManager.currentLanguage.flag)
                            Text(localizationManager.currentLanguage.displayName)
                                .foregroundStyle(.secondary)
                        }
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }


                NavigationLink("Notifications") { Text("Notifications settings") }
                NavigationLink("Data & Storage") { Text("Data & Storage settings") }
            }

            Section("About") {
                NavigationLink("About App") { Text("Version 1.0 • © You") }
            }
        }
        .navigationTitle(String.settings.localized)
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
}

struct MoonSunToggleStyle: ToggleStyle {
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
                        .fill(.ultraThinMaterial)
                        .overlay(
                            Capsule()
                                .stroke(Color(UIColor.separator), lineWidth: 1)
                        )
                        .frame(width: 72, height: 36)

                    HStack {
                        Image(systemName: "moon.fill")
                            .font(.system(size: 14, weight: .semibold))
                            .opacity(configuration.isOn ? 1 : 0.35)
                        Spacer()
                        Image(systemName: "sun.max.fill")
                            .font(.system(size: 14, weight: .semibold))
                            .opacity(configuration.isOn ? 0.35 : 1)
                    }
                    .padding(.horizontal, 10)

                    HStack {
                        if configuration.isOn { Spacer() }
                        Circle()
                            .fill(Color(UIColor.systemBackground))
                            .overlay(
                                Circle().stroke(Color(UIColor.separator), lineWidth: 1)
                            )
                            .frame(width: 30, height: 30)
                            .shadow(radius: 1, y: 1)
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
