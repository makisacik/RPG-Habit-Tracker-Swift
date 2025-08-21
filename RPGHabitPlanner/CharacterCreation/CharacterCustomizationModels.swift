//
//  CharacterCustomizationModels.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 10.11.2024.
//

import Foundation
import SwiftUI

// MARK: - Character Customization Models

struct CharacterCustomization: Codable, Equatable {
    var bodyType: BodyType
    var skinColor: SkinColor
    var hairStyle: HairStyle
    var hairColor: HairColor
    var eyeColor: EyeColor
    var outfit: Outfit
    var weapon: CharacterWeapon
    var accessory: Accessory?
    
    init() {
        self.bodyType = .body1
        self.skinColor = .light
        self.hairStyle = .brown1
        self.hairColor = .brown
        self.eyeColor = .brown
        self.outfit = .simple
        self.weapon = .swordDaggerWood
        self.accessory = nil
    }
}

// MARK: - Body Types
enum BodyType: String, CaseIterable, Codable, Identifiable {
    case body1 = "char_body_1"
    case body2 = "char_body_2"
    case body3 = "char_body_3"
    case body4 = "char_body_4"
    case body5 = "char_body_5"
    case body6 = "char_body_6"
    
    var id: String { self.rawValue }
    
    var displayName: String {
        switch self {
        case .body1: return "Body Type 1"
        case .body2: return "Body Type 2"
        case .body3: return "Body Type 3"
        case .body4: return "Body Type 4"
        case .body5: return "Body Type 5"
        case .body6: return "Body Type 6"
        }
    }
    
    var previewImageName: String {
        switch self {
        case .body1: return "char_body_1_preview"
        case .body2: return "char_body_2_preview"
        case .body3: return "char_body_3_preview"
        case .body4: return "char_body_4_preview"
        case .body5: return "char_body_5_preview"
        case .body6: return "char_body_6_preview"
        }
    }
    
    var isPremium: Bool {
        return false // Remove premium restriction
    }
}

// MARK: - Skin Colors
enum SkinColor: String, CaseIterable, Codable, Identifiable {
    case light = "light"
    case medium = "medium"
    case dark = "dark"
    case tan = "tan"
    case olive = "olive"
    
    var id: String { self.rawValue }
    
    var displayName: String {
        switch self {
        case .light: return "Light"
        case .medium: return "Medium"
        case .dark: return "Dark"
        case .tan: return "Tan"
        case .olive: return "Olive"
        }
    }
    
    var color: Color {
        switch self {
        case .light: return Color(red: 0.95, green: 0.85, blue: 0.75)
        case .medium: return Color(red: 0.85, green: 0.65, blue: 0.45)
        case .dark: return Color(red: 0.45, green: 0.25, blue: 0.15)
        case .tan: return Color(red: 0.90, green: 0.75, blue: 0.55)
        case .olive: return Color(red: 0.75, green: 0.65, blue: 0.45)
        }
    }
}

// MARK: - Hair Styles
enum HairStyle: String, CaseIterable, Codable, Identifiable {
    case brown1 = "char_hair_brown_1"
    case brown2 = "char_hair_brown_2"
    case punk = "char_hair_punk"
    
    var id: String { self.rawValue }
    
    var displayName: String {
        switch self {
        case .brown1: return "Classic"
        case .brown2: return "Modern"
        case .punk: return "Punk"
        }
    }
    
    var previewImageName: String {
        switch self {
        case .brown1: return "char_hair_brown_1_preview"
        case .brown2: return "char_hair_brown_2_preview"
        case .punk: return "char_hair_punk_preview"
        }
    }
    
    var isPremium: Bool {
        return false // Remove premium restriction
    }
}

// MARK: - Hair Colors
enum HairColor: String, CaseIterable, Codable, Identifiable {
    case brown = "brown"
    case black = "black"
    case blonde = "blonde"
    case red = "red"
    case gray = "gray"
    
    var id: String { self.rawValue }
    
    var displayName: String {
        switch self {
        case .brown: return "Brown"
        case .black: return "Black"
        case .blonde: return "Blonde"
        case .red: return "Red"
        case .gray: return "Gray"
        }
    }
    
    var color: Color {
        switch self {
        case .brown: return Color(red: 0.4, green: 0.2, blue: 0.1)
        case .black: return Color.black
        case .blonde: return Color(red: 0.9, green: 0.8, blue: 0.6)
        case .red: return Color(red: 0.8, green: 0.2, blue: 0.1)
        case .gray: return Color(red: 0.6, green: 0.6, blue: 0.6)
        }
    }
}

// MARK: - Eye Colors
enum EyeColor: String, CaseIterable, Codable, Identifiable {
    case brown = "char_eyeball_brown"
    case blue = "char_eyeball_blue"
    case green = "char_eyeball_green"
    
    var id: String { self.rawValue }
    
    var displayName: String {
        switch self {
        case .brown: return "Brown"
        case .blue: return "Blue"
        case .green: return "Green"
        }
    }
    
    var previewImageName: String {
        switch self {
        case .brown: return "char_eyeball_brown_preview"
        case .blue: return "char_eyeball_blue_preview"
        case .green: return "char_eyeball_green_preview"
        }
    }
    
    var isPremium: Bool {
        return false // Remove premium restriction
    }
}

// MARK: - Outfits
enum Outfit: String, CaseIterable, Codable, Identifiable {
    case simple = "char_outfit_simple"
    case hoodie = "char_outfit_hoodie"
    case dress = "char_outfit_dress"
    case red = "char_outfit_red"
    case iron = "char_outfit_iron"
    case bat = "char_outfit_bat"
    case assassin = "char_outfit_asassin"
    case fire = "char_outfit_fire"
    
    var id: String { self.rawValue }
    
    var displayName: String {
        switch self {
        case .simple: return "Simple"
        case .hoodie: return "Hoodie"
        case .dress: return "Dress"
        case .red: return "Red Outfit"
        case .iron: return "Iron Armor"
        case .bat: return "Bat Outfit"
        case .assassin: return "Assassin"
        case .fire: return "Fire Outfit"
        }
    }
    
    var previewImageName: String {
        switch self {
        case .simple: return "char_outfit_simple_preview"
        case .hoodie: return "char_outfit_hoodie_preview"
        case .dress: return "char_outfit_dress_preview"
        case .red: return "char_outfit_red_preview"
        case .iron: return "char_outfit_iron_preview"
        case .bat: return "char_outfit_bat_preview"
        case .assassin: return "char_outfit_asassin_preview"
        case .fire: return "char_outfit_fire_preview"
        }
    }
    
    var isPremium: Bool {
        return false // Remove premium restriction
    }
}

// MARK: - Character Weapons
enum CharacterWeapon: String, CaseIterable, Codable, Identifiable {
    case swordDaggerWood = "char_sword_dagger_wood"
    case swordDagger = "char_sword_dagger"
    case swordCopper = "char_sword_copper"
    case swordIron = "char_sword_iron"
    case swordMace = "char_sword_mace"
    case swordAxish = "char_sword_axish"
    case swordFirelord = "char_sword_firelord"
    case swordDeadly = "char_sword_deadly"
    
    var id: String { self.rawValue }
    
    var displayName: String {
        switch self {
        case .swordDaggerWood: return "Wooden Dagger"
        case .swordDagger: return "Steel Dagger"
        case .swordCopper: return "Copper Sword"
        case .swordIron: return "Iron Sword"
        case .swordMace: return "Mace"
        case .swordAxish: return "Battle Axe"
        case .swordFirelord: return "Firelord Sword"
        case .swordDeadly: return "Deadly Blade"
        }
    }
    
    var previewImageName: String {
        switch self {
        case .swordDaggerWood: return "char_sword_dagger_wood_preview"
        case .swordDagger: return "char_sword_dagger_preview"
        case .swordCopper: return "char_sword_copper_preview"
        case .swordIron: return "char_sword_iron_preview"
        case .swordMace: return "char_sword_mace_preview"
        case .swordAxish: return "char_sword_axish_preview"
        case .swordFirelord: return "char_sword_firelord_preview"
        case .swordDeadly: return "char_sword_deadly_preview"
        }
    }
    
    var isPremium: Bool {
        return false // Remove premium restriction
    }
}

// MARK: - Accessories
enum Accessory: String, CaseIterable, Codable, Identifiable {
    case eyeglassRed = "char_eyeglass_red"
    case eyeglassBlue = "char_eyeglass_blue"
    case eyeglassGray = "char_eyeglass_gray"
    case helmetRed = "char_helmet_red"
    case cheekBlush = "char_cheek_blush"
    case eyeLashes = "char_eye_lashes"
    case wingsWhite = "char_wings_white"
    
    var id: String { self.rawValue }
    
    var displayName: String {
        switch self {
        case .eyeglassRed: return "Red Glasses"
        case .eyeglassBlue: return "Blue Glasses"
        case .eyeglassGray: return "Gray Glasses"
        case .helmetRed: return "Red Helmet"
        case .cheekBlush: return "Blush"
        case .eyeLashes: return "Eyelashes"
        case .wingsWhite: return "White Wings"
        }
    }
    
    var previewImageName: String {
        switch self {
        case .eyeglassRed: return "char_eyeglass_red_preview"
        case .eyeglassBlue: return "char_eyeglass_blue_preview"
        case .eyeglassGray: return "char_eyeglass_gray_preview"
        case .helmetRed: return "char_helmet_red_preview"
        case .cheekBlush: return "char_cheek_blush_preview"
        case .eyeLashes: return "char_eye_lashes_preview"
        case .wingsWhite: return "char_wings_white_preview"
        }
    }
    
    var isPremium: Bool {
        return false // Remove premium restriction
    }
}

// MARK: - Character Preview
struct CharacterPreview {
    let customization: CharacterCustomization
    
    var bodyImageName: String {
        return customization.bodyType.rawValue
    }
    
    var hairImageName: String {
        return customization.hairStyle.rawValue
    }
    
    var eyeImageName: String {
        return customization.eyeColor.rawValue
    }
    
    var outfitImageName: String {
        return customization.outfit.rawValue
    }
    
    var weaponImageName: String {
        return customization.weapon.rawValue
    }
    
    var accessoryImageName: String? {
        return customization.accessory?.rawValue
    }
}
