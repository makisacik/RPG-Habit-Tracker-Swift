//
//  CharacterComponents.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 6.08.2025.
//

import SwiftUI

// MARK: - Compact Boosters Section View
struct CompactBoostersSectionView: View {
    @ObservedObject var boosterManager: BoosterManager
    let theme: Theme
    @State private var refreshTrigger = false

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Active Boosters")
                    .font(.appFont(size: 20, weight: .bold))
                    .foregroundColor(theme.textColor)
                Spacer()
            }

            if boosterManager.activeBoosters.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "bolt.slash")
                        .font(.system(size: 32))
                        .foregroundColor(theme.textColor.opacity(0.5))
                    Text("No active boosters")
                        .font(.appFont(size: 16))
                        .foregroundColor(theme.textColor.opacity(0.7))
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(theme.backgroundColor.opacity(0.7))
                )
            } else {
                VStack(spacing: 16) {
                    // Total Boosters Summary
                    totalBoostersSummary(theme: theme)
                    
                    // Individual Boosters List
                    individualBoostersList(theme: theme)
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .boostersUpdated)) { _ in
            print("🔄 CompactBoostersSectionView: Received boostersUpdated notification")
            refreshTrigger.toggle()
        }
    }
    
    private func totalBoostersSummary(theme: Theme) -> some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 12) {
            // Experience Booster
            VStack(spacing: 6) {
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundColor(.green)
                        .font(.system(size: 14))
                    Text("Experience")
                        .font(.appFont(size: 12, weight: .medium))
                        .foregroundColor(theme.textColor)
                }

                Text("\(Int((boosterManager.totalExperienceMultiplier - 1.0) * 100))%")
                    .font(.appFont(size: 18, weight: .black))
                    .foregroundColor(.green)

                if boosterManager.totalExperienceBonus > 0 {
                    Text("+\(boosterManager.totalExperienceBonus)")
                        .font(.appFont(size: 10))
                        .foregroundColor(.green.opacity(0.8))
                }
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(theme.primaryColor.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.green.opacity(0.3), lineWidth: 1)
                    )
            )

            // Coin Booster
            VStack(spacing: 6) {
                HStack {
                    Image("icon_gold")
                        .resizable()
                        .frame(width: 14, height: 14)
                    Text("Coins")
                        .font(.appFont(size: 12, weight: .medium))
                        .foregroundColor(theme.textColor)
                }

                Text("\(Int((boosterManager.totalCoinsMultiplier - 1.0) * 100))%")
                    .font(.appFont(size: 18, weight: .black))
                    .foregroundColor(.yellow)

                if boosterManager.totalCoinsBonus > 0 {
                    Text("+\(boosterManager.totalCoinsBonus)")
                        .font(.appFont(size: 10))
                        .foregroundColor(.yellow.opacity(0.8))
                }
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(theme.primaryColor.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.yellow.opacity(0.3), lineWidth: 1)
                    )
            )
        }
    }
    
    private func individualBoostersList(theme: Theme) -> some View {
        VStack(spacing: 8) {
            ForEach(getItemBoosters(), id: \.sourceId) { booster in
                compactBoosterRow(booster: booster, theme: theme)
            }
        }
    }
    
    private func compactBoosterRow(booster: BoosterEffect, theme: Theme) -> some View {
        HStack(spacing: 10) {
            // Booster icon
            if booster.type == .coins {
                Image("icon_gold")
                    .resizable()
                    .frame(width: 14, height: 14)
            } else {
                Image(systemName: boosterIconName(for: booster.type))
                    .foregroundColor(boosterColor(for: booster.type))
                    .font(.system(size: 14, weight: .bold))
                    .frame(width: 20, height: 20)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(booster.sourceName)
                    .font(.appFont(size: 12, weight: .medium))
                    .foregroundColor(theme.textColor)

                HStack(spacing: 6) {
                    Text("\(Int((booster.multiplier - 1.0) * 100))%")
                        .font(.appFont(size: 10, weight: .bold))
                        .foregroundColor(boosterColor(for: booster.type))

                    if booster.flatBonus > 0 {
                        Text("+\(booster.flatBonus)")
                            .font(.appFont(size: 10))
                            .foregroundColor(boosterColor(for: booster.type).opacity(0.8))
                    }

                    if let expiresAt = booster.expiresAt {
                        Spacer()
                        Text("Expires: \(expiresAt, style: .relative)")
                            .font(.appFont(size: 9))
                            .foregroundColor(.red.opacity(0.8))
                    }
                }
            }

            Spacer()
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 10)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(theme.primaryColor.opacity(0.05))
        )
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

// MARK: - Shop Button View
struct ShopButtonView: View {
    @Binding var showShop: Bool
    let theme: Theme

    var body: some View {
        Button(action: {
            showShop = true
        }) {
            HStack(spacing: 8) {
                Image(systemName: "cart.fill")
                    .font(.system(size: 16))
                Text("Visit Shop")
                    .font(.appFont(size: 16, weight: .medium))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 25)
                    .fill(theme.primaryColor)
                    .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}
