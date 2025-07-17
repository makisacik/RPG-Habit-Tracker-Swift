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
        ZStack {
            Image("pattern_grid_paper")
                .resizable(resizingMode: .tile)
                .ignoresSafeArea()

            VStack(alignment: .center, spacing: 10) {
                Image("banner_hanging")
                    .resizable()
                    .frame(height: 60)
                    .overlay(
                        Text("Quest Journal")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                    )
                    .padding(.bottom, 5)

                questTypePicker
                statusPicker

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
                                                lastScrollPosition = id
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
                        .padding()
                        .background(
                            Image("panel_brown")
                                .resizable(capInsets: EdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20), resizingMode: .stretch)
                        )
                        .cornerRadius(16)
                        .padding()
                    }
                    .onChange(of: viewModel.quests) { _ in
                        if let lastScrollPosition = lastScrollPosition {
                            scrollViewProxy.scrollTo(lastScrollPosition, anchor: .center)
                        }
                    }
                    .scrollIndicators(.hidden)
                }
            }
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
                        get: { quest },
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
    }

    private var questTypePicker: some View {
        VStack(alignment: .leading) {
            Text("Quest Type")
                .font(.headline)
                .padding(.leading)

            Picker("Quest Type", selection: $viewModel.selectedTab) {
                Text("Main").tag(QuestTab.main)
                Text("Side").tag(QuestTab.side)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            .background(
                Image("panel_brown_dark")
                    .resizable(capInsets: EdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20), resizingMode: .stretch)
            )
            .cornerRadius(10)
            .padding(.horizontal)
        }
    }

    private var statusPicker: some View {
        VStack(alignment: .leading) {
            Text("Status")
                .font(.headline)
                .padding(.leading)

            Picker("Status", selection: $viewModel.selectedStatus) {
                Text("All").tag(QuestStatusFilter.all)
                Text("Active").tag(QuestStatusFilter.active)
                Text("Inactive").tag(QuestStatusFilter.inactive)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            .background(
                Image("panel_brown_dark")
                    .resizable(capInsets: EdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20), resizingMode: .stretch)
            )
            .cornerRadius(10)
            .padding(.horizontal)
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
