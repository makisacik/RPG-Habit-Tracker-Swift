import Foundation
import SwiftUI

// MARK: - Building Types
enum BuildingType: String, CaseIterable, Codable {
    case house = "house"
    case castle = "castle"
    case tower = "tower"
    case tower2 = "tower2"
    case goldmine = "goldmine"
    
    var displayName: String {
        switch self {
        case .house: return "House"
        case .castle: return "Castle"
        case .tower: return "Tower"
        case .tower2: return "Tower"
        case .goldmine: return "Gold Mine"
        }
    }
    
    var description: String {
        switch self {
        case .house: return "Provides shelter and basic resources"
        case .castle: return "Fortified structure for defense"
        case .tower: return "Watchtower for surveillance"
        case .tower2: return "Watchtower for surveillance"
        case .goldmine: return "Generates gold over time"
        }
    }
    
    var baseCost: Int {
        switch self {
        case .house: return 1
        case .castle: return 1
        case .tower: return 1
        case .tower2: return 1
        case .goldmine: return 1
        }
    }
    
    var constructionTime: TimeInterval {
        switch self {
        case .house: return 60 // 1 minute
        case .castle: return 300 // 5 minutes
        case .tower: return 180 // 3 minutes
        case .tower2: return 180 // 3 minutes
        case .goldmine: return 120 // 2 minutes
        }
    }
    
    var iconName: String {
        switch self {
        case .house: return "house.fill"
        case .castle: return "building.2.fill"
        case .tower: return "building.columns.fill"
        case .tower2: return "building.columns.fill"
        case .goldmine: return "mountain.2.fill"
        }
    }
    
    // Note: villagePosition is now handled by VillageLayout.getFixedPositions(for:)
    
    var size: CGSize {
        switch self {
        case .house: return CGSize(width: 120, height: 120) // Much larger house
        case .castle: return CGSize(width: 400, height: 400) // Very large castle
        case .tower: return CGSize(width: 100, height: 140) // Larger tower
        case .tower2: return CGSize(width: 100, height: 140) // Larger tower
        case .goldmine: return CGSize(width: 120, height: 120) // Much larger goldmine
        }
    }
}

// MARK: - Building States
enum BuildingState: String, CaseIterable, Codable {
    case destroyed = "destroyed"
    case construction = "construction"
    case active = "active"
    case inactive = "inactive"
    
    var displayName: String {
        switch self {
        case .destroyed: return "Destroyed"
        case .construction: return "Under Construction"
        case .active: return "Active"
        case .inactive: return "Inactive"
        }
    }
    
    var color: Color {
        switch self {
        case .destroyed: return .red
        case .construction: return .orange
        case .active: return .green
        case .inactive: return .gray
        }
    }
    
    var priority: Int {
        switch self {
        case .destroyed: return 0
        case .construction: return 1
        case .inactive: return 2
        case .active: return 3
        }
    }
}

// Building colors are now fixed to blue

// MARK: - Building Model
struct Building: Identifiable, Codable {
    var id = UUID()
    let type: BuildingType
    var state: BuildingState
    var position: CGPoint
    var constructionStartTime: Date?
    var lastGoldGeneration: Date?
    var level: Int = 1
    
    var isUnderConstruction: Bool {
        state == .construction
    }
    
    var constructionProgress: Double {
        guard let startTime = constructionStartTime else { return 0.0 }
        let elapsed = Date().timeIntervalSince(startTime)
        let total = type.constructionTime
        return min(elapsed / total, 1.0)
    }
    
    var isConstructionComplete: Bool {
        constructionProgress >= 1.0
    }
    
    var imageName: String {
        switch type {
        case .goldmine:
            return "goldmine_active"
        case .tower2:
            return "tower_blue" // Use same asset as tower
        default:
            return "\(type.rawValue)_blue"
        }
    }
    
    var constructionImageName: String {
        switch type {
        case .tower2:
            return "tower_construction" // Use same asset as tower
        default:
            return "\(type.rawValue)_construction"
        }
    }
    
    var destroyedImageName: String {
        switch type {
        case .tower2:
            return "tower_destroyed" // Use same asset as tower
        default:
            return "\(type.rawValue)_destroyed"
        }
    }
    
    var inactiveImageName: String {
        switch type {
        case .goldmine:
            return "goldmine_inactive"
        case .tower2:
            return "tower_inactive" // Use same asset as tower
        default:
            return "\(type.rawValue)_inactive"
        }
    }
    
    var currentImageName: String {
        switch state {
        case .destroyed:
            return destroyedImageName
        case .construction:
            return constructionImageName
        case .active:
            return imageName
        case .inactive:
            return inactiveImageName
        }
    }
    
    // Gold generation for goldmines
    var goldGenerationRate: Int {
        guard type == .goldmine && state == .active else { return 0 }
        return 10 * level // 10 gold per hour per level
    }
    
    var canGenerateGold: Bool {
        guard type == .goldmine && state == .active else { return false }
        guard let lastGeneration = lastGoldGeneration else { return true }
        return Date().timeIntervalSince(lastGeneration) >= 3600 // 1 hour
    }
    
    var upgradeCost: Int {
        return type.baseCost * level
    }
    
    var canUpgrade: Bool {
        return state == .active && level < 5
    }
}

// MARK: - Village Layout
struct VillageLayout {
    static let gridSize: CGFloat = 80
    
    static func getVillageSize(for screenSize: CGSize) -> CGSize {
        // Use 90% of available screen width and height, with some padding
        let maxWidth = screenSize.width * 0.9
        let maxHeight = screenSize.height * 0.7 // Leave space for header
        return CGSize(width: maxWidth, height: maxHeight)
    }
    
    static func getFixedPositions(for screenSize: CGSize) -> [BuildingType: CGPoint] {
        let villageSize = getVillageSize(for: screenSize)
        let padding: CGFloat = 40 // Reduced padding for smaller screens
        
        // Calculate castle size to be 30% of village height
        let castleHeight = villageSize.height * 0.3
        let castleWidth = castleHeight // Keep it square
        
        // Castle positioned at the top center
        let castleX = screenSize.width / 2 // Center horizontally
        let castleY = padding + (castleHeight / 2) // Center of castle at top
        
        // House and Gold Mine positioned below the castle with proper spacing
        let houseX = screenSize.width * 0.25 // 25% from left
        let houseY = castleY + (castleHeight / 2) + 140 // Below castle with more spacing
        
        let goldmineX = screenSize.width * 0.75 // 75% from left (old tower position)
        let goldmineY = castleY + (castleHeight / 2) + 140 // Below castle, same level as house
        
        // Two towers at the bottom of the screen
        let tower1X = screenSize.width * 0.25 // 25% from left
        let tower1Y = screenSize.height - padding - 80 // At the bottom
        
        let tower2X = screenSize.width * 0.75 // 75% from left
        let tower2Y = screenSize.height - padding - 80 // At the bottom
        
        return [
            .house: CGPoint(x: houseX, y: houseY),
            .castle: CGPoint(x: castleX, y: castleY),
            .tower: CGPoint(x: tower1X, y: tower1Y), // First tower at bottom left
            .tower2: CGPoint(x: tower2X, y: tower2Y), // Second tower at bottom right
            .goldmine: CGPoint(x: goldmineX, y: goldmineY)
        ]
    }
    
    static func getBuildingSize(for buildingType: BuildingType, in screenSize: CGSize) -> CGSize {
        let villageSize = getVillageSize(for: screenSize)
        
        switch buildingType {
        case .castle:
            // Castle takes up 40% of village height for maximum prominence
            let castleHeight = villageSize.height * 0.4
            return CGSize(width: castleHeight, height: castleHeight)
        case .house:
            return CGSize(width: 140, height: 140) // Even larger house
        case .tower, .tower2:
            return CGSize(width: 120, height: 160) // Even larger tower
        case .goldmine:
            return CGSize(width: 140, height: 140) // Even larger goldmine
        }
    }
    
    static func getBuildingAtPosition(_ position: CGPoint, in screenSize: CGSize) -> BuildingType? {
        let fixedPositions = getFixedPositions(for: screenSize)
        for (type, fixedPosition) in fixedPositions {
            let distance = sqrt(pow(position.x - fixedPosition.x, 2) + pow(position.y - fixedPosition.y, 2))
            if distance < gridSize / 2 {
                return type
            }
        }
        return nil
    }
}

// MARK: - Base Model
struct Base: Codable {
    var buildings: [Building] = []
    var level: Int = 1
    var experience: Int = 0
    var maxBuildings: Int = 5
    var villageName: String = "Adventure Village"
    
    var experienceToNextLevel: Int {
        level * 100
    }
    
    var canAddBuilding: Bool {
        buildings.count < maxBuildings
    }
    
    var activeBuildings: [Building] {
        buildings.filter { $0.state == .active }
    }
    
    var constructionBuildings: [Building] {
        buildings.filter { $0.state == .construction }
    }
    
    var destroyedBuildings: [Building] {
        buildings.filter { $0.state == .destroyed }
    }
    
    var inactiveBuildings: [Building] {
        buildings.filter { $0.state == .inactive }
    }
    
    var totalGoldGeneration: Int {
        activeBuildings
            .filter { $0.type == .goldmine }
            .reduce(0) { total, building in
                total + building.goldGenerationRate
            }
    }
    
    mutating func addBuilding(_ building: Building) {
        buildings.append(building)
        checkLevelUp()
    }
    
    mutating func removeBuilding(_ building: Building) {
        buildings.removeAll { $0.id == building.id }
    }
    
    mutating func updateBuilding(_ building: Building) {
        if let index = buildings.firstIndex(where: { $0.id == building.id }) {
            buildings[index] = building
        }
    }
    
    mutating func checkLevelUp() {
        let requiredExp = experienceToNextLevel
        if experience >= requiredExp {
            level += 1
            experience -= requiredExp
            maxBuildings = min(maxBuildings + 1, 8)
        }
    }
    
    mutating func addExperience(_ amount: Int) {
        experience += amount
        checkLevelUp()
    }
    
    func getBuilding(at position: CGPoint) -> Building? {
        // Use fixed positions instead of stored positions
        let screenSize = UIScreen.main.bounds.size
        let fixedPositions = VillageLayout.getFixedPositions(for: screenSize)
        
        return buildings.first { building in
            if let fixedPosition = fixedPositions[building.type] {
                let distance = sqrt(pow(fixedPosition.x - position.x, 2) + pow(fixedPosition.y - position.y, 2))
                return distance < VillageLayout.gridSize / 2
            }
            return false
        }
    }
    
    mutating func initializeVillage() {
        // Initialize with default screen size, will be updated when view loads
        let defaultScreenSize = CGSize(width: 400, height: 600)
        let fixedPositions = VillageLayout.getFixedPositions(for: defaultScreenSize)
        buildings = []
        
        for (type, position) in fixedPositions {
            let building = Building(
                type: type,
                state: .destroyed, // Start with destroyed buildings
                position: position
            )
            buildings.append(building)
        }
    }
}
