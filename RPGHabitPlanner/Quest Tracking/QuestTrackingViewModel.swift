//
//  QuestTrackingViewModel.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 10.11.2024.
//

import SwiftUI
import Combine

enum QuestStatusFilter: String, CaseIterable {
    case all
    case active
    case inactive
}

final class QuestTrackingViewModel: ObservableObject {
    @Published var quests: [Quest] = []
    @Published var errorMessage: String?
    @Published var selectedStatus: QuestStatusFilter = .active
    
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
    
    var mainQuests: [Quest] {
        filteredQuests(for: quests.filter { $0.isMainQuest })
    }
    
    var sideQuests: [Quest] {
        filteredQuests(for: quests.filter { !$0.isMainQuest })
    }
    
    private func filteredQuests(for quests: [Quest]) -> [Quest] {
        switch selectedStatus {
        case .all:
            return quests
        case .active:
            return quests.filter { $0.isActive }
        case .inactive:
            return quests.filter { !$0.isActive }
        }
    }
}
