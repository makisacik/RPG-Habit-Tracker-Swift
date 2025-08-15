//
//  RewardView.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 5.08.2025.
//

import SwiftUI

struct RewardView: View {
    @Binding var isVisible: Bool
    let quest: Quest
    @State private var chestOpened = false
    @State private var rewardGiven = false
    @State private var rotation: Double = 0
    @State private var fadeOut = false
    @State private var rewardItem: Item?

    var body: some View {
        if isVisible {
            ZStack {
                Color.black.opacity(fadeOut ? 0 : 0.4)
                    .ignoresSafeArea()
                    .animation(.easeInOut(duration: 0.3), value: fadeOut)

                ZStack {
                    Image("icon_reward_animation")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 300, height: 300)
                        .opacity(0.8)
                        .rotationEffect(.degrees(rotation))
                        .onAppear {
                            withAnimation(.linear(duration: 6).repeatForever(autoreverses: false)) {
                                rotation = 360
                            }
                        }

                    VStack {
                        Image(chestOpened ? "icon_chest_open" : "icon_chest")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 150, height: 150)

                        if rewardGiven, let reward = rewardItem {
                            Image(reward.iconName)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100)
                                .transition(.scale.combined(with: .opacity))
                        }
                    }
                }
            }
            .onTapGesture {
                if !chestOpened {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        chestOpened = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        // Calculate coin reward based on quest difficulty and type
                        let coinReward = CurrencyManager.shared.calculateQuestReward(
                            difficulty: quest.difficulty,
                            isMainQuest: quest.isMainQuest,
                            taskCount: quest.tasks.count
                        )
                        
                        // Add coins to user
                        CurrencyManager.shared.addCoins(coinReward) { error in
                            if let error = error {
                                print("❌ Error adding coins: \(error)")
                            }
                        }
                        
                        // Create a coin reward item for display
                        rewardItem = Item(name: "Coins", info: "You earned \(coinReward) coins!", iconName: "icon_gold")
                        
                        withAnimation {
                            rewardGiven = true
                        }
                    }
                } else if rewardGiven {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        fadeOut = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        isVisible = false
                    }
                }
            }
            .onAppear {
                chestOpened = false
                rewardGiven = false
                fadeOut = false
                rotation = 0
            }
        }
    }
}
