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
    
    init(questDataService: QuestDataServiceProtocol) {
        self.questDataService = questDataService
    }
    
    func saveQuest(title: String, isMainQuest: Bool, info: String, difficulty: Int, dueDate: Date, isActive: Bool) {
        let newQuest = Quest(
            title: title,
            isMainQuest: isMainQuest,
            info: info,
            difficulty: difficulty,
            creationDate: Date(),
            dueDate: dueDate,
            isActive: isActive
        )
        
        
        questDataService.saveQuest(newQuest) { [weak self] error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    self?.didSaveQuest = false
                } else {
                    self?.didSaveQuest = true
                }
            }
        }
    }
}
