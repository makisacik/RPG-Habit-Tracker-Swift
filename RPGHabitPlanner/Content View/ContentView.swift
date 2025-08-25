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
    @EnvironmentObject var localizationManager: LocalizationManager

    private let questDataService: QuestDataServiceProtocol
    private let userManager: UserManager
    private let homeViewModel: HomeViewModel

    @Environment(\.colorScheme) private var colorScheme

    init(questDataService: QuestDataServiceProtocol) {
        self.questDataService = questDataService
        self.userManager = UserManager()
        self.homeViewModel = HomeViewModel(userManager: self.userManager, questDataService: questDataService)
    }

    var body: some View {
        ZStack {
            if showSplash {
                SplashView()
                    .transition(.opacity)
            } else if isCharacterCreated {
                HomeView(viewModel: homeViewModel, questDataService: questDataService)
                    .transition(.asymmetric(
                        insertion: .scale(scale: 1.2).combined(with: .opacity),
                        removal: .scale(scale: 0.8).combined(with: .opacity)
                    ))
                    .environmentObject(themeManager)
                    .environmentObject(localizationManager)
                    .environmentObject(PremiumManager.shared)
            } else {
                OnboardingView(isOnboardingCompleted: $isCharacterCreated)
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
                    .environmentObject(themeManager)
                    .environmentObject(localizationManager)
            }
        }
        .preferredColorScheme(themeManager.forcedColorScheme)
        .onAppear {
            themeManager.applyTheme(using: colorScheme)
            userManager.fetchUser { user, _ in
                DispatchQueue.main.async {
                    self.isCharacterCreated = (user != nil)

                    // If user exists but first quest hasn't been created, create it
                    if user != nil && !FirstTimeQuestService.shared.hasFirstQuestBeenCreated {
                        FirstTimeQuestService.shared.createFirstQuest(questDataService: questDataService) { error in
                            if let error = error {
                                print("❌ Error creating first quest: \(error)")
                            } else {
                                print("✅ First quest created successfully for existing user")
                            }
                        }
                    }
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
        .onChange(of: isCharacterCreated) { characterCreated in
            if characterCreated {
                // Create first quest for new users
                FirstTimeQuestService.shared.createFirstQuest(questDataService: questDataService) { error in
                    if let error = error {
                        print("❌ Error creating first quest: \(error)")
                    } else {
                        print("✅ First quest created successfully")
                    }
                }
            }
        }
    }
}

#Preview {
    let questDataService = QuestCoreDataService()
    ContentView(questDataService: questDataService)
}
