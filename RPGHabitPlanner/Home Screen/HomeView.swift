//
//  HomeView.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 10.11.2024.
//

import SwiftUI
import WidgetKit

struct HomeView: View {
    @ObservedObject var viewModel: HomeViewModel
    let questDataService: QuestDataServiceProtocol

    @State private var selectedTab: HomeTab = .tracking
    @State private var isCharacterDetailsPresented: Bool = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                TabView(selection: $selectedTab) {
                    QuestTrackingView(viewModel: QuestTrackingViewModel(questDataService: questDataService, userManager: viewModel.userManager))
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
            }
            .navigationTitle(navigationTitle)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        isCharacterDetailsPresented.toggle()
                    }) {
                        HStack {
                            if let user = viewModel.user,
                               let characterClass = CharacterClass(rawValue: user.characterClass ?? "knight") {
                                Image(characterClass.iconName)
                                    .resizable()
                                    .frame(width: 30, height: 30)
                            }
                            Text("Level \(viewModel.user?.level ?? 1)")
                                .font(.subheadline)
                                .foregroundColor(.primary)
                        }
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: QuestCreationView(viewModel: QuestCreationViewModel(questDataService: questDataService))) {
                        Image(systemName: "plus")
                            .font(.title2)
                            .foregroundStyle(Color(.appYellow))
                    }
                }
            }
            .sheet(isPresented: $isCharacterDetailsPresented) {
                if let user = viewModel.user {
                    CharacterDetailsView(user: user)
                }
            }
            .onAppear {
                viewModel.fetchUserData()
                WidgetCenter.shared.reloadAllTimelines()
            }
        }
    }

    private var navigationTitle: String {
        switch selectedTab {
        case .tracking:
            return "Quest Journal ⚔"
        case .completed:
            return "Completed Quests"
        }
    }
}


enum HomeTab: Hashable {
    case tracking
    case completed
}
