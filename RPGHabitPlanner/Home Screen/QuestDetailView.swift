//
//  QuestDetailView.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 11.11.2024.
//

import SwiftUI

struct QuestDetailView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var localizationManager: LocalizationManager
    @Environment(\.dismiss) private var dismiss
    @StateObject var viewModel: QuestDetailViewModel

    // UI state
    @State private var uiIsCompleted: Bool        // <- optimistic UI flag
    @State private var editingQuest: Quest?
    @State private var showingDeleteAlert = false
    @State private var showTagPicker = false

    private var theme: Theme { themeManager.activeTheme }

    // Custom init to seed the local copies
    init(quest: Quest, date: Date, questDataService: QuestDataServiceProtocol) {
        _viewModel = StateObject(wrappedValue: QuestDetailViewModel(
            quest: quest,
            date: date,
            questDataService: questDataService
        ))
        _uiIsCompleted = State(initialValue: quest.isCompleted(on: date))
    }

    var body: some View {
        ZStack {
            theme.backgroundColor.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    // Header Section
                    QuestDetailHeaderSection(quest: viewModel.quest, theme: theme)

                    // Tags Section
                    if !viewModel.quest.tags.isEmpty || showTagPicker {
                        QuestDetailTagsSection(
                            quest: viewModel.quest,
                            theme: theme,
                            showTagPicker: $showTagPicker
                        ) { updatedTags in
                                viewModel.updateQuestTags(updatedTags)
                        }
                    }

                    // Details Section
                    QuestDetailDetailsSection(quest: viewModel.quest, theme: theme)

                    // Tasks Section
                    if !viewModel.quest.tasks.isEmpty {
                        QuestDetailTasksSection(
                            quest: viewModel.quest,
                            theme: theme,
                            onToggleTask: toggleTaskCompletion
                        )
                    }

                    // Completion History
                    QuestDetailCompletionHistorySection(quest: viewModel.quest, theme: theme)

                    // Damage History
                    QuestDetailDamageHistorySection(quest: viewModel.quest, theme: theme)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 40)
            }
        }
        .navigationTitle("quest_details".localized)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("close".localized) { dismiss() }
                    .foregroundColor(theme.textColor)
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button("edit_quest".localized) {
                        editingQuest = viewModel.quest // pass a snapshot into the editor
                    }
                    Button("delete_quest".localized, role: .destructive) {
                        showingDeleteAlert = true
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundColor(theme.textColor)
                }
            }
        }

        .sheet(item: $editingQuest) { questToEdit in
            EditQuestView(
                viewModel: EditQuestViewModel(
                    quest: questToEdit,
                    questDataService: viewModel.questDataService
                ),
                onSaveSuccess: {
                    viewModel.refreshQuest()
                    refreshCurrentQuestFromStore()
                    // Notify other views that quest was updated
                    NotificationCenter.default.post(name: .questUpdated, object: viewModel.quest)
                },
                onDeleteSuccess: {
                    viewModel.refreshQuest()
                    editingQuest = nil
                    // Notify other views that quest was deleted
                    NotificationCenter.default.post(name: .questDeleted, object: viewModel.quest)
                    DispatchQueue.main.async {
                        dismiss()
                    }
                }
            )
            .environmentObject(themeManager)
            .environmentObject(localizationManager)
        }
        .alert("delete_quest_confirmation".localized, isPresented: $showingDeleteAlert) {
            Button("cancel".localized, role: .cancel) { }
            Button("delete".localized, role: .destructive) {
                deleteQuest()
            }
        } message: {
            Text("delete_quest_warning".localized)
        }
        .alert("error".localized, isPresented: .constant(viewModel.alertMessage != nil)) {
            Button("ok".localized) { viewModel.alertMessage = nil }
        } message: {
            if let alertMessage = viewModel.alertMessage {
                Text(alertMessage)
            }
        }
    }

    // MARK: - Helper Methods

    private func refreshCurrentQuestFromStore() {
        // The view model now handles this automatically through its refreshQuest method
        // We just need to update the UI state
        uiIsCompleted = viewModel.isCompleted
    }

    private func toggleTaskCompletion(_ task: QuestTask) {
        viewModel.toggleTaskCompletion(taskId: task.id, newValue: !task.isCompleted)
        refreshCurrentQuestFromStore()
    }

    private func deleteQuest() {
        // Provide haptic feedback for delete action
        HapticFeedbackManager.shared.errorOccurred()
        viewModel.deleteQuest()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            dismiss()
        }
    }
}

// MARK: - Quest Detail Tags Section

struct QuestDetailTagsSection: View {
    @EnvironmentObject var themeManager: ThemeManager
    let quest: Quest
    let theme: Theme
    @Binding var showTagPicker: Bool
    let onTagsUpdated: ([Tag]) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "tag.fill")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(theme.accentColor)

                    Text("tags".localized)
                        .font(.appFont(size: 18, weight: .bold))
                        .foregroundColor(theme.textColor)
                }

                Spacer()

                Button(action: {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        showTagPicker = true
                    }
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: quest.tags.isEmpty ? "plus.circle.fill" : "pencil.circle.fill")
                            .font(.system(size: 14, weight: .medium))
                        Text(quest.tags.isEmpty ? "add_tags".localized : "edit".localized)
                            .font(.appFont(size: 14, weight: .medium))
                    }
                    .foregroundColor(theme.accentColor)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(theme.accentColor.opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(theme.accentColor.opacity(0.3), lineWidth: 1)
                            )
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }

            if quest.tags.isEmpty {
                // Empty state
                VStack(spacing: 8) {
                    Image(systemName: "tag")
                        .font(.system(size: 24, weight: .light))
                        .foregroundColor(theme.textColor.opacity(0.3))

                    Text("no_tags_assigned".localized)
                        .font(.appFont(size: 14, weight: .medium))
                        .foregroundColor(theme.textColor.opacity(0.7))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(theme.cardBackgroundColor)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(theme.textColor.opacity(0.1), lineWidth: 1)
                        )
                )
            } else {
                // Tags display
                LazyVGrid(columns: [
                    GridItem(.adaptive(minimum: 80, maximum: 120), spacing: 8)
                ], spacing: 8) {
                    ForEach(Array(quest.tags), id: \.id) { tag in
                        TagChip(
                            tag: tag
                        ) {}
                    }
                }
                .padding(.vertical, 8)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(theme.cardBackgroundColor)
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        )
        .sheet(isPresented: $showTagPicker) {
            TagPickerView(selectedTags: Array(quest.tags)) { selectedTags in
                onTagsUpdated(selectedTags)
            }
        }
    }
}

#Preview {
    QuestDetailView(
        quest: Quest(
            title: "sample_quest_title".localized,
            isMainQuest: true,
            info: "sample_quest_description".localized,
            difficulty: 4,
            creationDate: Date(),
            dueDate: Date().addingTimeInterval(86400 * 7),
            isActive: true,
            progress: 75,
            tasks: [
                QuestTask(id: UUID(), title: "sample_task_1".localized, isCompleted: true, order: 0),
                QuestTask(id: UUID(), title: "sample_task_2".localized, isCompleted: false, order: 1),
                QuestTask(id: UUID(), title: "sample_task_3".localized, isCompleted: true, order: 2)
            ],
            repeatType: .weekly,
            completions: [Date(), Date().addingTimeInterval(-86400 * 7)],
            tags: [
                Tag(name: "work".localized, icon: "briefcase", color: "#FF6B6B"),
                Tag(name: "personal".localized, icon: "heart", color: "#4ECDC4"),
                Tag(name: "urgent".localized, icon: "exclamationmark.triangle", color: "#FFB347")
            ]
        ),
        date: Date(),
        questDataService: QuestCoreDataService()
    )
    .environmentObject(ThemeManager.shared)
}
