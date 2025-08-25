//
//  CreateTagView.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 14.08.2025.
//

import SwiftUI

struct CreateTagView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.dismiss) private var dismiss

    @StateObject private var viewModel = CreateTagViewModel()
    let onTagCreated: (Tag) -> Void

    var body: some View {
        let theme = themeManager.activeTheme

        NavigationView {
            ZStack {
                // Background
                theme.backgroundColor.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Large Preview Section
                        VStack(spacing: 16) {
                            Text(String(localized: "preview"))
                                .font(.appFont(size: 20, weight: .bold))
                                .foregroundColor(theme.textColor)
                                .frame(maxWidth: .infinity, alignment: .leading)

                            if !viewModel.tagName.isEmpty {
                                TagChip(
                                    tag: Tag(
                                        name: viewModel.tagName,
                                        icon: viewModel.selectedIcon,
                                        color: viewModel.selectedColor
                                    )
                                ) {}
                                .scaleEffect(1.5)
                                .transition(.scale.combined(with: .opacity))
                            } else {
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(theme.cardBackgroundColor)
                                    .frame(height: 60)
                                    .overlay(
                                        Text(String(localized: "tag_preview_will_appear_here"))
                                            .font(.appFont(size: 16, weight: .medium))
                                            .foregroundColor(theme.textColor.opacity(0.5))
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(theme.textColor.opacity(0.1), lineWidth: 1)
                                    )
                            }
                        }
                        .padding(24)
                        .background(
                            RoundedRectangle(cornerRadius: 24)
                                .fill(theme.cardBackgroundColor)
                                .shadow(color: Color.black.opacity(0.05), radius: 12, x: 0, y: 4)
                        )
                        .padding(.horizontal, 20)
                        .padding(.top, 20)

                        // Tag name input with modern styling
                        VStack(alignment: .leading, spacing: 12) {
                            Text(String(localized: "tag_name"))
                                .font(.appFont(size: 18, weight: .bold))
                                .foregroundColor(theme.textColor)

                            HStack(spacing: 12) {
                                Image(systemName: "tag.fill")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(theme.accentColor)
                                    .frame(width: 24)

                                TextField(String(localized: "enter_tag_name"), text: $viewModel.tagName)
                                    .textFieldStyle(PlainTextFieldStyle())
                                    .font(.appFont(size: 16, weight: .regular))
                                    .foregroundColor(theme.textColor)
                                    .padding(.vertical, 16)
                                    .padding(.horizontal, 16)
                                    .background(
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(theme.backgroundColor)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 16)
                                                    .stroke(theme.textColor.opacity(0.2), lineWidth: 1)
                                            )
                                    )
                            }
                        }
                        .padding(24)
                        .background(
                            RoundedRectangle(cornerRadius: 24)
                                .fill(theme.cardBackgroundColor)
                                .shadow(color: Color.black.opacity(0.05), radius: 12, x: 0, y: 4)
                        )
                        .padding(.horizontal, 20)

                        // Icon selection with modern grid
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text(String(localized: "icon"))
                                    .font(.appFont(size: 18, weight: .bold))
                                    .foregroundColor(theme.textColor)

                                Spacer()

                                Button(action: {
                                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                        viewModel.showIconPicker = true
                                    }
                                }) {
                                    HStack(spacing: 6) {
                                        Image(systemName: "square.grid.2x2")
                                            .font(.system(size: 14, weight: .medium))
                                        Text(String(localized: "browse_all"))
                                            .font(.appFont(size: 14, weight: .medium))
                                    }
                                    .foregroundColor(theme.accentColor)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(theme.accentColor.opacity(0.1))
                                    )
                                }
                            }

                            // Selected icon preview
                            HStack(spacing: 16) {
                                Image(systemName: viewModel.selectedIcon)
                                    .font(.system(size: 32, weight: .medium))
                                    .foregroundColor(.white)
                                    .frame(width: 60, height: 60)
                                    .background(
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(Color(hex: viewModel.selectedColor))
                                            .shadow(color: Color(hex: viewModel.selectedColor).opacity(0.3), radius: 8, x: 0, y: 4)
                                    )

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(String(localized: "selected_icon"))
                                        .font(.appFont(size: 14, weight: .medium))
                                        .foregroundColor(theme.textColor.opacity(0.7))

                                    Text(viewModel.selectedIcon)
                                        .font(.appFont(size: 16, weight: .bold))
                                        .foregroundColor(theme.textColor)
                                }

                                Spacer()
                            }
                            .padding(20)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(theme.backgroundColor)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(theme.textColor.opacity(0.1), lineWidth: 1)
                                    )
                            )
                        }
                        .padding(24)
                        .background(
                            RoundedRectangle(cornerRadius: 24)
                                .fill(theme.cardBackgroundColor)
                                .shadow(color: Color.black.opacity(0.05), radius: 12, x: 0, y: 4)
                        )
                        .padding(.horizontal, 20)

                        // Color selection with modern palette
                        VStack(alignment: .leading, spacing: 16) {
                            Text(String(localized: "color"))
                                .font(.appFont(size: 18, weight: .bold))
                                .foregroundColor(theme.textColor)

                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 16) {
                                ForEach(Tag.colorPalette, id: \.self) { colorHex in
                                    Button(action: {
                                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                            viewModel.selectedColor = colorHex
                                        }
                                    }) {
                                        ZStack {
                                            Circle()
                                                .fill(Color(hex: colorHex))
                                                .frame(width: 50, height: 50)
                                                .shadow(color: Color(hex: colorHex).opacity(0.3), radius: 6, x: 0, y: 3)

                                            if viewModel.selectedColor == colorHex {
                                                Circle()
                                                    .stroke(theme.accentColor, lineWidth: 3)
                                                    .frame(width: 56, height: 56)

                                                Image(systemName: "checkmark")
                                                    .font(.system(size: 16, weight: .bold))
                                                    .foregroundColor(.white)
                                                    .scaleEffect(1.2)
                                            }
                                        }
                                        .scaleEffect(viewModel.selectedColor == colorHex ? 1.1 : 1.0)
                                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: viewModel.selectedColor)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                        }
                        .padding(24)
                        .background(
                            RoundedRectangle(cornerRadius: 24)
                                .fill(theme.cardBackgroundColor)
                                .shadow(color: Color.black.opacity(0.05), radius: 12, x: 0, y: 4)
                        )
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(String(localized: "create_tag"))
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
                            Text(String(localized: "cancel"))
                                .font(.appFont(size: 16, weight: .medium))
                        }
                        .foregroundColor(theme.accentColor)
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            viewModel.createTag { tag in
                                onTagCreated(tag)
                                dismiss()
                            }
                        }
                    }) {
                        Text(String(localized: "create"))
                            .font(.appFont(size: 16, weight: .bold))
                            .foregroundColor(viewModel.tagName.isEmpty || viewModel.isCreating ? theme.textColor.opacity(0.5) : theme.accentColor)
                    }
                    .disabled(viewModel.tagName.isEmpty || viewModel.isCreating)
                }
            }
            .alert(String(localized: "error"), isPresented: $viewModel.showError) {
                Button(String(localized: "ok_button")) { }
            } message: {
                Text(viewModel.errorMessage ?? String(localized: "an_error_occurred"))
            }
            .onAppear {
                viewModel.reset()
            }
        }
        .sheet(isPresented: $viewModel.showIconPicker) {
            IconPickerView(selectedIcon: $viewModel.selectedIcon)
        }
    }
}

struct IconPickerView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.dismiss) private var dismiss

    @Binding var selectedIcon: String

    private let iconCategories = [
        (String(localized: "icon_category_general"), ["tag", "bookmark", "star", "heart", "flag", "pin"]),
        (String(localized: "icon_category_work"), ["briefcase", "folder", "doc.text", "calendar", "clock", "checkmark.circle"]),
        (String(localized: "icon_category_personal"), ["person", "house", "car", "gamecontroller", "tv", "music.note"]),
        (String(localized: "icon_category_health"), ["heart.fill", "cross", "pills", "bed.double", "figure.walk", "dumbbell"]),
        (String(localized: "icon_category_study"), ["book", "pencil", "graduationcap", "brain", "lightbulb", "magnifyingglass"]),
        (String(localized: "icon_category_travel"), ["airplane", "car.fill", "map", "location", "camera", "globe"]),
        (String(localized: "icon_category_food"), ["fork.knife", "cup.and.saucer", "wineglass", "birthday.cake", "leaf", "drop"]),
        (String(localized: "icon_category_nature"), ["leaf", "tree", "sun.max", "moon", "cloud", "snowflake"]),
        (String(localized: "icon_category_objects"), ["gift", "shoppingbag", "creditcard", "key", "lock", "gear"]),
        (String(localized: "icon_category_emotions"), ["face.smiling", "hand.thumbsup", "hand.thumbsdown", "exclamationmark.triangle", "questionmark.circle", "info.circle"])
    ]

    var body: some View {
        let theme = themeManager.activeTheme

        NavigationView {
            ZStack {
                theme.backgroundColor.ignoresSafeArea()

                ScrollView {
                    LazyVStack(spacing: 24) {
                        ForEach(iconCategories, id: \.0) { category in
                            VStack(alignment: .leading, spacing: 16) {
                                Text(category.0)
                                    .font(.appFont(size: 18, weight: .bold))
                                    .foregroundColor(theme.textColor)
                                    .padding(.horizontal, 20)

                                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 16) {
                                    ForEach(category.1, id: \.self) { iconName in
                                        Button(action: {
                                            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                                selectedIcon = iconName
                                                dismiss()
                                            }
                                        }) {
                                            ZStack {
                                                RoundedRectangle(cornerRadius: 16)
                                                    .fill(selectedIcon == iconName ? theme.accentColor : theme.cardBackgroundColor)
                                                    .frame(width: 60, height: 60)
                                                    .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)

                                                Image(systemName: iconName)
                                                    .font(.system(size: 24, weight: .medium))
                                                    .foregroundColor(selectedIcon == iconName ? .white : theme.textColor)
                                            }
                                            .scaleEffect(selectedIcon == iconName ? 1.1 : 1.0)
                                            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: selectedIcon)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                        }
                    }
                    .padding(.vertical, 20)
                }
            }
            .navigationTitle(String(localized: "choose_icon"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(String(localized: "done_button")) {
                        dismiss()
                    }
                    .foregroundColor(theme.accentColor)
                }
            }
        }
    }
}

class CreateTagViewModel: ObservableObject {
    @Published var tagName: String = ""
    @Published var selectedIcon: String = "tag"
    @Published var selectedColor: String = Tag.colorPalette[0]
    @Published var isCreating: Bool = false
    @Published var showError: Bool = false
    @Published var errorMessage: String?
    @Published var showIconPicker: Bool = false

    private let tagService: TagServiceProtocol = TagService()

    func reset() {
        tagName = ""
        selectedIcon = "tag"
        selectedColor = Tag.colorPalette[0]
        isCreating = false
        showError = false
        errorMessage = nil
        showIconPicker = false
    }

    func createTag(completion: @escaping (Tag) -> Void) {
        guard !tagName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

        isCreating = true

        tagService.createTag(
            name: tagName.trimmingCharacters(in: .whitespacesAndNewlines),
            icon: selectedIcon,
            color: selectedColor
        ) { [weak self] tag, error in
            DispatchQueue.main.async {
                self?.isCreating = false

                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    self?.showError = true
                } else if let tag = tag {
                    self?.reset()
                    completion(tag)
                }
            }
        }
    }
}

#Preview {
    CreateTagView { tag in
        print("Created tag: \(tag.name)")
    }
    .environmentObject(ThemeManager.shared)
}
