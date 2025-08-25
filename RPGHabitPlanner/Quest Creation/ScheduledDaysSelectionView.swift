//
//  ScheduledDaysSelectionView.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 30.10.2024.
//

import SwiftUI

struct ScheduledDaysSelectionView: View {
    @Binding var selectedDays: Set<Int>
    @EnvironmentObject var themeManager: ThemeManager

    private let weekdays = [
        (1, "Sun"),
        (2, "Mon"),
        (3, "Tue"),
        (4, "Wed"),
        (5, "Thu"),
        (6, "Fri"),
        (7, "Sat")
    ]

    var body: some View {
        let theme = themeManager.activeTheme

        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "calendar")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(theme.textColor.opacity(0.6))

                Text(String(localized: "scheduled_days"))
                    .font(.appFont(size: 18, weight: .semibold))
                    .foregroundColor(theme.textColor)

                Spacer()
            }

            HStack(spacing: 8) {
                ForEach(weekdays, id: \.0) { dayNumber, dayName in
                    Button(action: {
                        if selectedDays.contains(dayNumber) {
                            selectedDays.remove(dayNumber)
                        } else {
                            selectedDays.insert(dayNumber)
                        }
                    }) {
                        Text(dayName)
                            .font(.appFont(size: 12, weight: .medium))
                            .foregroundColor(selectedDays.contains(dayNumber) ? .white : theme.textColor)
                            .frame(width: 32, height: 32)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(selectedDays.contains(dayNumber) ? theme.accentColor : Color.clear)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(selectedDays.contains(dayNumber) ? theme.accentColor : theme.textColor.opacity(0.3), lineWidth: 1)
                                    )
                            )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    ScheduledDaysSelectionView(selectedDays: .constant([2, 4, 6]))
        .environmentObject(ThemeManager.shared)
        .padding()
}
