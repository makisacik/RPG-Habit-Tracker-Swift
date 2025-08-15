//
//  ActiveEffectsWidget.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 6.08.2025.
//

import SwiftUI

struct ActiveEffectsWidget: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var inventoryManager: InventoryManager
    @State private var showAllEffects = false
    
    var body: some View {
        let theme = themeManager.activeTheme
        
        if !inventoryManager.activeEffects.isEmpty {
            VStack(spacing: 8) {
                // Header
                HStack {
                    Image(systemName: "bolt.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.yellow)
                    
                    Text("Active Effects")
                        .font(.appFont(size: 14, weight: .black))
                        .foregroundColor(theme.textColor)
                    
                    Spacer()
                    
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showAllEffects.toggle()
                        }
                    }) {
                        Image(systemName: showAllEffects ? "chevron.up" : "chevron.down")
                            .font(.system(size: 12))
                            .foregroundColor(.yellow)
                    }
                }
                
                // Effects list
                if showAllEffects {
                    VStack(spacing: 6) {
                        ForEach(inventoryManager.activeEffects) { effect in
                            ActiveEffectWidgetRow(effect: effect)
                                .environmentObject(themeManager)
                        }
                    }
                    .transition(.move(edge: .top).combined(with: .opacity))
                } else {
                    // Compact view - show only the most important effect
                    if let mostImportantEffect = getMostImportantEffect() {
                        ActiveEffectWidgetRow(effect: mostImportantEffect, isCompact: true)
                            .environmentObject(themeManager)
                            .transition(.move(edge: .top).combined(with: .opacity))
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(theme.secondaryColor)
                    .shadow(color: Color.black.opacity(0.2), radius: 6, x: 0, y: 4)
            )
            .padding(.horizontal)
        }
    }
    
    private func getMostImportantEffect() -> ActiveEffect? {
        // Priority order: XP Boost > Health Regeneration > Focus Regeneration > others
        let priorityOrder: [ItemEffect.EffectType] = [
            .xpBoost,
            .healthRegeneration,
            .focusRegeneration,
            .coinBoost,
            .attack,
            .defense,
            .luck,
            .speed,
            .criticalChance,
            .criticalDamage
        ]
        
        for effectType in priorityOrder {
            if let effect = inventoryManager.getActiveEffect(for: effectType) {
                return effect
            }
        }
        
        return inventoryManager.activeEffects.first
    }
}

struct ActiveEffectWidgetRow: View {
    @EnvironmentObject var themeManager: ThemeManager
    let effect: ActiveEffect
    let isCompact: Bool
    @State private var remainingTime: TimeInterval = 0
    
    init(effect: ActiveEffect, isCompact: Bool = false) {
        self.effect = effect
        self.isCompact = isCompact
    }
    
    var body: some View {
        let theme = themeManager.activeTheme
        HStack(spacing: 8) {
            // Effect icon
            Image(systemName: effect.effect.type.icon)
                .font(.system(size: isCompact ? 12 : 14))
                .foregroundColor(.yellow)
                .frame(width: isCompact ? 16 : 20)
            
            // Effect name and value
            VStack(alignment: .leading, spacing: 2) {
                Text(effect.effect.type.rawValue)
                    .font(.appFont(size: isCompact ? 10 : 12, weight: .black))
                    .foregroundColor(theme.textColor)
                
                if !isCompact {
                    Text(effect.effect.displayValue)
                        .font(.appFont(size: 10, weight: .medium))
                        .foregroundColor(theme.textColor.opacity(0.8))
                }
            }
            
            Spacer()
            
            // Countdown timer
            if let remaining = effect.remainingTime {
                VStack(alignment: .trailing, spacing: 2) {
                    Text(formatTime(remaining))
                        .font(.appFont(size: isCompact ? 10 : 12, weight: .black))
                        .foregroundColor(.yellow)
                    
                    if !isCompact {
                        // Progress bar
                        ProgressView(value: effect.progress)
                            .progressViewStyle(LinearProgressViewStyle(tint: .yellow))
                            .frame(width: 40, height: 4)
                    }
                }
            }
        }
        .padding(.vertical, isCompact ? 2 : 4)
        .onAppear {
            updateRemainingTime()
        }
        .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in
            updateRemainingTime()
        }
    }
    
    private func updateRemainingTime() {
        remainingTime = effect.remainingTime ?? 0
    }
    
    private func formatTime(_ timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        
        if minutes > 0 {
            return String(format: "%dm %02ds", minutes, seconds)
        } else {
            return String(format: "%ds", seconds)
        }
    }
}

// MARK: - XP Boost Indicator

struct XPBoostIndicator: View {
    @EnvironmentObject var inventoryManager: InventoryManager
    
    var body: some View {
        if let xpBoost = inventoryManager.getActiveXPBoost() {
            HStack(spacing: 4) {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 12))
                    .foregroundColor(.green)
                
                Text("\(Int(inventoryManager.getXPBoostMultiplier() * 100))% XP")
                    .font(.appFont(size: 10, weight: .black))
                    .foregroundColor(.green)
                
                if let remaining = xpBoost.remainingTime {
                    Text("(\(formatTime(remaining)))")
                        .font(.appFont(size: 8, weight: .medium))
                        .foregroundColor(.green.opacity(0.8))
                }
            }
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.green.opacity(0.2))
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color.green.opacity(0.3), lineWidth: 1)
                    )
            )
        }
    }
    
    private func formatTime(_ timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        
        if minutes > 0 {
            return String(format: "%dm", minutes)
        } else {
            return String(format: "%ds", seconds)
        }
    }
}

// MARK: - Preview

struct ActiveEffectsWidget_Previews: PreviewProvider {
    static var previews: some View {
        ActiveEffectsWidget()
            .environmentObject(ThemeManager.shared)
            .environmentObject(InventoryManager.shared)
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
