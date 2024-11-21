//
//  MainQuestCardView.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 10.11.2024.
//

import SwiftUI

struct QuestCardView: View {
    let quest: Quest
    let onMarkComplete: (UUID) -> Void
    let onEditQuest: (Quest) -> Void
    let onUpdateProgress: (UUID, Int) -> Void

    @State private var isMenuPresented: Bool = false

    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(alignment: .leading) {
                Text(quest.title)
                    .font(.headline)
                if !quest.info.isEmpty {
                    Text(quest.info)
                        .font(.body)
                        .lineLimit(2)
                        .truncationMode(.tail)
                }

                HStack {
                    Button(action: { onUpdateProgress(quest.id, -20) }) {
                        Text("-")
                            .font(.title2)
                            .foregroundColor(.appYellow)
                            .contentShape(Rectangle())
                            .padding(.leading, 4)
                    }

                    ProgressView(value: Double(quest.progress) / 100.0)
                        .frame(height: 8)
                        .tint(.appYellow)
                        .padding(.horizontal, 4)

                    Button(action: { onUpdateProgress(quest.id, 20) }) {
                        Text("+")
                            .font(.title2)
                            .foregroundColor(.appYellow)
                            .contentShape(Rectangle())
                            .padding(.trailing, 4)
                    }
                }
                Spacer()

                HStack {
                    HStack(spacing: 2) {
                        ForEach(1...5, id: \.self) { index in
                            Image(systemName: "star.fill")
                                .resizable()
                                .frame(width: 12, height: 12)
                                .foregroundColor(index <= quest.difficulty ? .yellow : .gray)
                        }
                    }
                    Spacer()
                    Text(quest.dueDate, format: .dateTime.day().month(.abbreviated))
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding(.top, 4)
            }
            .padding()
            .background(Color(.secondarySystemGroupedBackground))
            .cornerRadius(10)
            .shadow(radius: 3)
            .frame(maxWidth: .infinity)

            Menu {
                Button("Mark as Completed") {
                    onMarkComplete(quest.id)
                }
                Button("Edit Quest") {
                    onEditQuest(quest)
                }
            } label: {
                Image(systemName: "ellipsis")
                    .padding()
                    .foregroundColor(.gray)
            }
        }
    }
}
