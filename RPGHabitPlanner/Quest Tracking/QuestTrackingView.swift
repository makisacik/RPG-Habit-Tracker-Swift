//
//  QuestTrackingView.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 10.11.2024.
//

import SwiftUI
import Lottie

struct QuestTrackingView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @StateObject var viewModel: QuestTrackingViewModel
    @State private var showAlert: Bool = false
    @State private var showSuccessAnimation: Bool = false
    @State private var lastScrollPosition: UUID?
    @State private var selectedQuestForDetail: Quest?
    @State private var showReward = false
    @State private var showLevelUp = false
    @State private var levelUpLevel: Int = 0

    var body: some View {
        ZStack {
            mainContent
            SuccessAnimationOverlay(isVisible: $showSuccessAnimation)
            RewardView(isVisible: $showReward)
            LevelUpView(isVisible: $showLevelUp, level: levelUpLevel)
        }
    }

    private var mainContent: some View {
        let theme = themeManager.activeTheme

        return VStack(alignment: .center, spacing: 5) {
            dayPicker.padding(.top, 5)
            questList
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(theme.primaryColor)
                .shadow(color: Color.black.opacity(0.5), radius: 6, x: 0, y: 4)
        )
        .padding(.horizontal)
        .onChange(of: viewModel.errorMessage) { errorMessage in
            showAlert = errorMessage != nil
        }
        .onChange(of: viewModel.questCompleted) { completed in
            if completed {
                showReward = true
                viewModel.questCompleted = false
            }
        }
        .onChange(of: showReward) { isVisible in
            if !isVisible && viewModel.didLevelUp, let level = viewModel.newLevel {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    showLevelUp = true
                    levelUpLevel = Int(level)
                }
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text(String.errorTitle.localized).font(.appFont(size: 16, weight: .black)),
                message: Text(viewModel.errorMessage ?? String.unknownError.localized).font(.appFont(size: 14)),
                dismissButton: .default(Text(String.okButton.localized).font(.appFont(size: 14, weight: .black))) { viewModel.errorMessage = nil }
            )
        }
        .sheet(item: $selectedQuestForDetail) { quest in
            NavigationStack {
                QuestDetailView(
                    quest: quest,
                    date: Date(),
                    questDataService: viewModel.questDataService
                )
                .environmentObject(themeManager)
            }
        }
        .onAppear {
            viewModel.fetchQuests()
            viewModel.refreshRecurringQuests()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            viewModel.refreshRecurringQuests()
        }
        .onReceive(Timer.publish(every: 60, on: .main, in: .common).autoconnect()) { _ in
            let currentDay = Calendar.current.startOfDay(for: Date())
            if viewModel.lastRefreshDay != currentDay {
                viewModel.lastRefreshDay = currentDay
                viewModel.refreshRecurringQuests()
            }
        }
    }

    private var questList: some View {
        ScrollViewReader { scrollViewProxy in
            ScrollView {
                VStack {
                    ForEach(questsForSelectedFilter) { quest in
                        questCard(for: quest)
                            .id(quest.id)
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding(5)
            }
            .onChange(of: viewModel.quests) { _ in
                if let lastScrollPosition = lastScrollPosition {
                    scrollViewProxy.scrollTo(lastScrollPosition, anchor: .center)
                }
            }
            .scrollIndicators(.hidden)
        }
    }

    private func questCard(for quest: Quest) -> some View {
        QuestCardView(
            quest: quest,
            onMarkComplete: { id in
                withAnimation {
                    viewModel.markQuestAsCompleted(id: id)
                    lastScrollPosition = id
                    showReward = true
                }
            },
            onEditQuest: { _ in }, // No longer used but keeping for compatibility
            onUpdateProgress: { id, change in
                viewModel.updateQuestProgress(id: id, by: change)
            },
            onToggleTaskCompletion: { taskId, isCompleted in
                viewModel.toggleTaskCompletion(
                    questId: quest.id,
                    taskId: taskId,
                    newValue: isCompleted
                )
            },
            onQuestTap: { quest in
                selectedQuestForDetail = quest
            }
        )
    }

    private var dayPicker: some View {
        Picker(String.today.localized, selection: $viewModel.selectedDayFilter) {
            Text(String.activeToday.localized).tag(DayFilter.active)
            Text(String.inactiveToday.localized).tag(DayFilter.inactive)
        }
        .pickerStyle(.segmented)
        .padding(.horizontal)
    }

    private var questsForSelectedFilter: [Quest] {
        switch viewModel.selectedDayFilter {
        case .active:
            return viewModel.activeTodayQuests
        case .inactive:
            return viewModel.inactiveTodayQuests
        }
    }
}

enum DayFilter: Hashable {
    case active
    case inactive
}


#Preview {
    let questDataService = QuestCoreDataService()
    let userManager = UserManager(container: PersistenceController.shared.container)
    QuestTrackingView(viewModel: QuestTrackingViewModel(questDataService: questDataService, userManager: userManager))
}
