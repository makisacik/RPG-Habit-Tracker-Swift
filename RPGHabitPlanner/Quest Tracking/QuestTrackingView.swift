//
//  QuestTrackingView.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 10.11.2024.
//

import SwiftUI

struct QuestTrackingView: View {
    @ObservedObject var viewModel: QuestTrackingViewModel
    @State private var showAlert: Bool = false
    
    var body: some View {
        VStack(alignment: .center) {
            Text("Main Quests")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.horizontal)
            
            TabView {
                ForEach(viewModel.mainQuests) { quest in
                    MainQuestCardView(quest: quest)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 16)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
            .frame(height: 170)
            
            Text("Side Quests")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(viewModel.sideQuests) { quest in
                        SideQuestCardView(quest: quest)
                            .frame(width: 160)
                            .padding(.vertical, 10)
                    }
                }
                .padding(.horizontal)
            }
            .padding(.bottom, 20)
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
}


#Preview {
    let questDataService = QuestCoreDataService()
    QuestTrackingView(viewModel: QuestTrackingViewModel(questDataService: questDataService))
}
