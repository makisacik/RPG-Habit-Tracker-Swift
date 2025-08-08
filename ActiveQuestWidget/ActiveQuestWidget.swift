//
//  ActiveQuestWidget.swift
//  ActiveQuestWidget
//
//  Created by Mehmet Ali Kısacık on 19.11.2024.
//

import WidgetKit
import SwiftUI
import CoreData

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
    
    var progress: Double {
        guard totalTasksCount > 0 else { return 0.0 }
        return Double(completedTasksCount) / Double(totalTasksCount)
    }

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
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color(hex: "#F8F7FF"), Color(hex: "#C4B5FD")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
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
                Image(systemName: "sword.fill")
                    .font(.title2)
                    .foregroundColor(.orange)
                
                Text("Active Quest")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(Color(hex: "#4B5563"))
                
                Spacer()
                
                // Difficulty indicator
                if let quest = entry.quest {
                    difficultyBadge(difficulty: Int(quest.difficulty))
                }
            }
            
            // Quest title
            if let quest = entry.quest {
                Text(quest.title ?? "Untitled Quest")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(Color(hex: "#1F2937"))
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }
            
            // Progress section
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Progress")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(Color(hex: "#6B7280"))
                    
                    Spacer()
                    
                    Text("\(entry.completedTasksCount)/\(entry.totalTasksCount)")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundColor(Color(hex: "#4B5563"))
                }
                
                // Progress bar
                ProgressView(value: entry.progress)
                    .progressViewStyle(LinearProgressViewStyle(tint: Color(hex: "#FFB700")))
                    .scaleEffect(y: 1.5)
                    .frame(height: 6)
            }
            
            // Due date and status
            HStack {
                if entry.isOverdue {
                    HStack(spacing: 4) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.caption)
                            .foregroundColor(.red)
                        
                        Text("Overdue!")
                            .font(.system(size: 11, weight: .semibold, design: .rounded))
                            .foregroundColor(.red)
                    }
                } else {
                    HStack(spacing: 4) {
                        Image(systemName: "calendar")
                            .font(.caption)
                            .foregroundColor(Color(hex: "#6B7280"))
                        
                        if entry.daysUntilDue == 0 {
                            Text("Due today")
                                .font(.system(size: 11, weight: .medium, design: .rounded))
                                .foregroundColor(Color(hex: "#6B7280"))
                        } else if entry.daysUntilDue == 1 {
                            Text("Due tomorrow")
                                .font(.system(size: 11, weight: .medium, design: .rounded))
                                .foregroundColor(Color(hex: "#6B7280"))
                        } else {
                            Text("\(entry.daysUntilDue) days left")
                                .font(.system(size: 11, weight: .medium, design: .rounded))
                                .foregroundColor(Color(hex: "#6B7280"))
                        }
                    }
                }
                
                Spacer()
                
                // Completion percentage
                Text("\(Int(entry.progress * 100))%")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundColor(Color(hex: "#FFB700"))
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
            
            Text("No Active Quests")
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(Color(hex: "#4B5563"))
            
            Text("All quests completed!")
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundColor(Color(hex: "#6B7280"))
                .multilineTextAlignment(.center)
        }
        .padding(12)
    }
    
    @ViewBuilder
    private var noQuestsContent: some View {
        VStack(spacing: 8) {
            Image(systemName: "plus.circle.fill")
                .font(.title)
                .foregroundColor(Color(hex: "#8B5CF6"))
            
            Text("Start Your Adventure")
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(Color(hex: "#4B5563"))
            
            Text("Create your first quest")
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundColor(Color(hex: "#6B7280"))
                .multilineTextAlignment(.center)
        }
        .padding(12)
    }
    
    @ViewBuilder
    private func difficultyBadge(difficulty: Int) -> some View {
        let (color, text) = difficultyInfo(for: difficulty)
        
        Text(text)
            .font(.system(size: 10, weight: .bold, design: .rounded))
            .foregroundColor(.white)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(
                RoundedRectangle(cornerRadius: 4)
                    .fill(color)
            )
    }
    
    private func difficultyInfo(for difficulty: Int) -> (Color, String) {
        switch difficulty {
        case 1:
            return (Color.green, "EASY")
        case 2:
            return (Color.orange, "EASY")
        case 3:
            return (Color.red, "MED")
        case 4:
            return (Color.red, "MED")
        case 5:
            return (Color.red, "HARD")
        default:
            return (Color.gray, "N/A")
        }
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
                    .containerBackground(.clear, for: .widget)
            } else {
                ActiveQuestWidgetEntryView(entry: entry)
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("Active Quest")
        .description("Track your current quest progress and due dates.")
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
