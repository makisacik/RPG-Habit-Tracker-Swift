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
            ZStack {
                // Background
                theme.backgroundColor.ignoresSafeArea()

                VStack(spacing: 0) {
                    // Modern search bar with glassmorphism effect
                    HStack(spacing: 12) {
                        HStack(spacing: 10) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(theme.textColor.opacity(0.7))

                            TextField("Search tags...", text: $viewModel.searchQuery)
                                .textFieldStyle(PlainTextFieldStyle())
                                .font(.appFont(size: 16, weight: .regular))
                                .foregroundColor(theme.textColor)

                            if !viewModel.searchQuery.isEmpty {
                                Button(action: {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        viewModel.searchQuery = ""
                                    }
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(theme.textColor.opacity(0.6))
                                }
                                .transition(.scale.combined(with: .opacity))
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(theme.cardBackgroundColor)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(theme.textColor.opacity(0.1), lineWidth: 1)
                                )
                                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
                        )

                        // Create new tag button
                        Button(action: {
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                viewModel.showCreateTag = true
                            }
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 24, weight: .medium))
                                .foregroundColor(theme.accentColor)
                                .frame(width: 44, height: 44)
                                .background(
                                    Circle()
                                        .fill(theme.cardBackgroundColor)
                                        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                                )
                        }
                        .scaleEffect(viewModel.showCreateTag ? 0.9 : 1.0)
                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: viewModel.showCreateTag)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)

                    // Selected tags section with modern card design
                    if !viewModel.selectedTags.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Selected Tags")
                                    .font(.appFont(size: 18, weight: .bold))
                                    .foregroundColor(theme.textColor)

                                // Spacer()

                                Text("\(viewModel.selectedTags.count)")
                                    .font(.appFont(size: 14, weight: .medium))
                                    .foregroundColor(theme.textColor.opacity(0.7))
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(
                                        Capsule()
                                            .fill(theme.accentColor.opacity(0.1))
                                    )

                                Button(action: {
                                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                        viewModel.clearAllTags()
                                    }
                                }) {
                                    Text("Clear All")
                                        .font(.appFont(size: 14, weight: .medium))
                                        .foregroundColor(theme.accentColor)
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 12)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(viewModel.selectedTags) { tag in
                                        TagChip(
                                            tag: tag,
                                            isSelected: true,
                                            isRemovable: true,
                                            onTap: {
                                                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                                    viewModel.toggleTagSelection(tag)
                                                }
                                            },
                                            onRemove: {
                                                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                                    viewModel.toggleTagSelection(tag)
                                                }
                                            }
                                        )
                                        .transition(.asymmetric(
                                            insertion: .scale.combined(with: .opacity),
                                            removal: .scale.combined(with: .opacity)
                                        ))
                                    }
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 4)
                            }
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(theme.cardBackgroundColor)
                                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
                        )
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                    }

                    // Available tags section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Available Tags")
                                .font(.appFont(size: 18, weight: .bold))
                                .foregroundColor(theme.textColor)

                            Spacer()

                            Text("\(viewModel.filteredTags.count)")
                                .font(.appFont(size: 14, weight: .medium))
                                .foregroundColor(theme.textColor.opacity(0.7))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    Capsule()
                                        .fill(theme.textColor.opacity(0.1))
                                )
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)

                        if viewModel.filteredTags.isEmpty && !viewModel.searchQuery.isEmpty {
                            // No search results with modern empty state
                            VStack(spacing: 20) {
                                Image(systemName: "magnifyingglass")
                                    .font(.system(size: 48, weight: .light))
                                    .foregroundColor(theme.textColor.opacity(0.3))
                                    .scaleEffect(1.2)

                                VStack(spacing: 8) {
                                    Text("No tags found")
                                        .font(.appFont(size: 20, weight: .bold))
                                        .foregroundColor(theme.textColor)

                                    Text("Try adjusting your search or create a new tag")
                                        .font(.appFont(size: 16, weight: .regular))
                                        .foregroundColor(theme.textColor.opacity(0.7))
                                        .multilineTextAlignment(.center)
                                }

                                Button(action: {
                                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                        viewModel.showCreateTag = true
                                    }
                                }) {
                                    HStack(spacing: 8) {
                                        Image(systemName: "plus.circle.fill")
                                            .font(.system(size: 16, weight: .medium))
                                        Text("Create New Tag")
                                            .font(.appFont(size: 16, weight: .medium))
                                    }
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 24)
                                    .padding(.vertical, 12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(theme.accentColor)
                                            .shadow(color: theme.accentColor.opacity(0.3), radius: 8, x: 0, y: 4)
                                    )
                                }
                                .scaleEffect(viewModel.showCreateTag ? 0.95 : 1.0)
                                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: viewModel.showCreateTag)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .padding(.horizontal, 40)
                        } else if viewModel.filteredTags.isEmpty && viewModel.isLoading {
                            // Loading state for available tags
                            VStack(spacing: 20) {
                                ProgressView()
                                    .scaleEffect(1.5)
                                    .padding(.bottom, 10)
                                Text("Loading tags...")
                                    .font(.appFont(size: 18, weight: .bold))
                                    .foregroundColor(theme.textColor)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .padding(.horizontal, 40)
                        } else if viewModel.filteredTags.isEmpty {
                            // No tags available with modern empty state
                            VStack(spacing: 20) {
                                Image(systemName: "tag")
                                    .font(.system(size: 48, weight: .light))
                                    .foregroundColor(theme.textColor.opacity(0.3))
                                    .scaleEffect(1.2)

                                VStack(spacing: 8) {
                                    Text("No tags available")
                                        .font(.appFont(size: 20, weight: .bold))
                                        .foregroundColor(theme.textColor)

                                    Text("Create your first tag to get started")
                                        .font(.appFont(size: 16, weight: .regular))
                                        .foregroundColor(theme.textColor.opacity(0.7))
                                        .multilineTextAlignment(.center)
                                }

                                Button(action: {
                                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                        viewModel.showCreateTag = true
                                    }
                                }) {
                                    HStack(spacing: 8) {
                                        Image(systemName: "plus.circle.fill")
                                            .font(.system(size: 16, weight: .medium))
                                        Text("Create Your First Tag")
                                            .font(.appFont(size: 16, weight: .medium))
                                    }
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 24)
                                    .padding(.vertical, 12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(theme.accentColor)
                                            .shadow(color: theme.accentColor.opacity(0.3), radius: 8, x: 0, y: 4)
                                    )
                                }
                                .scaleEffect(viewModel.showCreateTag ? 0.95 : 1.0)
                                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: viewModel.showCreateTag)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .padding(.horizontal, 40)
                        } else {
                            // Modern tags list with smooth animations
                            ScrollView {
                                VStack(spacing: 8) {
                                    ForEach(viewModel.filteredTags) { tag in
                                        ModernTagRowView(
                                            tag: tag,
                                            isSelected: viewModel.selectedTags.contains(tag)
                                        ) {
                                            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                                viewModel.toggleTagSelection(tag)
                                            }
                                        }
                                        .transition(.asymmetric(
                                            insertion: .move(edge: .trailing).combined(with: .opacity),
                                            removal: .move(edge: .leading).combined(with: .opacity)
                                        ))
                                    }
                                }
                                .padding(.horizontal, 20)
                                .padding(.bottom, 20)
                            }
                        }
                    }

                    Spacer()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Select Tags")
                        .font(.appFont(size: 20, weight: .bold))
                        .foregroundColor(theme.textColor)
                }

                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            dismiss()
                        }
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .medium))
                            Text("Cancel")
                                .font(.appFont(size: 16, weight: .medium))
                        }
                        .foregroundColor(theme.accentColor)
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            onTagsSelected(viewModel.selectedTags)
                            dismiss()
                        }
                    }) {
                        Text("Done")
                            .font(.appFont(size: 16, weight: .bold))
                            .foregroundColor(viewModel.selectedTags.isEmpty ? theme.textColor.opacity(0.5) : theme.accentColor)
                    }
                    .disabled(viewModel.selectedTags.isEmpty)
                }
            }
        }
        .sheet(isPresented: $viewModel.showCreateTag) {
            CreateTagView { newTag in
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    viewModel.addNewTag(newTag)
                }
            }
        }
    }
}

struct ModernTagRowView: View {
    @EnvironmentObject var themeManager: ThemeManager
    let tag: Tag
    let isSelected: Bool
    let onToggle: () -> Void

    var body: some View {
        let theme = themeManager.activeTheme

        Button(action: onToggle) {
            HStack(spacing: 16) {
                // Modern selection indicator
                ZStack {
                    Circle()
                        .stroke(isSelected ? theme.accentColor : theme.textColor.opacity(0.3), lineWidth: 2)
                        .frame(width: 24, height: 24)

                    if isSelected {
                        Circle()
                            .fill(theme.accentColor)
                            .frame(width: 16, height: 16)
                            .scaleEffect(isSelected ? 1.0 : 0.0)
                            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
                    }
                }

                // Tag chip with enhanced styling
                TagChip(
                    tag: tag,
                    onTap: onToggle
                )

                Spacer()

                // Selection checkmark
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(theme.accentColor)
                        .scaleEffect(isSelected ? 1.0 : 0.0)
                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(theme.cardBackgroundColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(isSelected ? theme.accentColor.opacity(0.3) : Color.clear, lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.03), radius: 4, x: 0, y: 2)
            )
            .scaleEffect(isSelected ? 1.02 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

class TagPickerViewModel: ObservableObject {
    @Published var selectedTags: [Tag] = []
    @Published var allTags: [Tag] = []
    @Published var searchQuery: String = ""
    @Published var showCreateTag: Bool = false
    @Published var isLoading: Bool = true

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
        isLoading = true
        tagService.fetchAllTags { [weak self] tags, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let error = error {
                    print("❌ Error loading tags: \(error)")
                } else {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        self?.allTags = tags
                    }
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
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            allTags.append(tag)
            // Sort tags alphabetically by name
            allTags.sort { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
            selectedTags.append(tag)
        }
    }
}

#Preview {
    TagPickerView(selectedTags: []) { tags in
        print("Selected tags: \(tags.map { $0.name })")
    }
    .environmentObject(ThemeManager.shared)
}
