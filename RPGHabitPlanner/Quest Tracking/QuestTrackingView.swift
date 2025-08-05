//
//  QuestTrackingView.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 10.11.2024.
//

import SwiftUI
import Lottie

struct QuestTrackingView: View {
    @StateObject var viewModel: QuestTrackingViewModel
    @State private var showAlert: Bool = false
    @State private var showSuccessAnimation: Bool = false
    @State private var lastScrollPosition: UUID?
    @State private var selectedQuestForEditing: Quest?
    @State private var showReward = false
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        ZStack {
            mainContent
            SuccessAnimationOverlay(isVisible: $showSuccessAnimation)
            RewardView(isVisible: $showReward)
        }
    }

    private var mainContent: some View {
        let theme = themeManager.activeTheme

        return VStack(alignment: .center, spacing: 5) {
            questTypePicker.padding(.top, 5)
            questList
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(theme.primaryColor)
                .shadow(color: Color.black.opacity(0.2), radius: 6, x: 0, y: 4)
        )
        .padding(.horizontal)
        .onChange(of: viewModel.errorMessage) { errorMessage in
            showAlert = errorMessage != nil
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Error").font(.appFont(size: 16, weight: .black)),
                message: Text(viewModel.errorMessage ?? "An unknown error occurred")
                    .font(.appFont(size: 14)),
                dismissButton: .default(Text("OK").font(.appFont(size: 14, weight: .black))) {
                    viewModel.errorMessage = nil
                }
            )
        }
        .sheet(item: $selectedQuestForEditing) { quest in
            editQuestSheet(quest)
        }
        .onAppear {
            viewModel.fetchQuests()
        }
    }

    private var questList: some View {
        ScrollViewReader { scrollViewProxy in
            ScrollView {
                VStack {
                    ForEach(questsToDisplay) { quest in
                        if !quest.isCompleted {
                            questCard(for: quest)
                                .id(quest.id)
                                .frame(maxWidth: .infinity)
                        }
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
            onEditQuest: { selectedQuestForEditing = $0 },
            onUpdateProgress: { id, change in
                viewModel.updateQuestProgress(id: id, by: change)
            },
            onToggleTaskCompletion: { taskId, isCompleted in
                viewModel.toggleTaskCompletion(
                    questId: quest.id,
                    taskId: taskId,
                    currentValue: isCompleted
                )
            }
        )
    }

    private func editQuestSheet(_ quest: Quest) -> some View {
        EditQuestView(
            viewModel: EditQuestViewModel(
                quest: quest,
                questDataService: viewModel.questDataService
            ),
            onSaveSuccess: {
                viewModel.fetchQuests()
                selectedQuestForEditing = nil
                showSuccessAnimation = true
            },
            onCancel: {
                selectedQuestForEditing = nil
            }
        )
    }


    private var questTypePicker: some View {
        Picker("Quest Type", selection: $viewModel.selectedTab) {
            ForEach(QuestTab.allCases, id: \.self) { tab in
                Text(tab.rawValue.capitalized).tag(tab)
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal)
    }

    private var questsToDisplay: [Quest] {
        switch viewModel.selectedTab {
        case .all:
            return viewModel.allQuests
        case .main:
            return viewModel.mainQuests
        case .side:
            return viewModel.sideQuests
        }
    }
}

enum QuestTab: String, CaseIterable {
    case all
    case main
    case side
}

#Preview {
    let questDataService = QuestCoreDataService()
    let userManager = UserManager(container: PersistenceController.shared.container)
    QuestTrackingView(viewModel: QuestTrackingViewModel(questDataService: questDataService, userManager: userManager))
}
