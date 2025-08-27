//
//  RewardView.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 5.08.2025.
//

import SwiftUI

struct RewardView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Binding var isVisible: Bool
    let quest: Quest
    @State private var chestOpened = false
    @State private var showRewards = false
    @State private var rotation: Double = 0
    @State private var fadeOut = false
    @State private var baseExp: Int = 0
    @State private var baseCoins: Int = 0
    @State private var boostedExp: Int = 0
    @State private var boostedCoins: Int = 0
    @State private var hasBoosters: Bool = false
    @State private var viewAppeared: Bool = false
    @State private var gems: Int = 5

    var body: some View {
        if isVisible {
            let theme = themeManager.activeTheme

            ZStack {
                Color.black.opacity(fadeOut ? 0 : 0.4)
                    .ignoresSafeArea()
                    .animation(.easeInOut(duration: 0.3), value: fadeOut)

                VStack(spacing: 20) {
                    Spacer()

                    // Reward Card
                    VStack(spacing: 16) {
                        // Chest Animation Section
                        ZStack {
                            // Background spinning animation (smaller)
                            Image("icon_reward_animation")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 120, height: 120)
                                .opacity(0.6)
                                .rotationEffect(.degrees(rotation))
                                .onAppear {
                                    withAnimation(.linear(duration: 4).repeatForever(autoreverses: false)) {
                                        rotation = 360
                                    }
                                }

                            // Chest
                            Image(chestOpened ? "icon_chest_open" : "icon_chest")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 80, height: 80)
                                .scaleEffect(chestOpened ? 1.1 : 1.0)
                                .animation(.spring(response: 0.5, dampingFraction: 0.6), value: chestOpened)
                        }
                        .frame(height: 120)

                        // Quest Title
                        Text(quest.title)
                            .font(.appFont(size: 20, weight: .bold))
                            .multilineTextAlignment(.center)
                            .foregroundColor(theme.textColor)

                        // Rewards Summary
                        if showRewards {
                            VStack(spacing: 12) {
                                // Experience Section
                                HStack {
                                    Image(systemName: "star.fill")
                                        .foregroundColor(.yellow)
                                        .frame(width: 20)

                                    VStack(alignment: .leading, spacing: 2) {
                                        HStack {
                                            Text("experience".localized)
                                                .font(.appFont(size: 14, weight: .medium))
                                                .foregroundColor(theme.textColor.opacity(0.7))
                                            Spacer()
                                            Text("\(boostedExp)")
                                                .font(.appFont(size: 16, weight: .bold))
                                                .foregroundColor(theme.textColor)
                                        }

                                        if hasBoosters {
                                            HStack {
                                                Text("\("base".localized): \(baseExp)")
                                                    .font(.appFont(size: 12))
                                                    .foregroundColor(theme.textColor.opacity(0.6))
                                                Spacer()
                                                Text("+\(boostedExp - baseExp) \("from_boosters".localized)")
                                                    .font(.appFont(size: 12, weight: .medium))
                                                    .foregroundColor(.green)
                                            }
                                        }
                                    }
                                }

                                Divider()
                                    .background(theme.textColor.opacity(0.2))

                                // Coins Section
                                HStack {
                                    Image("icon_gold")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 20, height: 20)

                                    VStack(alignment: .leading, spacing: 2) {
                                        HStack {
                                            Text("currency_coins".localized)
                                                .font(.appFont(size: 14, weight: .medium))
                                                .foregroundColor(theme.textColor.opacity(0.7))
                                            Spacer()
                                            Text("\(boostedCoins)")
                                                .font(.appFont(size: 16, weight: .bold))
                                                .foregroundColor(theme.textColor)
                                        }

                                        if hasBoosters {
                                            HStack {
                                                Text("\("base".localized): \(baseCoins)")
                                                    .font(.appFont(size: 12))
                                                    .foregroundColor(theme.textColor.opacity(0.6))
                                                Spacer()
                                                Text("+\(boostedCoins - baseCoins) \("from_boosters".localized)")
                                                    .font(.appFont(size: 12, weight: .medium))
                                                    .foregroundColor(.green)
                                            }
                                        }
                                    }
                                }

                                Divider()
                                    .background(theme.textColor.opacity(0.2))

                                // Gems Section
                                HStack {
                                    Image("icon_gem")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 20, height: 20)

                                    VStack(alignment: .leading, spacing: 2) {
                                        HStack {
                                            Text("currency_gems".localized)
                                                .font(.appFont(size: 14, weight: .medium))
                                                .foregroundColor(theme.textColor.opacity(0.7))
                                            Spacer()
                                            Text("\(gems)")
                                                .font(.appFont(size: 16, weight: .bold))
                                                .foregroundColor(theme.textColor)
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal)
                            .transition(.opacity.combined(with: .move(edge: .top)))
                        }
                    }
                    .padding(24)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(theme.cardBackgroundColor)
                            .shadow(color: theme.shadowColor, radius: 10, x: 0, y: 5)
                    )
                    .padding(.horizontal, 20)
                    .scaleEffect(viewAppeared ? 1.0 : 0.8)
                    .opacity(viewAppeared ? 1.0 : 0.0)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: viewAppeared)

                    // Dismiss Button - positioned under the card
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            fadeOut = true
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            isVisible = false
                        }
                    }) {
                        HStack {
                            Spacer()
                            Text("dismiss".localized)
                                .font(.appFont(size: 16, weight: .black))
                                .foregroundColor(theme.buttonTextColor)
                            Spacer()
                        }
                        .padding(.vertical, 16)
                        .background(
                            Image(theme.buttonPrimary)
                                .resizable(
                                    capInsets: EdgeInsets(
                                        top: 20,
                                        leading: 20,
                                        bottom: 20,
                                        trailing: 20
                                    ),
                                    resizingMode: .stretch
                                )
                        )
                        .frame(maxWidth: .infinity, minHeight: 44, maxHeight: 44)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.horizontal, 20)
                    .opacity(showRewards ? 1 : 0)
                    .animation(.easeInOut(duration: 0.3), value: showRewards)

                    Spacer()
                }
            }
            .onAppear {
                // Start the view appearance animation
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    viewAppeared = true
                }

                // Start the reward sequence after a short delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    startRewardSequence()
                }
            }
        }
    }

    private func startRewardSequence() {
        // Reset states
        chestOpened = false
        showRewards = false
        fadeOut = false
        rotation = 0
        viewAppeared = true // Ensure view is visible

        // Calculate rewards
        #if DEBUG
        baseExp = 50 * quest.difficulty
        #else
        baseExp = 10 * quest.difficulty
        #endif

        baseCoins = CurrencyManager.shared.calculateQuestReward(
            difficulty: quest.difficulty,
            isMainQuest: quest.isMainQuest,
            taskCount: quest.tasks.count
        )

        // Apply boosters
        let boosterManager = BoosterManager.shared
        let boostedRewards = boosterManager.calculateBoostedRewards(
            baseExperience: baseExp,
            baseCoins: baseCoins
        )

        boostedExp = boostedRewards.experience
        boostedCoins = boostedRewards.coins
        hasBoosters = !boosterManager.activeBoosters.isEmpty

        // Add boosted coins to user
        CurrencyManager.shared.addCoins(boostedCoins) { error in
            if let error = error {
                print("❌ Error adding coins: \(error)")
            }
        }

        // Add gems to user
        CurrencyManager.shared.addGems(gems) { error in
            if let error = error {
                print("❌ Error adding gems: \(error)")
            }
        }

        // Start automatic animation sequence
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.easeInOut(duration: 0.3)) {
                chestOpened = true
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.easeInOut(duration: 0.5)) {
                    showRewards = true
                }
            }
        }
    }
}
