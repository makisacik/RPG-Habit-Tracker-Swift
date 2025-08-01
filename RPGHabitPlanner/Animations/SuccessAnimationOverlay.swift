//
//  Success.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 1.08.2025.
//

import SwiftUI
import Lottie

struct SuccessAnimationOverlay: View {
    @Binding var isVisible: Bool
    var duration: Double = 2.0

    var body: some View {
        if isVisible {
            LottieView(animation: .named("success"))
                .playbackMode(.playing(.toProgress(1, loopMode: .playOnce)))
                .frame(width: 200, height: 200)
                .transition(.opacity)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                        withAnimation {
                            isVisible = false
                        }
                    }
                }
        }
    }
}
