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
            Text("Active Quests")
                .font(.title2)
                .bold()
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.horizontal)
            
            Text("Main Quests")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.horizontal)
            
            TabView {
                ForEach(viewModel.mainQuests) { quest in
                    MainQuestCardView(quest: quest)
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 16)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
            .frame(height: 200)
            
            Text("Side Quests")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(viewModel.sideQuests) { quest in
                        SideQuestCardView(quest: quest)
                            .frame(width: 150)
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
    }
}


#Preview {
    let questDataService = QuestCoreDataService()
    QuestTrackingView(viewModel: QuestTrackingViewModel(questDataService: questDataService))
}
