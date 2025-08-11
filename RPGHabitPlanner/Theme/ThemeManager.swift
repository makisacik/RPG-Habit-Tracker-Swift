//
//  ThemeManager.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 3.08.2025.
//

import SwiftUI
import Combine

final class ThemeManager: ObservableObject {
    static let shared = ThemeManager()
    
    @Published var currentTheme: AppTheme = .system
    @Published var activeTheme = Theme.create(for: .light)
    @Published var forcedColorScheme: ColorScheme?
    
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        loadTheme()
    }
    
    func setTheme(_ theme: AppTheme) {
        currentTheme = theme
        saveTheme()

        // Apply theme immediately
        switch theme {
        case .light:
            forcedColorScheme = .light
            activeTheme = Theme.create(for: .light)
        case .dark:
            forcedColorScheme = .dark
            activeTheme = Theme.create(for: .dark)
        case .system:
            forcedColorScheme = nil
            // Will be handled by system color scheme
        }
    }
    
    func applyTheme(using colorScheme: ColorScheme) {
        switch currentTheme {
        case .light:
            activeTheme = Theme.create(for: .light)
        case .dark:
            activeTheme = Theme.create(for: .dark)
        case .system:
            activeTheme = (colorScheme == .dark) ? Theme.create(for: .dark) : Theme.create(for: .light)
        }
    }
    
    func bindColorScheme(_ colorScheme: Published<ColorScheme>.Publisher) {
        colorScheme
            .sink { [weak self] scheme in
                self?.applyTheme(using: scheme)
            }
            .store(in: &cancellables)
    }
    
    private func saveTheme() {
        UserDefaults.standard.set(currentTheme.rawValue, forKey: "selectedTheme")
    }
    
    private func loadTheme() {
        if let raw = UserDefaults.standard.string(forKey: "selectedTheme"),
           let saved = AppTheme(rawValue: raw) {
            currentTheme = saved
            // Apply the saved theme immediately
            setTheme(saved)
        }
    }
}
