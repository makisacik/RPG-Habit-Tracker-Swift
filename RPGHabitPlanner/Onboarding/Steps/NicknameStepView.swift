//
//  NicknameStepView.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 7.01.2025.
//

import SwiftUI

struct NicknameStepView: View {
    @ObservedObject var coordinator: OnboardingCoordinator
    let theme: Theme
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Header
            VStack(spacing: 16) {
                Text("Name Your Hero")
                    .font(.appFont(size: 32, weight: .bold))
                    .foregroundColor(theme.textColor)
                
                Text("Choose a legendary name for your character")
                    .font(.appFont(size: 16))
                    .foregroundColor(theme.textColor.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }
            
            // Name input
            VStack(spacing: 8) {
                TextField("Enter hero name", text: $coordinator.nickname)
                    .font(.appFont(size: 18, weight: .medium))
                    .foregroundColor(theme.textColor)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(theme.cardBackgroundColor)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(theme.primaryColor.opacity(0.3), lineWidth: 1)
                            )
                    )
                    .textFieldStyle(PlainTextFieldStyle())
                    .onChange(of: coordinator.nickname) { newValue in
                        // Limit to 20 characters
                        if newValue.count > 20 {
                            coordinator.nickname = String(newValue.prefix(20))
                        }
                    }
                    .submitLabel(.done)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.words)
                
                Text("Maximum 20 characters")
                    .font(.appFont(size: 12))
                    .foregroundColor(theme.textColor.opacity(0.5))
            }
            .padding(.horizontal, 20)
            
            Spacer()
        }
        .padding(.horizontal, 20)
    }
}
