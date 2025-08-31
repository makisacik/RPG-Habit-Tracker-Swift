//
//  DetailedDamageModalView.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 6.08.2025.
//

import SwiftUI

struct DetailedDamageModalView: View {
    let damageData: DamageSummaryData
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        let theme = themeManager.activeTheme
        
        NavigationView {
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 16) {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.title2)
                            .foregroundColor(.red)
                        
                        Text("damage_breakdown".localized)
                            .font(.appFont(size: 20, weight: .bold))
                            .foregroundColor(theme.textColor)
                        
                        Spacer()
                        
                        Button(action: { dismiss() }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title2)
                                .foregroundColor(theme.textColor.opacity(0.7))
                        }
                    }
                    
                    // Summary card
                    VStack(spacing: 8) {
                        Text("total_damage_label".localized)
                            .font(.appFont(size: 14, weight: .medium))
                            .foregroundColor(theme.textColor.opacity(0.8))
                        
                        Text("\(damageData.totalDamage)")
                            .font(.appFont(size: 32, weight: .black))
                            .foregroundColor(.red)
                        
                        Text(String(format: "from_quests_affected".localized, damageData.questsAffected))
                            .font(.appFont(size: 12))
                            .foregroundColor(theme.textColor.opacity(0.6))
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
                }
                .padding()
                
                // Damage details list
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(Array(damageData.detailedDamage.enumerated()), id: \.offset) { _, damageItem in
                            DetailedDamageCard(damageItem: damageItem, theme: theme)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                }
            }
            .background(theme.backgroundColor)
            .navigationBarHidden(true)
        }
    }
}

struct DetailedDamageCard: View {
    let damageItem: DetailedDamageItem
    let theme: Theme
    @State private var isExpanded = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Main card content
            HStack(spacing: 12) {
                // Quest type icon
                VStack {
                    Image(systemName: questTypeIcon)
                        .font(.title3)
                        .foregroundColor(questTypeColor)
                    
                    Text("\(damageItem.damageAmount)")
                        .font(.appFont(size: 12, weight: .bold))
                        .foregroundColor(.red)
                }
                .frame(width: 40)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(damageItem.questTitle)
                        .font(.appFont(size: 16, weight: .semibold))
                        .foregroundColor(theme.textColor)
                        .lineLimit(2)
                    
                    Text(localizedQuestType(damageItem.questType))
                        .font(.appFont(size: 12, weight: .medium))
                        .foregroundColor(questTypeColor)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(questTypeColor.opacity(0.2))
                        )
                }
                
                Spacer()
                
                // Expand/collapse button
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isExpanded.toggle()
                    }
                }) {
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundColor(theme.textColor.opacity(0.6))
                        .frame(width: 24, height: 24)
                        .background(
                            Circle()
                                .fill(theme.textColor.opacity(0.1))
                        )
                }
            }
            .padding()
            .background(theme.cardBackgroundColor)
            .cornerRadius(12, corners: isExpanded ? [.topLeft, .topRight] : .allCorners)
            
            // Expanded content
            if isExpanded {
                VStack(alignment: .leading, spacing: 12) {
                    Divider()
                        .background(theme.textColor.opacity(0.2))
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("damage_reason".localized)
                            .font(.appFont(size: 14, weight: .semibold))
                            .foregroundColor(theme.textColor)
                        
                        Text(damageItem.reason)
                            .font(.appFont(size: 14))
                            .foregroundColor(theme.textColor.opacity(0.8))
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    
                    HStack {
                        Text("quest_type_label".localized)
                            .font(.appFont(size: 12, weight: .medium))
                            .foregroundColor(theme.textColor.opacity(0.6))
                        
                        Text(localizedQuestType(damageItem.questType))
                            .font(.appFont(size: 12, weight: .semibold))
                            .foregroundColor(questTypeColor)
                        
                        Spacer()
                        
                        Text(String(format: "damage_amount_label".localized, damageItem.damageAmount))
                            .font(.appFont(size: 12, weight: .bold))
                            .foregroundColor(.red)
                    }
                }
                .padding()
                .background(theme.cardBackgroundColor)
                .cornerRadius(12, corners: [.bottomLeft, .bottomRight])
            }
        }
        .shadow(color: theme.shadowColor, radius: 4, x: 0, y: 2)
    }
    
    private var questTypeIcon: String {
        switch damageItem.questType.lowercased() {
        case "daily":
            return "calendar.circle.fill"
        case "weekly":
            return "calendar.badge.clock"
        case "oneTime":
            return "target"
        case "scheduled":
            return "calendar.badge.plus"
        default:
            return "questionmark.circle.fill"
        }
    }
    
    private var questTypeColor: Color {
        switch damageItem.questType.lowercased() {
        case "daily":
            return .blue
        case "weekly":
            return .purple
        case "oneTime":
            return .orange
        case "scheduled":
            return .green
        default:
            return .gray
        }
    }
    
    private func localizedQuestType(_ questType: String) -> String {
        switch questType.lowercased() {
        case "daily":
            return "daily".localized
        case "weekly":
            return "weekly".localized
        case "onetime":
            return "one_time".localized
        case "scheduled":
            return "scheduled".localized
        default:
            return questType.capitalized
        }
    }
}

// Extension for rounded corners
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

#Preview {
    let sampleData = DamageSummaryData(
        totalDamage: 15,
        damageDate: Date(),
        questsAffected: 3,
        message: String(format: "damage_taken_message".localized, 15),
        detailedDamage: [
            DetailedDamageItem(
                questTitle: "Daily Workout",
                damageAmount: 6,
                reason: String(format: "daily_quest_missed_reason".localized, "Daily Workout", 2),
                questType: "daily"
            ),
            DetailedDamageItem(
                questTitle: "Weekly Report",
                damageAmount: 8,
                reason: String(format: "weekly_quest_missed_reason".localized, "Weekly Report", 1),
                questType: "weekly"
            ),
            DetailedDamageItem(
                questTitle: "Project Deadline",
                damageAmount: 10,
                reason: String(format: "one_time_quest_overdue_reason".localized, "Project Deadline"),
                questType: "oneTime"
            )
        ]
    )
    
    DetailedDamageModalView(damageData: sampleData)
        .environmentObject(ThemeManager.shared)
}
