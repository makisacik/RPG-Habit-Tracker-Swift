//
//  EditQuestViewModel.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 2.08.2025.
//

import Foundation
import SwiftUI
import Combine

final class EditQuestViewModel: ObservableObject {
    @Published var quest: Quest
    @Published var title: String
    @Published var description: String
    @Published var dueDate: Date
    @Published var isMainQuest: Bool
    @Published var difficulty: Int
    @Published var isActiveQuest: Bool
    @Published var progress: Int
    @Published var isSaving: Bool = false
    @Published var errorMessage: String?
    @Published var didUpdateQuest: Bool = false
    @Published var repeatType: QuestRepeatType
    @Published var repeatIntervalWeeks: Int?
    
    private let questDataService: QuestDataServiceProtocol

    init(quest: Quest, questDataService: QuestDataServiceProtocol) {
        self.quest = quest
        self.title = quest.title
        self.description = quest.info
        self.dueDate = quest.dueDate
        self.isMainQuest = quest.isMainQuest
        self.difficulty = quest.difficulty
        self.isActiveQuest = quest.isActive
        self.progress = quest.progress
        self.repeatType = quest.repeatType
        self.repeatIntervalWeeks = quest.repeatIntervalWeeks
        self.questDataService = questDataService
    }

    func validateInputs() -> Bool {
        guard !title.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "Quest title cannot be empty."
            return false
        }
        guard difficulty >= 1 && difficulty <= 5 else {
            errorMessage = "Difficulty must be between 1 and 5."
            return false
        }
        return true
    }

    func updateQuest(completion: @escaping (Bool) -> Void) {
        isSaving = true
        print(quest.repeatType)
        print(quest.repeatIntervalWeeks)
        let dueDateChanged = quest.dueDate != dueDate
        print("dueDateChanged", dueDateChanged)
        questDataService.updateQuest(
            withId: quest.id,
            title: title,
            isMainQuest: isMainQuest,
            info: description,
            difficulty: difficulty,
            dueDate: dueDate,
            isActive: isActiveQuest,
            progress: progress,
            repeatType: repeatType,
            repeatIntervalWeeks: repeatIntervalWeeks
        ) { [weak self] error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isSaving = false

                if let error = error {
                    self.errorMessage = error.localizedDescription
                    completion(false)
                } else {
                    self.quest.title = self.title
                    self.quest.info = self.description
                    self.quest.dueDate = self.dueDate
                    self.quest.isMainQuest = self.isMainQuest
                    self.quest.difficulty = self.difficulty
                    self.quest.isActive = self.isActiveQuest
                    self.quest.progress = self.progress

                    if dueDateChanged {
                        NotificationManager.shared.cancelQuestNotifications(questId: self.quest.id)
                        NotificationManager.shared.scheduleQuestNotification(for: self.quest)
                    }


                    self.didUpdateQuest = true
                    completion(true)
                }
            }
        }
    }
}
