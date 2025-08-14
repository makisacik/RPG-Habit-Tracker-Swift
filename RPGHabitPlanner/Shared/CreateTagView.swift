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
                            Text("Preview")
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
                                        Text("Tag preview will appear here")
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
                            Text("Tag Name")
                                .font(.appFont(size: 18, weight: .bold))
                                .foregroundColor(theme.textColor)
                            
                            HStack(spacing: 12) {
                                Image(systemName: "tag.fill")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(theme.accentColor)
                                    .frame(width: 24)
                                
                                TextField("Enter tag name", text: $viewModel.tagName)
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
                                Text("Icon")
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
                                        Text("Browse All")
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
                                    Text("Selected Icon")
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
                            Text("Color")
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
                    Text("Create Tag")
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
                            viewModel.createTag { tag in
                                onTagCreated(tag)
                                dismiss()
                            }
                        }
                    }) {
                        Text("Create")
                            .font(.appFont(size: 16, weight: .bold))
                            .foregroundColor(viewModel.tagName.isEmpty || viewModel.isCreating ? theme.textColor.opacity(0.5) : theme.accentColor)
                    }
                    .disabled(viewModel.tagName.isEmpty || viewModel.isCreating)
                }
            }
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK") { }
            } message: {
                Text(viewModel.errorMessage ?? "An error occurred")
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
        ("General", ["tag", "bookmark", "star", "heart", "flag", "pin"]),
        ("Work", ["briefcase", "folder", "doc.text", "calendar", "clock", "checkmark.circle"]),
        ("Personal", ["person", "house", "car", "gamecontroller", "tv", "music.note"]),
        ("Health", ["heart.fill", "cross", "pills", "bed.double", "figure.walk", "dumbbell"]),
        ("Study", ["book", "pencil", "graduationcap", "brain", "lightbulb", "magnifyingglass"]),
        ("Travel", ["airplane", "car.fill", "map", "location", "camera", "globe"]),
        ("Food", ["fork.knife", "cup.and.saucer", "wineglass", "birthday.cake", "leaf", "drop"]),
        ("Nature", ["leaf", "tree", "sun.max", "moon", "cloud", "snowflake"]),
        ("Objects", ["gift", "shoppingbag", "creditcard", "key", "lock", "gear"]),
        ("Emotions", ["face.smiling", "hand.thumbsup", "hand.thumbsdown", "exclamationmark.triangle", "questionmark.circle", "info.circle"])
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
            .navigationTitle("Choose Icon")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
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
