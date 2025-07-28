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
            VStack(alignment: .leading, spacing: 8) {
                Text(quest.title)
                    .font(.appFont(size: 16, weight: .black))

                if !quest.info.isEmpty {
                    Text(quest.info)
                        .font(.appFont(size: 14))
                        .lineLimit(2)
                        .truncationMode(.tail)
                }

                HStack {
                    Button(action: { onUpdateProgress(quest.id, -20) }) {
                        Text("-")
                            .font(.appFont(size: 18, weight: .black))
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
                            .font(.appFont(size: 18, weight: .black))
                            .foregroundColor(.appYellow)
                            .contentShape(Rectangle())
                            .padding(.trailing, 4)
                    }
                }

                Spacer()

                HStack {
                    StarRatingView(rating: .constant(quest.difficulty))
                        .disabled(true)

                    Spacer()

                    Text(quest.dueDate, format: .dateTime.day().month(.abbreviated))
                        .font(.appFont(size: 12))
                        .foregroundColor(.white)
                }
                .padding(.top, 4)
            }
            .padding()
            .background(
                Image("panel_brown_plus")
                    .resizable(capInsets: EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16), resizingMode: .stretch)
            )
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
                    .foregroundColor(.white)
            }
        }
    }
}
