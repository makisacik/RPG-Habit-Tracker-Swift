//
//  CalendarDayView.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 10.08.2025.
//

import SwiftUI

struct CalendarDayView: View {
    let date: Date
    let isSelected: Bool
    let items: [DayQuestItem]
    let theme: Theme
    let onTap: () -> Void
    private let calendar = Calendar.current
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 2) {
                Text("\(calendar.component(.day, from: date))")
                    .font(.appFont(size: 16, weight: isSelected ? .bold : .medium))
                    .foregroundColor(isSelected ? .white : theme.textColor)
                if !items.isEmpty {
                    HStack(spacing: 3) {
                        ForEach(items.prefix(3)) { item in
                            Circle()
                                .fill(dotColor(for: item))
                                .frame(width: 6, height: 6)
                                .overlay(Text(shortType(item.quest.repeatType)).font(.system(size: 6, weight: .black)).foregroundColor(.white))
                        }
                    }
                }
            }
            .frame(width: 40, height: 40)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? theme.primaryColor : Color.clear)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func dotColor(for item: DayQuestItem) -> Color {
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
    
    private func shortType(_ repeatType: QuestRepeatType) -> String {
        switch repeatType {
        case .daily: return "D"
        case .weekly: return "W"
        case .oneTime: return "O"
        }
    }
}
