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
        characterClass: CharacterClass,
        weapon: Weapon,
        level: Int16 = 1,
        exp: Int16 = 0,
        completion: @escaping (Error?) -> Void
    ) {
        let context = persistentContainer.viewContext
        let userEntity = UserEntity(context: context)
        
        userEntity.id = UUID()
        userEntity.nickname = nickname
        userEntity.characterClass = characterClass.rawValue
        userEntity.weapon = weapon.rawValue
        userEntity.level = level
        userEntity.exp = exp
        
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
                completion(NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "User not found"]))
            }
        } catch {
            completion(error)
        }
    }
    
    func updateUserLevel(newLevel: Int16, completion: @escaping (Error?) -> Void) {
        fetchUser { user, error in
            guard let user = user, error == nil else {
                completion(error ?? NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "User not found"]))
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
    
    func updateUserExperience(additionalExp: Int16, completion: @escaping (Error?) -> Void) {
        fetchUser { user, error in
            guard let user = user, error == nil else {
                completion(error ?? NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "User not found"]))
                return
            }
            
            let context = self.persistentContainer.viewContext
            user.exp += additionalExp
            
            while user.exp >= 100 {
                user.exp -= 100
                user.level += 1
            }
            
            do {
                try context.save()
                NotificationCenter.default.post(name: .userDidUpdate, object: nil)
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
}

extension Notification.Name {
    static let userDidUpdate = Notification.Name("userDidUpdate")
}
