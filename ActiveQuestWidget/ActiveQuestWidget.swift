//
//  ActiveQuestWidget.swift
//  ActiveQuestWidget
//
//  Created by Mehmet Ali Kısacık on 19.11.2024.
//

import WidgetKit
import SwiftUI
import CoreData

struct Provider: TimelineProvider {
    let persistenceController = PersistenceController.shared

    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), emoji: "😀", questTitle: "Sample Quest")
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> Void) {
        let entry = fetchLatestQuestEntry() ?? SimpleEntry(date: Date(), emoji: "😀", questTitle: "No Active Quest")
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        let currentDate = Date()
        let entry = fetchLatestQuestEntry() ?? SimpleEntry(date: currentDate, emoji: "😀", questTitle: "No Active Quest")
        
        // Create a single entry for now
        let timeline = Timeline(entries: [entry], policy: .atEnd)
        completion(timeline)
    }

    private func fetchLatestQuestEntry() -> SimpleEntry? {
        let context = persistenceController.container.viewContext
        let fetchRequest: NSFetchRequest<QuestEntity> = QuestEntity.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \QuestEntity.creationDate, ascending: false)]
        fetchRequest.fetchLimit = 1
        
        do {
            if let latestQuest = try context.fetch(fetchRequest).first {
                print(latestQuest.title)
                let emoji = mapDifficultyToEmoji(latestQuest.difficulty)
                return SimpleEntry(date: Date(), emoji: emoji, questTitle: latestQuest.title ?? "Untitled Quest")
            }
        } catch {
            print("Failed to fetch latest quest: \(error)")
        }
        return nil
    }

    private func mapDifficultyToEmoji(_ difficulty: Int16) -> String {
        switch difficulty {
        case 1: return "😊"
        case 2: return "😃"
        case 3: return "😤"
        default: return "😀"
        }
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let emoji: String
    let questTitle: String
}

struct ActiveQuestWidgetEntryView: View {
    var entry: Provider.Entry

    var body: some View {
        VStack(alignment: .leading) {
            Text("Active Quest:")
                .font(.headline)
            Text(entry.questTitle)
                .font(.subheadline)
                .foregroundColor(.primary)

            Spacer()

            Text("Emoji:")
            Text(entry.emoji)
                .font(.largeTitle)
        }
        .padding()
    }
}


struct ActiveQuestWidget: Widget {
    let persistenceController = PersistenceController.shared
    let kind: String = "ActiveQuestWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                ActiveQuestWidgetEntryView(entry: entry)
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                ActiveQuestWidgetEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
}

// #Preview(as: .systemSmall) {
//    ActiveQuestWidget()
// } timeline: {
//    SimpleEntry(date: .now, emoji: "😀")
//    SimpleEntry(date: .now, emoji: "🤩")
// }
