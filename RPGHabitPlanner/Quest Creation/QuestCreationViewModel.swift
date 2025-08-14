//
//  QuestCreationViewModel.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 28.10.2024.
//

import Foundation
import SwiftUI
import Combine
import UserNotifications

final class QuestCreationViewModel: ObservableObject {
    private let questDataService: QuestDataServiceProtocol
    private let premiumManager = PremiumManager.shared

    @Published var didSaveQuest = false
    @Published var errorMessage: String?
    @Published var isSaving = false
    @Published var questTitle: String = ""
    @Published var questDescription: String = ""
    @Published var questDueDate = Date()
    @Published var isMainQuest: Bool = true
    @Published var difficulty: Int = 3
    @Published var isActiveQuest: Bool = true
    @Published var tasks: [String] = []
    @Published var selectedTags: [Tag] = []
    @Published var notifyMe = true
    @Published var repeatType: QuestRepeatType = .oneTime
    @Published var currentQuestCount: Int = 0
    @Published var shouldShowPaywall = false

    init(questDataService: QuestDataServiceProtocol) {
        self.questDataService = questDataService
        fetchCurrentQuestCount()
    }

    func validateInputs() -> Bool {
        if questTitle.isEmpty {
            errorMessage = "Quest title cannot be empty."
            return false
        }
        return true
    }

    @MainActor
    func saveQuest() {
        guard validateInputs() else { return }

        // Check premium status before saving
        if !premiumManager.canCreateQuest(currentQuestCount: currentQuestCount) {
            shouldShowPaywall = true
            return
        }

        isSaving = true

        let newQuest = Quest(
            title: questTitle,
            isMainQuest: isMainQuest,
            info: questDescription,
            difficulty: difficulty,
            creationDate: Date(),
            dueDate: questDueDate,
            isActive: isActiveQuest,
            progress: 0,
            isCompleted: false,
            completionDate: nil,
            repeatType: repeatType,
            tags: Set(selectedTags)
        )

        let taskTitles = tasks
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }

        questDataService.saveQuest(newQuest, withTasks: taskTitles) { [weak self] error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isSaving = false

                if let error {
                    self.errorMessage = error.localizedDescription
                    self.didSaveQuest = false
                } else {
                    if self.notifyMe {
                        NotificationManager.shared.handleNotificationForQuest(newQuest, enabled: true)
                    }
                    self.didSaveQuest = true
                    // Update quest count
                    self.fetchCurrentQuestCount()
                    // Notify other views that a new quest was created
                    NotificationCenter.default.post(name: .questCreated, object: newQuest)
                }
            }
        }
    }

    func resetInputs() {
        questTitle = ""
        questDescription = ""
        questDueDate = Date()
        isMainQuest = false
        difficulty = 3
        isActiveQuest = false
        repeatType = .oneTime
        notifyMe = true
        selectedTags = []
    }

    // MARK: - Premium Methods

    private func fetchCurrentQuestCount() {
        questDataService.fetchAllQuests { [weak self] quests, _ in
            DispatchQueue.main.async {
                self?.currentQuestCount = quests.count
                self?.shouldShowPaywall = self?.premiumManager.shouldShowPaywall(currentQuestCount: quests.count) ?? false
            }
        }
    }

    @MainActor
    func checkPremiumStatus() {
        shouldShowPaywall = premiumManager.shouldShowPaywall(currentQuestCount: currentQuestCount)
    }
}
