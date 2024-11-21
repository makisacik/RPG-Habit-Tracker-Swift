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

    var body: some View {
        VStack(alignment: .center) {
            questTypePicker
            statusPicker
            questList
        }
        .background(Color(.appBackground))
        .onChange(of: viewModel.errorMessage) { errorMessage in
            showAlert = errorMessage != nil
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Error"),
                message: Text(viewModel.errorMessage ?? "An unknown error occurred"),
                dismissButton: .default(Text("OK")) {
                    viewModel.errorMessage = nil
                }
            )
        }
        .sheet(item: $selectedQuestForEditing) { quest in
            EditQuestView(
                quest: Binding(
                    get: {
                        quest
                    },
                    set: { updatedQuest in
                        if let index = viewModel.quests.firstIndex(where: { $0.id == updatedQuest.id }) {
                            viewModel.quests[index] = updatedQuest
                        }
                        selectedQuestForEditing = nil
                    }
                ),
                onSave: { updatedQuest in
                    viewModel.updateQuest(updatedQuest)
                    selectedQuestForEditing = nil
                },
                onCancel: {
                    selectedQuestForEditing = nil
                }
            )
        }
        .onAppear {
            viewModel.fetchQuests()
        }
        .overlay(
            Group {
                if showSuccessAnimation {
                    LottieView(animation: .named("success"))
                        .playbackMode(.playing(.toProgress(1, loopMode: .playOnce)))
                        .frame(width: 200, height: 200)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                withAnimation {
                                    showSuccessAnimation = false
                                }
                            }
                        }
                }
            }
        )
    }
    
    private var questTypePicker: some View {
        Picker("Quest Type", selection: $viewModel.selectedTab) {
            Text("Main").tag(QuestTab.main)
            Text("Side").tag(QuestTab.side)
        }
        .pickerStyle(SegmentedPickerStyle())
        .padding()
    }
    
    private var statusPicker: some View {
        Picker("Status", selection: $viewModel.selectedStatus) {
            Text("All").tag(QuestStatusFilter.all)
            Text("Active").tag(QuestStatusFilter.active)
            Text("Inactive").tag(QuestStatusFilter.inactive)
        }
        .pickerStyle(SegmentedPickerStyle())
        .padding()
    }
    
    private var questList: some View {
        ScrollViewReader { scrollViewProxy in
            ScrollView {
                VStack {
                    ForEach(questsToDisplay) { quest in
                        if !quest.isCompleted {
                            QuestCardView(
                                quest: quest,
                                onMarkComplete: { id in
                                    withAnimation {
                                        viewModel.markQuestAsCompleted(id: id)
                                        showSuccessAnimation = true
                                    }
                                },
                                onEditQuest: { questToEdit in
                                    selectedQuestForEditing = questToEdit
                                },
                                onUpdateProgress: { id, change in
                                    viewModel.updateQuestProgress(id: id, by: change)
                                }
                            )
                            .id(quest.id)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 16)
                        }
                    }
                }
            }
            .onChange(of: viewModel.quests) { _ in
                if let lastScrollPosition = lastScrollPosition {
                    scrollViewProxy.scrollTo(lastScrollPosition, anchor: .center)
                }
            }
            .scrollIndicators(.hidden)
        }
    }
    
    private var questsToDisplay: [Quest] {
        viewModel.selectedTab == .main ? viewModel.mainQuests : viewModel.sideQuests
    }
}


enum QuestTab: String, CaseIterable {
    case main
    case side
}

#Preview {
    let questDataService = QuestCoreDataService()
    let userManager = UserManager(container: PersistenceController.shared.container)
    QuestTrackingView(viewModel: QuestTrackingViewModel(questDataService: questDataService, userManager: userManager))
}
