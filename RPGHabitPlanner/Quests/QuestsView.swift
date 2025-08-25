//
//  QuestsView.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 6.08.2025.
//

import SwiftUI

struct QuestsView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @StateObject var viewModel: QuestsViewModel
    @State private var selectedQuestItem: DayQuestItem?
    @State private var showingQuestCreation = false
    @State private var showAlert: Bool = false

    // Reward and level-up overlay states
    @State private var showReward = false
    @State private var completedQuest: Quest?
    @State private var showLevelUp = false
    @State private var levelUpLevel: Int = 0

    let questDataService: QuestDataServiceProtocol

    private let calendar = Calendar.current
    private let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MMM d"
        return dateFormatter
    }()

    var body: some View {
        let theme = themeManager.activeTheme

        ZStack {
            theme.backgroundColor.ignoresSafeArea()

            VStack(spacing: 0) {
                // Header with date selection
                VStack(spacing: 16) {
                    HStack {
                        Text(String(localized: "my_quests"))
                            .font(.appFont(size: 24, weight: .bold))
                            .foregroundColor(theme.textColor)

                        Spacer()

                        // Date navigation
                        dateNavigationView(theme: theme)
                    }

                    // Quest count summary
                    questCountSummary(theme: theme)
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)

                // Quests list
                ScrollView {
                    VStack(spacing: 0) {
                        if viewModel.isLoading && viewModel.allQuests.isEmpty {
                            loadingView(theme: theme)
                        } else if !viewModel.itemsForSelectedDate.isEmpty {
                            questsListContent(theme: theme)
                        } else {
                            emptyStateView(theme: theme)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
            }

            // Reward and level-up overlays
            if let quest = completedQuest, showReward {
                RewardView(isVisible: $showReward, quest: quest)
                    .id("reward-\(quest.id)")
                    .zIndex(50)
            }
            LevelUpView(isVisible: $showLevelUp, level: levelUpLevel)
                .zIndex(50)

            // Quest finish confirmation popup
            if viewModel.showFinishConfirmation, let quest = viewModel.questToFinish {
                QuestFinishConfirmationPopup(
                    quest: quest,
                    onConfirm: {
                        viewModel.markQuestAsFinished(questId: quest.id)
                        viewModel.showFinishConfirmation = false
                        viewModel.questToFinish = nil
                    },
                    onCancel: {
                        viewModel.showFinishConfirmation = false
                        viewModel.questToFinish = nil
                    }
                )
                .zIndex(60)
            }

            // Reward Toast Container
            RewardToastContainerView()
                .zIndex(70)
        }
        .navigationTitle(String.questJournal.localized)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingQuestCreation, onDismiss: {
            viewModel.fetchQuests()
        }) {
            NavigationStack {
                QuestCreationView(viewModel: createQuestCreationViewModel())
            }
        }
        .sheet(item: $selectedQuestItem) { questItem in
            NavigationStack {
                QuestDetailView(
                    quest: questItem.quest,
                    date: questItem.date,
                    questDataService: questDataService
                )
                .environmentObject(themeManager)
            }
        }
        .onChange(of: viewModel.alertMessage) { alertMessage in
            showAlert = alertMessage != nil
        }
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
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text(String.errorTitle.localized).font(.appFont(size: 16, weight: .black)),
                message: Text(viewModel.alertMessage ?? String.unknownError.localized).font(.appFont(size: 14)),
                dismissButton: .default(Text(String.okButton.localized).font(.appFont(size: 14, weight: .black))) { viewModel.alertMessage = nil }
            )
        }
        .onAppear {
            viewModel.refreshQuestData()
        }
    }

    // MARK: - Helper Views

    @ViewBuilder
    private func dateNavigationView(theme: Theme) -> some View {
        HStack(spacing: 12) {
            Button(action: previousDay) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(theme.textColor)
            }

            Text(dateFormatter.string(from: viewModel.selectedDate))
                .font(.appFont(size: 16, weight: .medium))
                .foregroundColor(theme.textColor)
                .multilineTextAlignment(.center)
                .frame(width: 150, alignment: .center)

            Button(action: nextDay) {
                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(theme.textColor)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(theme.primaryColor.opacity(0.3))
        )
    }

    @ViewBuilder
    private func questCountSummary(theme: Theme) -> some View {
        HStack {
            Spacer()

            Button(String(localized: "create_quest")) {
                showingQuestCreation = true
            }
            .font(.appFont(size: 14, weight: .medium))
            .foregroundColor(.blue)
        }
    }

    @ViewBuilder
    private func loadingView(theme: Theme) -> some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
                .progressViewStyle(CircularProgressViewStyle(tint: theme.accentColor))

            Text(String(localized: "loading_quests"))
                .font(.appFont(size: 16))
                .foregroundColor(theme.textColor.opacity(0.7))
                .padding(.top, 8)
        }
        .padding(.vertical, 12)
    }

    @ViewBuilder
    private func questsListContent(theme: Theme) -> some View {
        VStack(spacing: 8) {
            ForEach(viewModel.itemsForSelectedDate) { item in
                QuestRow(
                    item: item,
                    theme: theme,
                    onToggle: {
                        viewModel.toggle(item: item)
                    },
                    onMarkFinished: {
                        // Flag button should always show confirmation dialog
                        viewModel.questToFinish = item.quest
                        viewModel.showFinishConfirmation = true
                    },
                    onToggleTaskCompletion: { taskId, isCompleted in
                        viewModel.toggleTaskCompletion(
                            questId: item.quest.id,
                            taskId: taskId,
                            newValue: isCompleted
                        )
                    },
                    onQuestTap: { questItem in
                        selectedQuestItem = questItem
                    }
                )
                .transition(.asymmetric(
                    insertion: .scale.combined(with: .opacity),
                    removal: .scale.combined(with: .opacity)
                ))
            }
        }
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: viewModel.itemsForSelectedDate.map { $0.id })
    }

    @ViewBuilder
    private func emptyStateView(theme: Theme) -> some View {
        VStack(spacing: 8) {
            Image(systemName: "list.bullet.clipboard")
                .font(.system(size: 32))
                .foregroundColor(theme.textColor.opacity(0.5))

            Text(String(localized: "no_quests_for_date").localized(with: dateFormatter.string(from: viewModel.selectedDate)))
                .font(.appFont(size: 16))
                .foregroundColor(theme.textColor.opacity(0.7))

            Button("Create Quest") {
                showingQuestCreation = true
            }
            .font(.appFont(size: 14, weight: .medium))
            .foregroundColor(.blue)
        }
        .frame(height: 100)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(theme.primaryColor.opacity(0.5))
        )
    }

    // MARK: - Helper Methods

    private func createQuestCreationViewModel() -> QuestCreationViewModel {
        let creationVM = QuestCreationViewModel(questDataService: questDataService)
        creationVM.questDueDate = viewModel.selectedDate
        return creationVM
    }

    private func previousDay() {
        if let newDate = calendar.date(byAdding: .day, value: -1, to: viewModel.selectedDate) {
            viewModel.selectedDate = calendar.startOfDay(for: newDate)
        }
    }

    private func nextDay() {
        if let newDate = calendar.date(byAdding: .day, value: 1, to: viewModel.selectedDate) {
            viewModel.selectedDate = calendar.startOfDay(for: newDate)
        }
    }
}

struct QuestRow: View {
    @State private var isExpanded: Bool = true // Tasks are expanded by default

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
                .onTapGesture {
                    onQuestTap(item)
                }

                // Tasks section (if quest has tasks)
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
                            Text("\(tasks.count) \(String(localized: "tasks"))")
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
                                .padding(.horizontal, 12)
                                .padding(.vertical, 4)
                            }
                        }
                        .padding(.bottom, 12)
                        .transition(.opacity.combined(with: .move(edge: .top)))
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
        case .daily: return "Daily"
        case .weekly: return "Weekly"
        case .oneTime: return "One-time"
        case .scheduled: return "Scheduled"
        }
    }
}

#Preview {
    let questDataService = QuestCoreDataService()
    QuestsView(
        viewModel: QuestsViewModel(
            questDataService: questDataService,
            userManager: UserManager()
        ),
        questDataService: questDataService
    )
    .environmentObject(ThemeManager.shared)
}
