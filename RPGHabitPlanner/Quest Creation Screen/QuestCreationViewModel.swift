//
//  QuestCreationViewModel.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 28.10.2024.
//

import Foundation

final class QuestCreationViewModel: ObservableObject {
    private let questDataService: QuestDataServiceProtocol
    
    init(questDataService: QuestDataServiceProtocol) {
        self.questDataService = questDataService
    }
    
    func createQuest(title: String, isMainQuest: Bool, info: String, difficulty: Int, creationDate: Date, dueDate: Date, completion: @escaping (Error?) -> Void) {
        let newQuest = Quest(
            title: title,
            isMainQuest: isMainQuest,
            info: info,
            difficulty: difficulty,
            creationDate: creationDate,
            dueDate: dueDate
        )
        
        questDataService.saveQuest(newQuest) { error in
            DispatchQueue.main.async {
                completion(error)
            }
        }
    }
}
