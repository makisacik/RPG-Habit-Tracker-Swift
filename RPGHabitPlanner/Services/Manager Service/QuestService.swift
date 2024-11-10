//
//  QuestService.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 30.10.2024.
//

import Foundation

final class QuestService {
    let questPersistence: QuestDataServiceProtocol
    let questCloudClient: QuestDataServiceProtocol
    
    init(questPersistence: QuestDataServiceProtocol, questCloudClient: QuestDataServiceProtocol) {
        self.questPersistence = questPersistence
        self.questCloudClient = questCloudClient
    }
}
