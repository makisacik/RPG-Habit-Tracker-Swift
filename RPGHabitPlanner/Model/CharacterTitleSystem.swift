//
//  CharacterTitleSystem.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 5.08.2025.
//

import Foundation

// MARK: - Character Title System

enum CharacterTitle: String, CaseIterable {
    case theBrave = "the_brave"
    case theWise = "the_wise"
    case theSwift = "the_swift"
    case theMighty = "the_mighty"
    case theShadow = "the_shadow"
    case theGuardian = "the_guardian"
    case theWanderer = "the_wanderer"
    case theLegendary = "the_legendary"
    case theWhimsical = "the_whimsical"
    case theStormborn = "the_stormborn"
    case theDreamweaver = "the_dreamweaver"
    case theStarlight = "the_starlight"
    
    var displayName: String {
        return self.rawValue.localized
    }
    
    var description: String {
        switch self {
        case .theBrave:
            return "the_brave_description".localized
        case .theWise:
            return "the_wise_description".localized
        case .theSwift:
            return "the_swift_description".localized
        case .theMighty:
            return "the_mighty_description".localized
        case .theShadow:
            return "the_shadow_description".localized
        case .theGuardian:
            return "the_guardian_description".localized
        case .theWanderer:
            return "the_wanderer_description".localized
        case .theLegendary:
            return "the_legendary_description".localized
        case .theWhimsical:
            return "the_whimsical_description".localized
        case .theStormborn:
            return "the_stormborn_description".localized
        case .theDreamweaver:
            return "the_dreamweaver_description".localized
        case .theStarlight:
            return "the_starlight_description".localized
        }
    }
    
    var icon: String {
        switch self {
        case .theBrave:
            return "icon_shield"
        case .theWise:
            return "brain.head.profile"
        case .theSwift:
            return "hare.fill"
        case .theMighty:
            return "bolt.fill"
        case .theShadow:
            return "eye.slash.fill"
        case .theGuardian:
            return "icon_shield"
        case .theWanderer:
            return "map.fill"
        case .theLegendary:
            return "crown.fill"
        case .theWhimsical:
            return "sparkles"
        case .theStormborn:
            return "bolt.fill"
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
