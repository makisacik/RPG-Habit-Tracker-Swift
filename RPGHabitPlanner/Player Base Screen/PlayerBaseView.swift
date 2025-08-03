//
//  PlayerBaseView.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 28.07.2025.
//

import SwiftUI

struct PlayerBaseView: View {
    @EnvironmentObject var themeManager: ThemeManager
    var body: some View {
        let theme = themeManager.activeTheme
        VStack(spacing: 16) {
            Image("background")
                .resizable()
                .scaledToFill()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(theme.primaryColor)
        )
        .padding([.horizontal, .top])
        .frame(maxWidth: .infinity)
    }
}


#Preview {
    PlayerBaseView()
}
