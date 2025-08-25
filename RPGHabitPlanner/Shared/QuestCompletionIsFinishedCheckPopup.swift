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
            return String(localized: "quest_completion_one_time_message")
        case .daily:
            return String(localized: "quest_completion_daily_message")
        case .weekly:
            return String(localized: "quest_completion_weekly_message")
        case .scheduled:
            return String(localized: "quest_completion_scheduled_message")
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
                    
                    Text(String(localized: "quest_finish_confirmation"))
                        .font(.appFont(size: 20, weight: .bold))
                        .foregroundColor(theme.textColor)
                }
                
                // Completion check message
                Text(completionCheckMessage)
                    .font(.appFont(size: 14))
                    .foregroundColor(theme.textColor.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                // Action buttons
                HStack(spacing: 16) {
                    Button(action: onCancel) {
                        Text(String(localized: "not_yet"))
                            .font(.appFont(size: 16, weight: .medium))
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
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.white)
                            Text(String(localized: "finish_quest"))
                                .font(.appFont(size: 16, weight: .bold))
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(.green)
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
        Text(String(localized: "quest_completion_is_finished_check_popup_examples"))
            .font(.title2)
            .padding()
        
        // One-time quest example
        QuestCompletionIsFinishedCheckPopup(
            quest: Quest(
                title: String(localized: "sample_one_time_quest_title"),
                isMainQuest: true,
                info: String(localized: "sample_one_time_quest_description"),
                difficulty: 3,
                creationDate: Date(),
                dueDate: Date().addingTimeInterval(86400),
                isActive: true,
                progress: 100,
                repeatType: .oneTime
            ),
            onConfirm: {},
            onCancel: {}
        )
        .environmentObject(ThemeManager.shared)
        
        // Daily quest example
        QuestCompletionIsFinishedCheckPopup(
            quest: Quest(
                title: String(localized: "sample_daily_quest_title"),
                isMainQuest: false,
                info: String(localized: "sample_daily_quest_description"),
                difficulty: 2,
                creationDate: Date(),
                dueDate: Date().addingTimeInterval(7 * 86400), // 7 days from now
                isActive: true,
                progress: 100,
                repeatType: .daily
            ),
            onConfirm: {},
            onCancel: {}
        )
        .environmentObject(ThemeManager.shared)
    }
}
