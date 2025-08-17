//
//  BoosterInfoView.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 6.08.2025.
//

import SwiftUI

struct BoosterInfoView: View {
    let building: Building
    @StateObject private var themeManager = ThemeManager.shared
    @ObservedObject private var boosterManager = BoosterManager.shared
    
    var body: some View {
        if let booster = getBuildingBooster() {
            VStack(spacing: 8) {
                HStack {
                    if booster.type == .coins {
                        Image("icon_gold")
                            .resizable()
                            .frame(width: 14, height: 14)
                    } else {
                        Image(systemName: boosterIconName(for: booster.type))
                            .foregroundColor(boosterColor(for: booster.type))
                            .font(.system(size: 14, weight: .bold))
                    }
                    
                    Text("Quest Booster")
                        .font(.appFont(size: 14, weight: .bold))
                        .foregroundColor(themeManager.activeTheme.textColor)
                    
                    Spacer()
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(booster.description)
                        .font(.appFont(size: 12))
                        .foregroundColor(themeManager.activeTheme.textColor.opacity(0.8))
                    
                    Text("Total Boost: +\(Int((boosterManager.totalExperienceMultiplier - 1.0) * 100))% XP, +\(Int((boosterManager.totalCoinsMultiplier - 1.0) * 100))% Coins")
                        .font(.appFont(size: 10))
                        .foregroundColor(.green)
                }
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
    }
    
    private func getBuildingBooster() -> BoosterEffect? {
        return boosterManager.activeBoosters.first { booster in
            booster.source == .building && booster.sourceId == building.type.rawValue
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

#Preview {
    let building = Building(
        type: .castle,
        state: .active,
        position: CGPoint(x: 0, y: 0),
        level: 3
    )
    
    return BoosterInfoView(building: building)
        .padding()
        .background(Color.black)
}
