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
    @State private var selectedQuestItem: DayQuestItem?
    @State private var showTagFilter = false

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
                // Modern header with tag filter button
                HStack {
                    monthHeader(theme: theme)

                    Spacer()

                    // Tag filter button - hide when filter is active
                    if !showTagFilter {
                        Button(action: {
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                showTagFilter.toggle()
                            }
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: "tag.fill")
                                    .font(.system(size: 14, weight: .medium))
                                Text("Filter")
                                    .font(.appFont(size: 14, weight: .medium))
                            }
                            .foregroundColor(theme.accentColor)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(theme.accentColor.opacity(0.1))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(theme.accentColor.opacity(0.3), lineWidth: 1)
                                    )
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        .transition(.asymmetric(
                            insertion: .scale.combined(with: .opacity),
                            removal: .scale.combined(with: .opacity)
                        ))
                        .padding(.trailing, 20)
                    }
                }

                // Tag filter section with close button
                if showTagFilter {
                    VStack(spacing: 0) {
                        // Apply Filters button
                        HStack {
                            Spacer()
                            Button(action: {
                                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                    showTagFilter.toggle()
                                }
                            }) {
                                HStack(spacing: 6) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 16, weight: .medium))
                                    Text("Apply Filters")
                                        .font(.appFont(size: 14, weight: .medium))
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(theme.accentColor)
                                        .shadow(color: theme.accentColor.opacity(0.3), radius: 4, x: 0, y: 2)
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                            .padding(.trailing, 20)
                            .padding(.top, 8)
                        }

                        TagFilterView(viewModel: viewModel.tagFilterViewModel)
                    }
                    .transition(.asymmetric(
                        insertion: .move(edge: .top).combined(with: .opacity),
                        removal: .move(edge: .top).combined(with: .opacity)
                    ))
                }

                dayOfWeekHeaders(theme: theme)
                calendarGrid(theme: theme)
                VStack(spacing: 0) {
                    if !viewModel.itemsForSelectedDate.isEmpty {
                        selectedDateDetails(theme: theme)
                    } else {
                        addQuestSection(theme: theme)
                    }
                }
                .frame(minHeight: 280, maxHeight: 320)
                .animation(.easeInOut(duration: 0.3), value: viewModel.itemsForSelectedDate.count)
            }
        }
        .navigationTitle(String.questCalendar.localized)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .onAppear {
            viewModel.selectedDate = calendar.startOfDay(for: selectedDate)
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
        .sheet(item: $selectedQuestItem) { questItem in
            NavigationStack {
                QuestDetailView(
                    quest: questItem.quest,
                    date: questItem.date,
                    questDataService: viewModel.questDataService
                )
                .environmentObject(themeManager)
            }
        }
        .onChange(of: viewModel.alertMessage) { msg in
            if msg != nil { showingAlert = true }
        }
        .alert(isPresented: $showingAlert) {
            Alert(title: Text(String.headsUp.localized),
                  message: Text(viewModel.alertMessage ?? ""),
                  dismissButton: .default(Text(String.okButton.localized)) { viewModel.alertMessage = nil })
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
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
                .id(dateFormatter.string(from: selectedDate))
            Spacer()
            Button(action: nextMonth) {
                Image(systemName: "chevron.right").font(.title2).foregroundColor(theme.textColor)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .padding(.bottom, 16)
        .animation(.easeInOut(duration: 0.3), value: selectedDate)
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
        .frame(minHeight: 280) // Ensure consistent height for 6 weeks max
        .padding(.horizontal, 20)
        .animation(.easeInOut(duration: 0.3), value: selectedDate)
    }

    private func selectedDateDetails(theme: Theme) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(selectedDate, style: .date)
                    .font(.appFont(size: 18, weight: .bold))
                    .foregroundColor(theme.textColor)
                Spacer()
                Text("\(viewModel.itemsForSelectedDate.count) \(viewModel.itemsForSelectedDate.count == 1 ? String.activeQuest.localized : String.activeQuests.localized)")
                    .font(.appFont(size: 14))
                    .foregroundColor(theme.textColor.opacity(0.7))
            }
            .frame(height: 24)

            ScrollView {
                LazyVStack(spacing: 6) {
                    ForEach(viewModel.itemsForSelectedDate) { item in
                        QuestCalendarRow(
                            item: item,
                            theme: theme,
                            onToggle: { viewModel.toggle(item: item) },
                            onMarkFinished: { viewModel.markQuestAsFinished(questId: item.quest.id) },
                            onToggleTaskCompletion: { taskId, isCompleted in
                                viewModel.toggleTaskCompletion(questId: item.quest.id, taskId: taskId, newValue: isCompleted)
                            },
                            onQuestTap: { questItem in
                                selectedQuestItem = questItem
                            }
                        )
                    }
                }
                .padding(.bottom, 8)
            }
            .frame(maxHeight: 240)
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
    }

    private func addQuestSection(theme: Theme) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(selectedDate, style: .date)
                    .font(.appFont(size: 18, weight: .bold))
                    .foregroundColor(theme.textColor)
                Spacer()
                Text(String.noQuests.localized)
                    .font(.appFont(size: 14))
                    .foregroundColor(theme.textColor.opacity(0.7))
            }
            .frame(height: 24)

            Spacer()

            Button(action: { showingQuestCreation = true }) {
                HStack {
                    Spacer()
                    Image(systemName: "plus.circle.fill").font(.title2).foregroundColor(theme.textColor)
                    Text(String.addQuest.localized)
                        .font(.appFont(size: 16, weight: .black))
                        .foregroundColor(theme.textColor)
                    Spacer()
                }
                .padding()
                .background(
                    Image(theme.buttonPrimary)
                        .resizable(
                            capInsets: EdgeInsets(
                                top: 20,
                                leading: 20,
                                bottom: 20,
                                trailing: 20
                            ),
                            resizingMode: .stretch
                        )
                )
                .frame(maxWidth: .infinity, minHeight: 44, maxHeight: 44)
            }
            .buttonStyle(PlainButtonStyle())

            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
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
                    .foregroundColor(selectionTextColor)
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
                    .fill(selectionBackgroundColor)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }

    private var selectionTextColor: Color {
        if isSelected {
            // For light theme, keep text black when selected
            if theme.backgroundColor == Color(hex: "#F8F7FF") {
                return theme.textColor
            } else {
                // Dark theme - keep white text
                return .white
            }
        } else {
            return theme.textColor
        }
    }

    private var selectionBackgroundColor: Color {
        if isSelected {
            // For light theme, use a subtle border/background
            if theme.backgroundColor == Color(hex: "#F8F7FF") {
                return Color(hex: "#E5E7EB").opacity(0.8) // Light gray background
            } else {
                // Dark theme - keep original primary color
                return theme.primaryColor
            }
        } else {
            return Color.clear
        }
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
    @State private var isExpanded: Bool = false
    @State private var showingQuestDetail = false

    let item: DayQuestItem
    let theme: Theme
    let onToggle: () -> Void
    let onMarkFinished: () -> Void
    let onToggleTaskCompletion: (UUID, Bool) -> Void
    let onQuestTap: (DayQuestItem) -> Void

    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(alignment: .leading, spacing: 0) {
                // Main quest row
                HStack(spacing: 10) {
                    Circle()
                        .fill(indicatorColor)
                        .frame(width: 8, height: 8)
                    VStack(alignment: .leading, spacing: 1) {
                        Text(item.quest.title)
                            .font(.appFont(size: 15, weight: .medium))
                            .foregroundColor(theme.textColor)
                            .lineLimit(1)
                        Text(subtitle)
                            .font(.appFont(size: 11, weight: .black))
                            .foregroundColor(theme.textColor.opacity(0.7))
                    }
                    Spacer()

                    Button(action: onToggle) {
                        Image(systemName: item.state == .done ? "checkmark.circle.fill" : "circle")
                            .font(.title3)
                            .foregroundColor(item.state == .done ? .green : theme.textColor.opacity(0.6))
                    }
                    .padding(.trailing, 28)
                }
                .padding(12)
                .contentShape(Rectangle())
                .onTapGesture {
                    onQuestTap(item)
                }

                // Tasks section
                let tasks = item.quest.tasks
                if !tasks.isEmpty {
                    Divider()
                        .background(theme.textColor.opacity(0.2))
                        .padding(.horizontal, 12)

                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            isExpanded.toggle()
                        }
                    }) {
                        HStack {
                            Text("\(tasks.count) \(String.tasks.localized)")
                                .font(.appFont(size: 12, weight: .medium))
                                .foregroundColor(theme.textColor.opacity(0.8))
                            Spacer()
                            Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                                .foregroundColor(theme.textColor.opacity(0.6))
                                .imageScale(.small)
                                .font(.caption)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(PlainButtonStyle())

                    if isExpanded {
                        VStack(alignment: .leading, spacing: 4) {
                            ForEach(tasks, id: \.id) { task in
                                HStack(spacing: 8) {
                                    Button(action: {
                                        onToggleTaskCompletion(task.id, !task.isCompleted)
                                    }) {
                                        Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle.fill")
                                            .resizable()
                                            .frame(width: 14, height: 14)
                                            .foregroundColor(task.isCompleted ? .green : .gray)
                                    }
                                    .buttonStyle(PlainButtonStyle())

                                    Text(task.title)
                                        .font(.appFont(size: 12))
                                        .foregroundColor(theme.textColor.opacity(0.9))
                                        .strikethrough(task.isCompleted)

                                    Spacer()
                                }
                                .contentShape(Rectangle())
                                .padding(.horizontal, 12)
                                .padding(.vertical, 4)
                            }
                        }
                        .padding(.bottom, 12)
                        .transition(.opacity.combined(with: .slide))
                    }
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(theme.primaryColor)
                    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
            )
            .padding(.horizontal, 4)
            .padding(.vertical, 2)

            Menu {
                Button("Mark as Finished") {
                    onMarkFinished()
                }
            } label: {
                Image(systemName: "ellipsis.circle")
                    .font(.caption)
                    .foregroundColor(theme.textColor.opacity(0.6))
            }
            .padding(.top, 8)
            .padding(.trailing, 8)
        }
    }

    private var indicatorColor: Color {
        switch item.state {
        case .done: return .green
        case .todo: return .orange
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
