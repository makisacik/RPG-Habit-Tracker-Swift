//
//  TagFilterManager.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 14.08.2025.
//

import Foundation

enum FilterScreen: String, CaseIterable {
    case calendar = "calendar"
    case questTracking = "questTracking"
}

class TagFilterManager {
    static let shared = TagFilterManager()

    private let userDefaults = UserDefaults.standard
    private let selectedTagsKey = "selectedTagIds"
    private let matchModeKey = "matchMode"

    private init() {}

    // MARK: - Save Filter Settings

    func saveFilterSettings(
        for screen: FilterScreen,
        selectedTagIds: [UUID],
        matchMode: TagMatchMode
    ) {
        let screenKey = screen.rawValue
        let tagIdsData = selectedTagIds.map { $0.uuidString }

        userDefaults.set(tagIdsData, forKey: "\(screenKey)_\(selectedTagsKey)")
        userDefaults.set(matchMode == .any ? "any" : "all", forKey: "\(screenKey)_\(matchModeKey)")
    }

    // MARK: - Load Filter Settings

    func loadFilterSettings(for screen: FilterScreen) -> (selectedTagIds: [UUID], matchMode: TagMatchMode) {
        let screenKey = screen.rawValue

        // Load selected tag IDs
        let tagIdsData = userDefaults.stringArray(forKey: "\(screenKey)_\(selectedTagsKey)") ?? []
        let selectedTagIds = tagIdsData.compactMap { UUID(uuidString: $0) }

        // Load match mode
        let matchModeString = userDefaults.string(forKey: "\(screenKey)_\(matchModeKey)") ?? "any"
        let matchMode: TagMatchMode = matchModeString == "all" ? .all : .any

        return (selectedTagIds, matchMode)
    }

    // MARK: - Clear Filter Settings

    func clearFilterSettings(for screen: FilterScreen) {
        let screenKey = screen.rawValue
        userDefaults.removeObject(forKey: "\(screenKey)_\(selectedTagsKey)")
        userDefaults.removeObject(forKey: "\(screenKey)_\(matchModeKey)")
    }

    // MARK: - Clear All Filter Settings

    func clearAllFilterSettings() {
        for screen in FilterScreen.allCases {
            clearFilterSettings(for: screen)
        }
    }

    // MARK: - Check if filters are active

    func hasActiveFilters(for screen: FilterScreen) -> Bool {
        let settings = loadFilterSettings(for: screen)
        return !settings.selectedTagIds.isEmpty
    }

    // MARK: - Get filter summary

    func getFilterSummary(for screen: FilterScreen) -> String? {
        let settings = loadFilterSettings(for: screen)

        guard !settings.selectedTagIds.isEmpty else { return nil }

        let tagCount = settings.selectedTagIds.count
        let modeText = settings.matchMode == .any ? "Any" : "All"

        if tagCount == 1 {
            return "1 tag (\(modeText))"
        } else {
            return "\(tagCount) tags (\(modeText))"
        }
    }
}
