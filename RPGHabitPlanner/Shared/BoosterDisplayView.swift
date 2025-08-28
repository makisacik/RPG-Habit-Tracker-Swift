//
//  BoosterDisplayView.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 6.08.2025.
//

import SwiftUI

struct BoosterDisplayView: View {
    @ObservedObject private var boosterManager = BoosterManager.shared
    @StateObject private var themeManager = ThemeManager.shared
    @State private var refreshTrigger = false

    var body: some View {
        Group {
            if !boosterManager.activeBoosters.isEmpty {
                VStack(spacing: 8) {
                    HStack {
                        Image(systemName: "bolt.fill")
                            .foregroundColor(.yellow)
                            .font(.system(size: 14, weight: .bold))

                        Text("active_boosters".localized)
                            .font(.appFont(size: 14, weight: .bold))
                            .foregroundColor(themeManager.activeTheme.textColor)

                        Spacer()
                    }

                    LazyVStack(spacing: 6) {
                        ForEach(boosterManager.activeBoosters.filter { $0.isActive && !$0.isExpired }) { booster in
                            BoosterItemView(booster: booster)
                        }
                    }
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(themeManager.activeTheme.backgroundColor.opacity(0.9))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.yellow.opacity(0.3), lineWidth: 1)
                        )
                )
                .transition(.scale.combined(with: .opacity))
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .boostersUpdated)) { _ in
            print("🔄 BoosterDisplayView: Received boostersUpdated notification")
            refreshTrigger.toggle()
        }
    }
}

struct BoosterItemView: View {
    let booster: BoosterEffect
    @StateObject private var themeManager = ThemeManager.shared

    var body: some View {
        HStack(spacing: 8) {
            // Booster type icon
            if booster.type == .coins {
                Image("icon_gold")
                    .resizable()
                    .frame(width: 12, height: 12)
            } else if booster.type == .experience {
                Image("icon_lightning")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 12, height: 12)
                    .foregroundColor(boosterColor)
            } else {
                Image(systemName: boosterIconName)
                    .foregroundColor(boosterColor)
                    .font(.system(size: 12, weight: .medium))
                    .frame(width: 16, height: 16)
            }

            // Booster description
            VStack(alignment: .leading, spacing: 2) {
                Text(booster.sourceName)
                    .font(.appFont(size: 12, weight: .medium))
                    .foregroundColor(themeManager.activeTheme.textColor)

                Text(booster.description)
                    .font(.appFont(size: 10))
                    .foregroundColor(themeManager.activeTheme.textColor.opacity(0.7))
            }

            Spacer()

            // Time remaining (for temporary boosters)
            if let expiresAt = booster.expiresAt {
                Text(timeRemainingText(from: expiresAt))
                    .font(.appFont(size: 10, weight: .medium))
                    .foregroundColor(.orange)
            }
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(themeManager.activeTheme.backgroundColor.opacity(0.5))
        )
    }

    private var boosterIconName: String {
        switch booster.type {
        case .experience:
            return "icon_lightning"
        case .coins:
            return "icon_gold"
        case .both:
            return "bolt.fill"
        }
    }

    private var boosterColor: Color {
        switch booster.type {
        case .experience:
            return .green
        case .coins:
            return .yellow
        case .both:
            return .orange
        }
    }

    private func timeRemainingText(from expiresAt: Date) -> String {
        let timeInterval = expiresAt.timeIntervalSinceNow
        if timeInterval <= 0 {
            return "expired".localized
        }

        let minutes = Int(timeInterval / 60)
        let hours = minutes / 60
        let remainingMinutes = minutes % 60

        if hours > 0 {
            return "\(hours)h \(remainingMinutes)m"
        } else {
            return "\(remainingMinutes)m"
        }
    }
}

#Preview {
    BoosterDisplayView()
        .padding()
        .background(Color.black)
}
