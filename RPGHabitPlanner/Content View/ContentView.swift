//
//  ContentView.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 10.11.2024.
//

import SwiftUI

struct ContentView: View {
    @State private var showSplash = true
    @State private var isCharacterCreated = false
    @StateObject private var themeManager = ThemeManager.shared
    
    private let questDataService: QuestDataServiceProtocol
    private let userManager: UserManager
    private let homeViewModel: HomeViewModel
    
    @Environment(\.colorScheme) private var colorScheme
    
    init(questDataService: QuestDataServiceProtocol) {
        self.questDataService = questDataService
        self.userManager = UserManager()
        self.homeViewModel = HomeViewModel(userManager: self.userManager)
    }

    var body: some View {
        ZStack {
            if showSplash {
                SplashView()
                    .transition(.opacity)
            } else if isCharacterCreated {
                HomeView(viewModel: homeViewModel, questDataService: questDataService)
                    .transition(.opacity)
                    .environmentObject(themeManager)
            } else {
                let characterViewModel = CharacterCreationViewModel()
                CharacterCreationView(viewModel: characterViewModel, isCharacterCreated: $isCharacterCreated)
                    .transition(.opacity)
                    .environmentObject(themeManager)
            }
        }
        .onAppear {
            themeManager.applyTheme(using: colorScheme)
            userManager.fetchUser { user, _ in
                DispatchQueue.main.async {
                    self.isCharacterCreated = (user != nil)
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation {
                    showSplash = false
                }
            }
        }
        .onChange(of: colorScheme) { newScheme in
            themeManager.applyTheme(using: newScheme)
        }
    }
}

#Preview {
    let questDataService = QuestCoreDataService()
    ContentView(questDataService: questDataService)
}
