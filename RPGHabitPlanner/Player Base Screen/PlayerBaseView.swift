//
//  PlayerBaseView.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 28.07.2025.
//

import SwiftUI

struct PlayerBaseView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image("background")
                .resizable()
                .scaledToFill()
        }
        .padding()
        .background(
            Image("panel_brown")
                .resizable(capInsets: EdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20), resizingMode: .stretch)
                .cornerRadius(12)
        )
        .padding([.horizontal, .top])
        .frame(maxWidth: .infinity)
    }
}


#Preview {
    PlayerBaseView()
}
