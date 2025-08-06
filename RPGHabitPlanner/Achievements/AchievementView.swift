//
//  AchievementView.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 6.08.2025.
//

import SwiftUI

struct AchievementView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @StateObject private var achievementManager = AchievementManager.shared
    @State private var selectedCategory: AchievementCategory = .all
    
    var body: some View {
        let theme = themeManager.activeTheme
        
        ZStack {
            theme.backgroundColor
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                // Category Picker
                categoryPicker
                
                // Achievement List
                ScrollView {
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 12),
                        GridItem(.flexible(), spacing: 12)
                    ], spacing: 12) {
                        ForEach(filteredAchievements) { achievement in
                            AchievementCardView(achievement: achievement)
                        }
                    }
                    .padding(.horizontal)
                }
                .scrollIndicators(.hidden)
            }
            .padding(.top)
        }
        .navigationTitle("Achievements")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var categoryPicker: some View {
        let theme = themeManager.activeTheme
        
        return ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(AchievementCategory.allCases, id: \.self) { category in
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedCategory = category
                        }
                    }) {
                        Text(category.displayName)
                            .font(.appFont(size: 14, weight: .black))
                            .foregroundColor(selectedCategory == category ? .white : theme.textColor)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(selectedCategory == category ? Color.yellow : theme.secondaryColor)
                                    .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
                            )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal)
        }
    }
    
    private var filteredAchievements: [AchievementDefinition] {
        let allAchievements = achievementManager.getAllAchievements()
        if selectedCategory == .all {
            return allAchievements
        } else {
            return allAchievements.filter { $0.category == selectedCategory }
        }
    }
}

struct AchievementCardView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @StateObject private var achievementManager = AchievementManager.shared
    let achievement: AchievementDefinition
    
    var body: some View {
        let theme = themeManager.activeTheme
        
        VStack(spacing: 12) {
            // Achievement Icon
            ZStack {
                Circle()
                    .fill(isUnlocked ? Color.yellow.opacity(0.2) : Color.gray.opacity(0.2))
                    .frame(width: 60, height: 60)
                
                Image(systemName: achievement.iconName)
                    .font(.title2)
                    .foregroundColor(isUnlocked ? .yellow : .gray)
            }
            
            // Achievement Info
            VStack(spacing: 4) {
                Text(achievement.title)
                    .font(.appFont(size: 14, weight: .black))
                    .foregroundColor(theme.textColor)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                
                Text(achievement.description)
                    .font(.appFont(size: 12, weight: .regular))
                    .foregroundColor(theme.textColor.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                
                if isUnlocked {
                    Text("Unlocked!")
                        .font(.appFont(size: 10, weight: .black))
                        .foregroundColor(.green)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.green.opacity(0.2))
                        )
                } else {
                    Text("Locked")
                        .font(.appFont(size: 10, weight: .black))
                        .foregroundColor(.gray)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.gray.opacity(0.2))
                        )
                }
            }
        }
        .padding()
        .frame(width: 160, height: 200)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(theme.secondaryColor)
                .shadow(color: Color.black.opacity(0.2), radius: 6, x: 0, y: 4)
        )
        .opacity(isUnlocked ? 1.0 : 0.7)
    }
    
    private var isUnlocked: Bool {
        achievementManager.isAchievementUnlocked(achievement.id)
    }
}


#Preview {
    AchievementView()
        .environmentObject(ThemeManager.shared)
}
