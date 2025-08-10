//
//  CompletedQuestsViewModel.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 17.11.2024.
//

import Foundation
import Combine

final class CompletedQuestsViewModel: ObservableObject {
    @Published var completedQuests: [Quest] = []
    @Published var errorMessage: String?

    private let questDataService: QuestDataServiceProtocol

    init(questDataService: QuestDataServiceProtocol) {
        self.questDataService = questDataService
        fetchCompletedQuests()
    }

    func fetchCompletedQuests() {
        questDataService.fetchFinishedQuests { [weak self] quests, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                } else {
                    // Sort by finished date, most recent first
                    self?.completedQuests = quests.sorted {
                        ($0.isFinishedDate ?? $0.creationDate) > ($1.isFinishedDate ?? $1.creationDate)
                    }
                }
            }
        }
    }
}
