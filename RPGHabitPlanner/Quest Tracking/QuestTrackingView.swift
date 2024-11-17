//
//  QuestTrackingView.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 10.11.2024.
//

import SwiftUI

struct QuestTrackingView: View {
    @StateObject var viewModel: QuestTrackingViewModel
    @State private var showAlert: Bool = false
    @State private var lastScrollPosition: UUID?
    
    var body: some View {
        VStack(alignment: .center) {
            questTypePicker
            statusPicker
            questList
        }
        .onAppear {
            viewModel.fetchQuests()
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
        .navigationTitle("Quest Journal ⚔")
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
                        QuestCardView(quest: quest) { id in
                            lastScrollPosition = quest.id
                            viewModel.markQuestAsCompleted(id: id)
                        }
                        .id(quest.id)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 16)
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
