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
    @State private var originalBackground: CharacterBackground
    @State private var hasChanges = false
    
    init() {
        let currentBackground = CharacterBackgroundManager.shared.getCurrentBackground()
        _selectedBackground = State(initialValue: currentBackground)
        _originalBackground = State(initialValue: currentBackground)
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
                
                // Save Button
                if hasChanges {
                    saveButtonView(theme: theme)
                }
            }
            .padding()
        }
        .onChange(of: selectedBackground) { newBackground in
            hasChanges = newBackground != originalBackground
        }
    }
    
    // MARK: - Header View
    @ViewBuilder
    private func headerView(theme: Theme) -> some View {
        VStack(spacing: 16) {
            HStack {
                Button("cancel".localized) {
                    dismiss()
                }
                .font(.appFont(size: 16, weight: .medium))
                .foregroundColor(theme.textColor.opacity(0.7))
                
                Spacer()
                
                Text("select_background".localized)
                    .font(.appFont(size: 18, weight: .bold))
                    .foregroundColor(theme.textColor)
                    .frame(maxWidth: .infinity)

                Spacer()
                
                // Invisible button to balance the layout
                Button("cancel".localized) {
                    dismiss()
                }
                .font(.appFont(size: 16, weight: .medium))
                .foregroundColor(.clear)
                .disabled(true)
            }
            .padding(.horizontal)
            
            Text("choose_character_background".localized)
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
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12)
            ], spacing: 16) {
                ForEach(CharacterBackground.allCases, id: \.self) { background in
                    BackgroundOptionCard(
                        background: background,
                        isSelected: selectedBackground == background,
                        onTap: {
                            selectedBackground = background
                        },
                        theme: theme
                    )
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 20)
        }
    }
    
    // MARK: - Save Button View
    @ViewBuilder
    private func saveButtonView(theme: Theme) -> some View {
        VStack(spacing: 12) {
            Button(action: {
                backgroundManager.setBackground(selectedBackground)
                dismiss()
            }) {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 16))
                    Text("save_changes".localized)
                        .font(.appFont(size: 16, weight: .semibold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(theme.accentColor)
                )
                .shadow(color: theme.accentColor.opacity(0.3), radius: 4, x: 0, y: 2)
            }
            .buttonStyle(PlainButtonStyle())
            
            Text("tap_to_apply_changes".localized)
                .font(.appFont(size: 12))
                .foregroundColor(theme.textColor.opacity(0.6))
                .multilineTextAlignment(.center)
        }
        .padding(.top, 16)
        .padding(.horizontal)
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
            VStack(spacing: 8) {
                // Background preview
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(theme.cardBackgroundColor)
                        .frame(height: 100)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(strokeColor, lineWidth: strokeWidth)
                        )
                        .shadow(color: theme.shadowColor, radius: 4, x: 0, y: 2)
                    
                    if let imageName = background.imageName {
                        Image(imageName)
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    } else {
                        // No background option
                        RoundedRectangle(cornerRadius: 10)
                            .fill(theme.cardBackgroundColor)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .overlay(
                                Image(systemName: "photo.slash")
                                    .font(.system(size: 24))
                                    .foregroundColor(theme.textColor.opacity(0.5))
                            )
                    }
                    
                    // Selection indicator
                    if isSelected {
                        VStack {
                            HStack {
                                Spacer()
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(.white)
                                    .background(
                                        Circle()
                                            .fill(theme.accentColor)
                                            .frame(width: 20, height: 20)
                                    )
                                    .padding(6)
                            }
                            Spacer()
                        }
                    }
                }
                
                // Background name
                Text(background.displayName)
                    .font(.appFont(size: 12, weight: isSelected ? .bold : .medium))
                    .foregroundColor(isSelected ? theme.accentColor : theme.textColor.opacity(0.8))
                    .lineLimit(1)
                    .multilineTextAlignment(.center)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}
