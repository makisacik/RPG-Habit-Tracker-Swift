//
//  Tag.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 14.08.2025.
//

import Foundation
import SwiftUI

struct Tag: Identifiable, Equatable, Hashable {
    let id: UUID
    var name: String
    var nameNormalized: String
    var icon: String?
    var color: String?

    init(
        id: UUID = UUID(),
        name: String,
        icon: String? = nil,
        color: String? = nil
    ) {
        self.id = id
        self.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        self.nameNormalized = name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        self.icon = icon
        self.color = color
    }
}

extension Tag {
    init(entity: TagEntity) {
        self.id = entity.id ?? UUID()
        self.name = entity.name ?? ""
        // Handle migration case where nameNormalized might be nil
        if let nameNormalized = entity.nameNormalized, !nameNormalized.isEmpty {
            self.nameNormalized = nameNormalized
        } else {
            // Fallback to computing from name
            self.nameNormalized = (entity.name ?? "").trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        }
        self.icon = entity.icon
        self.color = entity.color
    }

    var displayColor: Color {
        if let colorString = color {
            return Color(hex: colorString)
        }
        return .blue
    }

    var displayIcon: String {
        return icon ?? "tag"
    }
}

// MARK: - Tag Color Palette
extension Tag {
    static let colorPalette: [String] = [
        "#FF6B6B", // Red
        "#4ECDC4", // Teal
        "#45B7D1", // Blue
        "#96CEB4", // Green
        "#FFEAA7", // Yellow
        "#DDA0DD", // Plum
        "#FFB347", // Orange
        "#98D8C8", // Mint
        "#F7DC6F", // Gold
        "#BB8FCE", // Purple
        "#85C1E9", // Light Blue
        "#F8C471", // Light Orange
        "#82E0AA", // Light Green
        "#F1948A", // Light Red
        "#D7BDE2"  // Light Purple
    ]

    static let iconSet: [String] = [
        "tag", "star", "heart", "bookmark", "flag", "bolt", "fire", "leaf", "moon", "sun",
        "cloud", "drop", "flame", "gift", "key", "lock", "map", "music", "pencil", "phone",
        "camera", "gamecontroller", "cart", "bag", "creditcard", "house", "car", "airplane",
        "bicycle", "bus", "tram", "train", "ship", "rocket", "umbrella", "scissors", "hammer",
        "wrench", "gear", "lightbulb", "battery", "wifi", "antenna", "satellite", "radio",
        "tv", "computer", "laptop", "tablet", "mobile", "watch", "clock", "calendar",
        "alarm", "timer", "stopwatch", "hourglass", "compass", "globe", "map", "location",
        "pin", "flag", "banner", "trophy", "medal", "crown", "gem", "diamond", "ruby",
        "emerald", "sapphire", "pearl", "crystal", "magic", "sparkles", "rainbow", "unicorn"
    ]
}
