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
    
    let quest: Quest
    let date: Date
    
    @State private var showingEditQuest = false
    @State private var showingDeleteAlert = false
    
    private let calendar = Calendar.current
    
    var body: some View {
        let theme = themeManager.activeTheme
        
        NavigationStack {
            ZStack {
                theme.backgroundColor.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header Section
                        QuestDetailHeaderSection(quest: quest, theme: theme)
                        
                        // Progress Section
                        QuestDetailProgressSection(quest: quest, theme: theme)
                        
                        // Details Section
                        QuestDetailDetailsSection(quest: quest, theme: theme)
                        
                        // Tasks Section
                        if !quest.tasks.isEmpty {
                            QuestDetailTasksSection(
                                quest: quest,
                                theme: theme,
                                onToggleTask: toggleTaskCompletion
                            )
                        }
                        
                        // Completion History
                        QuestDetailCompletionHistorySection(quest: quest, theme: theme)
                        
                        // Action Buttons
                        QuestDetailActionButtonsSection(
                            quest: quest,
                            isCompleted: isCompleted,
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
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                    .foregroundColor(theme.textColor)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button("Edit Quest") {
                            showingEditQuest = true
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
            .sheet(isPresented: $showingEditQuest) {
                // TODO: Add EditQuestView here
                Text("Edit Quest View")
            }
            .alert("Delete Quest", isPresented: $showingDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    deleteQuest()
                }
            } message: {
                Text("Are you sure you want to delete this quest? This action cannot be undone.")
            }
        }
    }
    
    // MARK: - Helper Methods
    private func toggleQuestCompletion() {
        // Find the DayQuestItem for this quest and date
        if let item = viewModel.items(for: date).first(where: { $0.quest.id == quest.id }) {
            viewModel.toggle(item: item)
        }
    }
    
    private func toggleTaskCompletion(_ task: QuestTask) {
        viewModel.toggleTaskCompletion(questId: quest.id, taskId: task.id, newValue: !task.isCompleted)
    }
    
    private func markAsFinished() {
        viewModel.markQuestAsFinished(questId: quest.id)
    }
    
    private func deleteQuest() {
        viewModel.questDataService.deleteQuest(withId: quest.id) { [weak viewModel] _ in
            DispatchQueue.main.async {
                viewModel?.fetchQuests()
                dismiss()
            }
        }
    }
    
    // MARK: - Computed Properties
    private var isCompleted: Bool {
        quest.isCompleted(on: date)
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
