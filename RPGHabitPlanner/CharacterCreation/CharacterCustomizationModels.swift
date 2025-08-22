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
    var hairStyle: HairStyle
    var hairBackStyle: HairBackStyle? // New field for hair backs
    var hairColor: HairColor
    var eyeColor: EyeColor
    var outfit: Outfit
    var weapon: CharacterWeapon
    var accessory: Accessory?
    var mustache: Mustache? // New field for mustaches
    var flower: Flower? // New field for flowers

    init() {
        self.bodyType = .bodyWhite
        self.hairStyle = .hair1Black // Use the default black color for hair style 1
        self.hairBackStyle = nil
        self.hairColor = .black // Match the default hair color
        self.eyeColor = .eyeBlack
        self.outfit = .outfitVillager
        self.weapon = .swordWood
        self.accessory = nil
        self.mustache = nil
        self.flower = nil
    }

    // MARK: - Helper Methods for Customization Components

    func getValue(for category: AssetCategory) -> String? {
        switch category {
        case .bodyType:
            return bodyType.rawValue
        case .hairStyle:
            return hairStyle.rawValue
        case .hairBackStyle:
            return hairBackStyle?.rawValue
        case .hairColor:
            return hairColor.rawValue
        case .eyeColor:
            return eyeColor.rawValue
        case .outfit:
            return outfit.rawValue
        case .weapon:
            return weapon.rawValue
        case .accessory:
            return accessory?.rawValue
        case .mustache:
            return mustache?.rawValue
        case .flower:
            return flower?.rawValue
        }
    }

    mutating func setValue(_ value: String, for category: AssetCategory) {
        let setterMap: [AssetCategory: (inout CharacterCustomization, String) -> Void] = [
            .bodyType: { customization, value in
                customization.bodyType = BodyType(rawValue: value) ?? customization.bodyType
            },
            .hairStyle: { customization, value in
                customization.hairStyle = HairStyle(rawValue: value) ?? customization.hairStyle
            },
            .hairBackStyle: { customization, value in
                customization.hairBackStyle = HairBackStyle(rawValue: value)
            },
            .hairColor: { customization, value in
                customization.hairColor = HairColor(rawValue: value) ?? customization.hairColor
            },
            .eyeColor: { customization, value in
                customization.eyeColor = EyeColor(rawValue: value) ?? customization.eyeColor
            },
            .outfit: { customization, value in
                customization.outfit = Outfit(rawValue: value) ?? customization.outfit
            },
            .weapon: { customization, value in
                customization.weapon = CharacterWeapon(rawValue: value) ?? customization.weapon
            },
            .accessory: { customization, value in
                customization.accessory = Accessory(rawValue: value)
            },
            .mustache: { customization, value in
                customization.mustache = Mustache(rawValue: value)
            },
            .flower: { customization, value in
                customization.flower = Flower(rawValue: value)
            }
        ]

        setterMap[category]?(&self, value)
    }
}

// MARK: - Body Types (Skin Colors)
enum BodyType: String, CaseIterable, Codable, Identifiable {
    case bodyWhite = "char_body_white"
    case bodyBlue = "char_body_blue"
    case bodyTan = "char_body_tan"
    case bodyTan2 = "char_body_tan_2"
    case bodyTan3 = "char_body_tan_3"
    case bodyPurple = "char_body_purple"
    case bodyDark1 = "char_body_dark_1"
    case bodyDark2 = "char_body_dark_2"
    case bodyGreen = "char_body_green"

    var id: String { self.rawValue }

    var displayName: String {
        switch self {
        case .bodyWhite: return "White"
        case .bodyBlue: return "Blue"
        case .bodyTan: return "Tan"
        case .bodyTan2: return "Tan 2"
        case .bodyTan3: return "Tan 3"
        case .bodyPurple: return "Purple"
        case .bodyDark1: return "Dark 1"
        case .bodyDark2: return "Dark 2"
        case .bodyGreen: return "Green"
        }
    }

    var previewImageName: String {
        switch self {
        case .bodyWhite: return "char_body_white_preview"
        case .bodyBlue: return "char_body_blue_preview"
        case .bodyTan: return "char_body_tan_preview"
        case .bodyTan2: return "char_body_tan_2_preview"
        case .bodyTan3: return "char_body_tan_3_preview"
        case .bodyPurple: return "char_body_purple_preview"
        case .bodyDark1: return "char_body_dark_1_preview"
        case .bodyDark2: return "char_body_dark_2_preview"
        case .bodyGreen: return "char_body_green_preview"
        }
    }

    var isPremium: Bool {
        return false // Remove premium restriction
    }

    var color: Color {
        switch self {
        case .bodyWhite: return Color(red: 0.95, green: 0.85, blue: 0.75)
        case .bodyBlue: return Color(red: 0.7, green: 0.8, blue: 0.9)
        case .bodyTan: return Color(red: 0.90, green: 0.75, blue: 0.55)
        case .bodyTan2: return Color(red: 0.85, green: 0.65, blue: 0.45)
        case .bodyTan3: return Color(red: 0.80, green: 0.60, blue: 0.40)
        case .bodyPurple: return Color(red: 0.8, green: 0.7, blue: 0.9)
        case .bodyDark1: return Color(red: 0.45, green: 0.25, blue: 0.15)
        case .bodyDark2: return Color(red: 0.35, green: 0.20, blue: 0.10)
        case .bodyGreen: return Color(red: 0.7, green: 0.8, blue: 0.6)
        }
    }
}


// MARK: - Hair Styles
enum HairStyle: String, CaseIterable, Codable, Identifiable {
    // Hair Style 1 - Default: black
    case hair1Black = "char_hair_1_black"
    case hair1Blonde = "char_hair_1_blonde"
    case hair1Brown = "char_hair_1_brown"
    case hair1Darkbrown = "char_hair_1_darkbrown"

    // Hair Style 2 - REMOVED (no assets available)

    // Hair Style 3 - Default: black
    case hair3Black = "char_hair_3_black"
    case hair3Blonde = "char_hair_3_blonde"
    case hair3Brown = "char_hair_3_brown"
    case hair3Darkbrown = "char_hair_3_darkbrown"

    // Hair Style 4 - Default: black
    case hair4Black = "char_hair_4_black"
    case hair4Blonde = "char_hair_4_blonde"
    case hair4Brown = "char_hair_4_brown"
    case hair4Darkbrown = "char_hair_4_darkbrown"

    // Hair Style 5 - Default: black
    case hair5Black = "char_hair_5_black"
    case hair5Blonde = "char_hair_5_blonde"
    case hair5Brown = "char_hair_5_brown"
    case hair5Darkbrown = "char_hair_5_darkbrown"

    // Hair Style 10 - Default: brown
    case hair10Brown = "char_hair_10_brown"
    case hair10Darkbrown = "char_hair_10_darkbrown"

    // Hair Style 11 - Default: brown
    case hair11Brown = "char_hair_11_brown"
    case hair11Darkbrown = "char_hair_11_darkbrown"

    // Hair Style 12 - Default: black
    case hair12Black = "char_hair_12_black"

    // Hair Style 13 - Default: red
    case hair13Red = "char_hair_13_red"

    var id: String { self.rawValue }

    // Get the hair type (e.g., "hair1", "hair2", "hair3", etc.)
    var hairType: String {
        let components = self.rawValue.components(separatedBy: "_")
        if components.count >= 3 {
            return components[1] + components[2] // hair1, hair3, hair4, etc.
        }
        return "hair1"
    }

    // Get the hair color from the style
    var hairColor: HairColor {
        if self.rawValue.contains("black") {
            return .black
        } else if self.rawValue.contains("blonde") {
            return .blonde
        } else if self.rawValue.contains("red") {
            return .red
        } else if self.rawValue.contains("darkbrown") {
            return .darkbrown
        } else if self.rawValue.contains("brown") {
            return .brown
        } else {
            return .black // Default fallback
        }
    }

    // Get the default hair style for each hair type
    static func getDefaultStyle(for hairType: String) -> HairStyle {
        switch hairType {
        case "hair1": return .hair1Black
        case "hair3": return .hair3Black
        case "hair4": return .hair4Black
        case "hair5": return .hair5Black
        case "hair10": return .hair10Brown
        case "hair11": return .hair11Brown
        case "hair12": return .hair12Black
        case "hair13": return .hair13Red
        default: return .hair1Black
        }
    }

    // Get the default color for each hair type
    static func getDefaultColor(for hairType: String) -> HairColor {
        switch hairType {
        case "hair1", "hair3", "hair4", "hair5", "hair12": return .black
        case "hair10", "hair11": return .brown
        case "hair13": return .red
        default: return .black
        }
    }

    var displayName: String {
        let hairNumber = hairType.replacingOccurrences(of: "hair", with: "")
        return "Hair Style \(hairNumber)"
    }

    var previewImageName: String {
        switch self {
        // Hair Style 1
        case .hair1Black: return "char_hair_1_black_preview"
        case .hair1Blonde: return "char_hair_1_blonde_preview"
        case .hair1Brown: return "char_hair_1_brown_preview"
        case .hair1Darkbrown: return "char_hair_1_darkbrown_preview"

        // Hair Style 2 - REMOVED

        // Hair Style 3
        case .hair3Black: return "char_hair_3_black_preview"
        case .hair3Blonde: return "char_hair_3_blonde_preview"
        case .hair3Brown: return "char_hair_3_brown_preview"
        case .hair3Darkbrown: return "char_hair_3_darkbrown_preview"

        // Hair Style 4
        case .hair4Black: return "char_hair_4_black_preview"
        case .hair4Blonde: return "char_hair_4_blonde_preview"
        case .hair4Brown: return "char_hair_4_brown_preview"
        case .hair4Darkbrown: return "char_hair_4_darkbrown_preview"

        // Hair Style 5
        case .hair5Black: return "char_hair_5_black_preview"
        case .hair5Blonde: return "char_hair_5_blonde_preview"
        case .hair5Brown: return "char_hair_5_brown_preview"
        case .hair5Darkbrown: return "char_hair_5_darkbrown_preview"

        // Hair Style 10
        case .hair10Brown: return "char_hair_10_brown_preview"
        case .hair10Darkbrown: return "char_hair_10_darkbrown_preview"

        // Hair Style 11
        case .hair11Brown: return "char_hair_11_brown_preview"
        case .hair11Darkbrown: return "char_hair_11_darkbrown_preview"

        // Hair Style 12
        case .hair12Black: return "char_hair_12_black_preview"

        // Hair Style 13
        case .hair13Red: return "char_hair_13_red_preview"
        }
    }

    var isPremium: Bool {
        return false // Remove premium restriction
    }

    // Get unique hair types (for showing in hair style selection)
    static var uniqueHairTypes: [String] {
        let allStyles = HairStyle.allCases
        var seenTypes: Set<String> = []

        for style in allStyles {
            seenTypes.insert(style.hairType)
        }

        return Array(seenTypes).sorted { $0 < $1 }
    }

    // Get all hair styles for a specific hair type
    static func getStylesForType(_ hairType: String) -> [HairStyle] {
        return HairStyle.allCases.filter { $0.hairType == hairType }
    }

    // Get available hair colors for a specific hair type
    static func getAvailableColorsForType(_ hairType: String) -> [HairColor] {
        let styles = getStylesForType(hairType)
        var colors: Set<HairColor> = []

        for style in styles {
            colors.insert(style.hairColor)
        }

        return Array(colors).sorted { $0.rawValue < $1.rawValue }
    }

    // Get the hair style for a specific hair type and color
    static func getStyle(for hairType: String, color: HairColor) -> HairStyle? {
        return HairStyle.allCases.first { $0.hairType == hairType && $0.hairColor == color }
    }
}

// MARK: - Hair Back Styles (New)
enum HairBackStyle: String, CaseIterable, Codable, Identifiable {
    case hair2BackBrown = "char_hair_2_back_brown"
    case hair2BackBlack = "char_hair_2_back_black"
    case hair2BackBlonde = "char_hair_2_back_blonde"
    case hair2BackDarkbrown = "char_hair_2_back_darkbrown"
    case hair6BackBrown = "char_hair_6_back_brown"
    case hair6BackBlack = "char_hair_6_back_black"
    case hair6BackBlonde = "char_hair_6_back_blonde"
    case hair6BackDarkbrown = "char_hair_6_back_darkbrown"
    case hair7BackBrown = "char_hair_7_back_brown"
    case hair7BackBlack = "char_hair_7_back_black"
    case hair7BackBlonde = "char_hair_7_back_blonde"
    case hair7BackDarkbrown = "char_hair_7_back_darkbrown"
    case hair8BackBrown = "char_hair_8_back_brown"
    case hair8BackBlack = "char_hair_8_back_black"
    case hair8BackBlonde = "char_hair_8_back_blonde"
    case hair8BackDarkbrown = "char_hair_8_back_darkbrown"
    case hair9BackBrown = "char_hair_9_back_brown"
    case hair9BackDarkbrown = "char_hair_9_back_darkbrown"

    var id: String { self.rawValue }

    var displayName: String {
        switch self {
        case .hair2BackBrown: return "Back Style 2 Brown"
        case .hair2BackBlack: return "Back Style 2 Black"
        case .hair2BackBlonde: return "Back Style 2 Blonde"
        case .hair2BackDarkbrown: return "Back Style 2 Dark Brown"
        case .hair6BackBrown: return "Back Style 6 Brown"
        case .hair6BackBlack: return "Back Style 6 Black"
        case .hair6BackBlonde: return "Back Style 6 Blonde"
        case .hair6BackDarkbrown: return "Back Style 6 Dark Brown"
        case .hair7BackBrown: return "Back Style 7 Brown"
        case .hair7BackBlack: return "Back Style 7 Black"
        case .hair7BackBlonde: return "Back Style 7 Blonde"
        case .hair7BackDarkbrown: return "Back Style 7 Dark Brown"
        case .hair8BackBrown: return "Back Style 8 Brown"
        case .hair8BackBlack: return "Back Style 8 Black"
        case .hair8BackBlonde: return "Back Style 8 Blonde"
        case .hair8BackDarkbrown: return "Back Style 8 Dark Brown"
        case .hair9BackBrown: return "Back Style 9 Brown"
        case .hair9BackDarkbrown: return "Back Style 9 Dark Brown"
        }
    }

    var previewImageName: String {
        switch self {
        case .hair2BackBrown: return "char_hair_2_back_brown_preview"
        case .hair2BackBlack: return "char_hair_2_back_black_preview"
        case .hair2BackBlonde: return "char_hair_2_back_blonde_preview"
        case .hair2BackDarkbrown: return "char_hair_2_back_darkbrown_preview"
        case .hair6BackBrown: return "char_hair_6_back_brown_preview"
        case .hair6BackBlack: return "char_hair_6_back_black_preview"
        case .hair6BackBlonde: return "char_hair_6_back_blonde_preview"
        case .hair6BackDarkbrown: return "char_hair_6_back_darkbrown_preview"
        case .hair7BackBrown: return "char_hair_7_back_brown_preview"
        case .hair7BackBlack: return "char_hair_7_back_black_preview"
        case .hair7BackBlonde: return "char_hair_7_back_blonde_preview"
        case .hair7BackDarkbrown: return "char_hair_7_back_darkbrown_preview"
        case .hair8BackBrown: return "char_hair_8_back_brown_preview"
        case .hair8BackBlack: return "char_hair_8_back_black_preview"
        case .hair8BackBlonde: return "char_hair_8_back_blonde_preview"
        case .hair8BackDarkbrown: return "char_hair_8_back_darkbrown_preview"
        case .hair9BackBrown: return "char_hair_9_back_brown_preview"
        case .hair9BackDarkbrown: return "char_hair_9_back_darkbrown_preview"
        }
    }

    var isPremium: Bool {
        return false
    }
}

// MARK: - Hair Colors
enum HairColor: String, CaseIterable, Codable, Identifiable {
    case brown = "brown"
    case black = "black"
    case blonde = "blonde"
    case red = "red"
    case darkbrown = "darkbrown"

    var id: String { self.rawValue }

    var displayName: String {
        switch self {
        case .brown: return "Brown"
        case .black: return "Black"
        case .blonde: return "Blonde"
        case .red: return "Red"
        case .darkbrown: return "Dark Brown"
        }
    }

    var color: Color {
        switch self {
        case .brown: return Color(red: 0.4, green: 0.2, blue: 0.1)
        case .black: return Color.black
        case .blonde: return Color(red: 0.9, green: 0.8, blue: 0.6)
        case .red: return Color(red: 0.8, green: 0.2, blue: 0.1)
        case .darkbrown: return Color(red: 0.2, green: 0.1, blue: 0.05)
        }
    }

    var previewImageName: String {
        switch self {
        case .brown: return "char_hair_1_brown_preview"
        case .black: return "char_hair_1_black_preview"
        case .blonde: return "char_hair_1_blonde_preview"
        case .red: return "char_hair_13_red_preview"
        case .darkbrown: return "char_hair_1_darkbrown_preview"
        }
    }

    var isPremium: Bool {
        return false // Remove premium restriction
    }
}

// MARK: - Eye Colors
enum EyeColor: String, CaseIterable, Codable, Identifiable {
    case eyeBlack = "char_eye_black"
    case eyeBlue = "char_eye_blue"
    case eyeGreen = "char_eye_green"

    var id: String { self.rawValue }

    var displayName: String {
        switch self {
        case .eyeBlack: return "Black"
        case .eyeBlue: return "Blue"
        case .eyeGreen: return "Green"
        }
    }

    var previewImageName: String {
        switch self {
        case .eyeBlack: return "char_eye_black_preview"
        case .eyeBlue: return "char_eye_blue_preview"
        case .eyeGreen: return "char_eye_green_preview"
        }
    }

    var isPremium: Bool {
        return false // Remove premium restriction
    }
}

// MARK: - Outfits
enum Outfit: String, CaseIterable, Codable, Identifiable {
    case simple = "char_outfit_simple"
    case iron = "char_outfit_iron_old"
    case outfitVillager = "char_outfit_villager"
    case outfitVillagerBlue = "char_outfit_villager_blue"
    case outfitIron = "char_outfit_iron"
    case outfitIron2 = "char_outfit_iron_2"
    case outfitWizard = "char_outfit_wizard"
    case outfitDress = "char_outfit_dress"
    case outfitFire = "char_outfit_fire"
    case outfitBat = "char_outfit_bat"
    case outfitRed = "char_outfit_red"
    case outfitHoodie = "char_outfit_hoodie"

    var id: String { self.rawValue }

    var displayName: String {
        switch self {
        case .simple: return "Simple"
        case .iron: return "Iron"
        case .outfitVillager: return "Villager"
        case .outfitVillagerBlue: return "Blue Villager"
        case .outfitIron: return "Iron Armor"
        case .outfitIron2: return "Iron Armor 2"
        case .outfitWizard: return "Wizard Robe"
        case .outfitDress: return "Dress"
        case .outfitFire: return "Fire Armor"
        case .outfitBat: return "Bat Armor"
        case .outfitRed: return "Red Armor"
        case .outfitHoodie: return "Hoodie"
        }
    }

    var previewImageName: String {
        switch self {
        case .simple: return "char_outfit_simple_preview"
        case .iron: return "char_outfit_iron_old_preview"
        case .outfitVillager: return "char_outfit_villager_preview"
        case .outfitVillagerBlue: return "char_outfit_villager_blue_preview"
        case .outfitIron: return "char_outfit_iron_preview"
        case .outfitIron2: return "char_outfit_iron_2_preview"
        case .outfitWizard: return "char_outfit_wizard_preview"
        case .outfitDress: return "char_outfit_dress_preview"
        case .outfitFire: return "char_outfit_fire_preview"
        case .outfitBat: return "char_outfit_bat_preview"
        case .outfitRed: return "char_outfit_red_preview"
        case .outfitHoodie: return "char_outfit_hoodie_preview"
        }
    }

    var isPremium: Bool {
        return false // Remove premium restriction
    }
}

// MARK: - Weapons
enum CharacterWeapon: String, CaseIterable, Codable, Identifiable {
    case swordWood = "char_sword_wood"
    case swordIron = "char_sword_iron"
    case swordSteel = "char_sword_steel"
    case swordGold = "char_sword_gold"
    case swordGold2 = "char_sword_gold_2"
    case swordCopper = "char_sword_copper"
    case swordRed = "char_sword_red"
    case swordRed2 = "char_sword_red_2"
    case swordDeadly = "char_sword_deadly"
    case swordAxe = "char_sword_axe"
    case swordAxeSmall = "char_sword_axe_small"
    case swordMace = "char_sword_mace"
    case swordStaff = "char_sword_staff"
    case swordWhip = "char_sword_whip"

    var id: String { self.rawValue }

    var displayName: String {
        switch self {
        case .swordWood: return "Wood Sword"
        case .swordIron: return "Iron Sword"
        case .swordSteel: return "Steel Sword"
        case .swordGold: return "Gold Sword"
        case .swordGold2: return "Gold Sword 2"
        case .swordCopper: return "Copper Sword"
        case .swordRed: return "Red Sword"
        case .swordRed2: return "Red Sword 2"
        case .swordDeadly: return "Deadly Sword"
        case .swordAxe: return "Axe"
        case .swordAxeSmall: return "Small Axe"
        case .swordMace: return "Mace"
        case .swordStaff: return "Staff"
        case .swordWhip: return "Whip"
        }
    }

    var previewImageName: String {
        switch self {
        case .swordWood: return "char_sword_wood_preview"
        case .swordIron: return "char_sword_iron_preview"
        case .swordSteel: return "char_sword_steel_preview"
        case .swordGold: return "char_sword_gold_preview"
        case .swordGold2: return "char_sword_gold_2_preview"
        case .swordCopper: return "char_sword_copper_preview"
        case .swordRed: return "char_sword_red_preview"
        case .swordRed2: return "char_sword_red_2_preview"
        case .swordDeadly: return "char_sword_deadly_preview"
        case .swordAxe: return "char_sword_axe_preview"
        case .swordAxeSmall: return "char_sword_axe_small_preview"
        case .swordMace: return "char_sword_mace_preview"
        case .swordStaff: return "char_sword_staff_preview"
        case .swordWhip: return "char_sword_whip_preview"
        }
    }

    var isPremium: Bool {
        return false // Remove premium restriction
    }
}

// MARK: - Accessories
enum Accessory: String, CaseIterable, Codable, Identifiable {
    case eyeglassRed = "char_glass_red"
    case eyeglassBlue = "char_glass_blue"
    case eyeglassGray = "char_glass_gray"
    case helmetRed = "char_helmet_red"
    case helmetHood = "char_helmet_hood"
    case helmetIron = "char_helmet_iron"
    case cheekBlush = "char_cheek_blush"
    case eyeLashes = "char_eye_lashes"
    case eyelash = "char_eyelash"
    case blush = "char_blush"
    case wingsWhite = "char_wings_white"
    case wingsRed = "char_wings_red"
    case wingsBat = "char_wings_bat"
    case earring1 = "char_earring_1"
    case earring2 = "char_earring_2"
    case petCat2 = "char_pet_cat_2"

    var id: String { self.rawValue }

    var displayName: String {
        switch self {
        case .eyeglassRed: return "Red Glasses"
        case .eyeglassBlue: return "Blue Glasses"
        case .eyeglassGray: return "Gray Glasses"
        case .helmetRed: return "Red Helmet"
        case .helmetHood: return "Hood Helmet"
        case .helmetIron: return "Iron Helmet"
        case .cheekBlush: return "Blush"
        case .eyeLashes: return "Eyelashes"
        case .eyelash: return "Eyelash"
        case .blush: return "Blush"
        case .wingsWhite: return "White Wings"
        case .wingsRed: return "Red Wings"
        case .wingsBat: return "Bat Wings"
        case .earring1: return "Earring 1"
        case .earring2: return "Earring 2"
        case .petCat2: return "Pet Cat"
        }
    }

    var previewImageName: String {
        switch self {
        case .eyeglassRed: return "char_glass_red_preview"
        case .eyeglassBlue: return "char_glass_blue_preview"
        case .eyeglassGray: return "char_glass_gray_preview"
        case .helmetRed: return "char_helmet_red_preview"
        case .helmetHood: return "char_helmet_hood_preview"
        case .helmetIron: return "char_helmet_iron_preview"
        case .cheekBlush: return "char_cheek_blush_preview"
        case .eyeLashes: return "char_eye_lashes_preview"
        case .eyelash: return "char_eyelash_preview"
        case .blush: return "char_blush_preview"
        case .wingsWhite: return "char_wings_white_preview"
        case .wingsRed: return "char_wings_red_preview"
        case .wingsBat: return "char_wings_bat_preview"
        case .earring1: return "char_earring_1_preview"
        case .earring2: return "char_earring_2_preview"
        case .petCat2: return "char_pet_cat_2_preview"
        }
    }

    var isPremium: Bool {
        return false // Remove premium restriction
    }
}

// MARK: - Mustaches (New)
enum Mustache: String, CaseIterable, Codable, Identifiable {
    case mustache1Brown = "char_mustache_1_brown"
    case mustache1Black = "char_mustache_1_black"
    case mustache1Blonde = "char_mustache_1_blonde"
    case mustache1Darkbrown = "char_mustache_1_darkbrown"
    case mustache2Brown = "char_mustache_2_brown"
    case mustache2Black = "char_mustache_2_black"
    case mustache2Blonde = "char_mustache_2_blonde"
    case mustache2Darkbrown = "char_mustache_2_darkbrown"

    var id: String { self.rawValue }

    var displayName: String {
        switch self {
        case .mustache1Brown: return "Mustache 1 Brown"
        case .mustache1Black: return "Mustache 1 Black"
        case .mustache1Blonde: return "Mustache 1 Blonde"
        case .mustache1Darkbrown: return "Mustache 1 Dark Brown"
        case .mustache2Brown: return "Mustache 2 Brown"
        case .mustache2Black: return "Mustache 2 Black"
        case .mustache2Blonde: return "Mustache 2 Blonde"
        case .mustache2Darkbrown: return "Mustache 2 Dark Brown"
        }
    }

    var previewImageName: String {
        switch self {
        case .mustache1Brown: return "char_mustache_1_brown_preview"
        case .mustache1Black: return "char_mustache_1_black_preview"
        case .mustache1Blonde: return "char_mustache_1_blonde_preview"
        case .mustache1Darkbrown: return "char_mustache_1_darkbrown_preview"
        case .mustache2Brown: return "char_mustache_2_brown_preview"
        case .mustache2Black: return "char_mustache_2_black_preview"
        case .mustache2Blonde: return "char_mustache_2_blonde_preview"
        case .mustache2Darkbrown: return "char_mustache_2_darkbrown_preview"
        }
    }

    var isPremium: Bool {
        return false
    }
}

// MARK: - Flowers (New)
enum Flower: String, CaseIterable, Codable, Identifiable {
    case flowerGreen = "char_flower_green"
    case flowerBlue = "char_flower_blue"
    case flowerPurple = "char_flower_purple"

    var id: String { self.rawValue }

    var displayName: String {
        switch self {
        case .flowerGreen: return "Green Flower"
        case .flowerBlue: return "Blue Flower"
        case .flowerPurple: return "Purple Flower"
        }
    }

    var previewImageName: String {
        switch self {
        case .flowerGreen: return "char_flower_green_preview"
        case .flowerBlue: return "char_flower_blue_preview"
        case .flowerPurple: return "char_flower_purple_preview"
        }
    }

    var isPremium: Bool {
        return false
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

    var hairBackImageName: String? {
        return customization.hairBackStyle?.rawValue
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

    var mustacheImageName: String? {
        return customization.mustache?.rawValue
    }

    var flowerImageName: String? {
        return customization.flower?.rawValue
    }
}
