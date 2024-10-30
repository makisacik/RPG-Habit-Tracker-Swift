//
//  QuestService.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 30.10.2024.
//

import Foundation

final class QuestService {
    let questPersistence: QuestDataService
    let questCloudClient: QuestDataService
    
    init(questPersistence: QuestDataService, questCloudClient: QuestDataService) {
        self.questPersistence = questPersistence
        self.questCloudClient = questCloudClient
    }
    
}
