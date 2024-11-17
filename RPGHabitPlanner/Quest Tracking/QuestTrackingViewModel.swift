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
    @Published var selectedTab: QuestTab = .main // Moved from View
    @Published var selectedStatus: QuestStatusFilter = .active
    
    private let questDataService: QuestDataServiceProtocol
    private let userManager: UserManager
    
    init(questDataService: QuestDataServiceProtocol, userManager: UserManager) {
        self.questDataService = questDataService
        self.userManager = userManager
        fetchQuests()
    }
    
    func fetchQuests() {
        questDataService.fetchNonCompletedQuests { [weak self] quests, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                } else {
                    self?.quests = quests.reversed()
                }
            }
        }
    }

    func markQuestAsCompleted(id: UUID) {
        guard let quest = quests.first(where: { $0.id == id }) else { return }
        
        questDataService.updateQuestCompletion(forId: id, to: true) { [weak self] error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                } else {
                    self?.userManager.updateUserExperience(additionalExp: Int16(10 * quest.difficulty)) { expError in
                        if let expError = expError {
                            self?.errorMessage = expError.localizedDescription
                        } else {
                            self?.fetchQuests()
                        }
                    }
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
