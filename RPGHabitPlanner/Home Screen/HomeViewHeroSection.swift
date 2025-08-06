//
//  HomeViewHeroSection.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 6.08.2025.
//

import SwiftUI

// MARK: - HomeView Hero Section Extension

extension HomeView {
    var heroSection: some View {
        let theme = themeManager.activeTheme
        
        return VStack(spacing: 16) {
            if let user = viewModel.user {
                HStack(spacing: 16) {
                    // Character Avatar
                    ZStack {
                        Circle()
                            .fill(theme.primaryColor)
                            .frame(width: 80, height: 80)
                            .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                        
                        if let characterClass = CharacterClass(rawValue: user.characterClass ?? "knight") {
                            Image(characterClass.iconName)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 60, height: 60)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(user.nickname ?? "Adventurer")
                            .font(.appFont(size: 24, weight: .black))
                            .foregroundColor(theme.textColor)
                        
                        if let characterClass = CharacterClass(rawValue: user.characterClass ?? "") {
                            Text(characterClass.displayName)
                                .font(.appFont(size: 16))
                                .foregroundColor(theme.textColor.opacity(0.8))
                        }
                        
                        HStack {
                            Text("Level \(user.level)")
                                .font(.appFont(size: 18, weight: .bold))
                                .foregroundColor(theme.textColor)
                            
                            Spacer()
                            
                            Text("\(user.exp)/100 XP")
                                .font(.appFont(size: 14))
                                .foregroundColor(theme.textColor.opacity(0.7))
                        }
                        
                        // Experience Bar
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(theme.backgroundColor.opacity(0.3))
                                .frame(height: 12)
                            
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
                    
                    Spacer()
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(theme.primaryColor)
                        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                )
            } else {
                // Loading state
                HStack {
                    ProgressView()
                        .scaleEffect(1.2)
                    Text("Loading character...")
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
