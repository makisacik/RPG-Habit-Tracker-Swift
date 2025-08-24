//
//  CalendarViewComponents.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 11.11.2024.
//

import SwiftUI

// MARK: - Calendar View Components
enum CalendarViewComponents {
    // MARK: - Main Content View
    @ViewBuilder
    static func mainContentView(
        theme: Theme,
        showTagFilter: Bool,
        viewModel: CalendarViewModel,
        selectedQuestItem: Binding<DayQuestItem?>,
        showingQuestCreation: Binding<Bool>,
        onTagFilterToggle: @escaping () -> Void,
        onQuestTap: @escaping (DayQuestItem) -> Void
    ) -> some View {
        VStack(spacing: 0) {
            headerSection(
                theme: theme,
                showTagFilter: showTagFilter,
                viewModel: viewModel,
                onTagFilterToggle: onTagFilterToggle
            )
            scrollableContent(
                theme: theme,
                showTagFilter: showTagFilter,
                viewModel: viewModel,
                selectedQuestItem: selectedQuestItem,
                showingQuestCreation: showingQuestCreation,
                onQuestTap: onQuestTap
            )
        }
    }
    
    // MARK: - Header Section
    @ViewBuilder
    private static func headerSection(
        theme: Theme,
        showTagFilter: Bool,
        viewModel: CalendarViewModel,
        onTagFilterToggle: @escaping () -> Void
    ) -> some View {
        HStack {
            monthHeader(theme: theme, viewModel: viewModel)
            tagFilterButton(
                theme: theme,
                showTagFilter: showTagFilter,
                onToggle: onTagFilterToggle
            )
        }
    }
    
    // MARK: - Tag Filter Button
    @ViewBuilder
    private static func tagFilterButton(
        theme: Theme,
        showTagFilter: Bool,
        onToggle: @escaping () -> Void
    ) -> some View {
        if !showTagFilter {
            TagFilterButton(theme: theme) {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    onToggle()
                }
            }
            .padding(.trailing, 20)
            .transition(.asymmetric(
                insertion: .scale.combined(with: .opacity),
                removal: .scale.combined(with: .opacity)
            ))
        } else {
            ApplyFiltersButton(theme: theme) {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    onToggle()
                }
            }
            .padding(.trailing, 20)
            .transition(.asymmetric(
                insertion: .scale.combined(with: .opacity),
                removal: .scale.combined(with: .opacity)
            ))
        }
    }
    
    // MARK: - Scrollable Content
    @ViewBuilder
    private static func scrollableContent(
        theme: Theme,
        showTagFilter: Bool,
        viewModel: CalendarViewModel,
        selectedQuestItem: Binding<DayQuestItem?>,
        showingQuestCreation: Binding<Bool>,
        onQuestTap: @escaping (DayQuestItem) -> Void
    ) -> some View {
        ScrollView {
            VStack(spacing: 0) {
                tagFilterSection(
                    theme: theme,
                    showTagFilter: showTagFilter,
                    viewModel: viewModel
                )
                dayOfWeekHeaders(theme: theme)
                monthGridSection(
                    theme: theme,
                    viewModel: viewModel
                )
                selectedDateSection(
                    theme: theme,
                    viewModel: viewModel,
                    selectedQuestItem: selectedQuestItem,
                    showingQuestCreation: showingQuestCreation,
                    onQuestTap: onQuestTap
                )
            }
        }
    }
    
    // MARK: - Tag Filter Section
    @ViewBuilder
    private static func tagFilterSection(
        theme: Theme,
        showTagFilter: Bool,
        viewModel: CalendarViewModel
    ) -> some View {
        if showTagFilter {
            TagFilterView(viewModel: viewModel.tagFilterViewModel)
                .transition(.asymmetric(
                    insertion: .move(edge: .top).combined(with: .opacity),
                    removal: .move(edge: .top).combined(with: .opacity)
                ))
        }
    }
    
    // MARK: - Month Grid Section
    @ViewBuilder
    private static func monthGridSection(
        theme: Theme,
        viewModel: CalendarViewModel
    ) -> some View {
        MonthGrid(
            days: daysInMonth(for: viewModel.selectedDate),
            selectedDate: viewModel.selectedDate,
            theme: theme,
            onSelect: { viewModel.selectedDate = $0 },
            itemsResolver: { date in viewModel.items(for: date) }
        )
        .id(viewModel.refreshTrigger)
        .animation(Animation.easeInOut(duration: 0.3), value: viewModel.selectedDate)
    }
    
    // MARK: - Selected Date Section
    @ViewBuilder
    private static func selectedDateSection(
        theme: Theme,
        viewModel: CalendarViewModel,
        selectedQuestItem: Binding<DayQuestItem?>,
        showingQuestCreation: Binding<Bool>,
        onQuestTap: @escaping (DayQuestItem) -> Void
    ) -> some View {
        VStack(spacing: 0) {
            if !viewModel.itemsForSelectedDate.isEmpty {
                SelectedDateDetails(
                    date: viewModel.selectedDate,
                    theme: theme,
                    items: viewModel.itemsForSelectedDate,
                    onToggle: { item in
                        viewModel.toggle(item: item)
                    },
                    onMarkFinished: { item in
                        // Flag button should always show confirmation dialog
                        viewModel.questToFinish = item.quest
                        viewModel.showFinishConfirmation = true
                    },
                    onToggleTask: { taskId, isCompleted, item in
                        viewModel.toggleTaskCompletion(
                            questId: item.quest.id,
                            taskId: taskId,
                            newValue: isCompleted
                        )
                    },
                    onQuestTap: onQuestTap
                )
            } else {
                addQuestSection(
                    theme: theme,
                    showingQuestCreation: showingQuestCreation
                )
            }
        }
        .id(viewModel.refreshTrigger)
        .frame(minHeight: 280, maxHeight: 320)
        .animation(Animation.easeInOut(duration: 0.3), value: viewModel.itemsForSelectedDate.count)
    }
    
    // MARK: - Overlay Views
    @ViewBuilder
    static func overlayViews(
        theme: Theme,
        viewModel: CalendarViewModel
    ) -> some View {
        questFinishConfirmationOverlay(viewModel: viewModel)
    }
    
    // MARK: - Quest Finish Confirmation Overlay
    @ViewBuilder
    private static func questFinishConfirmationOverlay(viewModel: CalendarViewModel) -> some View {
        if viewModel.showFinishConfirmation, let quest = viewModel.questToFinish {
            QuestFinishConfirmationPopup(
                quest: quest,
                onConfirm: {
                    viewModel.markQuestAsFinished(questId: quest.id)
                    viewModel.showFinishConfirmation = false
                    viewModel.questToFinish = nil
                },
                onCancel: {
                    viewModel.showFinishConfirmation = false
                    viewModel.questToFinish = nil
                }
            )
            .zIndex(60)
        }
    }
    
    
    // MARK: - Helper Functions
    private static func daysInMonth(for date: Date) -> [Date?] {
        let calendar = Calendar.current
        let startOfMonth = calendar.dateInterval(of: .month, for: date)?.start ?? date
        let firstWeekday = calendar.component(.weekday, from: startOfMonth)
        let daysInMonth = calendar.range(of: .day, in: .month, for: date)?.count ?? 0
        var days: [Date?] = []
        for _ in 1..<firstWeekday { days.append(nil) }
        for day in 1...daysInMonth {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: startOfMonth) {
                days.append(date)
            }
        }
        return days
    }
    
    // MARK: - Month Header
    @ViewBuilder
    static func monthHeader(
        theme: Theme,
        viewModel: CalendarViewModel
    ) -> some View {
        HStack {
            Button(action: { previousMonth(viewModel: viewModel) }) {
                Image(systemName: "chevron.left")
                    .font(.title2)
                    .foregroundColor(theme.textColor)
            }
            .buttonStyle(PlainButtonStyle())
            
            Spacer()
            
            Text(dateFormatter.string(from: viewModel.selectedDate))
                .font(.appFont(size: 20, weight: .black))
                .foregroundColor(theme.textColor)
            
            Spacer()
            
            Button(action: { nextMonth(viewModel: viewModel) }) {
                Image(systemName: "chevron.right")
                    .font(.title2)
                    .foregroundColor(theme.textColor)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
    
    // MARK: - Day of Week Headers
    @ViewBuilder
    static func dayOfWeekHeaders(theme: Theme) -> some View {
        HStack(spacing: 0) {
            ForEach(calendar.shortWeekdaySymbols, id: \.self) { day in
                Text(day)
                    .font(.appFont(size: 12, weight: .bold))
                    .foregroundColor(theme.textColor.opacity(0.7))
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 8)
    }
    
    // MARK: - Add Quest Section
    @ViewBuilder
    static func addQuestSection(
        theme: Theme,
        showingQuestCreation: Binding<Bool>
    ) -> some View {
        VStack(spacing: 16) {
            Spacer()
            
            VStack(spacing: 8) {
                Image(systemName: "plus.circle")
                    .font(.system(size: 48))
                    .foregroundColor(theme.textColor.opacity(0.3))
                
                Spacer()
                Text(String.noQuests.localized)
                    .font(.appFont(size: 14))
                    .foregroundColor(theme.textColor.opacity(0.7))
            }
            .frame(height: 24)

            Spacer()

            Button(action: { showingQuestCreation.wrappedValue = true }) {
                HStack {
                    Spacer()
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundColor(theme.textColor)
                    Text(String.addQuest.localized)
                        .font(.appFont(size: 16, weight: .black))
                        .foregroundColor(theme.textColor)
                    Spacer()
                }
                .padding()
                .background(
                    Image(theme.buttonPrimary)
                        .resizable(
                            capInsets: EdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20),
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
    
    // MARK: - Navigation Functions
    private static func previousMonth(viewModel: CalendarViewModel) {
        let calendar = Calendar.current
        if let newDate = calendar.date(byAdding: .month, value: -1, to: viewModel.selectedDate) {
            viewModel.selectedDate = newDate
        }
    }
    
    private static func nextMonth(viewModel: CalendarViewModel) {
        let calendar = Calendar.current
        if let newDate = calendar.date(byAdding: .month, value: 1, to: viewModel.selectedDate) {
            viewModel.selectedDate = newDate
        }
    }
    
    private static let calendar = Calendar.current
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }()
}

// MARK: - Month Grid (extracted)
struct MonthGrid: View {
    let days: [Date?]
    let selectedDate: Date
    let theme: Theme
    let onSelect: (Date) -> Void
    let itemsResolver: (Date) -> [DayQuestItem]

    private let cal = Calendar.current

    var body: some View {
        let cols = Array(repeating: GridItem(.flexible()), count: 7)
        LazyVGrid(columns: cols, spacing: 8) {
            ForEach(days.indices, id: \.self) { idx in
                if let date = days[idx] {
                    CalendarDayView(
                        date: date,
                        isSelected: cal.isDate(date, inSameDayAs: selectedDate),
                        items: itemsResolver(date),
                        theme: theme
                    ) {
                        onSelect(cal.startOfDay(for: date))
                    }
                } else {
                    Color.clear.frame(height: 40)
                }
            }
        }
        .frame(minHeight: 280)
        .padding(.horizontal, 20)
    }
}

// MARK: - Selected Date Details (extracted)
struct SelectedDateDetails: View {
    let date: Date
    let theme: Theme
    let items: [DayQuestItem]
    let onToggle: (DayQuestItem) -> Void
    let onMarkFinished: (DayQuestItem) -> Void
    let onToggleTask: (UUID, Bool, DayQuestItem) -> Void
    let onQuestTap: (DayQuestItem) -> Void

    var body: some View {
        let activeCount = items.filter { $0.state == .todo }.count
        let completedCount = items.filter { $0.state == .done }.count

        VStack(alignment: .leading, spacing: 12) {
            header(active: activeCount, completed: completedCount)

            ScrollView {
                LazyVStack(spacing: 6) {
                    ForEach(items) { item in
                        QuestCalendarRow(
                            item: item,
                            theme: theme,
                            onToggle: { onToggle(item) },
                            onMarkFinished: { onMarkFinished(item) },
                            onToggleTaskCompletion: { taskId, isCompleted in
                                onToggleTask(taskId, isCompleted, item)
                            },
                            onQuestTap: onQuestTap
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

    private func header(active: Int, completed: Int) -> some View {
        HStack {
            Text(date, style: .date)
                .font(.appFont(size: 18, weight: .bold))
                .foregroundColor(theme.textColor)
            Spacer()
            Text("\(active) active, \(completed) completed")
                .font(.appFont(size: 14))
                .foregroundColor(theme.textColor.opacity(0.7))
        }
        .frame(height: 24)
    }
}

// MARK: - Small header buttons to reduce type-checking pressure
private struct TagFilterButton: View {
    let theme: Theme
    let action: () -> Void
    var body: some View {
        Button(action: action) {
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
    }
}

private struct ApplyFiltersButton: View {
    let theme: Theme
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 14, weight: .medium))
                Text("Apply")
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
    }
}
