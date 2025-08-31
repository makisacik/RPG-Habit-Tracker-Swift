//
//  QuestDamageTrackingManager.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 6.08.2025.
//

import Foundation
import Combine

final class QuestDamageTrackingManager: ObservableObject {
    static let shared = QuestDamageTrackingManager()
    
    private let damageTrackingService: QuestDamageTrackingService
    private let questDataService: QuestDataServiceProtocol
    private let healthManager: HealthManager
    
    @Published var isCalculatingDamage = false
    @Published var lastDamageCalculationDate: Date?
    @Published var totalDamageTakenToday: Int = 0
    
    private var cancellables = Set<AnyCancellable>()
    
    private init(
        damageTrackingService: QuestDamageTrackingService = .shared,
        questDataService: QuestDataServiceProtocol = QuestCoreDataService(),
        healthManager: HealthManager = .shared
    ) {
        self.damageTrackingService = damageTrackingService
        self.questDataService = questDataService
        self.healthManager = healthManager
        
        setupNotifications()
    }
    
    // MARK: - Public Interface
    
    /// Calculate damage for all active quests and apply it to the player's health
    func calculateAndApplyQuestDamage(completion: @escaping (Int, Error?) -> Void) {
        guard !isCalculatingDamage else {
            completion(0, NSError(domain: "", code: 409, userInfo: [NSLocalizedDescriptionKey: "Damage calculation already in progress"]))
            return
        }
        
        isCalculatingDamage = true
        var totalDamage = 0
        var calculationErrors: [Error] = []
        
        // Get all active quests
        questDataService.fetchAllQuests { [weak self] quests, error in
            guard let self = self else { return }
            
            if let error = error {
                DispatchQueue.main.async {
                    self.isCalculatingDamage = false
                    completion(0, error)
                }
                return
            }
            
            let activeQuests = quests.filter { $0.isActive && !$0.isCompleted }
            
            if activeQuests.isEmpty {
                DispatchQueue.main.async {
                    self.isCalculatingDamage = false
                    self.lastDamageCalculationDate = Date()
                    completion(0, nil)
                }
                return
            }
            
            let group = DispatchGroup()
            
            for quest in activeQuests {
                group.enter()
                
                self.calculateDamageForQuest(quest) { damageAmount, error in
                    if let error = error {
                        calculationErrors.append(error)
                    } else {
                        totalDamage += damageAmount
                    }
                    group.leave()
                }
            }
            
            group.notify(queue: .main) { [weak self] in
                guard let self = self else { return }
                
                // Apply damage cap and total damage to player health
                let cappedDamage = min(totalDamage, QuestDamageConstants.maxDamagePerSession)
                if cappedDamage > 0 {
                    self.healthManager.takeDamage(Int16(cappedDamage)) { error in
                        DispatchQueue.main.async {
                            self.isCalculatingDamage = false
                            self.lastDamageCalculationDate = Date()
                            self.totalDamageTakenToday += totalDamage
                            
                            if let error = error {
                                calculationErrors.append(error)
                            }
                            
                            let finalError = calculationErrors.isEmpty ? nil : calculationErrors.first
                            completion(cappedDamage, finalError)
                        }
                    }
                } else {
                    self.isCalculatingDamage = false
                    self.lastDamageCalculationDate = Date()
                    completion(0, calculationErrors.isEmpty ? nil : calculationErrors.first)
                }
            }
        }
    }
    
    /// Calculate damage for a specific quest
    func calculateDamageForQuest(_ quest: Quest, completion: @escaping (Int, Error?) -> Void) {
        // Get or create damage tracker for this quest
        damageTrackingService.fetchDamageTracker(for: quest.id) { [weak self] tracker, error in
            guard let self = self else { return }
            
            if let error = error {
                completion(0, error)
                return
            }
            
            let lastCheckDate: Date
            if let tracker = tracker {
                lastCheckDate = tracker.lastDamageCheckDate
            } else {
                // First time checking this quest, start from due date
                lastCheckDate = quest.dueDate
            }
            
            // Calculate damage based on quest type
            let calculator = self.getDamageCalculator(for: quest.repeatType)
            let result = calculator.calculateDamage(
                quest: quest,
                lastDamageCheckDate: lastCheckDate
            )
            
            // If there's damage to apply, update the tracker and record the event
            if result.damageAmount > 0 {
                self.updateDamageTrackerAndRecordEvent(
                    quest: quest,
                    tracker: tracker,
                    result: result,
                    completion: completion
                )
            } else {
                // No damage, but still update the last check date
                self.updateDamageTrackerLastCheckDate(
                    quest: quest,
                    tracker: tracker,
                    newLastCheckDate: result.newLastCheckDate,
                    completion: completion
                )
            }
        }
    }
    
    /// Get damage history for a specific quest
    func getDamageHistory(for questId: UUID, completion: @escaping ([DamageEvent], Error?) -> Void) {
        damageTrackingService.fetchDamageTracker(for: questId) { [weak self] tracker, error in
            guard let self = self else { return }
            
            if let error = error {
                completion([], error)
                return
            }
            
            guard let tracker = tracker else {
                completion([], nil)
                return
            }
            
            completion(tracker.damageHistory, nil)
        }
    }
    
    /// Get total damage taken for a specific quest
    func getTotalDamageForQuest(_ questId: UUID, completion: @escaping (Int, Error?) -> Void) {
        damageTrackingService.fetchDamageTracker(for: questId) { tracker, error in
            if let error = error {
                completion(0, error)
                return
            }
            
            let totalDamage = tracker?.totalDamageTaken ?? 0
            completion(totalDamage, nil)
        }
    }
    
    /// Deactivate damage tracking for a completed quest
    func deactivateDamageTracking(for questId: UUID, completion: @escaping (Error?) -> Void) {
        damageTrackingService.deactivateDamageTracker(for: questId, completion: completion)
    }
    
    /// Clean up damage tracking for finished quests
    func cleanupFinishedQuests(completion: @escaping (Error?) -> Void) {
        questDataService.fetchAllQuests { [weak self] quests, error in
            guard let self = self else { return }
            
            if let error = error {
                completion(error)
                return
            }
            
            let finishedQuestIds = quests
                .filter { $0.isFinished || !$0.isActive }
                .map { $0.id }
            
            let group = DispatchGroup()
            var errors: [Error] = []
            
            for questId in finishedQuestIds {
                group.enter()
                self.damageTrackingService.deactivateDamageTracker(for: questId) { error in
                    if let error = error {
                        errors.append(error)
                    }
                    group.leave()
                }
            }
            
            group.notify(queue: .main) {
                completion(errors.isEmpty ? nil : errors.first)
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func getDamageCalculator(for repeatType: QuestRepeatType) -> QuestTypeDamageCalculator {
        switch repeatType {
        case .daily:
            return .daily
        case .weekly:
            return .weekly
        case .oneTime:
            return .oneTime
        case .scheduled:
            return .scheduled
        }
    }
    
    private func updateDamageTrackerAndRecordEvent(
        quest: Quest,
        tracker: QuestDamageTracker?,
        result: DamageCalculationResult,
        completion: @escaping (Int, Error?) -> Void
    ) {
        let group = DispatchGroup()
        var errors: [Error] = []
        
        // Update or create damage tracker
        group.enter()
        let newTotalDamage = (tracker?.totalDamageTaken ?? 0) + result.damageAmount
        damageTrackingService.createOrUpdateDamageTracker(
            for: quest.id,
            lastDamageCheckDate: result.newLastCheckDate,
            totalDamageTaken: newTotalDamage
        ) { _, error in
            if let error = error {
                errors.append(error)
            }
            group.leave()
        }
        
        // Record damage event
        if let tracker = tracker {
            group.enter()
            damageTrackingService.addDamageEvent(
                to: tracker.id,
                damageAmount: result.damageAmount,
                reason: result.reason
            ) { error in
                if let error = error {
                    errors.append(error)
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            completion(result.damageAmount, errors.isEmpty ? nil : errors.first)
        }
    }
    
    private func updateDamageTrackerLastCheckDate(
        quest: Quest,
        tracker: QuestDamageTracker?,
        newLastCheckDate: Date,
        completion: @escaping (Int, Error?) -> Void
    ) {
        let totalDamage = tracker?.totalDamageTaken ?? 0
        damageTrackingService.createOrUpdateDamageTracker(
            for: quest.id,
            lastDamageCheckDate: newLastCheckDate,
            totalDamageTaken: totalDamage
        ) { _, error in
            completion(0, error)
        }
    }
    
    private func setupNotifications() {
        // Listen for quest completion to deactivate damage tracking
        NotificationCenter.default.publisher(for: .questCompleted)
            .sink { [weak self] notification in
                if let questId = notification.userInfo?["questId"] as? UUID {
                    self?.deactivateDamageTracking(for: questId) { _ in }
                }
            }
            .store(in: &cancellables)
        
        // Listen for quest failure to apply immediate damage
        NotificationCenter.default.publisher(for: .questFailed)
            .sink { [weak self] notification in
                if let questId = notification.userInfo?["questId"] as? UUID {
                    self?.questDataService.fetchQuestById(questId) { quest, _ in
                        if let quest = quest {
                            self?.calculateDamageForQuest(quest) { _, _ in }
                        }
                    }
                }
            }
            .store(in: &cancellables)
    }
}

// MARK: - Notifications

extension Notification.Name {
    static let questCompleted = Notification.Name("questCompleted")
    static let damageCalculated = Notification.Name("damageCalculated")
}
