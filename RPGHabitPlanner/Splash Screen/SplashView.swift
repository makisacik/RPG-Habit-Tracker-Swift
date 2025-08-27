//
//  SplashView.swift
//  RPGHabitPlanner
// purpose of the advanturer ??
//  Created by Mehmet Ali Kısacık on 26.10.2024.
//

import SwiftUI

struct SplashView: View {
    @State private var scale: CGFloat = 0.8
    @State private var opacity: Double = 0.0
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        let theme = themeManager.activeTheme

        ZStack {
            // Background color from theme
            theme.backgroundColor
                .ignoresSafeArea()

            // App Icon
            Image("splash_icon")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 250, height: 250)
            .scaleEffect(scale)
            .opacity(opacity)
            .animation(.easeInOut(duration: 0.5), value: scale)
            .animation(.easeInOut(duration: 0.5), value: opacity)
        }
        .onAppear {
            // Animate in
            withAnimation(.easeInOut(duration: 0.5)) {
                scale = 1.0
                opacity = 1.0
            }
        }
    }
}

#Preview {
    SplashView()
        .environmentObject(ThemeManager.shared)
}
