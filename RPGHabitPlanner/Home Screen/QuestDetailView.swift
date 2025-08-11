//
//  QuestDetailView.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 11.11.2024.
//

import SwiftUI

struct QuestDetailView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: CalendarViewModel

    // Inputs
    let date: Date

    // Local, editable copy of the quest
    @State private var currentQuest: Quest

    // UI state
    @State private var uiIsCompleted: Bool        // <- optimistic UI flag
    @State private var editingQuest: Quest?
    @State private var showingDeleteAlert = false

    private let calendar = Calendar.current
    private var theme: Theme { themeManager.activeTheme }

    // Custom init to seed the local copies
    init(viewModel: CalendarViewModel, quest: Quest, date: Date) {
        self.viewModel = viewModel
        self.date = date
        _currentQuest = State(initialValue: quest)
        _uiIsCompleted = State(initialValue: quest.isCompleted(on: date))
    }

    var body: some View {
        ZStack {
            theme.backgroundColor.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    // Header Section
                    QuestDetailHeaderSection(quest: currentQuest, theme: theme)

                    // Progress Section
                    QuestDetailProgressSection(quest: currentQuest, theme: theme)

                    // Details Section
                    QuestDetailDetailsSection(quest: currentQuest, theme: theme)

                    // Tasks Section
                    if !currentQuest.tasks.isEmpty {
                        QuestDetailTasksSection(
                            quest: currentQuest,
                            theme: theme,
                            onToggleTask: toggleTaskCompletion
                        )
                    }

                    // Completion History
                    QuestDetailCompletionHistorySection(quest: currentQuest, theme: theme)

                    // Action Buttons
                    QuestDetailActionButtonsSection(
                        quest: currentQuest,
                        isCompleted: uiIsCompleted,                  // use optimistic state
                        onToggleCompletion: toggleQuestCompletion,
                        onMarkAsFinished: markAsFinished
                    )
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 40)
            }
        }
        .navigationTitle("Quest Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Close") { dismiss() }
                    .foregroundColor(theme.textColor)
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button("Edit Quest") {
                        editingQuest = currentQuest // pass a snapshot into the editor
                    }
                    Button("Delete Quest", role: .destructive) {
                        showingDeleteAlert = true
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundColor(theme.textColor)
                }
            }
        }
        // Present editor; on save, refresh global + local
        .sheet(item: $editingQuest, onDismiss: refreshCurrentQuestFromStore) { questToEdit in
            EditQuestView(
                viewModel: EditQuestViewModel(
                    quest: questToEdit,
                    questDataService: viewModel.questDataService
                )
            ) {
                    viewModel.fetchQuests()
                    refreshCurrentQuestFromStore()
            }
            .environmentObject(themeManager)
        }
        .alert("Delete Quest", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                deleteQuest()
            }
        } message: {
            Text("Are you sure you want to delete this quest? This action cannot be undone.")
        }
        // If the backing store changes (e.g., from calendar list), keep detail in sync
        .onReceive(viewModel.$allQuests) { _ in
            refreshCurrentQuestFromStore()
        }
    }

    // MARK: - Helper Methods

    private func refreshCurrentQuestFromStore() {
        if let updated = viewModel.allQuests.first(where: { $0.id == currentQuest.id }) {
            currentQuest = updated
            uiIsCompleted = updated.isCompleted(on: date) // keep UI honest
        }
    }

    private func toggleQuestCompletion() {
        uiIsCompleted.toggle()
        if let item = viewModel.items(for: date).first(where: { $0.quest.id == currentQuest.id }) {
            viewModel.toggle(item: item)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                refreshCurrentQuestFromStore()
            }
        }
    }

    private func toggleTaskCompletion(_ task: QuestTask) {
        viewModel.toggleTaskCompletion(
            questId: currentQuest.id,
            taskId: task.id,
            newValue: !task.isCompleted
        )
        refreshCurrentQuestFromStore()
    }

    private func markAsFinished() {
        // Optimistic → completed
        uiIsCompleted = true
        viewModel.markQuestAsFinished(questId: currentQuest.id)
        refreshCurrentQuestFromStore()
    }

    private func deleteQuest() {
        viewModel.questDataService.deleteQuest(withId: currentQuest.id) { [weak viewModel] _ in
            DispatchQueue.main.async {
                viewModel?.fetchQuests()
                dismiss()
            }
        }
    }

    // MARK: - Computed

    private var isCompletedReal: Bool {
        currentQuest.isCompleted(on: date)
    }
}

#Preview {
    QuestDetailView(
        viewModel: CalendarViewModel(questDataService: QuestCoreDataService()),
        quest: Quest(
            title: "Sample Quest",
            isMainQuest: true,
            info: "This is a sample quest description that shows how the detail view looks with some content.",
            difficulty: 4,
            creationDate: Date(),
            dueDate: Date().addingTimeInterval(86400 * 7),
            isActive: true,
            progress: 75,
            tasks: [
                QuestTask(id: UUID(), title: "Task 1", isCompleted: true, order: 0),
                QuestTask(id: UUID(), title: "Task 2", isCompleted: false, order: 1),
                QuestTask(id: UUID(), title: "Task 3", isCompleted: true, order: 2)
            ],
            repeatType: .weekly,
            completions: [Date(), Date().addingTimeInterval(-86400 * 7)]
        ),
        date: Date()
    )
    .environmentObject(ThemeManager.shared)
}
