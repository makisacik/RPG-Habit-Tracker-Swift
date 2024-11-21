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
        SimpleEntry(date: Date(), dueDate: Date(), questTitle: "Sample Title", progress: 0.5)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> Void) {
        let entry = fetchLatestQuestEntry() ?? SimpleEntry(date: Date(), dueDate: Date(), questTitle: "No Active Quest", progress: 0.5)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        let currentDate = Date()
        let entry = fetchLatestQuestEntry() ?? SimpleEntry(date: Date(), dueDate: Date(), questTitle: "No Active Quest", progress: 0.5)
        
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
                return SimpleEntry(date: Date(), dueDate: latestQuest.dueDate ?? Date(), questTitle: latestQuest.title ?? "Untitled Quest", progress: 0.01 * Double(latestQuest.progress))
            }
        } catch {
            print("Failed to fetch latest quest: \(error)")
        }
        return nil
    }
}

struct SimpleEntry: TimelineEntry {
    var date: Date
    let dueDate: Date
    let questTitle: String
    let progress: Double
}

struct ActiveQuestWidgetEntryView: View {
    var entry: Provider.Entry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Header
            Text("Active Quest ⚔")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .center)
            
            // Quest Title
            Text(entry.questTitle)
                .font(.subheadline)
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: .center)
            
            // Due Date
            Text("Due: \(entry.dueDate.formatted(.dateTime.day().month().year()))")
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .center)
            
            // Progress Bar (Dummy Progress for Now)
            ProgressView(value: entry.progress) // Example: 50% progress
                .tint(.appYellow)
                .progressViewStyle(LinearProgressViewStyle())
                .frame(height: 8)
                .cornerRadius(4)
                .padding(.horizontal)
            
            Spacer()
        }
//        .background(
//            RoundedRectangle(cornerRadius: 12)
//                .fill(Color(.systemBackground))
//                .shadow(radius: 4)
//        )
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
                    .containerBackground(.gray.gradient, for: .widget)
            } else {
                ActiveQuestWidgetEntryView(entry: entry)
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
}
