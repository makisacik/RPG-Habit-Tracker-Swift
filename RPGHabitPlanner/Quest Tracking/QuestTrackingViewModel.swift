//
//  QuestTrackingViewModel.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 10.11.2024.
//

import SwiftUI
import Combine

class QuestTrackingViewModel: ObservableObject {
    @Published var quests: [Quest] = []
    @Published var currentPage: Int = 0
    @Published var errorMessage: String?

    private let questDataService: QuestDataServiceProtocol
    
    init(questDataService: QuestDataServiceProtocol) {
        self.questDataService = questDataService
        fetchQuests()
    }
    
    func fetchQuests() {
        questDataService.fetchAllQuests { [weak self] quests, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                } else {
                    self?.quests = quests
                }
            }
        }
    }
    
    var displayedQuests: [Quest] {
        let start = currentPage * 2
        let end = min(start + 2, quests.count)
        return Array(quests[start..<end])
    }
    
    func nextPage() {
        if (currentPage + 1) * 2 < quests.count {
            currentPage += 1
        }
    }
    
    func previousPage() {
        if currentPage > 0 {
            currentPage -= 1
        }
    }
}
