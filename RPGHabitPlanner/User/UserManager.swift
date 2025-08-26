//
//  UserManager.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 10.11.2024.
//

import Foundation
import CoreData

final class UserManager {
    private let persistentContainer: NSPersistentContainer

    init(container: NSPersistentContainer = PersistenceController.shared.container) {
        self.persistentContainer = container
    }

    func saveUser(
        nickname: String,
        title: String,
        characterClass: String,
        weapon: String,
        level: Int16 = 1,
        exp: Int16 = 0,
        coins: Int32 = 100,
        gems: Int32 = 0,
        health: Int16 = 50,
        maxHealth: Int16 = 50,
        completion: @escaping (Error?) -> Void
    ) {
        let context = persistentContainer.viewContext
        let userEntity = UserEntity(context: context)

        userEntity.id = UUID()
        userEntity.nickname = nickname
        userEntity.title = title
        userEntity.level = level
        userEntity.exp = exp
        userEntity.coins = coins
        userEntity.gems = gems
        userEntity.health = health
        userEntity.maxHealth = maxHealth

        do {
            try context.save()
            completion(nil)
        } catch {
            completion(error)
        }
    }

    func fetchUser(completion: @escaping (UserEntity?, Error?) -> Void) {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()

        do {
            let users = try context.fetch(fetchRequest)
            completion(users.first, nil)
        } catch {
            completion(nil, error)
        }
    }

    func deleteUser(completion: @escaping (Error?) -> Void) {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()

        do {
            let users = try context.fetch(fetchRequest)
            if let user = users.first {
                context.delete(user)
                try context.save()
                completion(nil)
            } else {
                completion(NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: String(localized: "user_not_found")]))
            }
        } catch {
            completion(error)
        }
    }

    func updateUserLevel(newLevel: Int16, completion: @escaping (Error?) -> Void) {
        fetchUser { user, error in
            guard let user = user, error == nil else {
                completion(error ?? NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: String(localized: "user_not_found")]))
                return
            }

            let context = self.persistentContainer.viewContext
            user.level = newLevel

            do {
                try context.save()
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }

    func updateUserExperience(additionalExp: Int16, completion: @escaping (Bool, Int16?, Error?) -> Void) {
        fetchUser { user, error in
            guard let user = user, error == nil else {
                completion(false, nil, error ?? NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: String(localized: "user_not_found")]))
                return
            }

            let context = self.persistentContainer.viewContext

            // Calculate total experience using the new leveling system
            let levelingSystem = LevelingSystem.shared
            let currentTotalExperience = levelingSystem.calculateTotalExperience(level: Int(user.level), experienceInLevel: Int(user.exp))
            let newTotalExperience = currentTotalExperience + Int(additionalExp)

            // Calculate new level and experience within level
            let newLevel = levelingSystem.calculateLevel(from: newTotalExperience)
            let newExperienceInLevel = newTotalExperience - levelingSystem.experienceRequiredForLevel(newLevel)

            // Check if leveled up
            let leveledUp = newLevel > user.level

            // Update user data
            user.level = Int16(newLevel)
            user.exp = Int16(newExperienceInLevel)

            do {
                try context.save()
                NotificationCenter.default.post(name: .userDidUpdate, object: nil)
                completion(leveledUp, user.level, nil)
            } catch {
                completion(false, nil, error)
            }
        }
    }

    func updateUserCoins(additionalCoins: Int32, completion: @escaping (Error?) -> Void) {
        fetchUser { user, error in
            guard let user = user, error == nil else {
                completion(error ?? NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: String(localized: "user_not_found")]))
                return
            }

            let context = self.persistentContainer.viewContext
            user.coins += additionalCoins

            do {
                try context.save()
                NotificationCenter.default.post(name: .userDidUpdate, object: nil)
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }

    func updateUserGems(additionalGems: Int32, completion: @escaping (Error?) -> Void) {
        fetchUser { user, error in
            guard let user = user, error == nil else {
                completion(error ?? NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: String(localized: "user_not_found")]))
                return
            }

            let context = self.persistentContainer.viewContext
            user.gems += additionalGems

            do {
                try context.save()
                NotificationCenter.default.post(name: .userDidUpdate, object: nil)
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }

    // MARK: - New Customization Methods

    func saveUserWithCustomization(
        nickname: String,
        title: String,
        customization: CharacterCustomization,
        level: Int16 = 1,
        exp: Int16 = 0,
        coins: Int32 = 100,
        gems: Int32 = 0,
        health: Int16 = 50,
        maxHealth: Int16 = 50,
        completion: @escaping (UserEntity?, Error?) -> Void
    ) {
        let context = persistentContainer.viewContext
        let userEntity = UserEntity(context: context)

        userEntity.id = UUID()
        userEntity.nickname = nickname
        userEntity.title = title
        userEntity.level = level
        userEntity.exp = exp
        userEntity.coins = coins
        userEntity.gems = gems
        userEntity.health = health
        userEntity.maxHealth = maxHealth
        do {
            try context.save()
            completion(userEntity, nil)
        } catch {
            completion(nil, error)
        }
    }
}

extension Notification.Name {
    static let userDidUpdate = Notification.Name("userDidUpdate")
}
