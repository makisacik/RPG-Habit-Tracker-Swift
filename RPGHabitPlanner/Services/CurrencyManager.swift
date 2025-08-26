//
//  CurrencyManager.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 17.11.2024.
//

import Foundation
import CoreData
import SwiftUI

final class CurrencyManager: ObservableObject {
    static let shared = CurrencyManager()
    @Published var currentCoins: Int = 0
    @Published var currentGems: Int = 0
    private let persistentContainer: NSPersistentContainer

    private init(container: NSPersistentContainer = PersistenceController.shared.container) {
        self.persistentContainer = container
        loadInitialCurrency()
    }

    // MARK: - Coin Operations

    func addCoins(_ amount: Int, source: TransactionSource = .other, questId: UUID? = nil, description: String? = nil, completion: @escaping (Error?) -> Void) {
        fetchUser { [weak self] user, error in
            guard let user = user, error == nil else {
                completion(error ?? NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "User not found"]))
                return
            }

            let context = self?.persistentContainer.viewContext
            user.coins += Int32(amount)

            do {
                try context?.save()

                // Record earned coins
                CurrencyTransactionService.shared.recordEarned(amount: amount, currency: .coins)

                DispatchQueue.main.async {
                    self?.currentCoins = Int(user.coins)
                    print("💰 CurrencyManager: Updated currentCoins to \(Int(user.coins)) after adding coins")
                }
                NotificationCenter.default.post(name: .userDidUpdate, object: nil)
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }

    func addGems(_ amount: Int, source: TransactionSource = .other, questId: UUID? = nil, description: String? = nil, completion: @escaping (Error?) -> Void) {
        fetchUser { [weak self] user, error in
            guard let user = user, error == nil else {
                completion(error ?? NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "User not found"]))
                return
            }

            let context = self?.persistentContainer.viewContext
            user.gems += Int32(amount)

            do {
                try context?.save()

                // Record earned gems
                CurrencyTransactionService.shared.recordEarned(amount: amount, currency: .gems)

                DispatchQueue.main.async {
                    self?.currentGems = Int(user.gems)
                    print("💎 CurrencyManager: Updated currentGems to \(Int(user.gems)) after adding gems")
                }
                NotificationCenter.default.post(name: .userDidUpdate, object: nil)
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }

    func spendCoins(_ amount: Int, source: TransactionSource = .shop, description: String? = nil, completion: @escaping (Bool, Error?) -> Void) {
        fetchUser { [weak self] user, error in
            guard let user = user, error == nil else {
                completion(false, error ?? NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "User not found"]))
                return
            }

            guard user.coins >= Int32(amount) else {
                completion(false, NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey: "Insufficient coins"]))
                return
            }

            let context = self?.persistentContainer.viewContext
            user.coins -= Int32(amount)

            do {
                try context?.save()


                DispatchQueue.main.async {
                    self?.currentCoins = Int(user.coins)
                    print("💰 CurrencyManager: Updated currentCoins to \(Int(user.coins)) after spending coins")
                }
                NotificationCenter.default.post(name: .userDidUpdate, object: nil)
                completion(true, nil)
            } catch {
                completion(false, error)
            }
        }
    }

    func spendGems(_ amount: Int, source: TransactionSource = .shop, description: String? = nil, completion: @escaping (Bool, Error?) -> Void) {
        fetchUser { [weak self] user, error in
            guard let user = user, error == nil else {
                completion(false, error ?? NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "User not found"]))
                return
            }

            guard user.gems >= Int32(amount) else {
                completion(false, NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey: "Insufficient gems"]))
                return
            }

            let context = self?.persistentContainer.viewContext
            user.gems -= Int32(amount)

            do {
                try context?.save()


                DispatchQueue.main.async {
                    self?.currentGems = Int(user.gems)
                    print("💎 CurrencyManager: Updated currentGems to \(Int(user.gems)) after spending gems")
                }
                NotificationCenter.default.post(name: .userDidUpdate, object: nil)
                completion(true, nil)
            } catch {
                completion(false, error)
            }
        }
    }

    func getCurrentCoins(completion: @escaping (Int, Error?) -> Void) {
        fetchUser { [weak self] user, error in
            guard let user = user, error == nil else {
                completion(0, error ?? NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "User not found"]))
                return
            }

            let coins = Int(user.coins)
            DispatchQueue.main.async {
                self?.currentCoins = coins
                print("💰 CurrencyManager: Updated currentCoins to \(coins) from getCurrentCoins")
            }
            completion(coins, nil)
        }
    }

    func getCurrentGems(completion: @escaping (Int, Error?) -> Void) {
        fetchUser { [weak self] user, error in
            guard let user = user, error == nil else {
                completion(0, error ?? NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "User not found"]))
                return
            }

            let gems = Int(user.gems)
            DispatchQueue.main.async {
                self?.currentGems = gems
                print("💎 CurrencyManager: Updated currentGems to \(gems) from getCurrentGems")
            }
            completion(gems, nil)
        }
    }

    private func loadInitialCurrency() {
        getCurrentCoins { _, _ in
            // This will update the published property automatically
        }
        getCurrentGems { _, _ in
            // This will update the published property automatically
        }
    }

    func refreshCurrency() {
        getCurrentCoins { _, _ in
            // This will update the published property automatically
        }
        getCurrentGems { _, _ in
            // This will update the published property automatically
        }
    }

    // MARK: - Quest Reward Calculations

    func calculateQuestReward(difficulty: Int, isMainQuest: Bool, taskCount: Int) -> Int {
        let baseReward = difficulty * 10
        let taskBonus = taskCount * 5
        let randomBonus = Int.random(in: 5...25)

        return baseReward + taskBonus + randomBonus
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
