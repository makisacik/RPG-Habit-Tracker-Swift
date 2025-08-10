//
//  MainQuestCardView.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 10.11.2024.
//

import SwiftUI

struct QuestCardView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @State private var isExpanded: Bool = false

    let quest: Quest
    let onMarkComplete: (UUID) -> Void
    let onEditQuest: (Quest) -> Void
    let onUpdateProgress: (UUID, Int) -> Void
    let onToggleTaskCompletion: (UUID, Bool) -> Void
    

    var body: some View {
        let theme = themeManager.activeTheme
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
                            .foregroundColor(theme.textColor)
                            .padding(.leading, 4)
                    }

                    ProgressView(value: Double(quest.progress) / 100.0)
                        .frame(height: 8)
                        .tint(theme.textColor)
                        .padding(.horizontal, 4)

                    Button(action: { onUpdateProgress(quest.id, 20) }) {
                        Text("+")
                            .font(.appFont(size: 18, weight: .black))
                            .foregroundColor(theme.textColor)
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
                                .foregroundColor(theme.textColor)
                            Spacer()
                            Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                                .foregroundColor(theme.textColor)
                                .imageScale(.small)
                        }
                    }

                    if isExpanded {
                        VStack(alignment: .leading, spacing: 4) {
                            ForEach(tasks, id: \.id) { task in
                                HStack {
                                    Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle.fill")
                                        .resizable()
                                        .frame(width: 18, height: 18)
                                        .foregroundColor(task.isCompleted ? .green : .gray)

                                    Text(task.title)
                                        .font(.appFont(size: 13))
                                        .foregroundColor(theme.textColor)
                                    
                                    Spacer()
                                }
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    onToggleTaskCompletion(task.id, !task.isCompleted)
                                }
                            }
                        }
                        .padding(.top, 4)
                        .transition(.opacity.combined(with: .slide))
                    }
                }
                   
                Spacer()

                HStack {
                    StarRatingView(rating: .constant(quest.difficulty), starSize: 14, spacing: 4)
                        .disabled(true)

                    Spacer()

                    Text(quest.dueDate, format: .dateTime.day().month(.abbreviated))
                        .font(.appFont(size: 12))
                        .foregroundColor(theme.textColor)
                }
                .padding(.top, 4)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(themeManager.activeTheme.secondaryColor)
                    .shadow(color: Color.black.opacity(0.2), radius: 6, x: 0, y: 4)
            )
            .cornerRadius(10)
            .shadow(radius: 3)
            .frame(maxWidth: .infinity)

            Menu {
                Button("Mark as Finished") {
                    onMarkComplete(quest.id)
                }
                Button("Edit Quest") {
                    onEditQuest(quest)
                }
            } label: {
                Image(systemName: "ellipsis")
                    .padding()
                    .foregroundColor(theme.textColor)
            }
        }
    }
}
