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
        level: Int16 = 1,
        exp: Int16 = 0,
        coins: Int32 = 100,
        health: Int16 = 50,
        maxHealth: Int16 = 50,
        completion: @escaping (Error?) -> Void
    ) {
        let context = persistentContainer.viewContext
        let userEntity = UserEntity(context: context)
        
        userEntity.id = UUID()
        userEntity.nickname = nickname
        userEntity.level = level
        userEntity.exp = exp
        userEntity.coins = coins
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
    
    func updateUser(
        nickname: String? = nil,
        level: Int16? = nil,
        exp: Int16? = nil,
        coins: Int32? = nil,
        health: Int16? = nil,
        maxHealth: Int16? = nil,
        completion: @escaping (Error?) -> Void
    ) {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        
        do {
            let users = try context.fetch(fetchRequest)
            guard let user = users.first else {
                completion(NSError(domain: "UserManager", code: 404, userInfo: [NSLocalizedDescriptionKey: "User not found"]))
                return
            }
            
            if let nickname = nickname {
                user.nickname = nickname
            }
            if let level = level {
                user.level = level
            }
            if let exp = exp {
                user.exp = exp
            }
            if let coins = coins {
                user.coins = coins
            }
            if let health = health {
                user.health = health
            }
            if let maxHealth = maxHealth {
                user.maxHealth = maxHealth
            }
            
            try context.save()
            completion(nil)
        } catch {
            completion(error)
        }
    }
    
    func deleteUser(completion: @escaping (Error?) -> Void) {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        
        do {
            let users = try context.fetch(fetchRequest)
            for user in users {
                context.delete(user)
            }
            try context.save()
            completion(nil)
        } catch {
            completion(error)
        }
    }
    
    func updateUserExperience(additionalExp: Int16, completion: @escaping (Bool, Int16?, Error?) -> Void) {
        fetchUser { user, error in
            guard let user = user, error == nil else {
                completion(false, nil, error ?? NSError(domain: "UserManager", code: 404, userInfo: [NSLocalizedDescriptionKey: "User not found"]))
                return
            }
            
            let context = self.persistentContainer.viewContext
            user.exp += additionalExp
            
            var leveledUp = false
            while user.exp >= 100 {
                user.exp -= 100
                user.level += 1
                leveledUp = true
            }
            
            do {
                try context.save()
                NotificationCenter.default.post(name: .userDidUpdate, object: nil)
                completion(leveledUp, user.level, nil)
            } catch {
                completion(false, nil, error)
            }
        }
    }
    
    // MARK: - New Customization Methods
    
    func saveUserWithCustomization(
        nickname: String,
        customization: CharacterCustomization,
        level: Int16 = 1,
        exp: Int16 = 0,
        coins: Int32 = 100,
        health: Int16 = 50,
        maxHealth: Int16 = 50,
        completion: @escaping (UserEntity?, Error?) -> Void
    ) {
        let context = persistentContainer.viewContext
        let userEntity = UserEntity(context: context)
        
        userEntity.id = UUID()
        userEntity.nickname = nickname
        userEntity.level = level
        userEntity.exp = exp
        userEntity.coins = coins
        userEntity.health = health
        userEntity.maxHealth = maxHealth
        
        // Set legacy fields for compatibility
        userEntity.characterClass = "Custom" // No longer using classes
        userEntity.weapon = customization.weapon.rawValue
        
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
