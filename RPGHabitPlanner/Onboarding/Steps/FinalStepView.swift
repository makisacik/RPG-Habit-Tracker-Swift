//
//  FinalStepView.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 7.01.2025.
//

import SwiftUI

struct FinalStepView: View {
    @ObservedObject var coordinator: OnboardingCoordinator
    let theme: Theme

    @State private var showCompletionAnimation = false
    @State private var heroScale: CGFloat = 0.8
    @State private var heroRotation: Double = 0
    @State private var showSparkles = false
    @State private var backgroundGlow = false

    var body: some View {
        ZStack {
            // Animated background
            theme.backgroundColor
                .ignoresSafeArea()
                .overlay(
                    Circle()
                        .fill(theme.accentColor.opacity(0.1))
                        .scaleEffect(backgroundGlow ? 1.5 : 0.5)
                        .blur(radius: 50)
                        .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: backgroundGlow)
                )

            VStack(spacing: 30) {
                Spacer()

                // Hero preview with animations
                VStack(spacing: 20) {
                    ZStack {
                        // Character background matching customization page
                        RoundedRectangle(cornerRadius: 20)
                            .fill(
                                LinearGradient(
                                    colors: [theme.primaryColor, theme.secondaryColor],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .shadow(color: theme.shadowColor, radius: 8, x: 0, y: 4)
                            .frame(width: 180, height: 180)

                        CharacterFullPreview(
                            customization: coordinator.characterCustomization,
                            size: 150
                        )
                        .scaleEffect(heroScale)
                        .rotationEffect(.degrees(heroRotation))
                        .animation(.spring(response: 0.8, dampingFraction: 0.6), value: heroScale)
                        .animation(.easeInOut(duration: 1.0), value: heroRotation)

                        // Sparkle effects
                        if showSparkles {
                            ForEach(0..<8, id: \.self) { index in
                                SparkleView(theme: theme)
                                    .offset(
                                        x: CGFloat.random(in: -100...100),
                                        y: CGFloat.random(in: -100...100)
                                    )
                                    .animation(
                                        .easeInOut(duration: 1.5)
                                        .delay(Double(index) * 0.1),
                                        value: showSparkles
                                    )
                            }
                        }
                    }

                    VStack(spacing: 8) {
                        Text(coordinator.nickname.isEmpty ? "Hero" : coordinator.nickname)
                            .font(.appFont(size: 28, weight: .bold))
                            .foregroundColor(theme.textColor)
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                            .scaleEffect(showCompletionAnimation ? 1.05 : 1.0)
                            .animation(.spring(response: 0.5, dampingFraction: 0.7), value: showCompletionAnimation)

                        Text("Custom Character")
                            .font(.appFont(size: 18, weight: .medium))
                            .foregroundColor(theme.textColor.opacity(0.8))
                            .opacity(showCompletionAnimation ? 1.0 : 0.7)
                            .animation(.easeInOut(duration: 0.8), value: showCompletionAnimation)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(theme.cardBackgroundColor)
                    )
                    .scaleEffect(showCompletionAnimation ? 1.02 : 1.0)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: showCompletionAnimation)
                }
                .padding(.horizontal, 20)

                // Adventure summary
                VStack(spacing: 16) {
                    Text("Your Adventure Awaits!")
                        .font(.appFont(size: 20, weight: .bold))
                        .foregroundColor(theme.textColor)
                        .opacity(showCompletionAnimation ? 1.0 : 0.8)
                        .animation(.easeInOut(duration: 1.2), value: showCompletionAnimation)

                    VStack(spacing: 12) {
                        AdventureFeatureRow(icon: "icon_sword", text: "Create quests and complete tasks", theme: theme)
                            .opacity(showCompletionAnimation ? 1.0 : 0.6)
                            .animation(.easeInOut(duration: 0.8).delay(0.2), value: showCompletionAnimation)
                        AdventureFeatureRow(icon: "trophy.fill", text: "Earn experience and level up", theme: theme)
                            .opacity(showCompletionAnimation ? 1.0 : 0.6)
                            .animation(.easeInOut(duration: 0.8).delay(0.4), value: showCompletionAnimation)
                        AdventureFeatureRow(icon: "star.fill", text: "Unlock achievements and rewards", theme: theme)
                            .opacity(showCompletionAnimation ? 1.0 : 0.6)
                            .animation(.easeInOut(duration: 0.8).delay(0.6), value: showCompletionAnimation)
                    }
                }
                .padding(.horizontal, 20)

                Spacer()
            }
        }
        .onAppear {
            startCompletionAnimation()
        }
    }

    private func startCompletionAnimation() {
        // Start background glow
        withAnimation(.easeInOut(duration: 1.0)) {
            backgroundGlow = true
        }

        // Start main completion animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
                showCompletionAnimation = true
                heroScale = 1.0
            }
        }

        // Start sparkles
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation(.easeInOut(duration: 0.5)) {
                showSparkles = true
            }
        }

        // Hero rotation effect
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            withAnimation(.easeInOut(duration: 1.0)) {
                heroRotation = 360
            }
        }
    }
}

// MARK: - Sparkle View

struct SparkleView: View {
    let theme: Theme
    @State private var isAnimating = false

    // Random sparkle colors for better visibility
    private var sparkleColor: Color {
        let colors: [Color] = [
            .yellow,
            .orange,
            .red,
            .pink,
            .purple,
            .blue,
            .cyan,
            .green,
            .white
        ]
        return colors.randomElement() ?? .yellow
    }

    var body: some View {
        Image(systemName: "sparkle")
            .font(.system(size: 18, weight: .bold))
            .foregroundColor(sparkleColor)
            .shadow(color: sparkleColor.opacity(0.8), radius: 2, x: 0, y: 0)
            .scaleEffect(isAnimating ? 1.8 : 0.3)
            .opacity(isAnimating ? 0.0 : 1.0)
            .rotationEffect(.degrees(isAnimating ? 180 : 0))
            .onAppear {
                withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: false)) {
                    isAnimating = true
                }
            }
    }
}

// MARK: - Adventure Feature Row

struct AdventureFeatureRow: View {
    let icon: String
    let text: String
    let theme: Theme

    var body: some View {
        HStack(spacing: 12) {
            if icon.hasPrefix("icon_") {
                Image(icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 16, height: 16)
                    .foregroundColor(theme.textColor)
            } else {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(theme.textColor)
            }

            Text(text)
                .font(.appFont(size: 14))
                .foregroundColor(theme.textColor.opacity(0.8))

            Spacer()
        }
    }
}
