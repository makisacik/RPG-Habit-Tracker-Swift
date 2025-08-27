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
    @State private var showShop = false

    var body: some View {
        VStack(spacing: 12) {
            // Header
            HStack {
                Text("active_boosters".localized)
                    .font(.appFont(size: 20, weight: .bold))
                    .foregroundColor(theme.textColor)
                Spacer()

                // Active boosters count badge
                if !boosterManager.activeBoosters.isEmpty {
                    Text("\(boosterManager.activeBoosters.count)")
                        .font(.appFont(size: 12, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(theme.primaryColor)
                        )
                }
            }

            if boosterManager.activeBoosters.isEmpty {
                // Empty state - modern design with shop navigation
                VStack(spacing: 16) {
                    HStack(spacing: 12) {
                        Image(systemName: "bolt.slash")
                            .font(.system(size: 20))
                            .foregroundColor(theme.textColor.opacity(0.5))
                        Text("no_active_boosters".localized)
                            .font(.appFont(size: 14))
                            .foregroundColor(theme.textColor.opacity(0.7))
                    }
                    
                    Text("visit_shop_to_get_boosters".localized)
                        .font(.appFont(size: 12))
                        .foregroundColor(theme.textColor.opacity(0.6))
                        .multilineTextAlignment(.center)
                    
                    Button(action: {
                        showShop = true
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "cart.fill")
                                .font(.system(size: 14))
                            Text("go_to_shop".localized)
                                .font(.appFont(size: 14, weight: .medium))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(theme.accentColor)
                                .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.vertical, 16)
                .padding(.horizontal, 20)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(theme.cardBackgroundColor.opacity(0.6))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(theme.borderColor.opacity(0.15), lineWidth: 1)
                        )
                )
            } else {
                VStack(spacing: 12) {
                    // Total Boosters Summary - modern horizontal layout
                    totalBoostersSummary(theme: theme)

                    // Individual Boosters List - only show if there are item boosters
                    if !getItemBoosters().isEmpty {
                        individualBoostersList(theme: theme)
                    }
                }
            }
        }
        .padding(16)
        .onReceive(NotificationCenter.default.publisher(for: .boostersUpdated)) { _ in
            print("🔄 CompactBoostersSectionView: Received boostersUpdated notification")
            refreshTrigger.toggle()
        }
        .sheet(isPresented: $showShop) {
            NavigationStack {
                ShopView(initialCategory: .consumables)
                    .environmentObject(ThemeManager.shared)
            }
        }
    }

    private func totalBoostersSummary(theme: Theme) -> some View {
        HStack(spacing: 12) {
            // Experience Booster
            HStack(spacing: 10) {
                Image("icon_lightning")
                    .resizable()
                    .frame(width: 16, height: 16)

                VStack(alignment: .leading, spacing: 2) {
                    Text("experience".localized)
                        .font(.appFont(size: 12, weight: .medium))
                        .foregroundColor(theme.textColor.opacity(0.8))

                    HStack(spacing: 4) {
                        Text("\(Int((boosterManager.totalExperienceMultiplier - 1.0) * 100))%")
                            .font(.appFont(size: 16, weight: .bold))
                            .foregroundColor(theme.accentColor)

                        if boosterManager.totalExperienceBonus > 0 {
                            Text("+\(boosterManager.totalExperienceBonus)")
                                .font(.appFont(size: 11))
                                .foregroundColor(theme.accentColor.opacity(0.8))
                        }
                    }
                }
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 14)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(theme.primaryColor.opacity(0.08))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(theme.primaryColor.opacity(0.15), lineWidth: 1)
                    )
            )

            // Coin Booster
            HStack(spacing: 10) {
                Image("icon_gold")
                    .resizable()
                    .frame(width: 16, height: 16)

                VStack(alignment: .leading, spacing: 2) {
                    Text("coins".localized)
                        .font(.appFont(size: 12, weight: .medium))
                        .foregroundColor(theme.textColor.opacity(0.8))

                    HStack(spacing: 4) {
                        Text("\(Int((boosterManager.totalCoinsMultiplier - 1.0) * 100))%")
                            .font(.appFont(size: 16, weight: .bold))
                            .foregroundColor(theme.accentColor)

                        if boosterManager.totalCoinsBonus > 0 {
                            Text("+\(boosterManager.totalCoinsBonus)")
                                .font(.appFont(size: 11))
                                .foregroundColor(theme.accentColor.opacity(0.8))
                        }
                    }
                }
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 14)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(theme.accentColor.opacity(0.08))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(theme.accentColor.opacity(0.15), lineWidth: 1)
                    )
            )

            Spacer()
        }
    }

    private func individualBoostersList(theme: Theme) -> some View {
        VStack(spacing: 6) {
            ForEach(getItemBoosters(), id: \.sourceId) { booster in
                compactBoosterRow(booster: booster, theme: theme)
            }
        }
    }

    private func compactBoosterRow(booster: BoosterEffect, theme: Theme) -> some View {
        HStack(spacing: 12) {
            // Booster icon
            if booster.type == .coins {
                Image("icon_gold")
                    .resizable()
                    .frame(width: 16, height: 16)
            } else if booster.type == .experience {
                Image("icon_lightning")
                    .resizable()
                    .frame(width: 16, height: 16)
            } else {
                Image(systemName: boosterIconName(for: booster.type))
                    .foregroundColor(boosterColor(for: booster.type))
                    .font(.system(size: 16, weight: .bold))
                    .frame(width: 20, height: 20)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(booster.sourceName)
                    .font(.appFont(size: 13, weight: .medium))
                    .foregroundColor(theme.textColor)
                    .lineLimit(1)

                                    HStack(spacing: 6) {
                        Text("\(Int((booster.multiplier - 1.0) * 100))%")
                            .font(.appFont(size: 11, weight: .bold))
                            .foregroundColor(theme.accentColor)

                        if booster.flatBonus > 0 {
                            Text("+\(booster.flatBonus)")
                                .font(.appFont(size: 10))
                                .foregroundColor(theme.accentColor.opacity(0.8))
                        }

                    if let expiresAt = booster.expiresAt {
                        Spacer()
                        Text("\("expires".localized): \(expiresAt, style: .relative)")
                            .font(.appFont(size: 10))
                            .foregroundColor(theme.textColor.opacity(0.6))
                            .lineLimit(1)
                    }
                                    }
            }

            Spacer()
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(theme.cardBackgroundColor.opacity(0.4))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(theme.borderColor.opacity(0.12), lineWidth: 1)
                )
        )
    }

    private func getItemBoosters() -> [BoosterEffect] {
        return boosterManager.activeBoosters.filter { $0.source == .item && $0.isActive && !$0.isExpired }
    }

    private func boosterIconName(for type: BoosterType) -> String {
        switch type {
        case .experience: return "bolt.fill"
        case .coins: return "icon_gold"
        case .both: return "bolt.fill"
        }
    }

    private func boosterColor(for type: BoosterType) -> Color {
        switch type {
        case .experience: return theme.primaryColor
        case .coins: return theme.accentColor
        case .both: return theme.primaryColor
        }
    }
}
