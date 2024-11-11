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
    private let questDataService: QuestDataServiceProtocol
    private let userManager = UserManager()
    
    init(questDataService: QuestDataServiceProtocol) {
        self.questDataService = questDataService
    }

    var body: some View {
        ZStack {
            if showSplash {
                SplashView()
                    .transition(.opacity)
            } else if isCharacterCreated {
                HomeView(questDataService: questDataService)
                    .transition(.opacity)
            } else {
                CharacterCreationView(isCharacterCreated: $isCharacterCreated) // Pass binding
                    .transition(.opacity)
            }
        }
        .onAppear {
            userManager.fetchUser { user, _ in
                DispatchQueue.main.async {
                    self.isCharacterCreated = (user != nil)
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                withAnimation {
                    showSplash = false
                }
            }
        }
    }
}

#Preview {
    let questDataService = QuestCoreDataService()
    ContentView(questDataService: questDataService)
}
