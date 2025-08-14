//
//  TagFilterView.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 14.08.2025.
//

import SwiftUI

struct TagFilterView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @ObservedObject var viewModel: TagFilterViewModel
    
    var body: some View {
        let theme = themeManager.activeTheme
        
        VStack(spacing: 12) {
            // Header with match mode toggle
            HStack {
                Text("Filter by Tags")
                    .font(.appFont(size: 16, weight: .bold))
                    .foregroundColor(theme.textColor)
                
                Spacer()
                
                // Match mode toggle
                Picker("Match Mode", selection: $viewModel.matchMode) {
                    Text("Any").tag(TagMatchMode.any)
                    Text("All").tag(TagMatchMode.all)
                }
                .pickerStyle(SegmentedPickerStyle())
                .frame(width: 120)
            }
            .padding(.horizontal, 16)
            
            // Selected tags row
            if !viewModel.selectedTags.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Selected (\(viewModel.selectedTags.count))")
                            .font(.appFont(size: 14, weight: .medium))
                            .foregroundColor(theme.textColor)
                        
                        Spacer()
                        
                        Button("Clear All") {
                            viewModel.clearAllTags()
                        }
                        .font(.appFont(size: 14, weight: .medium))
                        .foregroundColor(theme.accentColor)
                    }
                    .padding(.horizontal, 16)
                    
                    TagChipRow(
                        tags: Array(viewModel.selectedTags),
                        isSelectable: false,
                        selectedTags: [],
                        onTagTap: { tag in
                            viewModel.toggleTagSelection(tag)
                        },
                        onTagRemove: { tag in
                            viewModel.toggleTagSelection(tag)
                        }
                    )
                }
            }
            
            // Available tags
            if !viewModel.availableTags.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Available Tags")
                        .font(.appFont(size: 14, weight: .medium))
                        .foregroundColor(theme.textColor)
                        .padding(.horizontal, 16)
                    
                    TagChipRow(
                        tags: viewModel.availableTags,
                        isSelectable: true,
                        selectedTags: viewModel.selectedTags
                    ) { tag in
                            viewModel.toggleTagSelection(tag)
                    }
                }
            } else {
                // Empty state
                VStack(spacing: 8) {
                    Image(systemName: "tag")
                        .font(.system(size: 32))
                        .foregroundColor(theme.textColor.opacity(0.5))
                    
                    Text("No tags available")
                        .font(.appFont(size: 14, weight: .medium))
                        .foregroundColor(theme.textColor.opacity(0.7))
                    
                    Button("Create New Tag") {
                        viewModel.showCreateTag = true
                    }
                    .font(.appFont(size: 14, weight: .medium))
                    .foregroundColor(theme.accentColor)
                }
                .padding(.vertical, 20)
            }
        }
        .sheet(isPresented: $viewModel.showCreateTag) {
            CreateTagView { newTag in
                viewModel.addNewTag(newTag)
            }
        }
    }
}

class TagFilterViewModel: ObservableObject {
    @Published var selectedTags: Set<Tag> = []
    @Published var availableTags: [Tag] = []
    @Published var matchMode: TagMatchMode = .any
    @Published var showCreateTag: Bool = false
    
    private let tagService: TagServiceProtocol
    private let onFilterChange: ([UUID], TagMatchMode) -> Void
    
    init(tagService: TagServiceProtocol = TagService(), onFilterChange: @escaping ([UUID], TagMatchMode) -> Void) {
        self.tagService = tagService
        self.onFilterChange = onFilterChange
        loadTags()
    }
    
    func loadTags() {
        tagService.fetchAllTags { [weak self] tags, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ Error loading tags: \(error)")
                } else {
                    self?.availableTags = tags
                }
            }
        }
    }
    
    func toggleTagSelection(_ tag: Tag) {
        if selectedTags.contains(tag) {
            selectedTags.remove(tag)
        } else {
            selectedTags.insert(tag)
        }
        
        notifyFilterChange()
    }
    
    func clearAllTags() {
        selectedTags.removeAll()
        notifyFilterChange()
    }
    
    func addNewTag(_ tag: Tag) {
        availableTags.append(tag)
        selectedTags.insert(tag)
        notifyFilterChange()
    }
    
    private func notifyFilterChange() {
        let selectedTagIds = selectedTags.map { $0.id }
        onFilterChange(selectedTagIds, matchMode)
    }
}

#Preview {
    TagFilterView(viewModel: TagFilterViewModel { tagIds, matchMode in
        print("Filter changed: \(tagIds), mode: \(matchMode)")
    })
    .environmentObject(ThemeManager.shared)
}
