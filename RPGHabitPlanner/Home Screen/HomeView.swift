//
//  HomeView.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 10.11.2024.
//

import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: HomeViewModel
    let questDataService: QuestDataServiceProtocol

    var body: some View {
        NavigationStack {
            VStack {
                QuestTrackingView(viewModel: QuestTrackingViewModel(questDataService: questDataService))
                    .padding()
                    
                Spacer()
                
                BottomBarCharacterView(user: viewModel.user)
                    .frame(height: 100)
                    .background(Color(UIColor.systemGray6))
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: QuestCreationView(viewModel: QuestCreationViewModel(questDataService: questDataService))) {
                        Image(systemName: "plus")
                            .font(.title2)
                            .foregroundStyle(.yellow)
                    }
                }
            }
            .onAppear {
                viewModel.fetchUserData()
            }
        }
    }
}

#Preview {
    let questDataService = QuestCoreDataService()
    let userManager = UserManager()
    let homeViewModel = HomeViewModel(userManager: userManager)
    
    HomeView(viewModel: homeViewModel, questDataService: questDataService)
}
