//
//  DailyQuestsView.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 6.08.2025.
//

import SwiftUI

struct DailyQuestsView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @ObservedObject var viewModel: DailyQuestsViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showingAddConfirmation = false
    @State private var selectedQuest: DailyQuestTemplate?
    
    var body: some View {
        let theme = themeManager.activeTheme
        
        NavigationStack {
            ZStack {
                theme.backgroundColor
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Header Section
                        headerSection(theme: theme)
                        
                        // Daily Quest Categories
                        LazyVStack(spacing: 16) {
                            ForEach(DailyQuestCategory.allCases, id: \.self) { category in
                                categorySection(category: category, theme: theme)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 10)
                }
            }
            .navigationTitle("Daily Quests")
            .navigationBarTitleDisplayMode(.large)
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismiss()
                }
                .foregroundColor(theme.textColor)
            )
            .alert("Add Daily Quest", isPresented: $showingAddConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Add Quest") {
                    if let quest = selectedQuest {
                        viewModel.addDailyQuest(quest)
                        selectedQuest = nil
                    }
                }
            } message: {
                if let quest = selectedQuest {
                    Text("Add '\(quest.title)' as a daily quest? This quest will repeat every day.")
                }
            }
        }
    }
    
    private func headerSection(theme: Theme) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "sun.max.fill")
                .font(.system(size: 40))
                .foregroundColor(.orange)
            
            Text("Daily Quests")
                .font(.appFont(size: 28, weight: .black))
                .foregroundColor(theme.textColor)
            
            Text("Choose from these premade daily quests to build healthy habits and earn experience!")
                .font(.appFont(size: 16))
                .foregroundColor(theme.textColor.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(theme.primaryColor)
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
    }
    
    private func categorySection(category: DailyQuestCategory, theme: Theme) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: category.iconName)
                    .font(.system(size: 20))
                    .foregroundColor(category.color)
                
                Text(category.displayName)
                    .font(.appFont(size: 20, weight: .bold))
                    .foregroundColor(theme.textColor)
                
                Spacer()
            }
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(viewModel.questsForCategory(category), id: \.id) { quest in
                    DailyQuestCard(
                        quest: quest,
                        theme: theme,
                        isAlreadyAdded: viewModel.isQuestAlreadyAdded(quest)
                    ) {
                            selectedQuest = quest
                            showingAddConfirmation = true
                    }
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(theme.primaryColor)
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
    }
}

struct DailyQuestCard: View {
    let quest: DailyQuestTemplate
    let theme: Theme
    let isAlreadyAdded: Bool
    let onAdd: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: quest.iconName)
                    .font(.system(size: 16))
                    .foregroundColor(quest.category.color)
                
                Spacer()
                
                if isAlreadyAdded {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.green)
                }
            }
            
            Text(quest.title)
                .font(.appFont(size: 14, weight: .medium))
                .foregroundColor(theme.textColor)
                .lineLimit(2)
            
            Text(quest.description)
                .font(.appFont(size: 12))
                .foregroundColor(theme.textColor.opacity(0.7))
                .lineLimit(3)
            
            HStack {
                Text("\(quest.difficulty) XP")
                    .font(.appFont(size: 12, weight: .medium))
                    .foregroundColor(.green)
                
                Spacer()
                
                if !isAlreadyAdded {
                    Button("Add") {
                        onAdd()
                    }
                    .font(.appFont(size: 12, weight: .medium))
                    .foregroundColor(.blue)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.blue.opacity(0.1))
                    )
                } else {
                    Text("Added")
                        .font(.appFont(size: 12, weight: .medium))
                        .foregroundColor(.green)
                }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(theme.primaryColor.opacity(0.5))
        )
    }
}

#Preview {
    let questDataService = QuestCoreDataService()
    DailyQuestsView(viewModel: DailyQuestsViewModel(questDataService: questDataService))
        .environmentObject(ThemeManager.shared)
}
