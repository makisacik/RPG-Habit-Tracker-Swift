//
//  ActiveQuestWidget.swift
//  ActiveQuestWidget
//
//  Created by Mehmet Ali Kısacık on 19.11.2024.
//

import WidgetKit
import SwiftUI
import CoreData

// MARK: - Quest Repeat Type (copied from main app for widget compatibility)
enum QuestRepeatType: String, Codable {
    case oneTime
    case daily
    case weekly
    case scheduled
}

// MARK: - Widget Theme
struct WidgetTheme {
    let backgroundGradient: LinearGradient
    let primaryTextColor: Color
    let secondaryTextColor: Color
    let accentColor: Color
    let successColor: Color
    let surfaceColor: Color

    static func current() -> WidgetTheme {
        // Check if we're in dark mode
        let isDarkMode = UITraitCollection.current.userInterfaceStyle == .dark

        if isDarkMode {
            return WidgetTheme(
                backgroundGradient: LinearGradient(
                    colors: [Color(red: 21 / 255, green: 34 / 255, blue: 49 / 255), Color(red: 29 / 255, green: 44 / 255, blue: 66 / 255)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                primaryTextColor: Color.white,
                secondaryTextColor: Color(hex: "#D1D5DB"),
                accentColor: Color(hex: "#F59E0B"),
                successColor: Color(hex: "#48BB78"),
                surfaceColor: Color(red: 29 / 255, green: 44 / 255, blue: 66 / 255)
            )
        } else {
            return WidgetTheme(
                backgroundGradient: LinearGradient(
                    colors: [Color(hex: "#F8F7FF"), Color(hex: "#C4B5FD")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                primaryTextColor: Color(hex: "#1F2937"),
                secondaryTextColor: Color(hex: "#6B7280"),
                accentColor: Color(hex: "#FFB700"),
                successColor: Color(hex: "#38A169"),
                surfaceColor: Color(hex: "#FFFFFF")
            )
        }
    }
}

// MARK: - Color Extension for Hex Support
extension Color {
    init(hex: String) {
        let hexString = hex.hasPrefix("#") ? String(hex.dropFirst()) : hex
        let scanner = Scanner(string: hexString)
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)

        let red = Double((rgbValue & 0xFF0000) >> 16) / 255.0
        let green = Double((rgbValue & 0x00FF00) >> 8) / 255.0
        let blue = Double(rgbValue & 0x0000FF) / 255.0
        self.init(red: red, green: green, blue: blue)
    }
}

// MARK: - Timeline Provider
struct Provider: TimelineProvider {
    typealias Entry = DailyQuestWidgetEntry
    let persistenceController = PersistenceController.shared

    func placeholder(in context: Context) -> DailyQuestWidgetEntry {
        DailyQuestWidgetEntry(
            date: Date(),
            todaysQuests: [],
            completedQuestsCount: 0,
            totalQuestsCount: 0
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (DailyQuestWidgetEntry) -> Void) {
        let entry = fetchDailyQuestEntry()
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<DailyQuestWidgetEntry>) -> Void) {
        let currentDate = Date()
        let entry = fetchDailyQuestEntry()

        // Update every 30 minutes
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 30, to: currentDate) ?? currentDate
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }

    private func fetchDailyQuestEntry() -> DailyQuestWidgetEntry {
        let context = persistenceController.container.viewContext
        let fetchRequest: NSFetchRequest<QuestEntity> = QuestEntity.fetchRequest()

        // Fetch all quests that are active today
        fetchRequest.predicate = NSPredicate(format: "isActive == YES")
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \QuestEntity.isMainQuest, ascending: false),
            NSSortDescriptor(keyPath: \QuestEntity.creationDate, ascending: false)
        ]

        do {
            let allQuests = try context.fetch(fetchRequest)
            let today = Calendar.current.startOfDay(for: Date())

            // Filter quests that are active today (include all quests that should be shown today, regardless of completion status)
            let todaysQuests = allQuests.compactMap { quest -> QuestEntity? in
                // Check if quest is active today based on its repeat type
                let repeatType = QuestRepeatType(rawValue: quest.repeatType) ?? .oneTime
                switch repeatType {
                case .daily:
                    return quest // Daily quests are always active and can be toggled regardless of completion status
                case .weekly:
                    // Weekly quests are active if they haven't been completed this week
                    do {
                        let weekAnchor = weekAnchor(for: today)
                        let completionRequest: NSFetchRequest<QuestCompletionEntity> = QuestCompletionEntity.fetchRequest()
                        completionRequest.predicate = NSPredicate(format: "quest == %@ AND date == %@", quest, weekAnchor as NSDate)
                        let completions = try context.fetch(completionRequest)
                        return quest // Include weekly quests regardless of completion status
                    } catch {
                        return nil
                    }
                case .oneTime:
                    // One-time quests are active if due date is today or in the future and not completed
                    guard let dueDate = quest.dueDate else { return nil }
                    let dueDateAnchor = Calendar.current.startOfDay(for: dueDate)
                    do {
                        let completionRequest: NSFetchRequest<QuestCompletionEntity> = QuestCompletionEntity.fetchRequest()
                        completionRequest.predicate = NSPredicate(format: "quest == %@ AND date == %@", quest, dueDateAnchor as NSDate)
                        let completions = try context.fetch(completionRequest)
                        return dueDateAnchor >= today ? quest : nil
                    } catch {
                        return nil
                    }
                case .scheduled:
                    // Check if today is a scheduled day
                    let weekday = Calendar.current.component(.weekday, from: today)
                    let scheduledDays = quest.scheduledDays?.components(separatedBy: ",").compactMap { Int($0) } ?? []
                    return scheduledDays.contains(weekday) ? quest : nil
                }
            }

                        // Check completion status for today
            let completedQuests = todaysQuests.compactMap { quest -> QuestEntity? in
                let completionRequest: NSFetchRequest<QuestCompletionEntity> = QuestCompletionEntity.fetchRequest()
                let completionDate: Date

                let repeatType = QuestRepeatType(rawValue: quest.repeatType) ?? .oneTime
                switch repeatType {
                case .daily:
                    completionDate = today
                case .weekly:
                    completionDate = weekAnchor(for: today)
                case .oneTime:
                    completionDate = Calendar.current.startOfDay(for: quest.dueDate ?? today)
                case .scheduled:
                    completionDate = today
                }

                do {
                    completionRequest.predicate = NSPredicate(format: "quest == %@ AND date == %@", quest, completionDate as NSDate)
                    let completions = try context.fetch(completionRequest)
                    return !completions.isEmpty ? quest : nil
                } catch {
                    return nil
                }
            }

            return DailyQuestWidgetEntry(
                date: Date(),
                todaysQuests: todaysQuests,
                completedQuestsCount: completedQuests.count,
                totalQuestsCount: todaysQuests.count
            )
        } catch {
            print("Failed to fetch quests for widget: \(error)")
            return DailyQuestWidgetEntry(
                date: Date(),
                todaysQuests: [],
                completedQuestsCount: 0,
                totalQuestsCount: 0
            )
        }
    }

    private func weekAnchor(for date: Date) -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        return calendar.date(from: components) ?? date
    }
}

// MARK: - Widget Entry
struct DailyQuestWidgetEntry: TimelineEntry {
    var date: Date
    let todaysQuests: [QuestEntity]
    let completedQuestsCount: Int
    let totalQuestsCount: Int

    var progressPercentage: Double {
        guard totalQuestsCount > 0 else { return 0 }
        return Double(completedQuestsCount) / Double(totalQuestsCount)
    }
}

// MARK: - Widget View
struct DailyQuestWidgetEntryView: View {
    var entry: DailyQuestWidgetEntry
    @Environment(\.widgetFamily) var family

    private var theme: WidgetTheme {
        WidgetTheme.current()
    }

    var body: some View {
        ZStack {
            if entry.totalQuestsCount > 0 {
                if entry.completedQuestsCount == entry.totalQuestsCount {
                    allCompletedContent
                } else {
                    questsContent
                }
            } else {
                noQuestsContent
            }
        }
    }

    @ViewBuilder
    private var questsContent: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header with quest icon and title
            HStack {
                Image("icon_sword_double")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20, height: 20)
                    .foregroundColor(theme.accentColor)

                Text(LocalizationHelper.localized("daily_quests"))
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(theme.secondaryTextColor)

                Spacer()
            }


                        // Quest list (show exactly 2 quests in two lines)
            VStack(spacing: 6) {
                ForEach(Array(entry.todaysQuests.prefix(2)), id: \.id) { quest in
                    questRow(quest: quest)
                }

                // Fill empty space if less than 2 quests
                if entry.todaysQuests.count < 2 {
                    ForEach(0..<(2 - entry.todaysQuests.count), id: \.self) { _ in
                        HStack(spacing: 8) {
                            Image(systemName: "circle")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(theme.secondaryTextColor.opacity(0.3))
                                .frame(width: 16, height: 16)

                            Text("")
                                .font(.system(size: 12, weight: .medium, design: .rounded))
                                .foregroundColor(theme.primaryTextColor.opacity(0.3))

                            Spacer()

                            Image(systemName: "circle")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(theme.secondaryTextColor.opacity(0.3))
                        }
                        .padding(.vertical, 2)
                    }
                }
            }
        }
        .padding(12)
    }

        @ViewBuilder
    private func questRow(quest: QuestEntity) -> some View {
        let isCompleted = isQuestCompleted(quest)

        HStack(spacing: 8) {
            // Quest type icon
            Image(systemName: questIconName(for: quest))
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(questTypeColor(for: quest))
                .frame(width: 16, height: 16)

            // Quest title
            Text(quest.title ?? LocalizationHelper.localized(LocalizationHelper.untitledQuest))
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundColor(theme.primaryTextColor)
                .lineLimit(1)
                .strikethrough(isCompleted)
                .opacity(isCompleted ? 0.6 : 1.0)

            Spacer()

            // Completion status (tappable)
            Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(isCompleted ? theme.successColor : theme.secondaryTextColor.opacity(0.6))
        }
        .padding(.vertical, 2)
        .contentShape(Rectangle())
        .widgetURL(URL(string: "rpgquest://toggle-quest/\(quest.id?.uuidString ?? "")"))
    }

    @ViewBuilder
    private var noQuestsContent: some View {
        VStack(spacing: 8) {
            Image(systemName: "plus.circle.fill")
                .font(.title2)
                .foregroundColor(theme.accentColor)

            Text(LocalizationHelper.localized(LocalizationHelper.startYourAdventure))
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(theme.primaryTextColor)

            Text(LocalizationHelper.localized(LocalizationHelper.createYourFirstQuest))
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundColor(theme.secondaryTextColor)
                .multilineTextAlignment(.center)
        }
        .padding(12)
    }

    @ViewBuilder
    private var allCompletedContent: some View {
        VStack(spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .font(.title2)
                .foregroundColor(theme.successColor)

            Text(LocalizationHelper.localized("done_for_today"))
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(theme.primaryTextColor)

            Text(LocalizationHelper.localized("all_quests_completed_today"))
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundColor(theme.secondaryTextColor)
                .multilineTextAlignment(.center)
        }
        .padding(12)
    }

    // MARK: - Helper Methods

    private func isQuestCompleted(_ quest: QuestEntity) -> Bool {
        let today = Calendar.current.startOfDay(for: Date())
        let completionDate: Date

        let repeatType = QuestRepeatType(rawValue: quest.repeatType) ?? .oneTime
        switch repeatType {
        case .daily:
            completionDate = today
        case .weekly:
            completionDate = weekAnchor(for: today)
        case .oneTime:
            completionDate = Calendar.current.startOfDay(for: quest.dueDate ?? today)
        case .scheduled:
            completionDate = today
        }

        // Check if completion exists for this date
        let context = PersistenceController.shared.container.viewContext
        let completionRequest: NSFetchRequest<QuestCompletionEntity> = QuestCompletionEntity.fetchRequest()
        completionRequest.predicate = NSPredicate(format: "quest == %@ AND date == %@", quest, completionDate as NSDate)

        do {
            let completions = try context.fetch(completionRequest)
            return !completions.isEmpty
        } catch {
            return false
        }
    }

    private func questIconName(for quest: QuestEntity) -> String {
        if quest.isMainQuest {
            return "crown.fill"
        } else {
            let repeatType = QuestRepeatType(rawValue: quest.repeatType) ?? .oneTime
            switch repeatType {
            case .daily: return "sun.max.fill"
            case .weekly: return "calendar.badge.clock"
            case .oneTime: return "target"
            case .scheduled: return "calendar.badge.clock"
            }
        }
    }

    private func questTypeColor(for quest: QuestEntity) -> Color {
        if quest.isMainQuest {
            return .yellow
        } else {
            let repeatType = QuestRepeatType(rawValue: quest.repeatType) ?? .oneTime
            switch repeatType {
            case .daily: return .orange
            case .weekly: return .blue
            case .oneTime: return .purple
            case .scheduled: return .purple
            }
        }
    }

    private func weekAnchor(for date: Date) -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        return calendar.date(from: components) ?? date
    }
}

// MARK: - Widget Configuration
struct ActiveQuestWidget: Widget {
    let persistenceController = PersistenceController.shared
    let kind: String = "ActiveQuestWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                DailyQuestWidgetEntryView(entry: entry)
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
                    .containerBackground(for: .widget) {
                        WidgetTheme.current().backgroundGradient
                    }
            } else {
                DailyQuestWidgetEntryView(entry: entry)
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
                    .padding()
                    .background(WidgetTheme.current().backgroundGradient)
            }
        }
        .configurationDisplayName(LocalizationHelper.localized("daily_quest_summary"))
        .description(LocalizationHelper.localized("daily_quest_widget_description"))
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

// MARK: - Preview
#Preview(as: .systemSmall) {
    ActiveQuestWidget()
} timeline: {
    DailyQuestWidgetEntry(
        date: Date(),
        todaysQuests: [],
        completedQuestsCount: 0,
        totalQuestsCount: 0
    )

    DailyQuestWidgetEntry(
        date: Date(),
        todaysQuests: [],
        completedQuestsCount: 2,
        totalQuestsCount: 5
    )
}
