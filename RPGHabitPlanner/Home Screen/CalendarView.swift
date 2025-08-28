//
//  CalendarView.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 11.11.2024.
//

import SwiftUI

struct CalendarView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var localizationManager: LocalizationManager
    @ObservedObject var viewModel: CalendarViewModel
    @State private var showingQuestCreation = false
    @State private var showingAlert = false
    @State private var selectedQuestItem: DayQuestItem?
    @State private var showTagFilter = false

    // Reward system state
    @State private var showReward = false
    @State private var completedQuest: Quest?
    @State private var showLevelUp = false
    @State private var levelUpLevel: Int = 0

    private let calendar = Calendar.current
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        formatter.locale = localizationManager.currentLocale
        return formatter
    }

    // MARK: - Body
    var body: some View {
        let theme = themeManager.activeTheme

        mainContent(theme: theme)
            .navigationTitle("calendar".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
            .onAppear {
                print("Calendar appear", ObjectIdentifier(viewModel))
                viewModel.refreshQuestData()
            }
            .onDisappear { print("Calendar disappear") }
            .sheet(isPresented: $showingQuestCreation, onDismiss: {
                viewModel.fetchQuests()
            }) {
                NavigationStack {
                    QuestCreationView(viewModel: makeCreationVM())
                }
            }
            .sheet(item: $selectedQuestItem) { questItem in
                QuestDetailSheet(
                    questItem: questItem,
                    themeManager: themeManager,
                    svc: viewModel.questDataService
                )
            }
            .onChange(of: viewModel.alertMessage) { msg in
                if msg != nil { showingAlert = true }
            }

            // Listen to CalendarViewModel signals → show overlays
            .onChange(of: viewModel.questCompleted) { completed in
                if completed && !showReward {
                    if let quest = viewModel.lastCompletedQuest {
                        completedQuest = quest
                    } else if let id = viewModel.lastCompletedQuestId,
                              let quest = viewModel.allQuests.first(where: { $0.id == id }) {
                        completedQuest = quest
                    }
                    showReward = (completedQuest != nil)
                    // Reset flag so we don't re-trigger when list refreshes
                    viewModel.questCompleted = false
                }
            }
            .onChange(of: showReward) { visible in
                if !visible, viewModel.didLevelUp, let lvl = viewModel.newLevel {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        levelUpLevel = Int(lvl)
                        showLevelUp = true
                    }
                }
            }

            .alert(isPresented: $showingAlert) {
                Alert(
                    title: Text("heads_up".localized),
                    message: Text(viewModel.alertMessage ?? ""),
                    dismissButton: .default(Text("ok_button".localized)) {
                        viewModel.alertMessage = nil
                    }
                )
            }
    }

    // MARK: - Extracted View Components
    @ViewBuilder
    private func mainContent(theme: Theme) -> some View {
        ZStack {
            theme.backgroundColor.ignoresSafeArea()
            CalendarViewComponents.mainContentView(
                theme: theme,
                showTagFilter: showTagFilter,
                viewModel: viewModel,
                selectedQuestItem: $selectedQuestItem,
                showingQuestCreation: $showingQuestCreation,
                onTagFilterToggle: {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        showTagFilter.toggle()
                    }
                },
                onQuestTap: { item in
                    selectedQuestItem = item
                }
            )
            CalendarViewComponents.overlayViews(
                theme: theme,
                viewModel: viewModel
            )

            // Reward overlays
            if let quest = completedQuest, showReward {
                RewardView(isVisible: $showReward, quest: quest)
                    .id("reward-\(quest.id)")
                    .zIndex(50)
            }
            LevelUpView(isVisible: $showLevelUp, level: levelUpLevel)
                .zIndex(50)

            // Reward Toast Container
            RewardToastContainerView()
                .zIndex(70)
        }
    }

    // MARK: - VM factory (moved out of body)
    private func makeCreationVM() -> QuestCreationViewModel {
        let creationViewModel = QuestCreationViewModel(questDataService: viewModel.questDataService)
        creationViewModel.questDueDate = viewModel.selectedDate
        return creationViewModel
    }
}


// MARK: - Quest Detail Sheet wrapper (reduces generic bloat)
private struct QuestDetailSheet: View {
    let questItem: DayQuestItem
    let themeManager: ThemeManager
    let svc: QuestDataServiceProtocol
    var body: some View {
        NavigationStack {
            QuestDetailView(
                quest: questItem.quest,
                date: questItem.date,
                questDataService: svc
            )
            .environmentObject(themeManager)
        }
    }
}

// MARK: - Day Cell
struct CalendarDayView: View {
    let date: Date
    let isSelected: Bool
    let items: [DayQuestItem]
    let theme: Theme
    let onTap: () -> Void
    private let calendar = Calendar.current

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 2) {
                Text("\(calendar.component(.day, from: date))")
                    .font(.appFont(size: 16, weight: isSelected ? .bold : .medium))
                    .foregroundColor(selectionTextColor)

                // Fixed height container for dots to ensure consistent sizing
                HStack(spacing: 2) {
                    if !items.isEmpty {
                        ForEach(items.prefix(3)) { item in
                            Circle()
                                .fill(dotColor(for: item))
                                .frame(width: 8, height: 8)
                                .overlay(
                                    Text(shortType(item.quest.repeatType))
                                        .font(.system(size: 7, weight: .black))
                                        .foregroundColor(.white)
                                )
                        }
                    }
                }
                .frame(height: 8) // Fixed height for the dots row
                .frame(maxWidth: .infinity) // Center the dots horizontally
            }
            .frame(width: 40, height: 40)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(selectionBackgroundColor)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }

    private var selectionTextColor: Color {
        if isSelected {
            // Keep text visible across themes
            if theme.backgroundColor == Color(hex: "#F0F0F0") {
                return theme.textColor
            } else {
                return .white
            }
        } else {
            return theme.textColor
        }
    }

    private var selectionBackgroundColor: Color {
        if isSelected {
            if theme.backgroundColor == Color(hex: "#F0F0F0") {
                return Color(hex: "#E2E8F0").opacity(0.8)
            } else {
                return theme.primaryColor
            }
        } else {
            return Color.clear
        }
    }

    private func dotColor(for item: DayQuestItem) -> Color {
        switch item.state {
        case .done: return .green
        case .todo:
            switch item.quest.repeatType {
            case .daily: return .orange
            case .weekly: return .blue
            case .oneTime: return .orange
            case .scheduled: return .purple
            }
        case .inactive: return .gray
        }
    }

    private func shortType(_ repeatType: QuestRepeatType) -> String {
        switch repeatType {
        case .daily: return "D"
        case .weekly: return "W"
        case .oneTime: return "O"
        case .scheduled: return "S"
        }
    }
}

// MARK: - Quest Row
struct QuestCalendarRow: View {
    @State private var isExpanded: Bool = false
    @State private var showingQuestDetail = false

    let item: DayQuestItem
    let theme: Theme
    let onToggle: () -> Void
    let onMarkFinished: () -> Void
    let onToggleTaskCompletion: (UUID, Bool) -> Void
    let onQuestTap: (DayQuestItem) -> Void

    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(alignment: .leading, spacing: 0) {
                // Main quest row
                HStack(spacing: 10) {
                    Circle()
                        .fill(indicatorColor)
                        .frame(width: 8, height: 8)
                    VStack(alignment: .leading, spacing: 1) {
                        Text(item.quest.title)
                            .font(.appFont(size: 15, weight: .medium))
                            .foregroundColor(theme.textColor.opacity(item.state == .done ? 0.7 : 1.0))
                            .lineLimit(1)
                        Text(subtitle)
                            .font(.appFont(size: 11, weight: .black))
                            .foregroundColor(theme.textColor.opacity(item.state == .done ? 0.5 : 0.7))
                    }
                    Spacer()

                    Button(action: onToggle) {
                        Image(systemName: item.state == .done ? "checkmark.circle.fill" : "circle")
                            .font(.title3)
                            .foregroundColor(item.state == .done ? .green : theme.textColor.opacity(0.6))
                    }

                    // Flag button next to quest completion toggle
                    Button(action: {
                        onMarkFinished()
                    }) {
                        Image(systemName: "flag.fill")
                            .font(.title3)
                            .foregroundColor(.orange)
                    }
                    .padding(.trailing, 12)
                }
                .padding(12)
                .contentShape(Rectangle())
                .onTapGesture { onQuestTap(item) }

                // Tasks section
                let tasks = item.quest.tasks
                if !tasks.isEmpty {
                    Divider()
                        .background(theme.textColor.opacity(0.2))
                        .padding(.horizontal, 12)

                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            isExpanded.toggle()
                        }
                    }) {
                        HStack {
                            Text("\(tasks.count) \(("tasks".localized))")
                                .font(.appFont(size: 12, weight: .medium))
                                .foregroundColor(theme.textColor.opacity(0.8))
                            Spacer()
                            Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                                .foregroundColor(theme.textColor.opacity(0.6))
                                .imageScale(.small)
                                .font(.caption)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(PlainButtonStyle())

                    if isExpanded {
                        VStack(alignment: .leading, spacing: 4) {
                            ForEach(tasks, id: \.id) { task in
                                HStack(spacing: 8) {
                                    Button(action: {
                                        onToggleTaskCompletion(task.id, !task.isCompleted)
                                    }) {
                                        Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle.fill")
                                            .resizable()
                                            .frame(width: 14, height: 14)
                                            .foregroundColor(task.isCompleted ? .green : .gray)
                                    }
                                    .buttonStyle(PlainButtonStyle())

                                    Text(task.title)
                                        .font(.appFont(size: 12))
                                        .foregroundColor(theme.textColor.opacity(0.9))
                                        .strikethrough(task.isCompleted)

                                    Spacer()
                                }
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    onToggleTaskCompletion(task.id, !task.isCompleted)
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 4)
                            }
                        }
                        .padding(.bottom, 12)
                        .transition(.opacity.combined(with: .slide))
                    }
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(theme.primaryColor.opacity(item.state == .done ? 0.8 : 1.0))
                    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
            )
            .padding(.horizontal, 4)
            .padding(.vertical, 2)
        }
    }

    private var indicatorColor: Color {
        switch item.state {
        case .done: return .green
        case .todo: return .orange
        case .inactive: return .gray
        }
    }

    private var subtitle: String {
        switch item.quest.repeatType {
        case .daily: return "daily".localized
        case .weekly: return "weekly".localized
        case .oneTime: return "one_time".localized
        case .scheduled: return "scheduled".localized
        }
    }
}
