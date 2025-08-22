//
//  DamageHandler.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 6.08.2025.
//

import SwiftUI
import Combine

class DamageHandler: ObservableObject {
    @Published var damageNumbers: [DamageNumber] = []
    @Published var battleEffects: [BattleEffect] = []
    @Published var screenShake: Bool = false
    @Published var flashEffect: Bool = false

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Damage Number Management

    func showDamageNumber(damage: Int, position: CGPoint, isCritical: Bool = false, isHealing: Bool = false) {
        let damageNumber = DamageNumber(
            id: UUID(),
            value: damage,
            position: position,
            isCritical: isCritical,
            isHealing: isHealing,
            timestamp: Date()
        )

        damageNumbers.append(damageNumber)

        // Remove damage number after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.damageNumbers.removeAll { $0.id == damageNumber.id }
        }
    }

    func showBattleEffect(_ effect: BattleEffect) {
        battleEffects.append(effect)

        // Remove effect after duration
        DispatchQueue.main.asyncAfter(deadline: .now() + effect.duration) {
            self.battleEffects.removeAll { $0.id == effect.id }
        }
    }

    // MARK: - Visual Effects

    func triggerScreenShake(intensity: ScreenShakeIntensity = .medium) {
        screenShake = true

        DispatchQueue.main.asyncAfter(deadline: .now() + intensity.duration) {
            self.screenShake = false
        }
    }

    func triggerFlashEffect(color: Color = .red, duration: TimeInterval = 0.3) {
        flashEffect = true

        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            self.flashEffect = false
        }
    }

    // MARK: - Battle Action Processing

    func processBattleAction(_ action: BattleAction, entityPosition: CGPoint) {
        let damage = action.damage
        let isCritical = damage > action.attacker.attackPower
        let isHealing = action.actionType == .focus && action.target.isPlayer

        // Show damage number
        showDamageNumber(
            damage: damage,
            position: entityPosition,
            isCritical: isCritical,
            isHealing: isHealing
        )

        // Trigger visual effects based on action type
        switch action.actionType {
        case .attack:
            triggerScreenShake(intensity: .light)
        case .distraction:
            triggerFlashEffect(color: .orange, duration: 0.2)
        case .focus:
            triggerFlashEffect(color: .blue, duration: 0.4)
        case .special:
            triggerScreenShake(intensity: .heavy)
            triggerFlashEffect(color: .purple, duration: 0.5)
        }

        // Show battle effect
        let effect = BattleEffect(
            id: UUID(),
            type: .damage,
            position: entityPosition,
            color: isHealing ? .green : .red,
            duration: 1.0
        )
        showBattleEffect(effect)
    }

    // MARK: - Health Bar Animation

    func animateHealthBar(from: Double, targetValue: Double, duration: TimeInterval = 0.5) -> AnyPublisher<Double, Never> {
        let steps = 30
        let stepDuration = duration / Double(steps)
        let stepValue = (targetValue - from) / Double(steps)

        return Timer.publish(every: stepDuration, on: .main, in: .common)
            .autoconnect()
            .scan(from) { current, _ in
                let newValue = current + stepValue
                return newValue > targetValue ? targetValue : newValue
            }
            .prefix(steps + 1)
            .eraseToAnyPublisher()
    }
}

// MARK: - Supporting Models

struct DamageNumber: Identifiable {
    let id: UUID
    let value: Int
    let position: CGPoint
    let isCritical: Bool
    let isHealing: Bool
    let timestamp: Date

    var displayText: String {
        return isHealing ? "+\(value)" : "\(value)"
    }

    var textColor: Color {
        if isHealing {
            return .green
        } else if isCritical {
            return .red
        } else {
            return .white
        }
    }

    var fontSize: CGFloat {
        return isCritical ? 24 : 18
    }
}

struct BattleEffect: Identifiable {
    let id: UUID
    let type: EffectType
    let position: CGPoint
    let color: Color
    let duration: TimeInterval

    enum EffectType {
        case damage
        case heal
        case buff
        case debuff
        case explosion
    }
}

enum ScreenShakeIntensity {
    case light
    case medium
    case heavy

    var duration: TimeInterval {
        switch self {
        case .light: return 0.2
        case .medium: return 0.4
        case .heavy: return 0.6
        }
    }

    var magnitude: CGFloat {
        switch self {
        case .light: return 5
        case .medium: return 10
        case .heavy: return 15
        }
    }
}

// MARK: - Damage Number View

struct DamageNumberView: View {
    let damageNumber: DamageNumber
    @State private var offset: CGSize = .zero
    @State private var opacity: Double = 1.0
    @State private var scale: CGFloat = 1.0

    var body: some View {
        Text(damageNumber.displayText)
            .font(.system(size: damageNumber.fontSize, weight: .bold))
            .foregroundColor(damageNumber.textColor)
            .shadow(color: .black, radius: 2)
            .offset(offset)
            .opacity(opacity)
            .scaleEffect(scale)
            .onAppear {
                animateDamageNumber()
            }
    }

    private func animateDamageNumber() {
        // Random upward movement
        let randomX = CGFloat.random(in: -20...20)
        let randomY = CGFloat.random(in: -60...(-40))

        withAnimation(.easeOut(duration: 2.0)) {
            offset = CGSize(width: randomX, height: randomY)
            opacity = 0.0
            scale = 1.5
        }
    }
}

// MARK: - Battle Effect View

struct BattleEffectView: View {
    let effect: BattleEffect
    @State private var scale: CGFloat = 0.1
    @State private var opacity: Double = 1.0

    var body: some View {
        Circle()
            .fill(effect.color)
            .frame(width: 50, height: 50)
            .scaleEffect(scale)
            .opacity(opacity)
            .position(effect.position)
            .onAppear {
                animateEffect()
            }
    }

    private func animateEffect() {
        withAnimation(.easeOut(duration: effect.duration)) {
            scale = 2.0
            opacity = 0.0
        }
    }
}

// MARK: - Screen Shake Modifier

struct ScreenShakeModifier: ViewModifier {
    let isShaking: Bool
    let intensity: ScreenShakeIntensity

    func body(content: Content) -> some View {
        content
            .offset(x: isShaking ? CGFloat.random(in: -intensity.magnitude...intensity.magnitude) : 0,
                   y: isShaking ? CGFloat.random(in: -intensity.magnitude...intensity.magnitude) : 0)
            .animation(isShaking ? .easeInOut(duration: 0.1).repeatCount(3) : .default, value: isShaking)
    }
}

extension View {
    func screenShake(isShaking: Bool, intensity: ScreenShakeIntensity = .medium) -> some View {
        modifier(ScreenShakeModifier(isShaking: isShaking, intensity: intensity))
    }
}
