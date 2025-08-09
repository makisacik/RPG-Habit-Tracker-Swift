//
//  MonsterHPPersistenceService.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 6.08.2025.
//

import Foundation

final class MonsterHPPersistenceService {
    static let shared = MonsterHPPersistenceService()
    
    private let userDefaults = UserDefaults.standard
    private let monsterHPKey = "monster_hp_data"
    private let monsterLastDamageTimeKey = "monster_last_damage_time"
    private let monsterDefeatsKey = "monster_defeats_data"
    
    private init() {}
    
    // MARK: - Monster HP Persistence
    
    func saveMonsterHP(enemyType: EnemyType, currentHealth: Int) {
        var monsterHPData = loadAllMonsterHP()
        monsterHPData[enemyType.rawValue] = currentHealth
        userDefaults.set(monsterHPData, forKey: monsterHPKey)
    }
    
    func loadMonsterHP(enemyType: EnemyType) -> Int? {
        let monsterHPData = loadAllMonsterHP()
        return monsterHPData[enemyType.rawValue]
    }
    
    func loadAllMonsterHP() -> [String: Int] {
        return userDefaults.dictionary(forKey: monsterHPKey) as? [String: Int] ?? [:]
    }
    
    func clearMonsterHP(enemyType: EnemyType) {
        var monsterHPData = loadAllMonsterHP()
        monsterHPData.removeValue(forKey: enemyType.rawValue)
        userDefaults.set(monsterHPData, forKey: monsterHPKey)
    }
    
    func clearAllMonsterHP() {
        userDefaults.removeObject(forKey: monsterHPKey)
        userDefaults.removeObject(forKey: monsterLastDamageTimeKey)
    }
    
    // MARK: - Last Damage Time Persistence
    
    func saveLastDamageTime(_ date: Date) {
        userDefaults.set(date.timeIntervalSince1970, forKey: monsterLastDamageTimeKey)
    }
    
    func loadLastDamageTime() -> Date? {
        let timeInterval = userDefaults.double(forKey: monsterLastDamageTimeKey)
        return timeInterval > 0 ? Date(timeIntervalSince1970: timeInterval) : nil
    }
    
    // MARK: - Battle Session Persistence
    
    func saveBattleSession(_ battleSession: BattleSession) {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(battleSession)
            userDefaults.set(data, forKey: "battle_session_\(battleSession.id.uuidString)")
        } catch {
            print("Failed to save battle session: \(error)")
        }
    }
    
    func loadBattleSession(id: UUID) -> BattleSession? {
        let decoder = JSONDecoder()
        guard let data = userDefaults.data(forKey: "battle_session_\(id.uuidString)") else {
            return nil
        }
        
        do {
            return try decoder.decode(BattleSession.self, from: data)
        } catch {
            print("Failed to load battle session: \(error)")
            return nil
        }
    }
    
    func clearBattleSession(id: UUID) {
        userDefaults.removeObject(forKey: "battle_session_\(id.uuidString)")
    }
    
    // MARK: - Monster Defeats Tracking
    
    func incrementMonsterDefeats(enemyType: EnemyType) {
        var defeatsData = loadAllMonsterDefeats()
        defeatsData[enemyType.rawValue] = (defeatsData[enemyType.rawValue] ?? 0) + 1
        userDefaults.set(defeatsData, forKey: monsterDefeatsKey)
    }
    
    func getMonsterDefeats(enemyType: EnemyType) -> Int {
        let defeatsData = loadAllMonsterDefeats()
        return defeatsData[enemyType.rawValue] ?? 0
    }
    
    func loadAllMonsterDefeats() -> [String: Int] {
        return userDefaults.dictionary(forKey: monsterDefeatsKey) as? [String: Int] ?? [:]
    }
    
    func clearMonsterDefeats(enemyType: EnemyType) {
        var defeatsData = loadAllMonsterDefeats()
        defeatsData.removeValue(forKey: enemyType.rawValue)
        userDefaults.set(defeatsData, forKey: monsterDefeatsKey)
    }
    
    func clearAllMonsterDefeats() {
        userDefaults.removeObject(forKey: monsterDefeatsKey)
    }
}
