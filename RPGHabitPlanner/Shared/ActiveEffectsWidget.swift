//
//  ActiveEffectsWidget.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 6.08.2025.
//

import SwiftUI

struct ActiveEffectsWidget: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var boosterManager: BoosterManager
    @State private var showAllEffects = false
    @State private var refreshTrigger = false

    var body: some View {
        let theme = themeManager.activeTheme

        Group {
            if !boosterManager.activeBoosters.isEmpty {
                VStack(spacing: 8) {
                    // Header
                    HStack {
                        Image(systemName: "bolt.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.yellow)

                        Text(String(localized: "active_boosters"))
                            .font(.appFont(size: 14, weight: .black))
                            .foregroundColor(theme.textColor)

                        Spacer()

                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                showAllEffects.toggle()
                            }
                        }) {
                            Image(systemName: showAllEffects ? "chevron.up" : "chevron.down")
                                .font(.system(size: 12))
                                .foregroundColor(.yellow)
                        }
                    }

                    // Effects list
                    if showAllEffects {
                        VStack(spacing: 6) {
                            ForEach(boosterManager.activeBoosters.filter { $0.isActive && !$0.isExpired }) { booster in
                                BoosterWidgetRow(booster: booster)
                                    .environmentObject(themeManager)
                            }
                        }
                        .transition(.move(edge: .top).combined(with: .opacity))
                    } else {
                        // Compact view - show only the most important booster
                        if let mostImportantBooster = getMostImportantBooster() {
                            BoosterWidgetRow(booster: mostImportantBooster, isCompact: true)
                                .environmentObject(themeManager)
                                .transition(.move(edge: .top).combined(with: .opacity))
                        }
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(theme.secondaryColor)
                        .shadow(color: Color.black.opacity(0.2), radius: 6, x: 0, y: 4)
                )
                .padding(.horizontal)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .boostersUpdated)) { _ in
            print("🔄 ActiveEffectsWidget: Received boostersUpdated notification")
            refreshTrigger.toggle()
        }
    }

    private func getMostImportantBooster() -> BoosterEffect? {
        // Priority order: Experience > Coins > others
        let priorityOrder: [BoosterType] = [.experience, .coins, .both]

        for boosterType in priorityOrder {
                            if let booster = boosterManager.activeBoosters.first(where: {
                $0.type == boosterType && $0.isActive && !$0.isExpired
            }) {
                return booster
            }
        }

        return boosterManager.activeBoosters.first { $0.isActive && !$0.isExpired }
    }
}

struct BoosterWidgetRow: View {
    @EnvironmentObject var themeManager: ThemeManager
    let booster: BoosterEffect
    let isCompact: Bool
    @State private var remainingTime: TimeInterval = 0

    init(booster: BoosterEffect, isCompact: Bool = false) {
        self.booster = booster
        self.isCompact = isCompact
    }

    var body: some View {
        let theme = themeManager.activeTheme
        HStack(spacing: 8) {
            // Booster icon
            Image(systemName: boosterIcon)
                .font(.system(size: isCompact ? 12 : 14))
                .foregroundColor(.yellow)
                .frame(width: isCompact ? 16 : 20)

            // Booster name and value
            VStack(alignment: .leading, spacing: 2) {
                Text(booster.sourceName)
                    .font(.appFont(size: isCompact ? 10 : 12, weight: .black))
                    .foregroundColor(theme.textColor)

                if !isCompact {
                    Text(boosterDescription)
                        .font(.appFont(size: 10, weight: .medium))
                        .foregroundColor(theme.textColor.opacity(0.8))
                }
            }

            Spacer()

            // Countdown timer
            if let remaining = booster.remainingTime {
                VStack(alignment: .trailing, spacing: 2) {
                    Text(formatTime(remaining))
                        .font(.appFont(size: isCompact ? 10 : 12, weight: .black))
                        .foregroundColor(.yellow)

                    if !isCompact {
                        // Progress bar
                        ProgressView(value: booster.progress)
                            .progressViewStyle(LinearProgressViewStyle(tint: .yellow))
                            .frame(width: 40, height: 4)
                    }
                }
            }
        }
        .padding(.vertical, isCompact ? 2 : 4)
        .onAppear {
            updateRemainingTime()
        }
        .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in
            updateRemainingTime()
        }
    }

    private var boosterIcon: String {
        switch booster.type {
        case .experience:
            return "arrow.up.circle.fill"
        case .coins:
            return "dollarsign.circle.fill"
        case .both:
            return "bolt.fill"
        }
    }

    private var boosterDescription: String {
        let multiplierText = String(format: "%.0f%%", (booster.multiplier - 1.0) * 100)
        let bonusText = booster.flatBonus > 0 ? " +\(booster.flatBonus)" : ""

        switch booster.type {
        case .experience:
            return "\(multiplierText) \(String(localized: "experience"))\(bonusText)"
        case .coins:
            return "\(multiplierText) \(String(localized: "coins"))\(bonusText)"
        case .both:
            return "\(multiplierText) \(String(localized: "experience")) & \(String(localized: "coins"))\(bonusText)"
        }
    }

    private func updateRemainingTime() {
        remainingTime = booster.remainingTime ?? 0
    }

    private func formatTime(_ timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60

        if minutes > 0 {
            return String(format: "%dm %02ds", minutes, seconds)
        } else {
            return String(format: "%ds", seconds)
        }
    }
}

// MARK: - XP Boost Indicator

struct XPBoostIndicator: View {
    @EnvironmentObject var boosterManager: BoosterManager

    var body: some View {
        let expBoosters = boosterManager.getActiveBoosters(for: .experience)
        if !expBoosters.isEmpty {
            let totalMultiplier = expBoosters.reduce(1.0) { $0 * $1.multiplier }
            let totalBonus = expBoosters.reduce(0) { $0 + $1.flatBonus }

            HStack(spacing: 4) {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 12))
                    .foregroundColor(.green)

                Text("\(Int((totalMultiplier - 1.0) * 100))% \(String(localized: "experience"))")
                    .font(.appFont(size: 10, weight: .black))
                    .foregroundColor(.green)

                if totalBonus > 0 {
                    Text("+\(totalBonus)")
                        .font(.appFont(size: 8, weight: .medium))
                        .foregroundColor(.green.opacity(0.8))
                }

                let remainingTimes = expBoosters.compactMap { $0.remainingTime }
                if let shortestRemaining = remainingTimes.min() {
                    Text("(\(formatTime(shortestRemaining)))")
                        .font(.appFont(size: 8, weight: .medium))
                        .foregroundColor(.green.opacity(0.8))
                }
            }
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.green.opacity(0.2))
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color.green.opacity(0.3), lineWidth: 1)
                    )
            )
        }
    }

    private func formatTime(_ timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60

        if minutes > 0 {
            return String(format: "%dm", minutes)
        } else {
            return String(format: "%ds", seconds)
        }
    }
}

// MARK: - Preview

struct ActiveEffectsWidget_Previews: PreviewProvider {
    static var previews: some View {
        ActiveEffectsWidget()
            .environmentObject(ThemeManager.shared)
            .environmentObject(BoosterManager.shared)
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
