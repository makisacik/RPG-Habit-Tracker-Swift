//
//  QuestDetailComponents.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 11.11.2024.
//

import SwiftUI

// MARK: - Header Section Component
struct QuestDetailHeaderSection: View {
    let quest: Quest
    let theme: Theme
    
    var body: some View {
        VStack(spacing: 16) {
            // Quest Icon and Status
            HStack {
                questIcon
                Spacer()
                statusBadge
            }
            
            // Quest Title
            Text(quest.title)
                .font(.appFont(size: 28, weight: .black))
                .foregroundColor(theme.textColor)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Quest Description
            if !quest.info.isEmpty {
                Text(quest.info)
                    .font(.appFont(size: 16))
                    .foregroundColor(theme.textColor.opacity(0.8))
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(theme.primaryColor)
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
    }
    
    private var questIcon: some View {
        ZStack {
            Circle()
                .fill(questTypeColor.opacity(0.2))
                .frame(width: 60, height: 60)
            
            Image(systemName: questIconName)
                .font(.system(size: 24, weight: .medium))
                .foregroundColor(questTypeColor)
        }
    }
    
    private var statusBadge: some View {
        let (text, color) = statusInfo
        
        return Text(text)
            .font(.appFont(size: 12, weight: .black))
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(color)
            )
    }
    
    private var questIconName: String {
        if quest.isMainQuest {
            return "crown.fill"
        } else {
            switch quest.repeatType {
            case .daily: return "sun.max.fill"
            case .weekly: return "calendar.badge.clock"
            case .oneTime: return "target"
            }
        }
    }
    
    private var questTypeColor: Color {
        if quest.isMainQuest {
            return .yellow
        } else {
            switch quest.repeatType {
            case .daily: return .orange
            case .weekly: return .blue
            case .oneTime: return .purple
            }
        }
    }
    
    private var statusInfo: (String, Color) {
        if quest.isFinished {
            return (String.finished.localized, .gray)
        } else {
            return (String.active.localized, .blue)
        }
    }
}


// MARK: - Details Section Component
struct QuestDetailDetailsSection: View {
    let quest: Quest
    let theme: Theme
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text(String.questDetails.localized)
                    .font(.appFont(size: 18, weight: .bold))
                    .foregroundColor(theme.textColor)
                Spacer()
            }
            
            VStack(spacing: 12) {
                detailRow(
                    icon: "calendar",
                    title: String.questDueDate.localized,
                    value: dateFormatter.string(from: quest.dueDate),
                    theme: theme
                )
                
                detailRow(
                    icon: "clock",
                    title: String.created.localized,
                    value: dateFormatter.string(from: quest.creationDate),
                    theme: theme
                )
                
                detailRow(
                    icon: "repeat",
                    title: String.type.localized,
                    value: repeatTypeText,
                    theme: theme
                )
                
                if quest.isMainQuest {
                    detailRow(
                        icon: "crown.fill",
                                        title: String.mainQuestLabel.localized,
                value: String.yes.localized,
                        theme: theme
                    )
                }
                
                if let completionDate = quest.completionDate {
                    detailRow(
                        icon: "checkmark.circle.fill",
                        title: String.completedLabel.localized,
                        value: dateFormatter.string(from: completionDate),
                        theme: theme
                    )
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(theme.primaryColor)
                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
    }
    
    private func detailRow(icon: String, title: String, value: String, theme: Theme) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(theme.textColor.opacity(0.6))
                .frame(width: 20)
            
            Text(title)
                .font(.appFont(size: 14, weight: .medium))
                .foregroundColor(theme.textColor.opacity(0.8))
            
            Spacer()
            
            Text(value)
                .font(.appFont(size: 14))
                .foregroundColor(theme.textColor)
        }
    }
    
    private var repeatTypeText: String {
        switch quest.repeatType {
        case .daily: return String.daily.localized
        case .weekly: return String.weekly.localized
        case .oneTime: return String.oneTime.localized
        }
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }
}

// MARK: - Tasks Section Component
struct QuestDetailTasksSection: View {
    let quest: Quest
    let theme: Theme
    let onToggleTask: (QuestTask) -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("\(String.tasks.localized) (\(completedTasksCount)/\(quest.tasks.count))")
                    .font(.appFont(size: 18, weight: .bold))
                    .foregroundColor(theme.textColor)
                Spacer()
            }
            
            VStack(spacing: 8) {
                ForEach(quest.tasks, id: \.id) { task in
                    taskRow(task: task, theme: theme)
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(theme.primaryColor)
                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
    }
    
    private func taskRow(task: QuestTask, theme: Theme) -> some View {
        HStack(spacing: 12) {
            Button(action: {
                onToggleTask(task)
            }) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 18))
                    .foregroundColor(task.isCompleted ? .green : theme.textColor.opacity(0.6))
            }
            .buttonStyle(PlainButtonStyle())
            
            Text(task.title)
                .font(.appFont(size: 14))
                .foregroundColor(theme.textColor)
                .strikethrough(task.isCompleted)
                .opacity(task.isCompleted ? 0.6 : 1.0)
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
    
    private var completedTasksCount: Int {
        quest.tasks.filter { $0.isCompleted }.count
    }
}

// MARK: - Completion History Section Component
struct QuestDetailCompletionHistorySection: View {
    let quest: Quest
    let theme: Theme
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text(String.completionHistory.localized)
                    .font(.appFont(size: 18, weight: .bold))
                    .foregroundColor(theme.textColor)
                Spacer()
            }
            
            if quest.completions.isEmpty {
                                    Text(String.noCompletionsYet.localized)
                    .font(.appFont(size: 14))
                    .foregroundColor(theme.textColor.opacity(0.6))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 20)
            } else {
                LazyVStack(spacing: 8) {
                    ForEach(Array(quest.completions.sorted(by: >).prefix(5)), id: \.self) { date in
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                                .font(.system(size: 14))
                            
                            Text(dateFormatter.string(from: date))
                                .font(.appFont(size: 14))
                                .foregroundColor(theme.textColor)
                            
                            Spacer()
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(theme.primaryColor)
                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }
}

// MARK: - Action Buttons Section Component
struct QuestDetailActionButtonsSection: View {
    let quest: Quest
    let isCompleted: Bool
    let onToggleCompletion: () -> Void
    let onMarkAsFinished: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            Button(action: onToggleCompletion) {
                HStack {
                    Image(systemName: isCompleted ? "xmark.circle.fill" : "checkmark.circle.fill")
                        .font(.system(size: 18))
                                            Text(isCompleted ? String.markIncomplete.localized : String.markComplete.localized)
                        .font(.appFont(size: 16, weight: .bold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isCompleted ? .red : .green)
                )
            }
            .buttonStyle(PlainButtonStyle())
            
            if !quest.isFinished {
                Button(action: onMarkAsFinished) {
                    HStack {
                        Image(systemName: "flag.fill")
                            .font(.system(size: 18))
                        Text(String.markAsFinished.localized)
                            .font(.appFont(size: 16, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.orange)
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
}
