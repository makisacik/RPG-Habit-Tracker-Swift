//
//  Date+Anchors.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 9.08.2025.
//

import Foundation

func dayAnchor(_ date: Date, calendar: Calendar = .current) -> Date {
    calendar.startOfDay(for: date)
}

func weekAnchor(_ date: Date, calendar: Calendar = .current) -> Date {
    let comps = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
    let start = calendar.date(from: comps) ?? date
    return calendar.startOfDay(for: start)
}
