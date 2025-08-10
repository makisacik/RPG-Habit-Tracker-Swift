//
//  QuestCalendarRow.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 10.08.2025.
//

import SwiftUI

struct QuestCalendarRow: View {
    let item: DayQuestItem
    let theme: Theme
    let onToggle: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(indicatorColor)
                .frame(width: 10, height: 10)
            VStack(alignment: .leading, spacing: 2) {
                Text(item.quest.title)
                    .font(.appFont(size: 16, weight: .medium))
                    .foregroundColor(theme.textColor)
                    .lineLimit(1)
                Text(subtitle)
                    .font(.appFont(size: 12, weight: .black))
                    .foregroundColor(theme.textColor.opacity(0.7))
            }
            Spacer()
            Button(action: onToggle) {
                Image(systemName: item.state == .done ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(item.state == .done ? .green : theme.textColor.opacity(0.6))
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(theme.primaryColor.opacity(0.3))
        )
    }
    
    private var indicatorColor: Color {
        switch item.state {
        case .done: return .green
        case .todo:
            switch item.quest.repeatType {
            case .daily: return .orange
            case .weekly: return .blue
            case .oneTime: return .orange
            }
        case .inactive: return .gray
        }
    }
    
    private var subtitle: String {
        switch item.quest.repeatType {
        case .daily: return "Daily"
        case .weekly: return "Weekly"
        case .oneTime: return "One-time"
        }
    }
}
