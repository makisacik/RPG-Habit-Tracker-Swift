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
            case .scheduled: return "calendar.badge.clock"
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
            case .scheduled: return .purple
            }
        }
    }

    private var statusInfo: (String, Color) {
        if quest.isFinished {
            return ("finished".localized, .gray)
        } else {
            return ("active".localized, .blue)
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
                Text("quest_details".localized)
                    .font(.appFont(size: 18, weight: .bold))
                    .foregroundColor(theme.textColor)
                Spacer()
            }

            VStack(spacing: 12) {
                detailRow(
                    icon: "calendar",
                    title: "quest_due_date".localized,
                    value: dateFormatter.string(from: quest.dueDate),
                    theme: theme
                )

                detailRow(
                    icon: "clock",
                    title: "created".localized,
                    value: dateFormatter.string(from: quest.creationDate),
                    theme: theme
                )

                detailRow(
                    icon: "repeat",
                    title: "type".localized,
                    value: repeatTypeText,
                    theme: theme
                )

                if let completionDate = quest.completionDate {
                    detailRow(
                        icon: "checkmark.circle.fill",
                        title: "completed".localized,
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
        case .daily: return "daily".localized
        case .weekly: return "weekly".localized
        case .oneTime: return "one_time".localized
        case .scheduled: return "scheduled".localized
        }
    }

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = LocalizationManager.shared.currentLocale
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
                Text("\("tasks".localized) (\(completedTasksCount)/\(quest.tasks.count))")
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
                // Provide haptic feedback for task toggle
                if task.isCompleted {
                    HapticFeedbackManager.shared.taskUncompleted()
                } else {
                    HapticFeedbackManager.shared.taskCompleted()
                }
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
        .contentShape(Rectangle())
        .onTapGesture {
            // Provide haptic feedback for task toggle
            if task.isCompleted {
                HapticFeedbackManager.shared.taskUncompleted()
            } else {
                HapticFeedbackManager.shared.taskCompleted()
            }
            onToggleTask(task)
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
                Text("completion_history".localized)
                    .font(.appFont(size: 18, weight: .bold))
                    .foregroundColor(theme.textColor)
                Spacer()
            }

            if quest.completions.isEmpty {
                                    Text("no_completions_yet".localized)
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
        formatter.locale = LocalizationManager.shared.currentLocale
        return formatter
    }
}

// MARK: - Damage History Section Component
struct QuestDetailDamageHistorySection: View {
    @StateObject private var damageTrackingManager = QuestDamageTrackingManager.shared
    let quest: Quest
    let theme: Theme
    
    @State private var damageEvents: [DamageEvent] = []
    @State private var totalDamage: Int = 0
    @State private var isLoading = true
    @State private var showFullDamageHistory = false
    @State private var showDamageInfo = false

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.red)

                    Text("damage_history".localized)
                        .font(.appFont(size: 18, weight: .bold))
                        .foregroundColor(theme.textColor)
                }

                Spacer()

                HStack(spacing: 12) {
                    if totalDamage > 0 {
                        Text("total_damage".localized(with: String(totalDamage)))
                            .font(.appFont(size: 16, weight: .medium))
                            .foregroundColor(theme.textColor)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.red.opacity(0.1))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.red.opacity(0.3), lineWidth: 1)
                                    )
                            )
                    }
                    
                    Button(action: {
                        showDamageInfo = true
                    }) {
                        Image(systemName: "info.circle")
                            .font(.system(size: 16))
                            .foregroundColor(theme.accentColor)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }

            if isLoading {
                HStack {
                    ProgressView()
                        .scaleEffect(0.8)
                    Text("loading_damage_history".localized)
                        .font(.appFont(size: 14))
                        .foregroundColor(theme.textColor.opacity(0.7))
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 20)
            } else if damageEvents.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 24, weight: .light))
                        .foregroundColor(.green)

                    Text("no_damage_taken".localized)
                        .font(.appFont(size: 14, weight: .medium))
                        .foregroundColor(theme.textColor.opacity(0.7))
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 20)
            } else {
                VStack(spacing: 8) {
                    // Show recent damage events (up to 3)
                    ForEach(Array(damageEvents.prefix(3)), id: \.id) { event in
                        HStack {
                            Image(systemName: "heart.fill")
                                .foregroundColor(.red)
                                .font(.system(size: 12))

                            Text("damage_amount".localized(with: String(event.damageAmount)))
                                .font(.appFont(size: 14, weight: .bold))
                                .foregroundColor(.red)
                                .frame(width: 40, alignment: .leading)

                            Text(event.reason)
                                .font(.appFont(size: 12))
                                .foregroundColor(theme.textColor.opacity(0.8))
                                .lineLimit(1)

                            Spacer()

                            Text(event.date.formatted(date: .abbreviated, time: .omitted))
                                .font(.appFont(size: 10))
                                .foregroundColor(theme.textColor.opacity(0.5))
                        }
                        .padding(.vertical, 2)
                    }

                    // Show "View More" button if there are more events
                    if damageEvents.count > 3 {
                        Button(action: {
                            showFullDamageHistory = true
                        }) {
                            HStack {
                                Text("view_all_damage_events".localized(with: damageEvents.count))
                                    .font(.appFont(size: 12, weight: .medium))
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 10))
                            }
                            .foregroundColor(theme.accentColor)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(.top, 4)
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
        .onAppear {
            loadDamageHistory()
        }
        .sheet(isPresented: $showFullDamageHistory) {
            DamageHistoryView(
                questId: quest.id,
                questTitle: quest.title
            )
            .environmentObject(ThemeManager.shared)
        }
        .alert("damage_info_title".localized, isPresented: $showDamageInfo) {
            Button("OK") { }
        } message: {
            Text("damage_info_message".localized)
        }
    }
    
    private func loadDamageHistory() {
        isLoading = true
        
        damageTrackingManager.getDamageHistory(for: quest.id) { events, error in
            DispatchQueue.main.async {
                isLoading = false
                
                if let error = error {
                    print("Error loading damage history: \(error)")
                    damageEvents = []
                    totalDamage = 0
                } else {
                    damageEvents = events
                    totalDamage = events.reduce(0) { $0 + $1.damageAmount }
                }
            }
        }
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
            Button(action: {
                // Provide haptic feedback for toggle completion action
                if isCompleted {
                    HapticFeedbackManager.shared.questUncompleted()
                } else {
                    HapticFeedbackManager.shared.questCompleted()
                }
                onToggleCompletion()
            }) {
                HStack {
                    Image(systemName: isCompleted ? "xmark.circle.fill" : "checkmark.circle.fill")
                        .font(.system(size: 18))
                                            Text(isCompleted ? "mark_incomplete".localized : "mark_complete".localized)
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
                Button(action: {
                    // Provide haptic feedback for mark as finished action
                    HapticFeedbackManager.shared.questFinished()
                    onMarkAsFinished()
                }) {
                    HStack {
                        Image(systemName: "flag.fill")
                            .font(.system(size: 18))
                        Text("mark_as_finished".localized)
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
