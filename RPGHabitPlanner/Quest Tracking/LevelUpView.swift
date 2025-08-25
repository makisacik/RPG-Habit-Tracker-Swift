//
//  LevelUpView.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 6.08.2025.
//

import SwiftUI

struct LevelUpView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Binding var isVisible: Bool
    @State private var showContent = false
    @State private var isDismissing = false
    var level: Int

    var body: some View {
        let theme = themeManager.activeTheme
        if isVisible {
            ZStack {
                Color.black.opacity(0.6)
                    .ignoresSafeArea()
                    .onTapGesture {
                        dismissWithAnimation()
                    }

                ZStack {
                    Image("icon_level_wings")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 250, height: 150)
                        .offset(y: 10)
                        .scaleEffect(showContent && !isDismissing ? 1.0 : 0.5)
                        .opacity(showContent && !isDismissing ? 1.0 : 0.0)
                        .animation(.easeOut(duration: 0.6).delay(isDismissing ? 0.0 : 0.2), value: showContent)

                    Image("icon_level")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 120)
                        .scaleEffect(showContent && !isDismissing ? 1.0 : 0.8)
                        .opacity(showContent && !isDismissing ? 1.0 : 0.0)
                        .animation(.easeOut(duration: 0.5).delay(isDismissing ? 0.0 : 0.1), value: showContent)

                    VStack(spacing: 2) {
                        Text(String(localized: "level").uppercased())
                            .font(.appFont(size: 18, weight: .black))
                            .foregroundColor(theme.textColor)
                            .offset(y: 14)
                            .opacity(showContent && !isDismissing ? 1.0 : 0.0)
                            .offset(y: showContent && !isDismissing ? 0 : 20)
                            .animation(.easeOut(duration: 0.4).delay(isDismissing ? 0.0 : 0.3), value: showContent)

                        Text("\(level)")
                            .font(.appFont(size: 42, weight: .black))
                            .foregroundColor(theme.textColor)
                            .opacity(showContent && !isDismissing ? 1.0 : 0.0)
                            .offset(y: showContent && !isDismissing ? 0 : 20)
                            .animation(.easeOut(duration: 0.4).delay(isDismissing ? 0.0 : 0.4), value: showContent)
                    }
                }
            }
            .transition(.opacity.combined(with: .scale))
            .animation(.easeInOut(duration: 0.3), value: isVisible)
            .onAppear {
                withAnimation(.easeOut(duration: 0.3)) {
                    showContent = true
                }
            }
            .onDisappear {
                showContent = false
                isDismissing = false
            }
        }
    }

    private func dismissWithAnimation() {
        isDismissing = true
        showContent = false

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            withAnimation(.easeInOut(duration: 0.2)) {
                isVisible = false
            }
        }
    }
}
