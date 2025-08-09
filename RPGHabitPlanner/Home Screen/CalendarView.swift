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
    @State private var showingQuestDetail = false
    @State private var selectedQuest: Quest?
    
    private let calendar = Calendar.current
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }()
    
    var body: some View {
        let theme = themeManager.activeTheme
        
        NavigationStack {
            ZStack {
                theme.backgroundColor
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Month header
                    monthHeader(theme: theme)
                    
                    // Day of week headers
                    dayOfWeekHeaders(theme: theme)
                    
                    // Calendar grid
                    calendarGrid(theme: theme)
                    
                    // Selected date details
                    if !viewModel.questsForSelectedDate.isEmpty {
                        selectedDateDetails(theme: theme)
                    }
                }
            }
            .navigationTitle("Quest Calendar")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                viewModel.fetchQuests()
            }
        }
        .sheet(isPresented: $showingQuestDetail) {
            if let quest = selectedQuest {
                QuestDetailSheet(quest: quest, theme: theme)
            }
        }
        .onChange(of: selectedDate) { newDate in
            viewModel.selectedDate = newDate
        }
    }
    
    private func monthHeader(theme: Theme) -> some View {
        HStack {
            Button(action: previousMonth) {
                Image(systemName: "chevron.left")
                    .font(.title2)
                    .foregroundColor(theme.textColor)
            }
            
            Spacer()
            
            Text(dateFormatter.string(from: selectedDate))
                .font(.appFont(size: 20, weight: .bold))
                .foregroundColor(theme.textColor)
            
            Spacer()
            
            Button(action: nextMonth) {
                Image(systemName: "chevron.right")
                    .font(.title2)
                    .foregroundColor(theme.textColor)
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
                    CalendarDayView(
                        date: date,
                        isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                        quests: viewModel.questsForDate(date),
                        theme: theme
                    ) {
                        selectedDate = date
                        viewModel.selectedDate = date
                    }
                } else {
                    Color.clear
                        .frame(height: 40)
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
                
                Text("\(viewModel.questsForSelectedDate.count) quest\(viewModel.questsForSelectedDate.count == 1 ? "" : "s")")
                    .font(.appFont(size: 14))
                    .foregroundColor(theme.textColor.opacity(0.7))
            }
            
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(viewModel.questsForSelectedDate) { quest in
                        QuestCalendarCard(quest: quest, theme: theme) {
                            selectedQuest = quest
                            showingQuestDetail = true
                        }
                    }
                }
            }
            .frame(maxHeight: 200)
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
    }
    
    private func daysInMonth() -> [Date?] {
        let startOfMonth = calendar.dateInterval(of: .month, for: selectedDate)?.start ?? selectedDate
        let firstWeekday = calendar.component(.weekday, from: startOfMonth)
        let daysInMonth = calendar.range(of: .day, in: .month, for: selectedDate)?.count ?? 0
        
        var days: [Date?] = []
        
        // Add empty days for the first week
        for _ in 1..<firstWeekday {
            days.append(nil)
        }
        
        // Add all days in the month
        for day in 1...daysInMonth {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: startOfMonth) {
                days.append(date)
            }
        }
        
        return days
    }
    
    private func previousMonth() {
        if let newDate = calendar.date(byAdding: .month, value: -1, to: selectedDate) {
            selectedDate = newDate
        }
    }
    
    private func nextMonth() {
        if let newDate = calendar.date(byAdding: .month, value: 1, to: selectedDate) {
            selectedDate = newDate
        }
    }
}

struct CalendarDayView: View {
    let date: Date
    let isSelected: Bool
    let quests: [Quest]
    let theme: Theme
    let onTap: () -> Void
    
    private let calendar = Calendar.current
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 2) {
                Text("\(calendar.component(.day, from: date))")
                    .font(.appFont(size: 16, weight: isSelected ? .bold : .medium))
                    .foregroundColor(isSelected ? .white : theme.textColor)
                
                if !quests.isEmpty {
                    HStack(spacing: 2) {
                        ForEach(quests.prefix(3), id: \.id) { quest in
                            Circle()
                                .fill(questColor(for: quest))
                                .frame(width: 6, height: 6)
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
    
    private func questColor(for quest: Quest) -> Color {
        if quest.isCompleted {
            return .green
        } else if quest.isMainQuest {
            return .blue
        } else {
            return .orange
        }
    }
}

struct QuestCalendarCard: View {
    let quest: Quest
    let theme: Theme
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Quest status indicator
                Circle()
                    .fill(questColor)
                    .frame(width: 12, height: 12)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(quest.title)
                        .font(.appFont(size: 16, weight: .medium))
                        .foregroundColor(theme.textColor)
                        .lineLimit(1)
                    
                    Text(quest.info)
                        .font(.appFont(size: 14))
                        .foregroundColor(theme.textColor.opacity(0.7))
                        .lineLimit(2)
                }
                
                Spacer()
                
                if quest.isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.title3)
                }
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(theme.primaryColor.opacity(0.3))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var questColor: Color {
        if quest.isCompleted {
            return .green
        } else if quest.isMainQuest {
            return .blue
        } else {
            return .orange
        }
    }
}

struct QuestDetailSheet: View {
    let quest: Quest
    let theme: Theme
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Quest header
                    VStack(alignment: .leading, spacing: 8) {
                        Text(quest.title)
                            .font(.appFont(size: 24, weight: .bold))
                            .foregroundColor(theme.textColor)
                        
                        Text(quest.info)
                            .font(.appFont(size: 16))
                            .foregroundColor(theme.textColor.opacity(0.8))
                    }
                    
                    // Quest details
                    VStack(alignment: .leading, spacing: 12) {
                        DetailRow(title: "Difficulty", value: "\(quest.difficulty)/5")
                        DetailRow(title: "Progress", value: "\(quest.progress)%")
                        DetailRow(title: "Due Date", value: formatDate(quest.dueDate))
                        DetailRow(title: "Status", value: quest.isCompleted ? "Completed" : "Active")
                        DetailRow(title: "Type", value: quest.isMainQuest ? "Main Quest" : "Side Quest")
                    }
                    
                    // Tasks
                    if !quest.tasks.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Tasks")
                                .font(.appFont(size: 18, weight: .bold))
                                .foregroundColor(theme.textColor)
                            
                            ForEach(quest.tasks) { task in
                                HStack {
                                    Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                                        .foregroundColor(task.isCompleted ? .green : theme.textColor.opacity(0.5))
                                    
                                    Text(task.title)
                                        .font(.appFont(size: 16))
                                        .foregroundColor(theme.textColor)
                                        .strikethrough(task.isCompleted)
                                    
                                    Spacer()
                                }
                            }
                        }
                    }
                }
                .padding(20)
            }
            .background(theme.backgroundColor)
            .navigationTitle("Quest Details")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Done") {
                dismiss()
            })
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

struct DetailRow: View {
    let title: String
    let value: String
    let theme: Theme = ThemeManager.shared.activeTheme
    
    init(title: String, value: String) {
        self.title = title
        self.value = value
    }
    
    var body: some View {
        HStack {
            Text(title)
                .font(.appFont(size: 16, weight: .medium))
                .foregroundColor(theme.textColor.opacity(0.7))
            
            Spacer()
            
            Text(value)
                .font(.appFont(size: 16))
                .foregroundColor(theme.textColor)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    let questDataService = QuestCoreDataService()
    CalendarView(viewModel: CalendarViewModel(questDataService: questDataService))
        .environmentObject(ThemeManager.shared)
}
