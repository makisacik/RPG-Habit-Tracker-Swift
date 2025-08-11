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
            return ("Finished", .gray)
        } else {
            return ("Active", .blue)
        }
    }
}

// MARK: - Progress Section Component
struct QuestDetailProgressSection: View {
    let quest: Quest
    let theme: Theme
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Progress")
                    .font(.appFont(size: 18, weight: .bold))
                    .foregroundColor(theme.textColor)
                Spacer()
                Text("\(quest.progress)%")
                    .font(.appFont(size: 16, weight: .medium))
                    .foregroundColor(theme.textColor.opacity(0.7))
            }
            
            // Progress Bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(theme.textColor.opacity(0.2))
                        .frame(height: 12)
                    
                    RoundedRectangle(cornerRadius: 8)
                        .fill(progressColor)
                        .frame(width: geometry.size.width * CGFloat(quest.progress) / 100, height: 12)
                        .animation(.easeInOut(duration: 0.5), value: quest.progress)
                }
            }
            .frame(height: 12)
            
            // Difficulty Stars
            HStack(spacing: 4) {
                Text("Difficulty:")
                    .font(.appFont(size: 14))
                    .foregroundColor(theme.textColor.opacity(0.7))
                
                ForEach(1...5, id: \.self) { star in
                    Image(systemName: star <= quest.difficulty ? "star.fill" : "star")
                        .font(.system(size: 12))
                        .foregroundColor(star <= quest.difficulty ? .orange : theme.textColor.opacity(0.3))
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
    
    private var progressColor: Color {
        if quest.progress >= 80 {
            return .green
        } else if quest.progress >= 50 {
            return .orange
        } else {
            return .red
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
                Text("Quest Details")
                    .font(.appFont(size: 18, weight: .bold))
                    .foregroundColor(theme.textColor)
                Spacer()
            }
            
            VStack(spacing: 12) {
                detailRow(
                    icon: "calendar",
                    title: "Due Date",
                    value: dateFormatter.string(from: quest.dueDate),
                    theme: theme
                )
                
                detailRow(
                    icon: "clock",
                    title: "Created",
                    value: dateFormatter.string(from: quest.creationDate),
                    theme: theme
                )
                
                detailRow(
                    icon: "repeat",
                    title: "Type",
                    value: repeatTypeText,
                    theme: theme
                )
                
                if quest.isMainQuest {
                    detailRow(
                        icon: "crown.fill",
                        title: "Main Quest",
                        value: "Yes",
                        theme: theme
                    )
                }
                
                if let completionDate = quest.completionDate {
                    detailRow(
                        icon: "checkmark.circle.fill",
                        title: "Completed",
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
        case .daily: return "Daily"
        case .weekly: return "Weekly"
        case .oneTime: return "One-time"
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
                Text("Tasks (\(completedTasksCount)/\(quest.tasks.count))")
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
                Text("Completion History")
                    .font(.appFont(size: 18, weight: .bold))
                    .foregroundColor(theme.textColor)
                Spacer()
            }
            
            if quest.completions.isEmpty {
                Text("No completions yet")
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
            // Toggle Completion Button
            Button(action: onToggleCompletion) {
                HStack {
                    Image(systemName: isCompleted ? "xmark.circle.fill" : "checkmark.circle.fill")
                        .font(.system(size: 18))
                    Text(isCompleted ? "Mark Incomplete" : "Mark Complete")
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
            
            // Mark as Finished Button
            if !quest.isFinished {
                Button(action: onMarkAsFinished) {
                    HStack {
                        Image(systemName: "flag.fill")
                            .font(.system(size: 18))
                        Text("Mark as Finished")
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
