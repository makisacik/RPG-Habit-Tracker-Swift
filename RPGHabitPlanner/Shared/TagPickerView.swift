//
//  TagPickerView.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 14.08.2025.
//

import SwiftUI

struct TagPickerView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.dismiss) private var dismiss
    
    @StateObject private var viewModel: TagPickerViewModel
    let onTagsSelected: ([Tag]) -> Void
    
    init(selectedTags: [Tag], onTagsSelected: @escaping ([Tag]) -> Void) {
        self._viewModel = StateObject(wrappedValue: TagPickerViewModel(selectedTags: selectedTags))
        self.onTagsSelected = onTagsSelected
    }
    
    var body: some View {
        let theme = themeManager.activeTheme
        
        NavigationView {
            VStack(spacing: 0) {
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(theme.textColor.opacity(0.6))
                    
                    TextField("Search tags...", text: $viewModel.searchQuery)
                        .textFieldStyle(PlainTextFieldStyle())
                        .font(.appFont(size: 16, weight: .regular))
                    
                    if !viewModel.searchQuery.isEmpty {
                        Button(action: {
                            viewModel.searchQuery = ""
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(theme.textColor.opacity(0.6))
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(theme.cardBackgroundColor)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(theme.textColor.opacity(0.2), lineWidth: 1)
                        )
                )
                .padding(.horizontal, 16)
                .padding(.top, 16)
                
                // Selected tags
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
                        .padding(.top, 16)
                        
                        TagChipRow(
                            tags: viewModel.selectedTags,
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
                
                // Available tags list
                if viewModel.filteredTags.isEmpty && !viewModel.searchQuery.isEmpty {
                    // No search results
                    VStack(spacing: 12) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 32))
                            .foregroundColor(theme.textColor.opacity(0.5))
                        
                        Text("No tags found")
                            .font(.appFont(size: 16, weight: .medium))
                            .foregroundColor(theme.textColor.opacity(0.7))
                        
                        Button("Create New Tag") {
                            viewModel.showCreateTag = true
                        }
                        .font(.appFont(size: 14, weight: .medium))
                        .foregroundColor(theme.accentColor)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if viewModel.filteredTags.isEmpty {
                    // No tags available
                    VStack(spacing: 12) {
                        Image(systemName: "tag")
                            .font(.system(size: 32))
                            .foregroundColor(theme.textColor.opacity(0.5))
                        
                        Text("No tags available")
                            .font(.appFont(size: 16, weight: .medium))
                            .foregroundColor(theme.textColor.opacity(0.7))
                        
                        Button("Create New Tag") {
                            viewModel.showCreateTag = true
                        }
                        .font(.appFont(size: 14, weight: .medium))
                        .foregroundColor(theme.accentColor)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    // Tags list
                    List {
                        ForEach(viewModel.filteredTags) { tag in
                            TagRowView(
                                tag: tag,
                                isSelected: viewModel.selectedTags.contains(tag)
                            ) {
                                    viewModel.toggleTagSelection(tag)
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("Select Tags")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(theme.accentColor)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        onTagsSelected(viewModel.selectedTags)
                        dismiss()
                    }
                    .foregroundColor(theme.accentColor)
                }
            }
        }
        .sheet(isPresented: $viewModel.showCreateTag) {
            CreateTagView { newTag in
                viewModel.addNewTag(newTag)
            }
        }
    }
}

struct TagRowView: View {
    @EnvironmentObject var themeManager: ThemeManager
    let tag: Tag
    let isSelected: Bool
    let onToggle: () -> Void
    
    var body: some View {
        let theme = themeManager.activeTheme
        
        Button(action: onToggle) {
            HStack(spacing: 12) {
                // Selection indicator
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 20))
                    .foregroundColor(isSelected ? theme.accentColor : theme.textColor.opacity(0.5))
                
                // Tag chip
                TagChip(
                    tag: tag,
                    onTap: onToggle
                )
                
                Spacer()
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

class TagPickerViewModel: ObservableObject {
    @Published var selectedTags: [Tag] = []
    @Published var allTags: [Tag] = []
    @Published var searchQuery: String = ""
    @Published var showCreateTag: Bool = false
    
    private let tagService: TagServiceProtocol = TagService()
    
    var filteredTags: [Tag] {
        if searchQuery.isEmpty {
            return allTags
        } else {
            return allTags.filter { tag in
                tag.name.localizedCaseInsensitiveContains(searchQuery)
            }
        }
    }
    
    init(selectedTags: [Tag]) {
        self.selectedTags = selectedTags
        loadTags()
    }
    
    func loadTags() {
        tagService.fetchAllTags { [weak self] tags, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ Error loading tags: \(error)")
                } else {
                    self?.allTags = tags
                }
            }
        }
    }
    
    func toggleTagSelection(_ tag: Tag) {
        if let index = selectedTags.firstIndex(of: tag) {
            selectedTags.remove(at: index)
        } else {
            selectedTags.append(tag)
        }
    }
    
    func clearAllTags() {
        selectedTags.removeAll()
    }
    
    func addNewTag(_ tag: Tag) {
        allTags.append(tag)
        selectedTags.append(tag)
    }
}

#Preview {
    TagPickerView(selectedTags: []) { tags in
        print("Selected tags: \(tags.map { $0.name })")
    }
    .environmentObject(ThemeManager.shared)
}
