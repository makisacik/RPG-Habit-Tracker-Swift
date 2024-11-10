//
//  ContentView.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 10.11.2024.
//

import SwiftUI

struct ContentView: View {
    @State private var showSplash = true
    @AppStorage("isCharacterCreated") private var isCharacterCreated: Bool = false
    let questDataService: QuestDataServiceProtocol

    var body: some View {
        ZStack {
            if showSplash {
                SplashView()
                    .transition(.opacity)
            } else if isCharacterCreated {
                HomeView(questDataService: questDataService)
                    .transition(.opacity)
            } else {
                CharacterCreationView()
                    .transition(.opacity)
            }
        }
        .onAppear {
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
