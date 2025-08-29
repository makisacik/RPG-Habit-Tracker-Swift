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

        return VStack(spacing: 12) {
            if let user = viewModel.user {
                characterCard(user: user, theme: theme, healthManager: healthManager)
            } else {
                loadingState(theme: theme)
            }
        }
    }

    @ViewBuilder
    private func characterCard(user: UserEntity, theme: Theme, healthManager: HealthManager) -> some View {
        VStack(spacing: 0) {
            characterInfoSection(user: user, theme: theme)
            dividerSection(theme: theme)
            statsSection(user: user, theme: theme, healthManager: healthManager)
        }
        .background(characterCardBackground(theme: theme))
    }

    @ViewBuilder
    private func characterInfoSection(user: UserEntity, theme: Theme) -> some View {
        HStack(spacing: 12) {
            characterAvatar(theme: theme)
            characterDetails(user: user, theme: theme)
            Spacer()
        }
        .padding(.leading, 16)
        .padding(.trailing, 16)
        .padding(.top, 16)
    }

    @ViewBuilder
    private func characterAvatar(theme: Theme) -> some View {
        ZStack {
            // Main avatar background
            let avatarBackgroundGradient = LinearGradient(
                colors: [theme.primaryColor, theme.primaryColor.opacity(0.8)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            Circle()
                .fill(avatarBackgroundGradient)
                .frame(width: 62, height: 62)
                .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)

            // Character customization image
            CharacterDisplayView(
                customization: viewModel.characterCustomization,
                size: 45,
                showShadow: false
            )
            .scaleEffect(1.5525)
            .clipped()
        }
    }

    @ViewBuilder
    private func characterDetails(user: UserEntity, theme: Theme) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            characterName(user: user, theme: theme)
            characterTitle(user: user, theme: theme)
            levelAndXP(user: user, theme: theme)
        }
    }

    @ViewBuilder
    private func characterName(user: UserEntity, theme: Theme) -> some View {
        HStack {
            Text(user.nickname ?? "Adventurer")
                .font(.appFont(size: 16, weight: .black))
                .foregroundColor(theme.textColor)
                .shadow(color: .black.opacity(0.2), radius: 1, x: 0, y: 1)
                .minimumScaleFactor(0.8)
                .lineLimit(1)
            Spacer()
            currencySection(user: user)
        }
    }

    @ViewBuilder
    private func characterTitle(user: UserEntity, theme: Theme) -> some View {
        if let title = user.title, !title.isEmpty {
            // Use the same localization approach as the fallback case
            let localizedTitle = CharacterTitleManager.shared.getTitleByString(title)?.rawValue.localized ?? title.localized
            Text(localizedTitle)
                .font(.appFont(size: 14, weight: .medium))
                .foregroundColor(theme.textColor.opacity(0.8))
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(titleBackground(theme: theme))
        } else {
            Text("the_brave".localized)
                .font(.appFont(size: 14, weight: .medium))
                .foregroundColor(theme.textColor.opacity(0.8))
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(titleBackground(theme: theme))
        }
    }

    @ViewBuilder
    private func titleBackground(theme: Theme) -> some View {
        RoundedRectangle(cornerRadius: 6)
            .fill(theme.accentColor.opacity(0.2))
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(theme.accentColor.opacity(0.3), lineWidth: 1)
            )
    }

    @ViewBuilder
    private func levelAndXP(user: UserEntity, theme: Theme) -> some View {
        HStack {
            levelDisplay(user: user, theme: theme)
            Spacer()
        }
    }

    @ViewBuilder
    private func levelDisplay(user: UserEntity, theme: Theme) -> some View {
        HStack(spacing: 3) {
            Image("icon_star_fill")
                .resizable()
                .frame(width: 12, height: 12)
            Text("\("level".localized) \(user.level)")
                .font(.appFont(size: 14, weight: .bold))
                .foregroundColor(theme.textColor)
        }
    }


    @ViewBuilder
    private func dividerSection(theme: Theme) -> some View {
        let dividerGradient = LinearGradient(
            colors: [Color.clear, Color.yellow.opacity(0.3), Color.clear],
            startPoint: .leading,
            endPoint: .trailing
        )
        Rectangle()
            .fill(dividerGradient)
            .frame(height: 1)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
    }

    @ViewBuilder
    private func statsSection(user: UserEntity, theme: Theme, healthManager: HealthManager) -> some View {
        VStack(spacing: 10) {
            healthBarSection(healthManager: healthManager, theme: theme)
            currencyAndExperienceSection(user: user, theme: theme)
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
    }

    @ViewBuilder
    private func healthBarSection(healthManager: HealthManager, theme: Theme) -> some View {
        VStack(spacing: 4) {
            healthBarHeader(healthManager: healthManager, theme: theme)
            healthBarVisual(healthManager: healthManager)
        }
    }

    @ViewBuilder
    private func healthBarHeader(healthManager: HealthManager, theme: Theme) -> some View {
        HStack {
            Image(systemName: "heart.fill")
                .font(.system(size: 12))
                .foregroundColor(.red)
            Text("health".localized)
                .font(.appFont(size: 12, weight: .bold))
                .foregroundColor(theme.textColor)
            Spacer()
            Text("\(healthManager.currentHealth)/\(healthManager.maxHealth)")
                .font(.appFont(size: 11, weight: .black))
                .foregroundColor(theme.textColor)
        }
    }

    @ViewBuilder
    private func healthBarVisual(healthManager: HealthManager) -> some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.red.opacity(0.2))
                    .frame(height: 12)

                let healthPercentage = healthManager.getHealthPercentage()
                let healthGradient = LinearGradient(
                    colors: [Color.red, Color.red.opacity(0.8)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                RoundedRectangle(cornerRadius: 6)
                    .fill(healthGradient)
                    .frame(width: geometry.size.width * healthPercentage, height: 12)
                    .animation(.easeOut(duration: 0.5), value: healthPercentage)
            }
        }
        .frame(height: 12)
    }

    @ViewBuilder
    private func currencyAndExperienceSection(user: UserEntity, theme: Theme) -> some View {
        VStack(spacing: 10) {
            experienceBarSection(user: user, theme: theme)
        }
    }

    @ViewBuilder
    private func coinsDisplay(user: UserEntity) -> some View {
        HStack(spacing: 4) {
            Image("icon_gold")
                .resizable()
                .frame(width: 14, height: 14)
                .shadow(color: .black.opacity(0.2), radius: 1, x: 0, y: 1)
            Text("\(user.coins)")
                .font(.appFont(size: 14, weight: .black))
                .foregroundColor(.yellow)
                .shadow(color: .black.opacity(0.2), radius: 1, x: 0, y: 1)
        }
    }


    @ViewBuilder
    private func gemsDisplay(user: UserEntity) -> some View {
        HStack(spacing: 4) {
            Image("icon_gem")
                .resizable()
                .frame(width: 16, height: 16)
                .shadow(color: .black.opacity(0.2), radius: 1, x: 0, y: 1)
            Text("\(user.gems)")
                .font(.appFont(size: 14, weight: .black))
                .foregroundColor(.purple)
                .shadow(color: .black.opacity(0.2), radius: 1, x: 0, y: 1)
        }
    }


    @ViewBuilder
    private func currencySection(user: UserEntity) -> some View {
        HStack(spacing: 8) {
            coinsDisplay(user: user)
            gemsDisplay(user: user)
        }
    }

    @ViewBuilder
    private func experienceBarSection(user: UserEntity, theme: Theme) -> some View {
        VStack(spacing: 4) {
            experienceBarHeader(user: user, theme: theme)
            experienceBarVisual(user: user, theme: theme)
        }
    }

    @ViewBuilder
    private func experienceBarHeader(user: UserEntity, theme: Theme) -> some View {
        HStack {
            Image("icon_lightning")
                .resizable()
                .frame(width: 12, height: 12)
                .foregroundColor(.yellow)
            Text("experience".localized)
                .font(.appFont(size: 12, weight: .bold))
                .foregroundColor(theme.textColor)
            Spacer()
            let levelingSystem = LevelingSystem.shared
            let expRequiredForNextLevel = levelingSystem.experienceRequiredForNextLevel(from: Int(user.level))
            Text("\(user.exp)/\(expRequiredForNextLevel)")
                .font(.appFont(size: 11, weight: .black))
                .foregroundColor(theme.textColor)
        }
    }

    @ViewBuilder
    private func experienceBarVisual(user: UserEntity, theme: Theme) -> some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 6)
                    .fill(theme.secondaryColor.opacity(0.7))
                    .frame(height: 12)

                let levelingSystem = LevelingSystem.shared
                let totalExperience = levelingSystem.calculateTotalExperience(level: Int(user.level), experienceInLevel: Int(user.exp))
                let progress = levelingSystem.calculateLevelProgress(totalExperience: totalExperience, currentLevel: Int(user.level))
                let expRatio = min(CGFloat(progress), 1.0)
                let expGradient = LinearGradient(
                    colors: [Color.green, Color.green.opacity(0.7)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                RoundedRectangle(cornerRadius: 6)
                    .fill(expGradient)
                    .frame(width: geometry.size.width * expRatio, height: 12)
                    .animation(.easeInOut(duration: 0.5), value: expRatio)
            }
        }
        .frame(height: 12)
        .id("exp-bar-\(user.level)-\(user.exp)") // 👈 Make exp bar reactive to user changes
    }
    @ViewBuilder
    private func characterCardBackground(theme: Theme) -> some View {
        let cardGradient = LinearGradient(
            colors: [
                theme.primaryColor,
                theme.primaryColor.opacity(0.95)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        RoundedRectangle(cornerRadius: 16)
            .fill(cardGradient)
            .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
    }

    @ViewBuilder
    private func loadingState(theme: Theme) -> some View {
        HStack {
            ProgressView()
                .scaleEffect(1.0)
                .tint(.yellow)
            Text("loading_character".localized)
                .font(.appFont(size: 14))
                .foregroundColor(theme.textColor)
        }
        .frame(height: 80)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(theme.primaryColor)
                .shadow(color: .black.opacity(0.1), radius: 6, x: 0, y: 3)
        )
    }
}
