//
//  QuestsView.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 6.08.2025.
//

import SwiftUI

struct QuestsView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var localizationManager: LocalizationManager
    @EnvironmentObject var premiumManager: PremiumManager
    @StateObject var viewModel: QuestsViewModel
    @State private var selectedQuestItem: DayQuestItem?
    @State private var showingQuestCreation = false
    @State private var showAlert: Bool = false

    // Reward and level-up overlay states
    @State private var showReward = false
    @State private var completedQuest: Quest?
    @State private var showLevelUp = false
    @State private var levelUpLevel: Int = 0
    @State private var showCalendar = false

    let questDataService: QuestDataServiceProtocol

    private let calendar = Calendar.current
    private var dateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MMM d"
        dateFormatter.locale = localizationManager.currentLocale
        return dateFormatter
    }

    var body: some View {
        let theme = themeManager.activeTheme
        
        mainContent(theme: theme)
            .navigationTitle("quest_journal".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { showCalendar = true }) {
                        Image(systemName: "calendar")
                            .font(.title2)
                            .foregroundColor(theme.textColor)
                    }
                }
            }
            .sheet(isPresented: $showingQuestCreation, onDismiss: {
                viewModel.fetchQuests()
            }) {
                NavigationStack {
                    QuestCreationView(viewModel: createQuestCreationViewModel())
                        .environmentObject(themeManager)
                        .environmentObject(premiumManager)
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
            .sheet(isPresented: $showCalendar) {
                NavigationStack {
                    CalendarView(viewModel: CalendarViewModel(questDataService: questDataService, userManager: viewModel.userManager))
                        .environmentObject(themeManager)
                }
            }
            .onChange(of: viewModel.alertMessage) { alertMessage in
                showAlert = alertMessage != nil
            }
            .onChange(of: viewModel.questCompleted) { completed in
                handleQuestCompletion(completed)
            }
            .onChange(of: showReward) { visible in
                handleRewardVisibilityChange(visible)
            }
            .alert(isPresented: $showAlert) {
                createAlert()
            }
            .onAppear {
                viewModel.refreshQuestData()
            }
    }
    
    // MARK: - Main Content
    
    @ViewBuilder
    private func mainContent(theme: Theme) -> some View {
        ZStack {
            theme.backgroundColor.ignoresSafeArea()
            
            VStack(spacing: 0) {
                headerSection(theme: theme)
                questsListSection(theme: theme)
            }
            
            overlaysSection(theme: theme)
        }
    }
    
    @ViewBuilder
    private func headerSection(theme: Theme) -> some View {
        VStack(spacing: 16) {
            HStack {
                Text("my_quests".localized)
                    .font(.appFont(size: 24, weight: .bold))
                    .foregroundColor(theme.textColor)

                Spacer()

                dateNavigationView(theme: theme)
            }

            questCountSummary(theme: theme)
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
    }
    
    @ViewBuilder
    private func questsListSection(theme: Theme) -> some View {
        ScrollView {
            VStack(spacing: 0) {
                if viewModel.isLoading && !viewModel.hasInitialData {
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
        .scrollIndicators(.hidden)
    }
    
    @ViewBuilder
    private func overlaysSection(theme: Theme) -> some View {
        // Reward and level-up overlays
        if let quest = completedQuest, showReward {
            RewardView(isVisible: $showReward, quest: quest)
                .id("reward-\(quest.id)")
                .zIndex(50)
        }
        
        LevelUpView(isVisible: $showLevelUp, level: levelUpLevel)
            .zIndex(50)

        // Quest completion is finished check popup (when completion is toggled)
        if viewModel.showCompletionIsFinishedCheck, let quest = viewModel.questToCheckCompletion {
            QuestCompletionIsFinishedCheckPopup(
                quest: quest,
                onConfirm: {
                    viewModel.handleCompletionIsFinishedCheck(questId: quest.id)
                },
                onCancel: {
                    viewModel.showCompletionIsFinishedCheck = false
                    viewModel.questToCheckCompletion = nil
                }
            )
            .zIndex(60)
        }

        // Quest finish confirmation popup (when finished button is tapped)
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
        }
    }

    @ViewBuilder
    private func loadingView(theme: Theme) -> some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
                .progressViewStyle(CircularProgressViewStyle(tint: theme.accentColor))

            Text("loading_quests".localized)
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
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: viewModel.questsLastUpdated)
    }

    @ViewBuilder
    private func emptyStateView(theme: Theme) -> some View {
        VStack(spacing: 16) {
            Spacer()

            VStack(spacing: 8) {
                Image(systemName: "list.bullet.clipboard")
                    .font(.system(size: 48))
                    .foregroundColor(theme.textColor.opacity(0.3))

                Text("no_quests_for_date".localized.localized(with: dateFormatter.string(from: viewModel.selectedDate)))
                    .font(.appFont(size: 16))
                    .foregroundColor(theme.textColor.opacity(0.7))
            }

            Spacer()

            Button(action: { showingQuestCreation = true }) {
                HStack {
                    Spacer()
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundColor(theme.textColor)
                    Text("create_quest".localized)
                        .font(.appFont(size: 16, weight: .black))
                        .foregroundColor(theme.textColor)
                    Spacer()
                }
                .padding()
                .background(
                    Image(theme.buttonPrimary)
                        .resizable(
                            capInsets: EdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20),
                            resizingMode: .stretch
                        )
                )
                .frame(maxWidth: .infinity, minHeight: 44, maxHeight: 44)
            }
            .buttonStyle(PlainButtonStyle())

            Spacer()
        }
        .padding(.top, 8)
    }

    // MARK: - Helper Methods
    
    private func handleQuestCompletion(_ completed: Bool) {
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
    
    private func handleRewardVisibilityChange(_ visible: Bool) {
        if !visible, viewModel.didLevelUp, let lvl = viewModel.newLevel {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                levelUpLevel = Int(lvl)
                showLevelUp = true
            }
        }
    }
    
    private func createAlert() -> Alert {
        Alert(
                                title: Text("error".localized).font(.appFont(size: 16, weight: .black)),
                    message: Text(viewModel.alertMessage ?? "unknown_error".localized).font(.appFont(size: 14)),
                    dismissButton: .default(Text("ok".localized).font(.appFont(size: 14, weight: .black))) {
                viewModel.alertMessage = nil
                    }
        )
    }

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

                    Button(action: {
                        // Provide haptic feedback for quest toggle
                        if item.state == .done {
                            HapticFeedbackManager.shared.questUncompleted()
                        } else {
                            HapticFeedbackManager.shared.questCompleted()
                        }
                        onToggle()
                    }) {
                        Image(systemName: item.state == .done ? "checkmark.circle.fill" : "circle")
                            .font(.title3)
                            .foregroundColor(item.state == .done ? .green : theme.textColor.opacity(0.6))
                    }

                    // Flag button next to quest completion toggle
                    Button(action: {
                        // Provide haptic feedback for mark as finished action
                        HapticFeedbackManager.shared.questFinished()
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
                                        // Provide haptic feedback for task toggle
                                        if task.isCompleted {
                                            HapticFeedbackManager.shared.taskUncompleted()
                                        } else {
                                            HapticFeedbackManager.shared.taskCompleted()
                                        }
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
                                    // Provide haptic feedback for task toggle
                                    if task.isCompleted {
                                        HapticFeedbackManager.shared.taskUncompleted()
                                    } else {
                                        HapticFeedbackManager.shared.taskCompleted()
                                    }
                                    onToggleTaskCompletion(task.id, !task.isCompleted)
                                }
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
        case .daily: return "daily".localized
        case .weekly: return "weekly".localized
        case .oneTime: return "one_time".localized
        case .scheduled: return "scheduled".localized
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
