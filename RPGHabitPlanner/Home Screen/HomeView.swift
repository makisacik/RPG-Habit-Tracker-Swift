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

    @State private var selectedTab: HomeTab = .tracking

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                TabView(selection: $selectedTab) {
                    QuestTrackingView(viewModel: QuestTrackingViewModel(questDataService: questDataService))
                        .tabItem {
                            Label("Tracking", systemImage: "list.bullet")
                        }
                        .tag(HomeTab.tracking)

                    CompletedQuestsView(viewModel: CompletedQuestsViewModel(questDataService: questDataService))
                        .tabItem {
                            Label("Completed", systemImage: "checkmark.circle")
                        }
                        .tag(HomeTab.completed)
                }

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

enum HomeTab: Hashable {
    case tracking
    case completed
}

#Preview {
    let questDataService = QuestCoreDataService()
    let userManager = UserManager()
    let homeViewModel = HomeViewModel(userManager: userManager)

    HomeView(viewModel: homeViewModel, questDataService: questDataService)
}
