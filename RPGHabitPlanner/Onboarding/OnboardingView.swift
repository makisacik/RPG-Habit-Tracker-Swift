//
//  OnboardingView.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 10.11.2024.
//

import SwiftUI

struct OnboardingView: View {
    @Binding var isOnboardingCompleted: Bool
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        OnboardingFlowView(isOnboardingCompleted: $isOnboardingCompleted)
            .environmentObject(themeManager)
    }
}
