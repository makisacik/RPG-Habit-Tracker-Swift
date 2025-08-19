//
//  HomeViewHeroSection.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 6.08.2025.
//

import SwiftUI

// MARK: - HomeView Hero Section Extension

extension HomeView {
    func heroSection(healthManager: HealthManager) -> some View {
        let theme = themeManager.activeTheme

        return VStack(spacing: 16) {
            if let user = viewModel.user {
                // Redesigned Character Card
                VStack(spacing: 0) {
                    // Top section with character info
                    HStack(spacing: 16) {
                        // Character Avatar with enhanced styling
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
                                .frame(width: 90, height: 90)
                                .shadow(color: .yellow.opacity(0.3), radius: 8, x: 0, y: 4)

                            // Main avatar background
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [theme.primaryColor, theme.primaryColor.opacity(0.8)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 80, height: 80)
                                .shadow(color: .black.opacity(0.2), radius: 6, x: 0, y: 3)

                            // Character icon
                            if let characterClass = CharacterClass(rawValue: user.characterClass ?? "knight") {
                                Image(characterClass.iconName)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 60, height: 60)
                                    .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
                            }
                        }

                        // Character details
                        VStack(alignment: .leading, spacing: 8) {
                            // Name and premium badge
                            HStack {
                                Text(user.nickname ?? "Adventurer")
                                    .font(.appFont(size: 24, weight: .black))
                                    .foregroundColor(theme.textColor)
                                    .shadow(color: .black.opacity(0.2), radius: 1, x: 0, y: 1)
                                Spacer()
                                PremiumBadgeView()
                            }

                            // Character class
                            if let characterClass = CharacterClass(rawValue: user.characterClass ?? "") {
                                Text(characterClass.displayName)
                                    .font(.appFont(size: 16, weight: .medium))
                                    .foregroundColor(theme.textColor.opacity(0.8))
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 4)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(Color.yellow.opacity(0.2))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 8)
                                                    .stroke(Color.yellow.opacity(0.3), lineWidth: 1)
                                            )
                                    )
                            }

                            // Level and XP
                            HStack {
                                HStack(spacing: 4) {
                                    Image("icon_star_fill")
                                        .resizable()
                                        .frame(width: 14, height: 14)
                                    Text("\(String.level.localized) \(user.level)")
                                        .font(.appFont(size: 16, weight: .bold))
                                        .foregroundColor(theme.textColor)
                                }

                                Spacer()

                                HStack(spacing: 4) {
                                    Image("icon_lightning")
                                        .resizable()
                                        .frame(width: 12, height: 12)
                                    Text("\(user.exp)/100 XP")
                                        .font(.appFont(size: 14, weight: .medium))
                                        .foregroundColor(theme.textColor.opacity(0.8))
                                }
                            }
                        }

                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)

                    // Divider
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [Color.clear, Color.yellow.opacity(0.3), Color.clear],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(height: 1)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)

                    // Bottom section with stats
                    VStack(spacing: 12) {
                        // Health Bar with reddish color
                        VStack(spacing: 6) {
                            HStack {
                                Image(systemName: "heart.fill")
                                    .font(.system(size: 14))
                                    .foregroundColor(.red)
                                Text("Health")
                                    .font(.appFont(size: 14, weight: .bold))
                                    .foregroundColor(theme.textColor)
                                Spacer()
                                Text("\(healthManager.currentHealth)/\(healthManager.maxHealth)")
                                    .font(.appFont(size: 12, weight: .black))
                                    .foregroundColor(theme.textColor)
                            }

                            // Reddish health bar
                            GeometryReader { geometry in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.red.opacity(0.2))
                                        .frame(height: 16)

                                    let healthPercentage = healthManager.getHealthPercentage()
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(
                                            LinearGradient(
                                                colors: [Color.red, Color.red.opacity(0.8)],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .frame(width: geometry.size.width * healthPercentage, height: 16)
                                        .animation(.easeOut(duration: 0.5), value: healthPercentage)
                                }
                            }
                            .frame(height: 16)
                        }

                        // Coins and Experience Bar
                        HStack(spacing: 16) {
                            // Coins display
                            HStack(spacing: 6) {
                                Image("icon_gold")
                                    .resizable()
                                    .frame(width: 18, height: 18)
                                    .shadow(color: .black.opacity(0.2), radius: 1, x: 0, y: 1)
                                Text("\(user.coins)")
                                    .font(.appFont(size: 16, weight: .black))
                                    .foregroundColor(.yellow)
                                    .shadow(color: .black.opacity(0.2), radius: 1, x: 0, y: 1)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.yellow.opacity(0.2))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.yellow.opacity(0.3), lineWidth: 1)
                                    )
                            )

                            Spacer()

                            // Experience Bar
                            VStack(spacing: 4) {
                                Text("Experience")
                                    .font(.appFont(size: 12, weight: .medium))
                                    .foregroundColor(theme.textColor.opacity(0.7))

                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(theme.backgroundColor.opacity(0.3))
                                        .frame(width: 120, height: 12)

                                    let expRatio = min(CGFloat(user.exp) / 100.0, 1.0)
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(
                                            LinearGradient(
                                                colors: [Color.green, Color.green.opacity(0.7)],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .frame(width: 120 * expRatio, height: 12)
                                        .animation(.easeInOut(duration: 0.5), value: user.exp)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            LinearGradient(
                                colors: [
                                    theme.primaryColor,
                                    theme.primaryColor.opacity(0.95)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: .black.opacity(0.15), radius: 12, x: 0, y: 6)
                )
            } else {
                // Loading state
                HStack {
                    ProgressView()
                        .scaleEffect(1.2)
                        .tint(.yellow)
                    Text(String.loadingCharacter.localized)
                        .font(.appFont(size: 16))
                        .foregroundColor(theme.textColor)
                }
                .frame(height: 120)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(theme.primaryColor)
                        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                )
            }
        }
    }
}
