import Foundation
import CoreData
import SwiftUI

final class HealthManager: ObservableObject {
    static let shared = HealthManager()
    private let persistentContainer: NSPersistentContainer
    
    @Published var currentHealth: Int16 = 50
    @Published var maxHealth: Int16 = 50
    @Published var isLowHealth: Bool = false
    @Published var showDamageAnimation: Bool = false
    @Published var showHealAnimation: Bool = false
    
    private init(container: NSPersistentContainer = PersistenceController.shared.container) {
        self.persistentContainer = container
        loadHealthData()
    }
    
    // MARK: - Health Management
    
    func loadHealthData() {
        fetchUser { user, error in
            if let user = user, error == nil {
                DispatchQueue.main.async {
                    self.currentHealth = user.health
                    self.maxHealth = user.maxHealth
                    self.updateLowHealthStatus()
                }
            }
        }
    }
    
    func takeDamage(_ amount: Int16, completion: @escaping (Error?) -> Void = { _ in }) {
        fetchUser { user, error in
            guard let user = user, error == nil else {
                completion(error ?? NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "User not found"]))
                return
            }
            
            let context = self.persistentContainer.viewContext
            let newHealth = max(0, user.health - amount)
            user.health = newHealth
            
            do {
                try context.save()
                DispatchQueue.main.async {
                    self.currentHealth = newHealth
                    self.updateLowHealthStatus()
                    self.triggerDamageAnimation()
                }
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
    
    func heal(_ amount: Int16, completion: @escaping (Error?) -> Void = { _ in }) {
        fetchUser { user, error in
            guard let user = user, error == nil else {
                completion(error ?? NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "User not found"]))
                return
            }
            
            let context = self.persistentContainer.viewContext
            let newHealth = min(user.maxHealth, user.health + amount)
            user.health = newHealth
            
            do {
                try context.save()
                DispatchQueue.main.async {
                    self.currentHealth = newHealth
                    self.updateLowHealthStatus()
                    self.triggerHealAnimation()
                }
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
    
    func restoreFullHealth(completion: @escaping (Error?) -> Void = { _ in }) {
        fetchUser { user, error in
            guard let user = user, error == nil else {
                completion(error ?? NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "User not found"]))
                return
            }
            
            let context = self.persistentContainer.viewContext
            user.health = user.maxHealth
            
            do {
                try context.save()
                DispatchQueue.main.async {
                    self.currentHealth = user.maxHealth
                    self.updateLowHealthStatus()
                    self.triggerHealAnimation()
                }
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
    
    func increaseMaxHealth(_ amount: Int16, completion: @escaping (Error?) -> Void = { _ in }) {
        fetchUser { user, error in
            guard let user = user, error == nil else {
                completion(error ?? NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "User not found"]))
                return
            }
            
            let context = self.persistentContainer.viewContext
            let newMaxHealth = user.maxHealth + amount
            user.maxHealth = newMaxHealth
            // Also increase current health by the same amount
            user.health = min(newMaxHealth, user.health + amount)
            
            do {
                try context.save()
                DispatchQueue.main.async {
                    self.maxHealth = newMaxHealth
                    self.currentHealth = user.health
                    self.updateLowHealthStatus()
                    self.triggerHealAnimation()
                }
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
    
    // MARK: - Quest Failure Damage
    
    func handleQuestFailure(questDifficulty: Int, completion: @escaping (Error?) -> Void = { _ in }) {
        // Calculate damage based on quest difficulty (1-5)
        // Higher difficulty quests cause more damage when failed
        let damageAmount = Int16(questDifficulty * 2) // 2, 4, 6, 8, 10 damage
        
        takeDamage(damageAmount) { error in
            if error == nil {
                // Post notification for UI updates
                NotificationCenter.default.post(name: .questFailed, object: nil, userInfo: ["damage": damageAmount])
            }
            completion(error)
        }
    }
    
    // MARK: - Health Status
    
    private func updateLowHealthStatus() {
        let healthPercentage = Double(currentHealth) / Double(maxHealth)
        isLowHealth = healthPercentage <= 0.3 // 30% or less is considered low health
    }
    
    func getHealthPercentage() -> Double {
        return Double(currentHealth) / Double(maxHealth)
    }
    
    func isDead() -> Bool {
        return currentHealth <= 0
    }
    
    // MARK: - Animations
    
    private func triggerDamageAnimation() {
        showDamageAnimation = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.showDamageAnimation = false
        }
    }
    
    private func triggerHealAnimation() {
        showHealAnimation = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.showHealAnimation = false
        }
    }
    
    // MARK: - Private Methods
    
    private func fetchUser(completion: @escaping (UserEntity?, Error?) -> Void) {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        
        do {
            let users = try context.fetch(fetchRequest)
            completion(users.first, nil)
        } catch {
            completion(nil, error)
        }
    }
}

// MARK: - Notifications

extension Notification.Name {
    static let questFailed = Notification.Name("questFailed")
    static let healthChanged = Notification.Name("healthChanged")
}
