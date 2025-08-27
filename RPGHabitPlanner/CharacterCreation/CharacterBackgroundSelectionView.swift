//
//  CharacterBackgroundSelectionView.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 7.01.2025.
//

import SwiftUI

struct CharacterBackgroundSelectionView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.dismiss) private var dismiss
    @StateObject private var backgroundManager = CharacterBackgroundManager.shared
    @State private var selectedBackground: CharacterBackground
    
    init() {
        _selectedBackground = State(initialValue: CharacterBackgroundManager.shared.getCurrentBackground())
    }
    
    var body: some View {
        let theme = themeManager.activeTheme
        
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(theme.backgroundColor)
            
            VStack(spacing: 0) {
                // Header
                headerView(theme: theme)
                
                // Background Options Grid
                backgroundOptionsGridView(theme: theme)
            }
            .padding()
        }
    }
    
    // MARK: - Header View
    @ViewBuilder
    private func headerView(theme: Theme) -> some View {
        VStack(spacing: 16) {
            HStack {
                Button(String(localized: "cancel")) {
                    dismiss()
                }
                .font(.appFont(size: 16, weight: .medium))
                .foregroundColor(theme.textColor.opacity(0.7))
                
                Spacer()
                
                Text(String(localized: "select_background"))
                    .font(.appFont(size: 18, weight: .bold))
                    .foregroundColor(theme.textColor)
                
                Spacer()
            }
            .padding(.horizontal)
            
            Text(String(localized: "choose_character_background"))
                .font(.appFont(size: 14))
                .foregroundColor(theme.textColor.opacity(0.8))
                .multilineTextAlignment(.center)
        }
        .padding(.bottom, 20)
    }
    
    // MARK: - Background Options Grid View
    @ViewBuilder
    private func backgroundOptionsGridView(theme: Theme) -> some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                ForEach(CharacterBackground.allCases, id: \.self) { background in
                    BackgroundOptionCard(
                        background: background,
                        isSelected: selectedBackground == background,
                        onTap: {
                            selectedBackground = background
                            backgroundManager.setBackground(background)
                        },
                        theme: theme
                    )
                }
            }
            .padding(.horizontal)
        }
    }
}

// MARK: - Background Option Card

struct BackgroundOptionCard: View {
    let background: CharacterBackground
    let isSelected: Bool
    let onTap: () -> Void
    let theme: Theme
    
    private var strokeColor: Color {
        isSelected ? theme.accentColor : theme.borderColor.opacity(0.3)
    }
    
    private var strokeWidth: CGFloat {
        isSelected ? 3 : 1
    }
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 12) {
                // Background preview
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(theme.cardBackgroundColor)
                        .frame(height: 120)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(strokeColor, lineWidth: strokeWidth)
                        )
                        .shadow(color: theme.shadowColor, radius: 4, x: 0, y: 2)
                    
                    if let imageName = background.imageName {
                        Image(imageName)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 120)
                            .clipped()
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    } else {
                        // No background option
                        RoundedRectangle(cornerRadius: 12)
                            .fill(theme.cardBackgroundColor)
                            .frame(height: 120)
                            .overlay(
                                Image(systemName: "photo.slash")
                                    .font(.system(size: 30))
                                    .foregroundColor(theme.textColor.opacity(0.5))
                            )
                    }
                    
                    // Selection indicator
                    if isSelected {
                        VStack {
                            HStack {
                                Spacer()
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(.white)
                                    .background(
                                        Circle()
                                            .fill(theme.accentColor)
                                            .frame(width: 24, height: 24)
                                    )
                                    .padding(8)
                            }
                            Spacer()
                        }
                    }
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}
