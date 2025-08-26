//
//  RewardTypes.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 6.08.2025.
//

import SwiftUI

// MARK: - Reward Types

enum RewardType: String, Codable {
    case quest
    case task
    
    var icon: String {
        switch self {
        case .quest: return "flag.fill"
        case .task: return "checkmark.circle.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .quest: return .blue
        case .task: return .green
        }
    }
}

// MARK: - Completion Tracking

struct CompletionRecord: Codable {
    let id: UUID
    let questId: UUID
    let taskId: UUID?
    let completionDate: Date
    let rewardType: RewardType
    
    init(questId: UUID, taskId: UUID? = nil, rewardType: RewardType) {
        self.id = UUID()
        self.questId = questId
        self.taskId = taskId
        self.completionDate = Date()
        self.rewardType = rewardType
    }
}

class CompletionTracker {
    static let shared = CompletionTracker()
    
    private let userDefaults = UserDefaults.standard
    private let completionRecordsKey = "completionRecords"
    private let cooldownPeriod: TimeInterval = 60 // 1 minute cooldown
    
    private init() {}
    
    // MARK: - Quest Completion Tracking
    
    func canCompleteQuest(_ questId: UUID) -> Bool {
        let records = getCompletionRecords()
        let recentRecords = records.filter { record in
            record.questId == questId &&
            record.taskId == nil && // Quest completion (not task)
            Date().timeIntervalSince(record.completionDate) < cooldownPeriod
        }
        
        return recentRecords.isEmpty
    }
    
    func recordQuestCompletion(_ questId: UUID) {
        let record = CompletionRecord(questId: questId, rewardType: .quest)
        var records = getCompletionRecords()
        records.append(record)
        saveCompletionRecords(records)
    }
    
    // MARK: - Task Completion Tracking
    
    func canCompleteTask(_ taskId: UUID, questId: UUID) -> Bool {
        let records = getCompletionRecords()
        let recentRecords = records.filter { record in
            record.taskId == taskId &&
            record.questId == questId &&
            Date().timeIntervalSince(record.completionDate) < cooldownPeriod
        }
        
        return recentRecords.isEmpty
    }
    
    func recordTaskCompletion(_ taskId: UUID, questId: UUID) {
        let record = CompletionRecord(questId: questId, taskId: taskId, rewardType: .task)
        var records = getCompletionRecords()
        records.append(record)
        saveCompletionRecords(records)
    }
    
    // MARK: - Cleanup
    
    func cleanupOldRecords() {
        let records = getCompletionRecords()
        let cutoffDate = Date().addingTimeInterval(-cooldownPeriod)
        let validRecords = records.filter { $0.completionDate > cutoffDate }
        saveCompletionRecords(validRecords)
    }
    
    // MARK: - Public Methods
    
    func getCompletionRecords() -> [CompletionRecord] {
        guard let data = userDefaults.data(forKey: completionRecordsKey),
              let records = try? JSONDecoder().decode([CompletionRecord].self, from: data) else {
            return []
        }
        return records
    }
    
    // MARK: - Private Methods
    
    private func saveCompletionRecords(_ records: [CompletionRecord]) {
        if let data = try? JSONEncoder().encode(records) {
            userDefaults.set(data, forKey: completionRecordsKey)
        }
    }
}
