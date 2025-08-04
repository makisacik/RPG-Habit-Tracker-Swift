//
//  CloseButtonView.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 4.08.2025.
//

import SwiftUI

struct CloseButtonView: View {
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject var themeManager: ThemeManager
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                Image(colorScheme == .dark ? "btn_lines_darkblue" : "btn_lines_white")
                    .resizable()
                    .frame(width: 40, height: 40)

                Image("icon_cross")
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 16, height: 16)
                    .foregroundColor(colorScheme == .dark ? Color(red: 0 / 255, green: 51 / 255, blue: 102 / 255) : .gray)
            }
        }
        .buttonStyle(.plain)
    }
}
