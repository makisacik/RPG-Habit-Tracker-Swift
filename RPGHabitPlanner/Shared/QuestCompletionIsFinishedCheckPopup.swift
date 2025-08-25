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
            return "Is this quest finished? This one-time quest will be marked as completed for today."
        case .daily:
            return "Is this quest finished? This daily quest will be marked as completed for today."
        case .weekly:
            return "Is this quest finished? This weekly quest will be marked as completed for this week."
        case .scheduled:
            return "Is this quest finished? This scheduled quest will be marked as completed for today."
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
                    
                    Text("Is this quest finished?")
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
                        Text("Not yet")
                            .font(.appFont(size: 16, weight: .medium))
                            .foregroundColor(theme.textColor)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(theme.primaryColor)
                            )
                    }
                    
                    Button(action: onConfirm) {
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.white)
                            Text("Yes, mark as done")
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
        Text("Quest Completion Is Finished Check Popup Examples")
            .font(.title2)
            .padding()
        
        // One-time quest example
        QuestCompletionIsFinishedCheckPopup(
            quest: Quest(
                title: "Sample One-Time Quest",
                isMainQuest: true,
                info: "This is a sample one-time quest description",
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
                title: "Sample Daily Quest",
                isMainQuest: false,
                info: "This is a sample daily quest description",
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
