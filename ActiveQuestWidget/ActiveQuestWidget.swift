//
//  ActiveQuestWidget.swift
//  ActiveQuestWidget
//
//  Created by Mehmet Ali Kısacık on 19.11.2024.
//

import WidgetKit
import SwiftUI
import CoreData

// MARK: - Widget Theme
struct WidgetTheme {
    let backgroundGradient: LinearGradient
    let primaryTextColor: Color
    let secondaryTextColor: Color
    let accentColor: Color
    
    static func current() -> WidgetTheme {
        // Check if we're in dark mode
        let isDarkMode = UITraitCollection.current.userInterfaceStyle == .dark

        if isDarkMode {
            return WidgetTheme(
                backgroundGradient: LinearGradient(
                    colors: [Color(hex: "#1F2937"), Color(hex: "#374151")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                primaryTextColor: Color(hex: "#F9FAFB"),
                secondaryTextColor: Color(hex: "#D1D5DB"),
                accentColor: Color(hex: "#F59E0B"),
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
    typealias Entry = QuestWidgetEntry
    let persistenceController = PersistenceController.shared

    func placeholder(in context: Context) -> QuestWidgetEntry {
        QuestWidgetEntry(
            date: Date(),
            quest: nil,
            hasActiveQuests: false,
            completedTasksCount: 0,
            totalTasksCount: 0
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (QuestWidgetEntry) -> Void) {
        let entry = fetchActiveQuestEntry()
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<QuestWidgetEntry>) -> Void) {
        let currentDate = Date()
        let entry = fetchActiveQuestEntry()
        
        // Update every 30 minutes
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 30, to: currentDate) ?? currentDate
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }

    private func fetchActiveQuestEntry() -> QuestWidgetEntry {
        let context = persistenceController.container.viewContext
        let fetchRequest: NSFetchRequest<QuestEntity> = QuestEntity.fetchRequest()
        
        // Fetch active, non-completed quests, sorted by due date (earliest first)
        fetchRequest.predicate = NSPredicate(format: "isActive == YES AND isCompleted == NO")
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \QuestEntity.dueDate, ascending: true),
            NSSortDescriptor(keyPath: \QuestEntity.creationDate, ascending: false)
        ]
        fetchRequest.fetchLimit = 1

        do {
            let quests = try context.fetch(fetchRequest)
            if let activeQuest = quests.first {
                let tasks = activeQuest.taskList
                let completedTasks = tasks.filter { $0.isCompleted }.count

                return QuestWidgetEntry(
                    date: Date(),
                    quest: activeQuest,
                    hasActiveQuests: true,
                    completedTasksCount: completedTasks,
                    totalTasksCount: tasks.count
                )
            } else {
                // No active quests, check if there are any quests at all
                let allQuestsFetch: NSFetchRequest<QuestEntity> = QuestEntity.fetchRequest()
                let allQuests = try context.fetch(allQuestsFetch)

                return QuestWidgetEntry(
                    date: Date(),
                    quest: nil,
                    hasActiveQuests: allQuests.isEmpty,
                    completedTasksCount: 0,
                    totalTasksCount: 0
                )
            }
        } catch {
            print("Failed to fetch quests for widget: \(error)")
            return QuestWidgetEntry(
                date: Date(),
                quest: nil,
                hasActiveQuests: false,
                completedTasksCount: 0,
                totalTasksCount: 0
            )
        }
    }
}

// MARK: - Widget Entry
struct QuestWidgetEntry: TimelineEntry {
    var date: Date
    let quest: QuestEntity?
    let hasActiveQuests: Bool
    let completedTasksCount: Int
    let totalTasksCount: Int
    

    var daysUntilDue: Int {
        guard let quest = quest, let dueDate = quest.dueDate else { return 0 }
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: Date(), to: dueDate)
        return components.day ?? 0
    }

    var isOverdue: Bool {
        guard let quest = quest, let dueDate = quest.dueDate else { return false }
        return dueDate < Date()
    }
}

// MARK: - Widget View
struct ActiveQuestWidgetEntryView: View {
    var entry: QuestWidgetEntry
    @Environment(\.widgetFamily) var family
    
    private var theme: WidgetTheme {
        WidgetTheme.current()
    }
    
    var body: some View {
        ZStack {
            if entry.quest != nil {
                questContent
            } else if entry.hasActiveQuests {
                noActiveQuestsContent
            } else {
                noQuestsContent
            }
        }
    }
    
    @ViewBuilder
    private var questContent: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header with quest icon and title
            HStack {
                Image("icon_sword_double")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)
                    .foregroundColor(theme.accentColor)
                
                Text(LocalizationHelper.localized(LocalizationHelper.activeQuest))
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(theme.secondaryTextColor)
                
                Spacer()
            }
            
            // Quest title
            if let quest = entry.quest {
                Text(quest.title ?? LocalizationHelper.localized(LocalizationHelper.untitledQuest))
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(theme.primaryTextColor)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }
            
            
            // Due date and status
            HStack {
                if entry.isOverdue {
                    HStack(spacing: 4) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.caption)
                            .foregroundColor(.red)
                        
                        Text(LocalizationHelper.localized(LocalizationHelper.overdue))
                            .font(.system(size: 11, weight: .semibold, design: .rounded))
                            .foregroundColor(.red)
                    }
                } else {
                    HStack(spacing: 4) {
                        Image(systemName: "calendar")
                            .font(.caption)
                            .foregroundColor(theme.secondaryTextColor)
                        
                        if entry.daysUntilDue == 0 {
                            Text(LocalizationHelper.localized(LocalizationHelper.dueToday))
                                .font(.system(size: 11, weight: .medium, design: .rounded))
                                .foregroundColor(theme.secondaryTextColor)
                        } else if entry.daysUntilDue == 1 {
                            Text(LocalizationHelper.localized(LocalizationHelper.dueTomorrow))
                                .font(.system(size: 11, weight: .medium, design: .rounded))
                                .foregroundColor(theme.secondaryTextColor)
                        } else {
                            Text("\(entry.daysUntilDue) \(LocalizationHelper.localized(LocalizationHelper.daysLeft))")
                                .font(.system(size: 11, weight: .medium, design: .rounded))
                                .foregroundColor(theme.secondaryTextColor)
                        }
                    }
                }
                
                Spacer()
            }
        }
        .padding(12)
    }
    
    @ViewBuilder
    private var noActiveQuestsContent: some View {
        VStack(spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .font(.title)
                .foregroundColor(.green)
            
            Text(LocalizationHelper.localized(LocalizationHelper.noActiveQuests))
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(theme.primaryTextColor)
            
            Text(LocalizationHelper.localized(LocalizationHelper.allQuestsCompleted))
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundColor(theme.secondaryTextColor)
                .multilineTextAlignment(.center)
        }
        .padding(12)
    }
    
    @ViewBuilder
    private var noQuestsContent: some View {
        VStack(spacing: 8) {
            Image(systemName: "plus.circle.fill")
                .font(.title)
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
}

// MARK: - Widget Configuration
struct ActiveQuestWidget: Widget {
    let persistenceController = PersistenceController.shared
    let kind: String = "ActiveQuestWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                ActiveQuestWidgetEntryView(entry: entry)
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
                    .containerBackground(for: .widget) {
                        WidgetTheme.current().backgroundGradient
                    }
            } else {
                ActiveQuestWidgetEntryView(entry: entry)
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
                    .padding()
                    .background(WidgetTheme.current().backgroundGradient)
            }
        }
        .configurationDisplayName(LocalizationHelper.localized(LocalizationHelper.activeQuest))
        .description(LocalizationHelper.localized("widget_description"))
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

// MARK: - Preview
#Preview(as: .systemSmall) {
    ActiveQuestWidget()
} timeline: {
    QuestWidgetEntry(
        date: Date(),
        quest: nil,
        hasActiveQuests: false,
        completedTasksCount: 0,
        totalTasksCount: 0
    )
    
    QuestWidgetEntry(
        date: Date(),
        quest: nil,
        hasActiveQuests: true,
        completedTasksCount: 0,
        totalTasksCount: 0
    )
}
