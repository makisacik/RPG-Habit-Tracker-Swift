import Foundation

struct HealthPotion: Identifiable, Equatable {
    let id: UUID
    let name: String
    let description: String
    let iconName: String
    let rarity: ItemRarity
    let healAmount: Int16
    let value: Int
    
    init(
        id: UUID = UUID(),
        name: String,
        description: String,
        iconName: String,
        rarity: ItemRarity = .common,
        healAmount: Int16,
        value: Int
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.iconName = iconName
        self.rarity = rarity
        self.healAmount = healAmount
        self.value = value
    }
    
    // MARK: - Predefined Health Potions
    
    static let minorHealthPotion = HealthPotion(
        name: "Minor Health Potion",
        description: "Restores 15 HP. A basic healing potion made from common herbs.",
        iconName: "potion_health_minor",
        rarity: .common,
        healAmount: 15,
        value: 25
    )
    
    static let healthPotion = HealthPotion(
        name: "Health Potion",
        description: "Restores 30 HP. A reliable healing potion for adventurers.",
        iconName: "potion_health",
        rarity: .uncommon,
        healAmount: 30,
        value: 50
    )
    
    static let greaterHealthPotion = HealthPotion(
        name: "Greater Health Potion",
        description: "Restores 50 HP. A powerful healing potion that can save your life.",
        iconName: "potion_health_greater",
        rarity: .rare,
        healAmount: 50,
        value: 100
    )
    
    static let superiorHealthPotion = HealthPotion(
        name: "Superior Health Potion",
        description: "Restores 75 HP. An exceptional healing potion with rare ingredients.",
        iconName: "potion_health_superior",
        rarity: .epic,
        healAmount: 75,
        value: 200
    )
    
    static let legendaryHealthPotion = HealthPotion(
        name: "Legendary Health Potion",
        description: "Fully restores health. A legendary potion that brings you back from the brink of death.",
        iconName: "potion_health_legendary",
        rarity: .legendary,
        healAmount: 999, // Full heal
        value: 500
    )
    
    // MARK: - All Health Potions
    
    static let allHealthPotions: [HealthPotion] = [
        minorHealthPotion,
        healthPotion,
        greaterHealthPotion,
        superiorHealthPotion,
        legendaryHealthPotion
    ]
    
    // MARK: - Helper Methods
    
    func use(on healthManager: HealthManager, completion: @escaping (Error?) -> Void) {
        if healAmount >= 999 {
            // Full heal
            healthManager.restoreFullHealth(completion: completion)
        } else {
            // Partial heal
            healthManager.heal(healAmount, completion: completion)
        }
    }
    
    var displayName: String {
        return name
    }
    
    var displayDescription: String {
        return description
    }
    
    var displayHealAmount: String {
        if healAmount >= 999 {
            return "Full Health"
        } else {
            return "\(healAmount) HP"
        }
    }
}
