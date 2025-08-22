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
    @Published var isDead: Bool = false

    private init(container: NSPersistentContainer = PersistenceController.shared.container) {
        self.persistentContainer = container
        loadHealthData()
    }

    // MARK: - Health Management

    func loadHealthData() {
        fetchUser { [weak self] user, error in
            guard let self = self else { return }

            if let user = user, error == nil {
                DispatchQueue.main.async {
                    self.currentHealth = user.health
                    self.maxHealth = user.maxHealth
                    self.updateHealthStatus()
                }
            } else {
                print("❌ Error loading health data: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }

    func takeDamage(_ amount: Int16, completion: @escaping (Error?) -> Void = { _ in }) {
        guard amount > 0 else {
            completion(HealthError.invalidDamageAmount)
            return
        }

        fetchUser { [weak self] user, error in
            guard let self = self else { return }

            guard let user = user, error == nil else {
                completion(error ?? HealthError.userNotFound)
                return
            }

            let context = self.persistentContainer.viewContext
            let newHealth = max(0, user.health - amount)
            user.health = newHealth

            do {
                try context.save()
                DispatchQueue.main.async {
                    self.currentHealth = newHealth
                    self.updateHealthStatus()
                    self.triggerDamageAnimation()
                }
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }

    func heal(_ amount: Int16, completion: @escaping (Error?) -> Void = { _ in }) {
        guard amount > 0 else {
            completion(HealthError.invalidHealAmount)
            return
        }

        fetchUser { [weak self] user, error in
            guard let self = self else { return }

            guard let user = user, error == nil else {
                completion(error ?? HealthError.userNotFound)
                return
            }

            let context = self.persistentContainer.viewContext
            let newHealth = min(user.maxHealth, user.health + amount)
            user.health = newHealth

            do {
                try context.save()
                DispatchQueue.main.async {
                    self.currentHealth = newHealth
                    self.updateHealthStatus()
                    self.triggerHealAnimation()
                }
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }

    func restoreFullHealth(completion: @escaping (Error?) -> Void = { _ in }) {
        fetchUser { [weak self] user, error in
            guard let self = self else { return }

            guard let user = user, error == nil else {
                completion(error ?? HealthError.userNotFound)
                return
            }

            let context = self.persistentContainer.viewContext
            user.health = user.maxHealth

            do {
                try context.save()
                DispatchQueue.main.async {
                    self.currentHealth = user.maxHealth
                    self.updateHealthStatus()
                    self.triggerHealAnimation()
                }
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }

    func increaseMaxHealth(_ amount: Int16, completion: @escaping (Error?) -> Void = { _ in }) {
        guard amount > 0 else {
            completion(HealthError.invalidMaxHealthAmount)
            return
        }

        fetchUser { [weak self] user, error in
            guard let self = self else { return }

            guard let user = user, error == nil else {
                completion(error ?? HealthError.userNotFound)
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
                    self.updateHealthStatus()
                    self.triggerHealAnimation()
                }
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }

    func setHealth(_ health: Int16, completion: @escaping (Error?) -> Void = { _ in }) {
        guard health >= 0 else {
            completion(HealthError.invalidHealthAmount)
            return
        }

        fetchUser { [weak self] user, error in
            guard let self = self else { return }

            guard let user = user, error == nil else {
                completion(error ?? HealthError.userNotFound)
                return
            }

            let context = self.persistentContainer.viewContext
            let clampedHealth = min(user.maxHealth, health)
            user.health = clampedHealth

            do {
                try context.save()
                DispatchQueue.main.async {
                    self.currentHealth = clampedHealth
                    self.updateHealthStatus()
                    if clampedHealth > health {
                        self.triggerHealAnimation()
                    } else if clampedHealth < health {
                        self.triggerDamageAnimation()
                    }
                }
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }

    // MARK: - Quest Failure Damage

    func handleQuestFailure(questDifficulty: Int, completion: @escaping (Error?) -> Void = { _ in }) {
        guard questDifficulty >= 1 && questDifficulty <= 5 else {
            completion(HealthError.invalidQuestDifficulty)
            return
        }

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

    private func updateHealthStatus() {
        let healthPercentage = Double(currentHealth) / Double(maxHealth)
        isLowHealth = healthPercentage <= 0.3 // 30% or less is considered low health
        isDead = currentHealth <= 0
    }

    func getHealthPercentage() -> Double {
        return Double(currentHealth) / Double(maxHealth)
    }

    func getHealthStatus() -> HealthStatus {
        let percentage = getHealthPercentage()

        switch percentage {
        case 0.0:
            return .dead
        case 0.0..<0.3:
            return .critical
        case 0.3..<0.6:
            return .low
        case 0.6..<1.0:
            return .moderate
        case 1.0:
            return .full
        default:
            return .unknown
        }
    }

    func canTakeDamage() -> Bool {
        return !isDead
    }

    func canHeal() -> Bool {
        return currentHealth < maxHealth
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

// MARK: - Health Status Enum

enum HealthStatus {
    case dead
    case critical
    case low
    case moderate
    case full
    case unknown

    var description: String {
        switch self {
        case .dead:
            return "Dead"
        case .critical:
            return "Critical"
        case .low:
            return "Low"
        case .moderate:
            return "Moderate"
        case .full:
            return "Full"
        case .unknown:
            return "Unknown"
        }
    }

    var color: Color {
        switch self {
        case .dead:
            return .black
        case .critical:
            return .red
        case .low:
            return .orange
        case .moderate:
            return .yellow
        case .full:
            return .green
        case .unknown:
            return .gray
        }
    }
}

// MARK: - Health Errors

enum HealthError: LocalizedError {
    case userNotFound
    case invalidDamageAmount
    case invalidHealAmount
    case invalidMaxHealthAmount
    case invalidHealthAmount
    case invalidQuestDifficulty
    case healthAtMaximum
    case healthAtMinimum

    var errorDescription: String? {
        switch self {
        case .userNotFound:
            return "User not found"
        case .invalidDamageAmount:
            return "Invalid damage amount"
        case .invalidHealAmount:
            return "Invalid heal amount"
        case .invalidMaxHealthAmount:
            return "Invalid max health amount"
        case .invalidHealthAmount:
            return "Invalid health amount"
        case .invalidQuestDifficulty:
            return "Invalid quest difficulty"
        case .healthAtMaximum:
            return "Health is already at maximum"
        case .healthAtMinimum:
            return "Health is already at minimum"
        }
    }
}

// MARK: - Notifications

extension Notification.Name {
    static let questFailed = Notification.Name("questFailed")
    static let healthChanged = Notification.Name("healthChanged")
}
