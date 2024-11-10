//
//  ContentView.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 10.11.2024.
//

import SwiftUI

struct ContentView: View {
    @State private var showSplash = true
    let questDataService: QuestDataServiceProtocol

    var body: some View {
        ZStack {
            if showSplash {
                SplashView()
                    .transition(.opacity)
            } else {
                HomeView(questDataService: questDataService)
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
