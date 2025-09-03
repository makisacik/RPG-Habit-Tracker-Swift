//
//  QuestCompletionIsFinishedCheckPopup.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 7.01.2025.
//

import SwiftUI

struct QuestCompletionIsFinishedCheckPopup: View {
    let quest: Quest
    let onConfirm: () -> Void
    let onCancel: () -> Void
    
    @EnvironmentObject var themeManager: ThemeManager
    
    private var completionCheckMessage: String {
        switch quest.repeatType {
        case .oneTime:
            return "quest_completion_one_time_message".localized
        case .daily:
            return "quest_completion_daily_message".localized
        case .weekly:
            return "quest_completion_weekly_message".localized
        case .scheduled:
            return "quest_completion_scheduled_message".localized
        }
    }
    
    var body: some View {
        let theme = themeManager.activeTheme
        
        ZStack {
            // Background overlay
            Color.black.opacity(0.6)
                .ignoresSafeArea()
                .onTapGesture {
                    onCancel()
                }
            
            // Popup content
            VStack(spacing: 20) {
                // Header with quest icon
                VStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(quest.isMainQuest ? .orange : .blue)
                            .frame(width: 60, height: 60)
                        
                        Image(systemName: quest.isMainQuest ? "star.fill" : "target")
                            .font(.system(size: 24, weight: .medium))
                            .foregroundColor(.white)
                    }
                    
                    Text("quest_finish_confirmation".localized)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(theme.textColor)
                }
                
                // Completion check message
                Text(completionCheckMessage)
                    .font(.system(size: 14))
                    .foregroundColor(theme.textColor.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                // Action buttons
                HStack(spacing: 16) {
                    Button(action: onCancel) {
                        Text("not_yet".localized)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(theme.textColor)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(theme.primaryColor)
                            )
                    }
                    
                    Button(action: {
                        // Provide success haptic feedback when user confirms quest is finished
                        HapticFeedbackManager.shared.questFinished()
                        onConfirm()
                    }) {
                        Text("done".localized)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(theme.textColor)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(theme.primaryColor)
                            )
                    }
                }
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(theme.backgroundColor)
                    .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
            )
            .padding(.horizontal, 20)
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        Text("quest_completion_is_finished_check_popup_examples".localized)
            .font(.title2)
            .padding()
        
        // One-time quest example
        QuestCompletionIsFinishedCheckPopup(
            quest: Quest(
                title: "sample_one_time_quest_title".localized,
                isMainQuest: true,
                info: "sample_one_time_quest_description".localized,
                difficulty: 3,
                creationDate: Date(),
                dueDate: Date().addingTimeInterval(86400),
                isActive: true,
                progress: 100,
                repeatType: .oneTime,
                reminderTimes: [],
                enableReminders: false
            ),
            onConfirm: {},
            onCancel: {}
        )
        .environmentObject(ThemeManager.shared)
        
        // Daily quest example
        QuestCompletionIsFinishedCheckPopup(
            quest: Quest(
                title: "sample_daily_quest_title".localized,
                isMainQuest: false,
                info: "sample_daily_quest_description".localized,
                difficulty: 2,
                creationDate: Date(),
                dueDate: Date().addingTimeInterval(7 * 86400), // 7 days from now
                isActive: true,
                progress: 100,
                repeatType: .daily,
                reminderTimes: [],
                enableReminders: false
            ),
            onConfirm: {},
            onCancel: {}
        )
        .environmentObject(ThemeManager.shared)
    }
}
