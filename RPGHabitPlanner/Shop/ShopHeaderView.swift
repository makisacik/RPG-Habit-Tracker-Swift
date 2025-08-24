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
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Adventure Shop")
                    .font(.appFont(size: 24, weight: .black))
                    .foregroundColor(theme.textColor)

                Text("Trade your coins for powerful items")
                    .font(.appFont(size: 14))
                    .foregroundColor(theme.textColor.opacity(0.7))
            }

            Spacer()

            // Coin display
            HStack(spacing: 8) {
                Image("icon_gold")
                    .resizable()
                    .frame(width: 24, height: 24)

                Text("\(currentCoins)")
                    .font(.appFont(size: 18, weight: .black))
                    .foregroundColor(.yellow)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.yellow.opacity(0.2))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.yellow.opacity(0.5), lineWidth: 1)
                    )
            )
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
