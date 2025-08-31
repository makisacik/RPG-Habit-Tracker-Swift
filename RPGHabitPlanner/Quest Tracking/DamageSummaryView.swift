//
//  DamageSummaryView.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 6.08.2025.
//

import SwiftUI

struct DamageSummaryView: View {
    let damageData: DamageSummaryData
    let onDismiss: () -> Void
    @EnvironmentObject var themeManager: ThemeManager
    @State private var damageNumberScale: CGFloat = 0.5
    @State private var damageNumberOpacity: Double = 0
    @State private var cardOffset: CGFloat = 50
    @State private var cardOpacity: Double = 0
    
    var body: some View {
        let theme = themeManager.activeTheme
        
        VStack(spacing: 20) {
            // Header
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.title)
                    .foregroundColor(.red)
                
                Text("Damage Summary")
                    .font(.appFont(size: 24, weight: .bold))
                    .foregroundColor(theme.textColor)
                
                Spacer()
                
                Button(action: onDismiss) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(theme.textColor.opacity(0.7))
                }
            }
            .padding(.horizontal)
            
            // Damage Info Card
            VStack(spacing: 16) {
                // Total Damage
                VStack(spacing: 8) {
                    Text("Total Damage Taken")
                        .font(.appFont(size: 18, weight: .semibold))
                        .foregroundColor(theme.textColor)
                    
                    Text("\(damageData.totalDamage)")
                        .font(.appFont(size: 48, weight: .bold))
                        .foregroundColor(.red)
                        .scaleEffect(damageNumberScale)
                        .opacity(damageNumberOpacity)
                }
                
                // Details
                VStack(spacing: 12) {
                    HStack {
                        Text("Damage Date:")
                            .font(.appFont(size: 16, weight: .medium))
                            .foregroundColor(theme.textColor)
                        Spacer()
                        Text(formatDate(damageData.damageDate))
                            .font(.appFont(size: 16))
                            .foregroundColor(theme.textColor.opacity(0.8))
                    }
                    
                    HStack {
                        Text("Quests Affected:")
                            .font(.appFont(size: 16, weight: .medium))
                            .foregroundColor(theme.textColor)
                        Spacer()
                        Text("\(damageData.questsAffected)")
                            .font(.appFont(size: 16))
                            .foregroundColor(theme.textColor.opacity(0.8))
                    }
                    
                    // Message
                    Text(damageData.message)
                        .font(.appFont(size: 14))
                        .foregroundColor(theme.textColor.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.top, 8)
                }
                .padding(.horizontal)
            }
            .padding()
            .background(theme.cardBackgroundColor)
            .cornerRadius(16)
            .shadow(color: theme.shadowColor, radius: 8, x: 0, y: 4)
            .offset(y: cardOffset)
            .opacity(cardOpacity)
            
            // Action Buttons
            VStack(spacing: 12) {
                Button(action: {
                    // Navigate to damage history or quest management
                    onDismiss()
                }) {
                    HStack {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                        Text("View Damage History")
                    }
                    .font(.appFont(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(theme.accentColor)
                    .cornerRadius(12)
                }
                
                Button(action: {
                    // Navigate to active quests
                    onDismiss()
                }) {
                    HStack {
                        Image(systemName: "list.bullet.clipboard")
                        Text("Manage Quests")
                    }
                    .font(.appFont(size: 16, weight: .medium))
                    .foregroundColor(theme.accentColor)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(theme.accentColor.opacity(0.1))
                    .cornerRadius(12)
                }
            }
            .offset(y: cardOffset)
            .opacity(cardOpacity)
            
            Spacer()
        }
        .padding()
        .background(theme.backgroundColor)
        .cornerRadius(20)
        .padding(.horizontal, 20)
        .padding(.vertical, 40)
        .onAppear {
            // Animate the card sliding up
            withAnimation(.easeOut(duration: 0.6)) {
                cardOffset = 0
                cardOpacity = 1
            }
            
            // Animate the damage number with a bounce effect
            withAnimation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.3)) {
                damageNumberScale = 1.0
                damageNumberOpacity = 1
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
