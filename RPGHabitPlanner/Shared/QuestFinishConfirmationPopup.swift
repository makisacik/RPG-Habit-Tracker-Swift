//
//  QuestFinishConfirmationPopup.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 7.01.2025.
//

import SwiftUI

struct QuestFinishConfirmationPopup: View {
    let quest: Quest
    let onConfirm: () -> Void
    let onCancel: () -> Void
    
    @EnvironmentObject var themeManager: ThemeManager
    
    private var confirmationMessage: String {
        switch quest.repeatType {
        case .oneTime:
            return "This is a one-time quest. Would you like to mark it as finished and receive your rewards?"
        case .daily:
            return "This daily quest has reached its final day. Would you like to mark it as finished and receive your rewards?"
        case .weekly:
            return "This weekly quest has reached its final week. Would you like to mark it as finished and receive your rewards?"
        case .scheduled:
            return "This scheduled quest has reached its final day. Would you like to mark it as finished and receive your rewards?"
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
                    
                    Text("Quest Finished!")
                        .font(.appFont(size: 20, weight: .bold))
                        .foregroundColor(theme.textColor)
                }
                
                // Quest details
                VStack(spacing: 8) {
                    Text(quest.title)
                        .font(.appFont(size: 16, weight: .medium))
                        .foregroundColor(theme.textColor)
                        .multilineTextAlignment(.center)
                    
                    if !quest.info.isEmpty {
                        Text(quest.info)
                            .font(.appFont(size: 14))
                            .foregroundColor(theme.textColor.opacity(0.7))
                            .multilineTextAlignment(.center)
                            .lineLimit(3)
                    }
                }
                
                // Confirmation message
                Text(confirmationMessage)
                    .font(.appFont(size: 14))
                    .foregroundColor(theme.textColor.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                // Action buttons
                HStack(spacing: 16) {
                    Button(action: onCancel) {
                        Text("Not Yet")
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
                            Text("Finish Quest")
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
        Text("Quest Finish Confirmation Popup Examples")
            .font(.title2)
            .padding()
        
        // One-time quest example
        QuestFinishConfirmationPopup(
            quest: Quest(
                title: "Sample One-Time Quest",
                isMainQuest: true,
                info: "This is a sample one-time quest description.",
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
        QuestFinishConfirmationPopup(
            quest: Quest(
                title: "Sample Daily Quest",
                isMainQuest: false,
                info: "This is a sample daily quest description.",
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
