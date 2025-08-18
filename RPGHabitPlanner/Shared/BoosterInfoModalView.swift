//
//  BoosterInfoModalView.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 6.08.2025.
//

import SwiftUI

struct BoosterInfoModalView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @ObservedObject private var boosterManager = BoosterManager.shared
    @Environment(\.dismiss) private var dismiss
    @State private var refreshTrigger = false
    
    var body: some View {
        let theme = themeManager.activeTheme
        
        NavigationView {
            ZStack {
                theme.backgroundColor
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Header with total boosters
                        totalBoostersSection(theme: theme)
                        
                        // Building boosters
                        if !getBuildingBoosters().isEmpty {
                            boosterSection(
                                title: "Building Boosters",
                                icon: "building.2.fill",
                                boosters: getBuildingBoosters(),
                                theme: theme
                            )
                        }
                        
                        // Item boosters
                        if !getItemBoosters().isEmpty {
                            boosterSection(
                                title: "Item Boosters",
                                icon: "bag.fill",
                                boosters: getItemBoosters(),
                                theme: theme
                            )
                        }
                        
                        // No boosters message
                        if boosterManager.activeBoosters.isEmpty {
                            noBoostersView(theme: theme)
                        }
                        
                        Spacer()
                    }
                    .padding()
                }
            }
            .navigationTitle("Active Boosters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(theme.accentColor)
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: .boostersUpdated)) { _ in
                print("🔄 BoosterInfoModalView: Received boostersUpdated notification")
                refreshTrigger.toggle()
            }
        }
    }
    
    private func totalBoostersSection(theme: Theme) -> some View {
        VStack(spacing: 16) {
            HStack {
                Image("icon_lightning")
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundColor(.yellow)
                
                Text("Total Active Boosters")
                    .font(.appFont(size: 20, weight: .bold))
                    .foregroundColor(theme.textColor)
                
                Spacer()
            }
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                // Experience Booster
                VStack(spacing: 8) {
                    HStack {
                        Image(systemName: "star.fill")
                            .foregroundColor(.green)
                        Text("Experience")
                            .font(.appFont(size: 14, weight: .medium))
                            .foregroundColor(theme.textColor)
                    }
                    
                    Text("\(Int((boosterManager.totalExperienceMultiplier - 1.0) * 100))%")
                        .font(.appFont(size: 24, weight: .black))
                        .foregroundColor(.green)
                    
                    if boosterManager.totalExperienceBonus > 0 {
                        Text("+\(boosterManager.totalExperienceBonus)")
                            .font(.appFont(size: 12))
                            .foregroundColor(.green.opacity(0.8))
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(theme.primaryColor.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.green.opacity(0.3), lineWidth: 1)
                        )
                )
                
                // Coin Booster
                VStack(spacing: 8) {
                    HStack {
                        Image("icon_gold")
                            .resizable()
                            .frame(width: 16, height: 16)
                        Text("Coins")
                            .font(.appFont(size: 14, weight: .medium))
                            .foregroundColor(theme.textColor)
                    }
                    
                    Text("\(Int((boosterManager.totalCoinsMultiplier - 1.0) * 100))%")
                        .font(.appFont(size: 24, weight: .black))
                        .foregroundColor(.yellow)
                    
                    if boosterManager.totalCoinsBonus > 0 {
                        Text("+\(boosterManager.totalCoinsBonus)")
                            .font(.appFont(size: 12))
                            .foregroundColor(.yellow.opacity(0.8))
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(theme.primaryColor.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.yellow.opacity(0.3), lineWidth: 1)
                        )
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(theme.secondaryColor)
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
    }
    
    private func boosterSection(title: String, icon: String, boosters: [BoosterEffect], theme: Theme) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(theme.accentColor)
                Text(title)
                    .font(.appFont(size: 18, weight: .bold))
                    .foregroundColor(theme.textColor)
                Spacer()
            }
            
            LazyVStack(spacing: 8) {
                ForEach(boosters, id: \.sourceId) { booster in
                    boosterRow(booster: booster, theme: theme)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(theme.secondaryColor)
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
    }
    
    private func boosterRow(booster: BoosterEffect, theme: Theme) -> some View {
        HStack(spacing: 12) {
            // Booster icon
            if booster.type == .coins {
                Image("icon_gold")
                    .resizable()
                    .frame(width: 16, height: 16)
            } else {
                Image(systemName: boosterIconName(for: booster.type))
                    .foregroundColor(boosterColor(for: booster.type))
                    .font(.system(size: 16, weight: .bold))
                    .frame(width: 24, height: 24)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(booster.sourceName)
                    .font(.appFont(size: 14, weight: .medium))
                    .foregroundColor(theme.textColor)
                
                HStack(spacing: 8) {
                    Text("\(Int((booster.multiplier - 1.0) * 100))%")
                        .font(.appFont(size: 12, weight: .bold))
                        .foregroundColor(boosterColor(for: booster.type))
                    
                    if booster.flatBonus > 0 {
                        Text("+\(booster.flatBonus)")
                            .font(.appFont(size: 12))
                            .foregroundColor(boosterColor(for: booster.type).opacity(0.8))
                    }
                    
                    if let expiresAt = booster.expiresAt {
                        Spacer()
                        Text("Expires: \(expiresAt, style: .relative)")
                            .font(.appFont(size: 10))
                            .foregroundColor(.red.opacity(0.8))
                    }
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(theme.primaryColor.opacity(0.05))
        )
    }
    
    private func noBoostersView(theme: Theme) -> some View {
        VStack(spacing: 16) {
            Image("icon_lightning")
                .resizable()
                .frame(width: 64, height: 64)
                .foregroundColor(.gray.opacity(0.5))
            
            Text("No Active Boosters")
                .font(.appFont(size: 20, weight: .bold))
                .foregroundColor(theme.textColor)
            
            Text("Build structures in your town or collect items to get boosters!")
                .font(.appFont(size: 14))
                .foregroundColor(theme.textColor.opacity(0.7))
                .multilineTextAlignment(.center)
        }
        .padding(40)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(theme.secondaryColor)
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
    }
    
    private func getBuildingBoosters() -> [BoosterEffect] {
        let buildingBoosters = boosterManager.activeBoosters.filter { $0.source == .building && $0.isActive && !$0.isExpired }
        print("🔄 BoosterInfoModalView: Found \(buildingBoosters.count) building boosters: \(buildingBoosters.map { $0.sourceName })")
        return buildingBoosters
    }
    
    private func getItemBoosters() -> [BoosterEffect] {
        return boosterManager.activeBoosters.filter { $0.source == .item && $0.isActive && !$0.isExpired }
    }
    
    private func boosterIconName(for type: BoosterType) -> String {
        switch type {
        case .experience: return "star.fill"
        case .coins: return "icon_gold"
        case .both: return "bolt.fill"
        }
    }
    
    private func boosterColor(for type: BoosterType) -> Color {
        switch type {
        case .experience: return .green
        case .coins: return .yellow
        case .both: return .orange
        }
    }
}

#Preview {
    BoosterInfoModalView()
        .environmentObject(ThemeManager.shared)
}
