//
//  CharacterComponents.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 6.08.2025.
//

import SwiftUI

// MARK: - Boosters Section View
struct BoostersSectionView: View {
    @ObservedObject var boosterManager: BoosterManager
    @Binding var showBoosterInfo: Bool
    let theme: Theme

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Active Boosters")
                    .font(.appFont(size: 20, weight: .bold))
                    .foregroundColor(theme.textColor)
                Spacer()
                Button(action: {
                    showBoosterInfo = true
                }) {
                    Image(systemName: "info.circle")
                        .font(.system(size: 16))
                        .foregroundColor(theme.textColor.opacity(0.7))
                }
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
                VStack(spacing: 8) {
                    ForEach(boosterManager.activeBoosters, id: \.id) { booster in
                        BoosterCard(booster: booster, theme: theme)
                    }
                }
            }
        }
        .sheet(isPresented: $showBoosterInfo) {
            BoosterInfoModalView()
                .environmentObject(ThemeManager.shared)
        }
    }
}

// MARK: - Booster Card
struct BoosterCard: View {
    let booster: BoosterEffect
    let theme: Theme

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "bolt.fill")
                .font(.system(size: 20))
                .foregroundColor(.yellow)

            VStack(alignment: .leading, spacing: 4) {
                Text(booster.sourceName)
                    .font(.appFont(size: 14, weight: .medium))
                    .foregroundColor(theme.textColor)

                Text(booster.type.description)
                    .font(.appFont(size: 12))
                    .foregroundColor(theme.textColor.opacity(0.7))
            }

            Spacer()

            if let remainingTime = booster.remainingTime {
                Text("\(Int(remainingTime))s")
                    .font(.appFont(size: 12, weight: .medium))
                    .foregroundColor(theme.textColor.opacity(0.8))
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(theme.backgroundColor.opacity(0.7))
                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        )
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
