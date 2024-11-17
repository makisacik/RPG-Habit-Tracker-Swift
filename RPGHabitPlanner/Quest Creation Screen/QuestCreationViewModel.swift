//
//  QuestCreationViewModel.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 28.10.2024.
//

import Foundation
import SwiftUI
import Combine

final class QuestCreationViewModel: ObservableObject {
    private let questDataService: QuestDataServiceProtocol

    @Published var didSaveQuest = false
    @Published var errorMessage: String?
    @Published var isSaving = false
    @Published var questTitle: String = ""
    @Published var questDescription: String = ""
    @Published var questDueDate = Date()
    @Published var isMainQuest: Bool = false
    @Published var difficulty: Int = 3
    @Published var isActiveQuest: Bool = true

    init(questDataService: QuestDataServiceProtocol) {
        self.questDataService = questDataService
    }

    func validateInputs() -> Bool {
        if questTitle.isEmpty {
            errorMessage = "Quest title cannot be empty."
            return false
        }
        return true
    }


    func saveQuest() {
        guard validateInputs() else { return }

        isSaving = true
        let newQuest = Quest(
            title: questTitle,
            isMainQuest: isMainQuest,
            info: questDescription,
            difficulty: difficulty,
            creationDate: Date(),
            dueDate: questDueDate,
            isActive: isActiveQuest
        )

        questDataService.saveQuest(newQuest) { [weak self] error in
            DispatchQueue.main.async {
                self?.isSaving = false
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    self?.didSaveQuest = false
                } else {
                    self?.didSaveQuest = true
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
    }
}
