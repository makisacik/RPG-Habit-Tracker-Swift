//
//  DamageHistoryView.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 6.08.2025.
//

import SwiftUI

struct DamageHistoryView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @StateObject private var damageTrackingManager = QuestDamageTrackingManager.shared
    
    let questId: UUID
    let questTitle: String
    
    @State private var damageEvents: [DamageEvent] = []
    @State private var totalDamage: Int = 0
    @State private var isLoading = true
    @State private var errorMessage: String?
    
    var body: some View {
        let theme = themeManager.activeTheme
        
        NavigationView {
            VStack(spacing: 0) {
                // Header with total damage
                VStack(spacing: 12) {
                    HStack {
                        Image(systemName: "heart.fill")
                            .foregroundColor(.red)
                            .font(.title2)
                        
                        Text(String(localized: "total_damage_taken"))
                            .font(.appFont(size: 18, weight: .bold))
                            .foregroundColor(theme.textColor)
                        
                        Spacer()
                        
                        Text("\(totalDamage)")
                            .font(.appFont(size: 24, weight: .black))
                            .foregroundColor(.red)
                    }
                    
                    Text("\(String(localized: "quest_label")) \(questTitle)")
                        .font(.appFont(size: 14))
                        .foregroundColor(theme.textColor.opacity(0.7))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.red.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.red.opacity(0.3), lineWidth: 1)
                        )
                )
                .padding(.horizontal)
                .padding(.top)
                
                // Damage history list
                if isLoading {
                    Spacer()
                    ProgressView("Loading damage history...")
                        .foregroundColor(theme.textColor)
                    Spacer()
                } else if let errorMessage = errorMessage {
                    Spacer()
                    VStack(spacing: 12) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.orange)
                            .font(.title)
                        
                        Text(String(localized: "error_loading_damage_history"))
                            .font(.appFont(size: 16, weight: .bold))
                            .foregroundColor(theme.textColor)
                        
                        Text(errorMessage)
                            .font(.appFont(size: 14))
                            .foregroundColor(theme.textColor.opacity(0.7))
                            .multilineTextAlignment(.center)
                        
                        Button(String(localized: "retry")) {
                            loadDamageHistory()
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.orange)
                    }
                    .padding()
                    Spacer()
                } else if damageEvents.isEmpty {
                    Spacer()
                    VStack(spacing: 12) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.title)
                        
                        Text(String(localized: "no_damage_history"))
                            .font(.appFont(size: 16, weight: .bold))
                            .foregroundColor(theme.textColor)
                        
                        Text(String(localized: "no_damage_yet_message"))
                            .font(.appFont(size: 14))
                            .foregroundColor(theme.textColor.opacity(0.7))
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    Spacer()
                } else {
                    List {
                        ForEach(damageEvents) { event in
                            DamageEventRow(event: event, theme: themeManager.activeTheme)
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle(String(localized: "damage_history"))
            .navigationBarTitleDisplayMode(.inline)
            .background(theme.backgroundColor)
            .onAppear {
                loadDamageHistory()
            }
        }
    }
    
    private func loadDamageHistory() {
        isLoading = true
        errorMessage = nil
        
        damageTrackingManager.getDamageHistory(for: questId) { events, error in
            DispatchQueue.main.async {
                isLoading = false
                
                if let error = error {
                    errorMessage = error.localizedDescription
                } else {
                    damageEvents = events
                    totalDamage = events.reduce(0) { $0 + $1.damageAmount }
                }
            }
        }
    }
}

struct DamageEventRow: View {
    let event: DamageEvent
    let theme: Theme
    
    var body: some View {
        HStack(spacing: 12) {
            // Damage icon
            VStack {
                Image(systemName: "heart.fill")
                    .foregroundColor(.red)
                    .font(.title3)
                
                Text("\(event.damageAmount)")
                    .font(.appFont(size: 12, weight: .bold))
                    .foregroundColor(.red)
            }
            .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(event.reason)
                    .font(.appFont(size: 14, weight: .medium))
                    .foregroundColor(theme.textColor)
                    .lineLimit(2)
                
                Text(formatDate(event.date))
                    .font(.appFont(size: 12))
                    .foregroundColor(theme.textColor.opacity(0.6))
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.red.opacity(0.05))
        )
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

#Preview {
    DamageHistoryView(
        questId: UUID(),
        questTitle: String(localized: "sample_quest_title")
    )
    .environmentObject(ThemeManager.shared)
}
