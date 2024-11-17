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
        questDataService.fetchCompletedQuests { [weak self] quests, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                } else {
                    self?.completedQuests = quests.reversed()
                }
            }
        }
    }
}
