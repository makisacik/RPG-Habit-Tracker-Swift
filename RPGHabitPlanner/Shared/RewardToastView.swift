//
//  RewardToastView.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 6.08.2025.
//

import SwiftUI

struct RewardToastView: View {
    let toast: RewardToast
    let onDismiss: () -> Void
    
    @EnvironmentObject var themeManager: ThemeManager
    @State private var isVisible = false
    
    var body: some View {
        let theme = themeManager.activeTheme
        
        HStack(spacing: 12) {
            // Icon
            Image(systemName: toast.type.icon)
                .font(.title2)
                .foregroundColor(toast.type.color)
                .frame(width: 24, height: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                // Title
                Text(toast.title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(theme.textColor)
                    .lineLimit(1)
                
                // Rewards
                HStack(spacing: 12) {
                    // Experience
                    HStack(spacing: 4) {
                        Image("icon_lightning")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 12, height: 12)
                            .foregroundColor(.yellow)
                        
                        Text("+\(toast.experience) \("xp".localized)")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(theme.textColor)
                    }
                    
                    // Coins
                    HStack(spacing: 4) {
                        Image("icon_gold")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 12, height: 12)
                            .foregroundColor(.yellow)
                        
                        Text("+\(toast.coins) \("currency_coins".localized)")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(theme.textColor)
                    }
                }
            }
            
            Spacer()
            
            // Dismiss button
            Button(action: onDismiss) {
                Image(systemName: "xmark")
                    .font(.caption)
                    .foregroundColor(theme.textColor.opacity(0.6))
                    .frame(width: 20, height: 20)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(theme.cardBackgroundColor)
                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(toast.type.color.opacity(0.3), lineWidth: 1)
        )
        .offset(y: toast.offset)
        .opacity(toast.isVisible ? 1 : 0)
        .scaleEffect(toast.isVisible ? 1 : 0.8)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                isVisible = true
            }
        }
    }
}

// MARK: - Toast Container View

struct RewardToastContainerView: View {
    @ObservedObject var toastManager = RewardToastManager.shared
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        let theme = themeManager.activeTheme
        
        VStack {
            Spacer()
            
            // Toast stack
            VStack(spacing: 8) {
                ForEach(toastManager.toasts) { toast in
                    RewardToastView(toast: toast) {
                        toastManager.dismissToast(toast)
                    }
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .trailing).combined(with: .opacity)
                    ))
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 20) // Small gap above tab bar
        }
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: toastManager.toasts.count)
    }
}

// MARK: - Preview

struct RewardToastView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleToast = RewardToast(
            title: "Complete Daily Quest",
            experience: 25,
            coins: 15,
            type: .quest,
            timestamp: Date()
        )
        
        VStack {
            RewardToastView(toast: sampleToast) {}
            
            RewardToastContainerView()
        }
        .environmentObject(ThemeManager.shared)
        .background(Color.gray.opacity(0.1))
    }
}
