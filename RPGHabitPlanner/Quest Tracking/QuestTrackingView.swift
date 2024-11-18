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
    
    var body: some View {
        VStack(alignment: .center) {
            questTypePicker
            statusPicker
            questList
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
                            QuestCardView(quest: quest) { id in
                                withAnimation {
                                    viewModel.markQuestAsCompleted(id: id)
                                }
                            }
                            .id(quest.id)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 16)
                            .onDisappear {
                                // Trigger Lottie animation on card removal
                                showSuccessAnimation = true
                            }
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
