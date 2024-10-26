//
//  SplashView.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 26.10.2024.
//

import SwiftUI

struct SplashView: View {
    @State var show = false
    let title = "RPG Your Life"

    private let colorsTuple: [(color: Color, delay: Double)] = [
        (Color(hex: "#E9EED9"), 0.0),
        (Color(hex: "#CBD2A4"), 0.04),
        (Color(hex: "#FFFF00"), 0.12),
        (Color(hex: "#9A7E6F"), 0.18),
        (Color(hex: "#B99470"), 0.28),
        (Color(hex: "#54473F"), 0.35)
    ]

    var body: some View {
        ZStack {
            ForEach(0..<colorsTuple.count, id: \.self) { index in
                let colorDelay = colorsTuple[index]
                AnimatedTitleView(title: title, color: colorDelay.color, initialDelay: colorDelay.delay, animationType: .spring(duration: 1))
            }
        }
    }
}

#Preview {
    SplashView()
}
