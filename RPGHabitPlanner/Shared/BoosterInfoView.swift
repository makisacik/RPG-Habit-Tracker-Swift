//
//  BoosterInfoView.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 6.08.2025.
//

import SwiftUI

struct BoosterInfoView: View {
    @StateObject private var themeManager = ThemeManager.shared
    @ObservedObject private var boosterManager = BoosterManager.shared
    @State private var refreshTrigger = false
    
    var body: some View {
        EmptyView()
    }
    
    @ViewBuilder
    private func boosterContent(booster: BoosterEffect) -> some View {
        VStack(spacing: 8) {
            boosterHeader(booster: booster)
            boosterDetails(booster: booster)
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(themeManager.activeTheme.backgroundColor.opacity(0.7))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(boosterColor(for: booster.type).opacity(0.3), lineWidth: 1)
                )
        )
    }
    
    @ViewBuilder
    private func boosterHeader(booster: BoosterEffect) -> some View {
        HStack {
            boosterIcon(booster: booster)

            Text("Quest Booster")
                .font(.appFont(size: 14, weight: .bold))
                .foregroundColor(themeManager.activeTheme.textColor)

            Spacer()
        }
    }
    
    @ViewBuilder
    private func boosterIcon(booster: BoosterEffect) -> some View {
        if booster.type == .coins {
            Image("icon_gold")
                .resizable()
                .frame(width: 14, height: 14)
        } else {
            Image(systemName: boosterIconName(for: booster.type))
                .foregroundColor(boosterColor(for: booster.type))
                .font(.system(size: 14, weight: .bold))
        }
    }
    
    @ViewBuilder
    private func boosterDetails(booster: BoosterEffect) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(booster.description)
                .font(.appFont(size: 12))
                .foregroundColor(themeManager.activeTheme.textColor.opacity(0.8))

            Text("Total Boost: +\(Int((boosterManager.totalExperienceMultiplier - 1.0) * 100))% XP, +\(Int((boosterManager.totalCoinsMultiplier - 1.0) * 100))% Coins")
                .font(.appFont(size: 10))
                .foregroundColor(.green)
        }
    }
    
    
    private func boosterIconName(for type: BoosterType) -> String {
        switch type {
        case .experience:
            return "star.fill"
        case .coins:
            return "icon_gold"
        case .both:
            return "bolt.fill"
        }
    }
    
    private func boosterColor(for type: BoosterType) -> Color {
        switch type {
        case .experience:
            return .green
        case .coins:
            return .yellow
        case .both:
            return .orange
        }
    }
}
