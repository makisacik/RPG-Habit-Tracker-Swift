//
//  CharacterTitleSystem.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 5.08.2025.
//

import Foundation

// MARK: - Character Title System

enum CharacterTitle: String, CaseIterable {
    case theBrave = "The Brave"
    case theWise = "The Wise"
    case theSwift = "The Swift"
    case theMighty = "The Mighty"
    case theShadow = "The Shadow"
    case theGuardian = "The Guardian"
    case theWanderer = "The Wanderer"
    case theLegendary = "The Legendary"
    case theWhimsical = "The Whimsical"
    case theStormborn = "The Stormborn"
    case theDreamweaver = "The Dreamweaver"
    case theStarlight = "The Starlight"
    
    var displayName: String {
        return self.rawValue
    }
    
    var description: String {
        switch self {
        case .theBrave:
            return "Fearless in the face of danger"
        case .theWise:
            return "Knowledge and wisdom guide their path"
        case .theSwift:
            return "Quick as the wind, agile as a cat"
        case .theMighty:
            return "Strength and power personified"
        case .theShadow:
            return "Moves unseen, strikes from darkness"
        case .theGuardian:
            return "Protector of the innocent and weak"
        case .theWanderer:
            return "Explorer of unknown lands and secrets"
        case .theLegendary:
            return "Destined for greatness and fame"
        case .theWhimsical:
            return "Brings joy and wonder wherever they go"
        case .theStormborn:
            return "Born of thunder, master of chaos"
        case .theDreamweaver:
            return "Weaves dreams into reality"
        case .theStarlight:
            return "Illuminates the darkest paths"
        }
    }
    
    var icon: String {
        switch self {
        case .theBrave:
            return "shield.fill"
        case .theWise:
            return "brain.head.profile"
        case .theSwift:
            return "hare.fill"
        case .theMighty:
            return "bolt.fill"
        case .theShadow:
            return "eye.slash.fill"
        case .theGuardian:
            return "lock.shield.fill"
        case .theWanderer:
            return "map.fill"
        case .theLegendary:
            return "crown.fill"
        case .theWhimsical:
            return "sparkles"
        case .theStormborn:
            return "bolt.rainbow"
        case .theDreamweaver:
            return "moon.stars.fill"
        case .theStarlight:
            return "star.circle.fill"
        }
    }
    
    var color: String {
        switch self {
        case .theBrave:
            return "red"
        case .theWise:
            return "blue"
        case .theSwift:
            return "green"
        case .theMighty:
            return "orange"
        case .theShadow:
            return "purple"
        case .theGuardian:
            return "cyan"
        case .theWanderer:
            return "brown"
        case .theLegendary:
            return "yellow"
        case .theWhimsical:
            return "pink"
        case .theStormborn:
            return "purple"
        case .theDreamweaver:
            return "indigo"
        case .theStarlight:
            return "cyan"
        }
    }
}

// MARK: - Title Manager

class CharacterTitleManager {
    static let shared = CharacterTitleManager()
    
    private init() {}
    
    func getRandomTitle() -> CharacterTitle {
        return CharacterTitle.allCases.randomElement() ?? .theBrave
    }
    
    func getTitleByString(_ titleString: String) -> CharacterTitle? {
        return CharacterTitle.allCases.first { $0.rawValue == titleString }
    }
    
    func getAllTitles() -> [CharacterTitle] {
        return CharacterTitle.allCases
    }
}
