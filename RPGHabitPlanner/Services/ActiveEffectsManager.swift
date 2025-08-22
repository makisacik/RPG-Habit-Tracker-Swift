//
//  ActiveEffectsManager.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 18.08.2025.
//

import Foundation
import Combine

@MainActor
final class ActiveEffectsManager: ObservableObject {
    static let shared = ActiveEffectsManager()

    @Published private(set) var activeEffects: [ActiveEffect] = []
    @Published private(set) var isLoading = false

    private let service: ActiveEffectsServiceProtocol
    private var cancellables = Set<AnyCancellable>()

    private init(service: ActiveEffectsServiceProtocol = ActiveEffectsCoreDataService()) {
        self.service = service
        loadActiveEffects()
    }

    // MARK: - Public Methods

    func loadActiveEffects() {
        isLoading = true

        Task {
            let effects = service.fetchActiveEffects()
            await MainActor.run {
                self.activeEffects = effects
                self.isLoading = false
            }
        }
    }

    func addActiveEffect(_ effect: ActiveEffect) {
        service.saveActiveEffect(effect)
        activeEffects.append(effect)

        // Set up a timer to remove the effect when it expires
        if let endTime = effect.endTime {
            let timeUntilExpiry = endTime.timeIntervalSince(Date())
            if timeUntilExpiry > 0 {
                DispatchQueue.main.asyncAfter(deadline: .now() + timeUntilExpiry) { [weak self] in
                    Task { @MainActor in
                        self?.removeExpiredEffects()
                    }
                }
            }
        }
    }

    func removeActiveEffect(_ effect: ActiveEffect) {
        service.removeActiveEffect(effect)
        activeEffects.removeAll { $0.id == effect.id }
    }

    func removeExpiredEffects() {
        let expiredEffects = activeEffects.filter { !$0.isActive }
        expiredEffects.forEach { removeActiveEffect($0) }

        // Also clear expired effects from Core Data
        service.clearExpiredEffects()
    }

    func clearAllEffects() {
        service.clearAllEffects()
        activeEffects.removeAll()
    }

    // MARK: - Helper Methods

    func getActiveEffects(of type: ItemEffect.EffectType) -> [ActiveEffect] {
        return activeEffects.filter { $0.effect.type == type && $0.isActive }
    }

    func hasActiveEffect(of type: ItemEffect.EffectType) -> Bool {
        return activeEffects.contains { $0.effect.type == type && $0.isActive }
    }

    func getTotalEffectValue(for type: ItemEffect.EffectType) -> Int {
        let effects = getActiveEffects(of: type)
        return effects.reduce(0) { total, effect in
            total + effect.effect.value
        }
    }

    func getEffectMultiplier(for type: ItemEffect.EffectType) -> Double {
        let effects = getActiveEffects(of: type)
        return effects.reduce(1.0) { multiplier, effect in
            if effect.effect.isPercentage {
                return multiplier * (1.0 + Double(effect.effect.value) / 100.0)
            } else {
                return multiplier + Double(effect.effect.value) / 100.0
            }
        }
    }

    // MARK: - Timer Management

    func startExpiryTimer() {
        // Check for expired effects every minute
        Timer.publish(every: 60, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.removeExpiredEffects()
            }
            .store(in: &cancellables)
    }

    func stopExpiryTimer() {
        cancellables.removeAll()
    }
}
