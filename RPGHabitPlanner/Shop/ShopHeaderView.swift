//
//  ShopHeaderView.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 24.08.2025.
//

import SwiftUI

struct ShopHeaderView: View {
    let theme: Theme
    let currentCoins: Int
    let currentGems: Int
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("adventure_shop".localized)
                    .font(.appFont(size: 24, weight: .black))
                    .foregroundColor(theme.textColor)

                Text("shop_description".localized)
                    .font(.appFont(size: 14))
                    .foregroundColor(theme.textColor.opacity(0.7))
            }

            Spacer()

            // Currency display
            HStack(spacing: 8) {
                // Coins
                HStack(spacing: 4) {
                    Image("icon_gold")
                        .resizable()
                        .frame(width: 20, height: 20)

                    Text("\(currentCoins)")
                        .font(.appFont(size: 16, weight: .black))
                        .foregroundColor(.yellow)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.yellow.opacity(0.2))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.yellow.opacity(0.5), lineWidth: 1)
                        )
                )

                // Gems
                HStack(spacing: 4) {
                    Image("icon_gem")
                        .resizable()
                        .frame(width: 20, height: 20)

                    Text("\(currentGems)")
                        .font(.appFont(size: 16, weight: .black))
                        .foregroundColor(.purple)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.purple.opacity(0.2))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.purple.opacity(0.5), lineWidth: 1)
                        )
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(theme.primaryColor)
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        )
        .padding(.horizontal)
        .padding(.top)
    }
}
