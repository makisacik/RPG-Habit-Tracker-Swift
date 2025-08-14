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
    @EnvironmentObject var premiumManager: PremiumManager
    @StateObject var viewModel: QuestTrackingViewModel
    @State private var showAlert: Bool = false
    @State private var showSuccessAnimation: Bool = false
    @State private var lastScrollPosition: UUID?
    @State private var selectedQuestForDetail: Quest?
    @State private var showReward = false
    @State private var showLevelUp = false
    @State private var levelUpLevel: Int = 0
    @State private var showPaywall = false
    @State private var showTagFilter = false

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
            // Fixed header that won't move
            HStack {
                dayPicker

                Spacer()

                // Tag filter button - hide when filter is active
                if !showTagFilter {
                    Button(action: {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            showTagFilter.toggle()
                        }
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "tag.fill")
                                .font(.system(size: 14, weight: .medium))
                            Text("Filter")
                                .font(.appFont(size: 14, weight: .medium))
                        }
                        .foregroundColor(theme.accentColor)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(theme.accentColor.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(theme.accentColor.opacity(0.3), lineWidth: 1)
                                )
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    .transition(.asymmetric(
                        insertion: .scale.combined(with: .opacity),
                        removal: .scale.combined(with: .opacity)
                    ))
                }
            }
            .padding(.horizontal)
            .padding(.top, 5)

            // Scrollable content area
            ScrollView {
                VStack(spacing: 0) {
                    // Tag filter section
                    if showTagFilter {
                        VStack(spacing: 0) {
                            // Apply Filters button
                            HStack {
                                Spacer()
                                Button(action: {
                                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                        showTagFilter.toggle()
                                    }
                                }) {
                                    HStack(spacing: 6) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.system(size: 16, weight: .medium))
                                        Text("Apply Filters")
                                        .font(.appFont(size: 14, weight: .medium))
                                    }
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(theme.accentColor)
                                            .shadow(color: theme.accentColor.opacity(0.3), radius: 4, x: 0, y: 2)
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                                .padding(.trailing, 20)
                                .padding(.top, 8)
                            }

                            TagFilterView(viewModel: viewModel.tagFilterViewModel)
                        }
                        .transition(.asymmetric(
                            insertion: .move(edge: .top).combined(with: .opacity),
                            removal: .move(edge: .top).combined(with: .opacity)
                        ))
                    }

                    questList
                }
            }
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
        .sheet(isPresented: $showPaywall) {
            PaywallView()
                .environmentObject(premiumManager)
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
        VStack(spacing: 8) {
            HStack {
                Picker(String.today.localized, selection: $viewModel.selectedDayFilter) {
                    Text(String.activeToday.localized).tag(DayFilter.active)
                    Text(String.inactiveToday.localized).tag(DayFilter.inactive)
                }
                .pickerStyle(.segmented)

                Spacer()

                // Premium indicator
                PremiumIndicatorView()
            }
            .padding(.horizontal)
        }
    }

    private var questsForSelectedFilter: [Quest] {
        let filteredQuests = switch viewModel.selectedDayFilter {
        case .active:
            viewModel.activeTodayQuests
        case .inactive:
            viewModel.inactiveTodayQuests
        }

        // Apply tag filtering if any tags are selected
        return viewModel.applyTagFiltering(to: filteredQuests)
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
