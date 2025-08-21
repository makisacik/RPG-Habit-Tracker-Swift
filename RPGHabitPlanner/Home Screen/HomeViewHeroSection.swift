//
//  HomeViewHeroSection.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 6.08.2025.
//

import SwiftUI

// MARK: - HomeView Hero Section Extension

extension HomeView {
    func heroSection(healthManager: HealthManager, customizationManager: CharacterCustomizationManager) -> some View {
        let theme = themeManager.activeTheme

        return VStack(spacing: 12) {
            if let user = viewModel.user {
                // Compact Character Card
                VStack(spacing: 0) {
                    // Top section with character info
                    HStack(spacing: 12) {
                        // Character Avatar with compact styling
                        ZStack {
                            // Outer glow effect
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color.yellow.opacity(0.3), Color.orange.opacity(0.1)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 70, height: 70)
                                .shadow(color: .yellow.opacity(0.3), radius: 6, x: 0, y: 3)

                            // Custom Character Avatar
                            CustomizedCharacterPreviewCard(
                                customization: customizationManager.currentCustomization,
                                theme: theme,
                                size: CGSize(width: 60, height: 60)
                            )
                            .clipShape(Circle())
                        }

                        // Character info
                        VStack(alignment: .leading, spacing: 4) {
                            Text(user.nickname ?? String.adventurer.localized)
                                .font(.appFont(size: 20, weight: .black))
                                .foregroundColor(theme.textColor)
                                .lineLimit(1)

                            Text("Level \(user.level)")
                                .font(.appFont(size: 14, weight: .medium))
                                .foregroundColor(theme.textColor.opacity(0.8))

                            // Coins display
                            HStack(spacing: 4) {
                                Image(systemName: "coins")
                                    .font(.system(size: 12))
                                    .foregroundColor(.yellow)
                                
                                Text("\(user.coins)")
                                    .font(.appFont(size: 12, weight: .medium))
                                    .foregroundColor(theme.textColor)
                            }
                        }

                        Spacer()

                        // Health indicator
                        VStack(spacing: 4) {
                            Text("\(user.health)/\(user.maxHealth)")
                                .font(.appFont(size: 12, weight: .bold))
                                .foregroundColor(theme.textColor)

                            ProgressView(value: Double(user.health), total: Double(user.maxHealth))
                                .progressViewStyle(LinearProgressViewStyle(tint: .green))
                                .frame(width: 60, height: 4)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                }
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(theme.cardBackgroundColor)
                        .shadow(color: theme.textColor.opacity(0.1), radius: 8, x: 0, y: 4)
                )
            }
        }
    }
}
