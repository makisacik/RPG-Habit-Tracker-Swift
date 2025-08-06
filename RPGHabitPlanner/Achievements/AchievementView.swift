//
//  AchievementView.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 6.08.2025.
//

import SwiftUI

struct AchievementView: View {
    @EnvironmentObject var themeManager: ThemeManager
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
    
    private var filteredAchievements: [Achievement] {
        if selectedCategory == .all {
            return Achievement.dummyAchievements
        } else {
            return Achievement.dummyAchievements.filter { $0.category == selectedCategory }
        }
    }
}

struct AchievementCardView: View {
    @EnvironmentObject var themeManager: ThemeManager
    let achievement: Achievement
    
    var body: some View {
        let theme = themeManager.activeTheme
        
        VStack(spacing: 12) {
            // Achievement Icon
            ZStack {
                Circle()
                    .fill(achievement.isUnlocked ? Color.yellow.opacity(0.2) : Color.gray.opacity(0.2))
                    .frame(width: 60, height: 60)
                
                Image(systemName: achievement.iconName)
                    .font(.title2)
                    .foregroundColor(achievement.isUnlocked ? .yellow : .gray)
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
                
                if achievement.isUnlocked {
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
        .opacity(achievement.isUnlocked ? 1.0 : 0.7)
    }
}

// MARK: - Models

struct Achievement: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let iconName: String
    let category: AchievementCategory
    let isUnlocked: Bool
    
    static let dummyAchievements: [Achievement] = [
        // Quest Achievements
        Achievement(
            title: "First Steps",
            description: "Complete your first quest",
            iconName: "flag.fill",
            category: .quests,
            isUnlocked: true
        ),
        Achievement(
            title: "Quest Master",
            description: "Complete 50 quests",
            iconName: "crown.fill",
            category: .quests,
            isUnlocked: false
        ),
        Achievement(
            title: "Speed Runner",
            description: "Complete 3 quests in one day",
            iconName: "bolt.fill",
            category: .quests,
            isUnlocked: true
        ),
        Achievement(
            title: "Consistency",
            description: "Complete quests for 7 days in a row",
            iconName: "calendar.badge.clock",
            category: .quests,
            isUnlocked: false
        ),
        
        // Level Achievements
        Achievement(
            title: "Level Up!",
            description: "Reach level 5",
            iconName: "star.fill",
            category: .leveling,
            isUnlocked: true
        ),
        Achievement(
            title: "Veteran",
            description: "Reach level 20",
            iconName: "star.circle.fill",
            category: .leveling,
            isUnlocked: false
        ),
        Achievement(
            title: "Legend",
            description: "Reach level 50",
            iconName: "star.square.fill",
            category: .leveling,
            isUnlocked: false
        ),
        Achievement(
            title: "Experience Hunter",
            description: "Gain 1000 experience points",
            iconName: "sparkles",
            category: .leveling,
            isUnlocked: false
        ),
        
        // Character Achievements
        Achievement(
            title: "Character Creator",
            description: "Create your first character",
            iconName: "person.fill",
            category: .character,
            isUnlocked: true
        ),
        Achievement(
            title: "Weapon Master",
            description: "Try all weapon types",
            iconName: "sword.fill",
            category: .character,
            isUnlocked: false
        ),
        Achievement(
            title: "Class Explorer",
            description: "Try all character classes",
            iconName: "person.3.fill",
            category: .character,
            isUnlocked: false
        ),
        
        // Special Achievements
        Achievement(
            title: "Early Bird",
            description: "Complete a quest before 8 AM",
            iconName: "sunrise.fill",
            category: .special,
            isUnlocked: false
        ),
        Achievement(
            title: "Night Owl",
            description: "Complete a quest after 10 PM",
            iconName: "moon.fill",
            category: .special,
            isUnlocked: false
        ),
        Achievement(
            title: "Weekend Warrior",
            description: "Complete 5 quests on a weekend",
            iconName: "calendar.badge.plus",
            category: .special,
            isUnlocked: false
        ),
        Achievement(
            title: "Perfect Day",
            description: "Complete all daily quests",
            iconName: "checkmark.circle.fill",
            category: .special,
            isUnlocked: false
        )
    ]
}

enum AchievementCategory: String, CaseIterable {
    case all
    case quests
    case leveling
    case character
    case special
    
    var displayName: String {
        switch self {
        case .all: return "All"
        case .quests: return "Quests"
        case .leveling: return "Leveling"
        case .character: return "Character"
        case .special: return "Special"
        }
    }
}

#Preview {
    AchievementView()
        .environmentObject(ThemeManager.shared)
}
