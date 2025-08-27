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

        VStack(spacing: 16) {
            // Modern header with match mode toggle
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "tag.fill")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(theme.accentColor)

                    Text("filter_by_tags".localized)
                        .font(.appFont(size: 16, weight: .bold))
                        .foregroundColor(theme.textColor)
                }

                Spacer()

                // Modern match mode toggle
                HStack(spacing: 4) {
                    Button(action: {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                            viewModel.matchMode = .any
                        }
                    }) {
                        Text("any".localized)
                            .font(.appFont(size: 12, weight: .medium))
                            .foregroundColor(viewModel.matchMode == .any ? .white : theme.textColor.opacity(0.7))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(viewModel.matchMode == .any ? theme.accentColor : theme.cardBackgroundColor)
                                    .shadow(color: viewModel.matchMode == .any ? theme.accentColor.opacity(0.3) : Color.clear, radius: 4, x: 0, y: 2)
                            )
                    }
                    .buttonStyle(PlainButtonStyle())

                    Button(action: {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                            viewModel.matchMode = .all
                        }
                    }) {
                        Text("all".localized)
                            .font(.appFont(size: 12, weight: .medium))
                            .foregroundColor(viewModel.matchMode == .all ? .white : theme.textColor.opacity(0.7))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(viewModel.matchMode == .all ? theme.accentColor : theme.cardBackgroundColor)
                                    .shadow(color: viewModel.matchMode == .all ? theme.accentColor.opacity(0.3) : Color.clear, radius: 4, x: 0, y: 2)
                            )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(4)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(theme.backgroundColor)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(theme.textColor.opacity(0.1), lineWidth: 1)
                        )
                )
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)

            // Selected tags section with modern design
            if !viewModel.selectedTags.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        HStack(spacing: 6) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(theme.textColor)

                            Text(String(format: "selected_tags_count".localized, viewModel.selectedTags.count))
                                .font(.appFont(size: 14, weight: .bold))
                                .foregroundColor(theme.textColor)
                        }

                        Spacer()

                        Button(action: {
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                viewModel.clearAllTags()
                            }
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 12, weight: .medium))
                                Text("clear_all".localized)
                                    .font(.appFont(size: 12, weight: .medium))
                            }
                            .foregroundColor(theme.textColor)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(theme.textColor.opacity(0.1))
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding(.horizontal, 16)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(Array(viewModel.selectedTags), id: \.id) { tag in
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
                        .padding(.horizontal, 16)
                        .padding(.bottom, 8)
                    }
                }
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(theme.cardBackgroundColor)
                        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
                )
                .padding(.horizontal, 16)
            }

            // Available tags section with modern design
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    HStack(spacing: 6) {
                        Image(systemName: "tag")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(theme.textColor.opacity(0.7))

                        Text("available_tags".localized)
                            .font(.appFont(size: 14, weight: .bold))
                            .foregroundColor(theme.textColor)
                    }

                    Spacer()

                    Text("\(viewModel.availableTags.count)")
                        .font(.appFont(size: 12, weight: .medium))
                        .foregroundColor(theme.textColor.opacity(0.7))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(theme.textColor.opacity(0.1))
                        )
                }
                .padding(.horizontal, 16)

                if !viewModel.availableTags.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(viewModel.availableTags, id: \.id) { tag in
                                TagChip(
                                    tag: tag,
                                    isSelected: viewModel.selectedTags.contains(tag)
                                ) {
                                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                            viewModel.toggleTagSelection(tag)
                                        }
                                }
                                .scaleEffect(viewModel.selectedTags.contains(tag) ? 1.05 : 1.0)
                                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: viewModel.selectedTags.contains(tag))
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 8)
                    }
                } else {
                    // Modern empty state
                    VStack(spacing: 12) {
                        Image(systemName: "tag")
                            .font(.system(size: 32, weight: .light))
                            .foregroundColor(theme.textColor.opacity(0.3))
                            .scaleEffect(1.2)

                        VStack(spacing: 4) {
                            Text("no_tags_available".localized)
                                .font(.appFont(size: 16, weight: .bold))
                                .foregroundColor(theme.textColor)

                            Text("create_first_tag_to_get_started".localized)
                                .font(.appFont(size: 14, weight: .regular))
                                .foregroundColor(theme.textColor.opacity(0.7))
                                .multilineTextAlignment(.center)
                        }

                        Button(action: {
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                viewModel.showCreateTag = true
                            }
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 14, weight: .medium))
                                Text("create_new_tag".localized)
                                    .font(.appFont(size: 14, weight: .medium))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(theme.accentColor)
                                    .shadow(color: theme.accentColor.opacity(0.3), radius: 6, x: 0, y: 3)
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        .scaleEffect(viewModel.showCreateTag ? 0.95 : 1.0)
                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: viewModel.showCreateTag)
                    }
                    .padding(.vertical, 24)
                    .padding(.horizontal, 16)
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(theme.cardBackgroundColor)
                    .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
            )
            .padding(.horizontal, 16)
            .padding(.bottom, 8)
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
                    withAnimation(.easeInOut(duration: 0.3)) {
                        self?.availableTags = tags
                    }
                }
            }
        }
    }

    func toggleTagSelection(_ tag: Tag) {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            if selectedTags.contains(tag) {
                selectedTags.remove(tag)
            } else {
                selectedTags.insert(tag)
            }
        }

        notifyFilterChange()
    }

    func clearAllTags() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            selectedTags.removeAll()
        }
        notifyFilterChange()
    }

    func addNewTag(_ tag: Tag) {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            availableTags.append(tag)
            selectedTags.insert(tag)
        }
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
