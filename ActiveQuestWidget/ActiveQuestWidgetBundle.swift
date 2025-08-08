//
//  ActiveQuestWidgetBundle.swift
//  ActiveQuestWidget
//
//  Created by Mehmet Ali Kısacık on 19.11.2024.
//

import WidgetKit
import SwiftUI

@main
struct ActiveQuestWidgetBundle: WidgetBundle {
    var body: some Widget {
        ActiveQuestWidget()
        QuestProgressWidget()
    }
}

// MARK: - Additional Widget for Progress Focus
struct QuestProgressWidget: Widget {
    let persistenceController = PersistenceController.shared
    let kind: String = "QuestProgressWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                QuestProgressWidgetEntryView(entry: entry)
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
                    .containerBackground(.clear, for: .widget)
            } else {
                QuestProgressWidgetEntryView(entry: entry)
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("Quest Progress")
        .description("Focus on your quest completion progress.")
        .supportedFamilies([.systemSmall])
    }
}

// MARK: - Progress-Focused Widget View
struct QuestProgressWidgetEntryView: View {
    var entry: QuestWidgetEntry
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color(hex: "#8B5CF6"), Color(hex: "#C4B5FD")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            if entry.quest != nil {
                progressContent
            } else {
                noQuestContent
            }
        }
    }
    
    @ViewBuilder
    private var progressContent: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.3), lineWidth: 8)
                    .frame(width: 80, height: 80)
                
                Circle()
                    .trim(from: 0, to: entry.progress)
                    .stroke(Color.white, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .frame(width: 80, height: 80)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 1.0), value: entry.progress)
                
                VStack(spacing: 2) {
                    Text("\(Int(entry.progress * 100))%")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("Complete")
                        .font(.system(size: 10, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            
            // Quest title
            if let quest = entry.quest {
                Text(quest.title ?? "Untitled Quest")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
            }
            
            // Task count
            Text("\(entry.completedTasksCount)/\(entry.totalTasksCount) tasks")
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.8))
        }
        .padding(16)
    }
    
    @ViewBuilder
    private var noQuestContent: some View {
        VStack(spacing: 8) {
            Image(systemName: "plus.circle.fill")
                .font(.title)
                .foregroundColor(.white)
            
            Text("Create Quest")
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
            
            Text("Start your adventure")
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
        }
        .padding(16)
    }
}
