//
//  CalendarView.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 11.11.2024.
//

import SwiftUI

struct CalendarView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @ObservedObject var viewModel: CalendarViewModel
    @State private var selectedDate = Date()
    @State private var showingQuestCreation = false
    @State private var showingAlert = false

    private let calendar = Calendar.current
    private let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM yyyy"
        return dateFormatter
    }()
    
    var body: some View {
        let theme = themeManager.activeTheme
        
        var creationVM: QuestCreationViewModel {
            let creationVM = QuestCreationViewModel(questDataService: viewModel.questDataService)
            creationVM.questDueDate = selectedDate
            return creationVM
        }
        
            ZStack {
                theme.backgroundColor.ignoresSafeArea()
                VStack(spacing: 0) {
                    monthHeader(theme: theme)
                    dayOfWeekHeaders(theme: theme)
                    calendarGrid(theme: theme)
                    VStack(spacing: 0) {
                        if !viewModel.itemsForSelectedDate.isEmpty {
                            selectedDateDetails(theme: theme)
                        } else {
                            addQuestSection(theme: theme)
                        }
                    }
                    .frame(height: 220)
                }
            }
            .navigationTitle("Quest Calendar")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                viewModel.selectedDate = calendar.startOfDay(for: selectedDate)
                viewModel.fetchQuests()
            }
            .onAppear { print("Calendar appear", ObjectIdentifier(viewModel)) }
            .onDisappear { print("Calendar disappear") }
            .sheet(isPresented: $showingQuestCreation, onDismiss: {
                viewModel.fetchQuests()
            }) {
                NavigationStack {
                    QuestCreationView(viewModel: creationVM)
                }
            }
            .onChange(of: viewModel.alertMessage) { msg in
                if msg != nil { showingAlert = true }
            }
            .alert(isPresented: $showingAlert) {
                Alert(title: Text("Heads up"),
                      message: Text(viewModel.alertMessage ?? ""),
                      dismissButton: .default(Text("OK")) { viewModel.alertMessage = nil })
            }
    }
    
    private func monthHeader(theme: Theme) -> some View {
        HStack {
            Button(action: previousMonth) {
                Image(systemName: "chevron.left").font(.title2).foregroundColor(theme.textColor)
            }
            Spacer()
            Text(dateFormatter.string(from: selectedDate))
                .font(.appFont(size: 20, weight: .bold))
                .foregroundColor(theme.textColor)
            Spacer()
            Button(action: nextMonth) {
                Image(systemName: "chevron.right").font(.title2).foregroundColor(theme.textColor)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
    
    private func dayOfWeekHeaders(theme: Theme) -> some View {
        HStack(spacing: 0) {
            ForEach(calendar.shortWeekdaySymbols, id: \.self) { day in
                Text(day)
                    .font(.appFont(size: 14, weight: .medium))
                    .foregroundColor(theme.textColor.opacity(0.7))
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 8)
    }
    
    private func calendarGrid(theme: Theme) -> some View {
        let days = daysInMonth()
        return LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
            ForEach(Array(days.enumerated()), id: \.offset) { _, date in
                if let date = date {
                    let items = viewModel.items(for: date)
                    CalendarDayView(
                        date: date,
                        isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                        items: items,
                        theme: theme
                    ) {
                        selectedDate = date
                        viewModel.selectedDate = calendar.startOfDay(for: date)
                    }
                } else {
                    Color.clear.frame(height: 40)
                }
            }
        }
        .padding(.horizontal, 20)
    }
    
    private func selectedDateDetails(theme: Theme) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(selectedDate, style: .date)
                    .font(.appFont(size: 18, weight: .bold))
                    .foregroundColor(theme.textColor)
                Spacer()
                Text("\(viewModel.itemsForSelectedDate.count) item\(viewModel.itemsForSelectedDate.count == 1 ? "" : "s")")
                    .font(.appFont(size: 14))
                    .foregroundColor(theme.textColor.opacity(0.7))
            }
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(viewModel.itemsForSelectedDate) { item in
                        QuestCalendarRow(
                            item: item,
                            theme: theme,
                            onToggle: { viewModel.toggle(item: item) },
                            onMarkFinished: { viewModel.markQuestAsFinished(questId: item.quest.id) }
                        )
                    }
                }
            }
            .frame(maxHeight: 220)
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
    }
    
    private func addQuestSection(theme: Theme) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(selectedDate, style: .date)
                    .font(.appFont(size: 18, weight: .bold))
                    .foregroundColor(theme.textColor)
                Spacer()
                Text("No quests")
                    .font(.appFont(size: 14))
                    .foregroundColor(theme.textColor.opacity(0.7))
            }
            Button(action: { showingQuestCreation = true }) {
                HStack {
                    Image(systemName: "plus.circle.fill").font(.title2).foregroundColor(.white)
                    Text("Add Quest").font(.appFont(size: 16, weight: .medium)).foregroundColor(.white)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(theme.primaryColor)
                        .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                )
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
    }
    
    private func daysInMonth() -> [Date?] {
        let startOfMonth = calendar.dateInterval(of: .month, for: selectedDate)?.start ?? selectedDate
        let firstWeekday = calendar.component(.weekday, from: startOfMonth)
        let daysInMonth = calendar.range(of: .day, in: .month, for: selectedDate)?.count ?? 0
        var days: [Date?] = []
        for _ in 1..<firstWeekday { days.append(nil) }
        for day in 1...daysInMonth {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: startOfMonth) {
                days.append(date)
            }
        }
        return days
    }
    
    private func previousMonth() {
        if let newDate = calendar.date(byAdding: .month, value: -1, to: selectedDate) { selectedDate = newDate }
    }
    
    private func nextMonth() {
        if let newDate = calendar.date(byAdding: .month, value: 1, to: selectedDate) { selectedDate = newDate }
    }
}

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

struct QuestCalendarRow: View {
    let item: DayQuestItem
    let theme: Theme
    let onToggle: () -> Void
    let onMarkFinished: () -> Void  // Add this

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
            Button(action: onMarkFinished) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(.green)
            }
            
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
