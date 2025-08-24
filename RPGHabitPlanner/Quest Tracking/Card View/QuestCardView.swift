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
    @State private var showFinishConfirmation: Bool = false

    let quest: Quest
    let onMarkComplete: (UUID) -> Void
    let onEditQuest: (Quest) -> Void

    let onToggleTaskCompletion: (UUID, Bool) -> Void
    let onQuestTap: (Quest) -> Void

    var body: some View {
        let theme = themeManager.activeTheme
        ZStack(alignment: .topTrailing) {
            VStack(alignment: .leading, spacing: 8) {
                // Quest title and info
                VStack(alignment: .leading, spacing: 6) {
                    Text(quest.title)
                        .font(.appFont(size: 16, weight: .black))
                        .foregroundColor(theme.textColor)

                    if !quest.info.isEmpty {
                        Text(quest.info)
                            .font(.appFont(size: 14))
                            .foregroundColor(theme.textColor.opacity(0.8))
                            .lineLimit(isExpanded ? nil : 2)
                            .truncationMode(.tail)
                    }
                }

                // Tags section
                if !quest.tags.isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Image(systemName: "tag.fill")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(theme.textColor.opacity(0.6))

                            Text("Tags")
                                .font(.appFont(size: 12, weight: .medium))
                                .foregroundColor(theme.textColor.opacity(0.6))

                            Spacer()
                        }

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 6) {
                                ForEach(Array(quest.tags), id: \.id) { tag in
                                    TagChip(
                                        tag: tag
                                    ) {}
                                    .scaleEffect(0.8)
                                }
                            }
                            .padding(.horizontal, 2)
                        }
                    }
                    .padding(.vertical, 4)
                }

                // Tasks section
                let tasks = quest.tasks
                if !tasks.isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        Button(action: {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                isExpanded.toggle()
                            }
                        }) {
                            HStack {
                                Image(systemName: "list.bullet")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(theme.textColor.opacity(0.6))

                                Text("\(tasks.count) \(String.tasks.localized)")
                                    .font(.appFont(size: 12, weight: .medium))
                                    .foregroundColor(theme.textColor.opacity(0.6))

                                Spacer()

                                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundColor(theme.textColor.opacity(0.6))
                                    .rotationEffect(.degrees(isExpanded ? 0 : 0))
                                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isExpanded)
                            }
                        }
                        .buttonStyle(PlainButtonStyle())

                        if isExpanded {
                            VStack(alignment: .leading, spacing: 4) {
                                ForEach(tasks, id: \.id) { task in
                                    HStack(spacing: 8) {
                                        Button(action: {
                                            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                                onToggleTaskCompletion(task.id, !task.isCompleted)
                                            }
                                        }) {
                                            Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                                                .font(.system(size: 14, weight: .medium))
                                                .foregroundColor(task.isCompleted ? .green : theme.textColor.opacity(0.5))
                                        }
                                        .buttonStyle(PlainButtonStyle())

                                        Text(task.title)
                                            .font(.appFont(size: 13))
                                            .foregroundColor(theme.textColor.opacity(0.9))
                                            .strikethrough(task.isCompleted)

                                        Spacer()

                                        // Flag button next to task completion toggle
                                        Button(action: {
                                            showFinishConfirmation = true
                                        }) {
                                            Image(systemName: "flag.fill")
                                                .font(.system(size: 14, weight: .medium))
                                                .foregroundColor(.orange)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                    .contentShape(Rectangle())
                                    .padding(.vertical, 2)
                                }
                            }
                            .padding(.top, 4)
                            .transition(.asymmetric(
                                insertion: .opacity.combined(with: .move(edge: .top)),
                                removal: .opacity.combined(with: .move(edge: .top))
                            ))
                        }
                    }
                    .padding(.vertical, 4)
                }

                Spacer()

                // Footer with difficulty and due date
                HStack {
                    StarRatingView(rating: .constant(quest.difficulty), starSize: 14, spacing: 4)
                        .disabled(true)

                    Spacer()

                    Text(quest.dueDate, format: .dateTime.day().month(.abbreviated))
                        .font(.appFont(size: 12))
                        .foregroundColor(theme.textColor.opacity(0.7))
                }
                .padding(.top, 4)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(theme.primaryColor)
                    .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
            )
            .onTapGesture {
                onQuestTap(quest)
            }
        }
        .alert("Is this quest finished?", isPresented: $showFinishConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Yes, finish it!") {
                onMarkComplete(quest.id)
            }
        } message: {
            Text("Are you sure you want to mark '\(quest.title)' as finished?")
        }
    }
}
