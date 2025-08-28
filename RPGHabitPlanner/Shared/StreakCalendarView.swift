import SwiftUI

struct StreakCalendarView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var localizationManager: LocalizationManager
    @ObservedObject var streakManager: StreakManager
    @State private var selectedDate = Date()
    @State private var showingStreakDetails = false

    private let calendar = Calendar.current
    private var dateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM yyyy"
        dateFormatter.locale = localizationManager.currentLocale
        return dateFormatter
    }

    // Store activity dates for the current month
    @State private var activityDates: Set<Date> = []

    var body: some View {
        let theme = themeManager.activeTheme

        ZStack {
            theme.backgroundColor.ignoresSafeArea()

            VStack(spacing: 0) {
                // Fixed header
                HStack {
                    monthHeader(theme: theme)
                    Spacer()
                }

                // Scrollable content area
                ScrollView {
                    VStack(spacing: 0) {
                        dayOfWeekHeaders(theme: theme)
                        calendarGrid(theme: theme)
                        streakStatisticsSection(theme: theme)
                    }
                }
            }
        }
        .navigationTitle("streak_calendar".localized)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .onAppear {
            loadActivityDates()
        }
        .onChange(of: selectedDate) { _ in
            loadActivityDates()
        }
        .onReceive(NotificationCenter.default.publisher(for: .streakUpdated)) { _ in
            loadActivityDates()
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
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
                .id(dateFormatter.string(from: selectedDate))
            Spacer()
            Button(action: nextMonth) {
                Image(systemName: "chevron.right")
                    .font(.title2)
                    .foregroundColor(theme.textColor)
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
                CalendarDayItem(
                    date: date,
                    activityDates: activityDates,
                    selectedDate: selectedDate,
                    theme: theme,
                    calendar: calendar
                ) { selectedDate in
                        self.selectedDate = selectedDate
                        let dateStartOfDay = calendar.startOfDay(for: selectedDate)
                        if activityDates.contains(dateStartOfDay) {
                            showingStreakDetails = true
                        }
                }
            }
        }
        .frame(minHeight: 280)
        .padding(.horizontal, 20)
        .animation(.easeInOut(duration: 0.3), value: selectedDate)
    }

    private func streakStatisticsSection(theme: Theme) -> some View {
        VStack(spacing: 20) {
            // Current streak info
            VStack(spacing: 16) {
                HStack {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.orange)
                    Text("current_streak".localized)
                        .font(.appFont(size: 18, weight: .bold))
                        .foregroundColor(theme.textColor)
                    Spacer()
                }

                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(streakManager.currentStreak)")
                            .font(.appFont(size: 32, weight: .black))
                            .foregroundColor(theme.textColor)
                        Text(streakManager.currentStreak == 1 ? "streak_day".localized : "streak_days".localized)
                            .font(.appFont(size: 14, weight: .medium))
                            .foregroundColor(theme.textColor.opacity(0.7))
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 4) {
                        Text("\(streakManager.longestStreak)")
                            .font(.appFont(size: 24, weight: .bold))
                            .foregroundColor(theme.textColor.opacity(0.8))
                        Text("longest_streak".localized)
                            .font(.appFont(size: 12, weight: .medium))
                            .foregroundColor(theme.textColor.opacity(0.6))
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(theme.primaryColor.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(theme.primaryColor.opacity(0.2), lineWidth: 1)
                        )
                )
            }

            // Average streak and motivation
            if streakManager.currentStreak > 0 {
                VStack(spacing: 12) {
                    // Average streak
                    HStack {
                        Image(systemName: "chart.bar.fill")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(theme.textColor.opacity(0.8))
                        Text("analytics_avg_streak".localized)
                            .font(.appFont(size: 16, weight: .bold))
                            .foregroundColor(theme.textColor)
                        Spacer()
                        Text(String(format: "%.1f", Double(streakManager.longestStreak)))
                            .font(.appFont(size: 18, weight: .bold))
                            .foregroundColor(theme.textColor)
                    }

                    // Streak motivation
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "lightbulb.fill")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(theme.accentColor)
                            Text("analytics_streak_motivation".localized)
                                .font(.appFont(size: 16, weight: .bold))
                                .foregroundColor(theme.textColor)
                            Spacer()
                        }

                        Text(streakMotivationText)
                            .font(.appFont(size: 14, weight: .medium))
                            .foregroundColor(theme.textColor.opacity(0.8))
                            .padding(12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(theme.accentColor.opacity(0.1))
                            .cornerRadius(8)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(theme.primaryColor.opacity(0.05))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(theme.primaryColor.opacity(0.1), lineWidth: 1)
                        )
                )
            }

            // Monthly statistics
            VStack(spacing: 16) {
                HStack {
                    Image(systemName: "calendar")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(theme.textColor.opacity(0.8))
                    Text("monthly_activity".localized)
                        .font(.appFont(size: 16, weight: .bold))
                        .foregroundColor(theme.textColor)
                    Spacer()
                }

                let monthlyStats = calculateMonthlyStats()

                HStack(spacing: 20) {
                    StreakStatCard(
                        title: "active_days".localized,
                        value: "\(monthlyStats.activeDays)",
                        total: "\(monthlyStats.totalDays)",
                        theme: theme
                    )

                    StreakStatCard(
                        title: "activity_rate".localized,
                        value: "\(monthlyStats.activityRate)%",
                        theme: theme
                    )
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .padding(.bottom, 40)
    }

    private func previousMonth() {
        withAnimation(.easeInOut(duration: 0.3)) {
            selectedDate = calendar.date(byAdding: .month, value: -1, to: selectedDate) ?? selectedDate
        }
    }

    private func nextMonth() {
        withAnimation(.easeInOut(duration: 0.3)) {
            selectedDate = calendar.date(byAdding: .month, value: 1, to: selectedDate) ?? selectedDate
        }
    }

    private func daysInMonth() -> [Date?] {
        let startOfMonth = calendar.dateInterval(of: .month, for: selectedDate)?.start ?? selectedDate
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: startOfMonth)?.start ?? startOfMonth

        let endOfMonth = calendar.dateInterval(of: .month, for: selectedDate)?.end ?? selectedDate
        let endOfWeek = calendar.dateInterval(of: .weekOfYear, for: endOfMonth)?.end ?? endOfMonth

        var days: [Date?] = []
        var currentDate = startOfWeek

        while currentDate < endOfWeek {
            if calendar.isDate(currentDate, equalTo: startOfMonth, toGranularity: .month) {
                days.append(currentDate)
            } else {
                days.append(nil)
            }
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        }

        return days
    }


    private func loadActivityDates() {
        // Load actual activity dates from StreakManager
        activityDates = streakManager.getActivityDates()
        print("📅 StreakCalendarView: Loaded \(activityDates.count) activity dates")
        print("📅 StreakCalendarView: Activity dates: \(activityDates)")
    }

    private func calculateMonthlyStats() -> (activeDays: Int, totalDays: Int, activityRate: Int) {
        let startOfMonth = calendar.dateInterval(of: .month, for: selectedDate)?.start ?? selectedDate
        let endOfMonth = calendar.dateInterval(of: .month, for: selectedDate)?.end ?? selectedDate

        // Calculate total days in the month
        let totalDays = calendar.dateComponents([.day], from: startOfMonth, to: endOfMonth).day ?? 0

        // Filter activity dates for the current month
        let activeDays = activityDates.filter { date in
            let dateStartOfDay = calendar.startOfDay(for: date)
            return dateStartOfDay >= startOfMonth && dateStartOfDay < endOfMonth
        }.count

        let activityRate = totalDays > 0 ? Int((Double(activeDays) / Double(totalDays)) * 100) : 0

        print("📅 StreakCalendarView: Monthly stats calculation:")
        print("📅 StreakCalendarView: Selected date: \(selectedDate)")
        print("📅 StreakCalendarView: Start of month: \(startOfMonth)")
        print("📅 StreakCalendarView: End of month: \(endOfMonth)")
        print("📅 StreakCalendarView: Total days: \(totalDays)")
        print("📅 StreakCalendarView: Active days: \(activeDays)")
        print("📅 StreakCalendarView: Activity rate: \(activityRate)%")

        return (activeDays: activeDays, totalDays: totalDays, activityRate: activityRate)
    }

    private var streakMotivationText: String {
        if streakManager.currentStreak >= streakManager.longestStreak {
            return "analytics_streak_motivation_record".localized
        } else if streakManager.currentStreak >= streakManager.longestStreak / 2 {
            return "analytics_streak_motivation_halfway".localized
        } else {
            return "analytics_streak_motivation_keep_going".localized
        }
    }
}

struct CalendarDayItem: View {
    let date: Date?
    let activityDates: Set<Date>
    let selectedDate: Date
    let theme: Theme
    let calendar: Calendar
    let onDateSelected: (Date) -> Void

    var body: some View {
        Group {
            if let date = date {
                let dateStartOfDay = calendar.startOfDay(for: date)
                let hasActivity = activityDates.contains(dateStartOfDay)

                StreakCalendarDayView(
                    date: date,
                    hasActivity: hasActivity,
                    isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                    theme: theme
                ) {
                    onDateSelected(date)
                }
            } else {
                Color.clear.frame(height: 40)
            }
        }
    }
}

struct StreakCalendarDayView: View {
    let date: Date
    let hasActivity: Bool
    let isSelected: Bool
    let theme: Theme
    let onTap: () -> Void

    private let calendar = Calendar.current

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 2) {
                Text("\(calendar.component(.day, from: date))")
                    .font(.appFont(size: 16, weight: isSelected ? .bold : .medium))
                    .foregroundColor(selectionTextColor)

                if hasActivity {
                    Circle()
                        .fill(activityColor)
                        .frame(width: 8, height: 8)
                        .shadow(color: activityColor.opacity(0.3), radius: 2, x: 0, y: 1)
                } else {
                    Circle()
                        .fill(Color.clear)
                        .frame(width: 8, height: 8)
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
            if theme.backgroundColor == Color(hex: "#F0F0F0") {
                return theme.textColor
            } else {
                return .white
            }
        } else {
            return theme.textColor
        }
    }

    private var selectionBackgroundColor: Color {
        if isSelected {
            if theme.backgroundColor == Color(hex: "#F0F0F0") {
                return Color(hex: "#E5E7EB").opacity(0.8)
            } else {
                return theme.primaryColor
            }
        } else {
            return Color.clear
        }
    }

    private var activityColor: Color {
        if hasActivity {
            return .orange
        } else {
            return .clear
        }
    }
}

struct StreakStatCard: View {
    let title: String
    let value: String
    let total: String?
    let theme: Theme

    init(title: String, value: String, total: String? = nil, theme: Theme) {
        self.title = title
        self.value = value
        self.total = total
        self.theme = theme
    }

    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.appFont(size: 12, weight: .medium))
                .foregroundColor(theme.textColor.opacity(0.7))

            HStack(spacing: 4) {
                Text(value)
                    .font(.appFont(size: 20, weight: .bold))
                    .foregroundColor(theme.textColor)

                if let total = total {
                    Text("/ \(total)")
                        .font(.appFont(size: 14, weight: .medium))
                        .foregroundColor(theme.textColor.opacity(0.6))
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(theme.primaryColor.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(theme.primaryColor.opacity(0.1), lineWidth: 1)
                )
        )
    }
}
