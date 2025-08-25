//
//  DamageCalculationView.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 6.08.2025.
//

import SwiftUI

struct DamageCalculationView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @StateObject private var damageTrackingManager = QuestDamageTrackingManager.shared
    private let questDataService = QuestCoreDataService()
    
    @State private var quests: [Quest] = []
    @State private var isLoading = false
    @State private var calculationResult: String?
    @State private var showResult = false
    
    var body: some View {
        let theme = themeManager.activeTheme
        
        NavigationView {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "bolt.fill")
                        .foregroundColor(.orange)
                        .font(.title)
                    
                    Text(String(localized: "quest_damage_calculator"))
                        .font(.appFont(size: 24, weight: .black))
                        .foregroundColor(theme.textColor)
                    
                    Text(String(localized: "calculate_damage_for_active_quests"))
                        .font(.appFont(size: 16))
                        .foregroundColor(theme.textColor.opacity(0.7))
                        .multilineTextAlignment(.center)
                }
                .padding()
                
                // Active quests info
                VStack(spacing: 12) {
                    HStack {
                        Image(systemName: "list.bullet")
                            .foregroundColor(theme.accentColor)
                            .font(.title3)
                        
                        Text(String(localized: "active_quests"))
                            .font(.appFont(size: 18, weight: .semibold))
                            .foregroundColor(theme.textColor)
                        
                        Spacer()
                        
                        Text("\(quests.filter { $0.isActive && !$0.isCompleted }.count)")
                            .font(.appFont(size: 24, weight: .black))
                            .foregroundColor(theme.accentColor)
                    }
                    
                    if !quests.filter({ $0.isActive && !$0.isCompleted }).isEmpty {
                        ScrollView {
                            LazyVStack(spacing: 8) {
                                ForEach(quests.filter { $0.isActive && !$0.isCompleted }) { quest in
                                    QuestDamagePreviewRow(quest: quest, theme: theme)
                                }
                            }
                        }
                        .frame(maxHeight: 200)
                    } else {
                        Text(String(localized: "no_active_quests_found"))
                            .font(.appFont(size: 16))
                            .foregroundColor(theme.textColor.opacity(0.7))
                            .padding()
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(theme.cardBackgroundColor)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(theme.borderColor, lineWidth: 1)
                        )
                )
                .padding(.horizontal)
                
                // Calculate button
                Button(action: calculateDamage) {
                    HStack {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.8)
                        } else {
                            Image(systemName: "bolt.fill")
                                .font(.title3)
                        }
                        
                        Text(isLoading ? String(localized: "calculating") : String(localized: "calculate_damage"))
                            .font(.appFont(size: 16, weight: .medium))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(isLoading ? Color.gray : Color.red)
                    )
                }
                .disabled(isLoading)
                .padding(.horizontal)
                
                // Today's damage summary
                VStack(spacing: 8) {
                    HStack {
                        Image(systemName: "heart.fill")
                            .foregroundColor(.red)
                            .font(.title3)
                        
                        Text(String(localized: "todays_total_damage"))
                            .font(.appFont(size: 18, weight: .semibold))
                            .foregroundColor(theme.textColor)
                        
                        Spacer()
                        
                        Text("\(damageTrackingManager.totalDamageTakenToday)")
                            .font(.appFont(size: 24, weight: .black))
                            .foregroundColor(theme.accentColor)
                    }
                    
                    if let lastCalculation = damageTrackingManager.lastDamageCalculationDate {
                        Text(String(localized: "last_calculated").localized(with: formatDate(lastCalculation)))
                            .font(.appFont(size: 14))
                            .foregroundColor(theme.textColor.opacity(0.6))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
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
                
                Spacer()
            }
            .navigationTitle(String(localized: "damage_calculator"))
            .navigationBarTitleDisplayMode(.inline)
            .background(theme.backgroundColor)
            .onAppear {
                loadQuests()
            }
            .alert(String(localized: "damage_calculation_result"), isPresented: $showResult) {
                Button(String(localized: "ok_button")) { }
            } message: {
                Text(calculationResult ?? String(localized: "unknown_result"))
            }
        }
    }
    
    private func loadQuests() {
        questDataService.fetchAllQuests { quests, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error loading quests: \(error)")
                } else {
                    self.quests = quests
                }
            }
        }
    }
    
    private func calculateDamage() {
        isLoading = true
        calculationResult = nil
        
        damageTrackingManager.calculateAndApplyQuestDamage { totalDamage, error in
            DispatchQueue.main.async {
                isLoading = false
                
                if let error = error {
                    calculationResult = String(localized: "error_prefix") + error.localizedDescription
                } else if totalDamage > 0 {
                    calculationResult = String(localized: "damage_applied_message").localized(with: totalDamage)
                } else {
                    calculationResult = String(localized: "no_damage_calculated_message")
                }
                
                showResult = true
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct QuestDamagePreviewRow: View {
    let quest: Quest
    let theme: Theme
    
    var body: some View {
        HStack(spacing: 12) {
            // Quest type icon
            Image(systemName: questTypeIcon)
                .foregroundColor(questTypeColor)
                .font(.title3)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(quest.title)
                    .font(.appFont(size: 14, weight: .medium))
                    .foregroundColor(theme.textColor)
                    .lineLimit(1)
                
                Text(quest.repeatType.rawValue.capitalized)
                    .font(.appFont(size: 12))
                    .foregroundColor(theme.textColor.opacity(0.6))
            }
            
            Spacer()
            
            // Due date info
            VStack(alignment: .trailing, spacing: 2) {
                Text(daysUntilDueText)
                    .font(.appFont(size: 12, weight: .medium))
                    .foregroundColor(daysUntilDueColor)
                
                Text(formatDate(quest.dueDate))
                    .font(.appFont(size: 10))
                    .foregroundColor(theme.textColor.opacity(0.5))
            }
        }
        .padding(.vertical, 4)
    }
    
    private var questTypeIcon: String {
        switch quest.repeatType {
        case .daily:
            return "calendar.day.timeline.left"
        case .weekly:
            return "calendar.badge.clock"
        case .oneTime:
            return "target"
        case .scheduled:
            return "calendar"
        }
    }
    
    private var questTypeColor: Color {
        switch quest.repeatType {
        case .daily:
            return .blue
        case .weekly:
            return .purple
        case .oneTime:
            return .orange
        case .scheduled:
            return .green
        }
    }
    
    private var daysUntilDueText: String {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let dueDate = calendar.startOfDay(for: quest.dueDate)
        
        if dueDate < today {
            let days = calendar.dateComponents([.day], from: dueDate, to: today).day ?? 0
            return String(localized: "days_overdue").localized(with: days)
        } else if dueDate == today {
            return String(localized: "due_today")
        } else {
            let days = calendar.dateComponents([.day], from: today, to: dueDate).day ?? 0
            return String(localized: "days_left").localized(with: days)
        }
    }
    
    private var daysUntilDueColor: Color {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let dueDate = calendar.startOfDay(for: quest.dueDate)
        
        if dueDate < today {
            return .red
        } else if dueDate == today {
            return .orange
        } else {
            return .green
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }
}

#Preview {
    DamageCalculationView()
        .environmentObject(ThemeManager.shared)
}
