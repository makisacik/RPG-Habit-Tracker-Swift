//
//  NicknamePopupView.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 4.08.2025.
//

import SwiftUI

struct NicknamePopupView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Binding var nickname: String
    var onConfirm: () -> Void
    var onCancel: () -> Void

    var body: some View {
        let theme = themeManager.activeTheme

        VStack(spacing: 0) {
            Image(themeManager.currentTheme == .dark ? "icon_popup_top_blue" : "icon_popup_top_white")
                .resizable()
                .scaledToFit()
                .frame(width: 155)

            VStack(spacing: 16) {
                Text("Enter Your Nickname")
                    .font(.appFont(size: 18, weight: .black))
                    .foregroundColor(theme.textColor)

                TextField("Nickname", text: $nickname)
                    .font(.appFont(size: 18))
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(theme.backgroundColor)
                            .shadow(color: Color.black.opacity(0.2), radius: 6, x: 0, y: 4)
                    )

                Button(action: { onConfirm() }) {
                    Text("OK")
                        .font(.appFont(size: 18))
                        .foregroundColor(theme.textColor)
                        .padding(.horizontal)
                        .frame(height: 44)
                        .background(
                            Image(theme.buttonPrimary)
                                .resizable(
                                    capInsets: EdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20),
                                    resizingMode: .stretch
                                )
                        )
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(theme.primaryColor)
            )
            .overlay(
                CloseButtonView {
                    onCancel()
                }
                .offset(x: 20, y: -20),
                alignment: .topTrailing
            )
        }
        .overlay(
            Image("icon_feather")
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)
                .offset(y: -85)
        )
        .padding(.horizontal, 40)
    }
}
