//
//  QuestTrackingView.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 10.11.2024.
//

import SwiftUI

struct QuestTrackingView: View {
    @ObservedObject var viewModel: QuestTrackingViewModel
    @State private var selectedTab: QuestTab = .main
    @State private var showAlert: Bool = false
    
    var body: some View {
        VStack(alignment: .center) {
            Picker("Quest Type", selection: $selectedTab) {
                Text("Main").tag(QuestTab.main)
                Text("Side").tag(QuestTab.side)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            Picker("Status", selection: $viewModel.selectedStatus) {
                Text("All").tag(QuestStatusFilter.all)
                Text("Active").tag(QuestStatusFilter.active)
                Text("Inactive").tag(QuestStatusFilter.inactive)
            }
            .pickerStyle(SegmentedPickerStyle())
            
            ScrollView {
                VStack {
                    ForEach(questsToDisplay) { quest in
                        QuestCardView(quest: quest)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 16)
                    }
                }
            }.scrollIndicators(.hidden)
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
    
    private var questsToDisplay: [Quest] {
        selectedTab == .main ? viewModel.mainQuests : viewModel.sideQuests
    }
}

enum QuestTab: String, CaseIterable {
    case main
    case side
}

#Preview {
    let questDataService = QuestCoreDataService()
    QuestTrackingView(viewModel: QuestTrackingViewModel(questDataService: questDataService))
}
