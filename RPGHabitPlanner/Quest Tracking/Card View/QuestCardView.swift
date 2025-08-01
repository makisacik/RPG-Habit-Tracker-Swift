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

    @State private var isExpanded: Bool = false

    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(alignment: .leading, spacing: 8) {
                Text(quest.title)
                    .font(.appFont(size: 16, weight: .black))

                if !quest.info.isEmpty {
                    Text(quest.info)
                        .font(.appFont(size: 14))
                        .lineLimit(isExpanded ? nil : 2)
                        .truncationMode(.tail)
                }

                HStack {
                    Button(action: { onUpdateProgress(quest.id, -20) }) {
                        Text("-")
                            .font(.appFont(size: 18, weight: .black))
                            .foregroundColor(.black)
                            .padding(.leading, 4)
                    }

                    ProgressView(value: Double(quest.progress) / 100.0)
                        .frame(height: 8)
                        .tint(.black)
                        .padding(.horizontal, 4)

                    Button(action: { onUpdateProgress(quest.id, 20) }) {
                        Text("+")
                            .font(.appFont(size: 18, weight: .black))
                            .foregroundColor(.black)
                            .padding(.trailing, 4)
                    }
                }

                let tasks = quest.tasks
                if !tasks.isEmpty {
                    Button(action: {
                        withAnimation {
                            isExpanded.toggle()
                        }
                    }) {
                        HStack {
                            Text("\(tasks.count) Tasks")
                                .font(.appFont(size: 14, weight: .regular))
                                .foregroundColor(.black)
                            Spacer()
                            Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                                .foregroundColor(.black)
                                .imageScale(.small)
                        }
                    }

                    if isExpanded {
                        VStack(alignment: .leading, spacing: 4) {
                            ForEach(tasks, id: \.id) { task in
                                HStack {
                                    Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                                        .foregroundColor(task.isCompleted ? .green : .gray)
                                    Text(task.title ?? "")
                                        .font(.appFont(size: 13))
                                        .foregroundColor(.black)
                                }
                            }
                        }
                        .padding(.top, 4)
                        .transition(.opacity.combined(with: .slide))
                    }
                }
                   
                Spacer()

                HStack {
                    StarRatingView(rating: .constant(quest.difficulty))
                        .disabled(true)

                    Spacer()

                    Text(quest.dueDate, format: .dateTime.day().month(.abbreviated))
                        .font(.appFont(size: 12))
                        .foregroundColor(.black)
                }
                .padding(.top, 4)
            }
            .padding()
            .background(
                Image("panel_beigeLight")
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
