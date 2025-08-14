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
            VStack(spacing: 20) {
                // Tag name input
                VStack(alignment: .leading, spacing: 8) {
                    Text("Tag Name")
                        .font(.appFont(size: 16, weight: .bold))
                        .foregroundColor(theme.textColor)
                    
                    TextField("Enter tag name", text: $viewModel.tagName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .font(.appFont(size: 16, weight: .regular))
                }
                
                // Icon selection
                VStack(alignment: .leading, spacing: 12) {
                    Text("Icon")
                        .font(.appFont(size: 16, weight: .bold))
                        .foregroundColor(theme.textColor)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 8), spacing: 12) {
                        ForEach(Tag.iconSet, id: \.self) { iconName in
                            Button(action: {
                                viewModel.selectedIcon = iconName
                            }) {
                                Image(systemName: iconName)
                                    .font(.system(size: 20))
                                    .foregroundColor(viewModel.selectedIcon == iconName ? .white : theme.textColor)
                                    .frame(width: 40, height: 40)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(viewModel.selectedIcon == iconName ? theme.accentColor : Color.clear)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 8)
                                                    .stroke(theme.textColor.opacity(0.3), lineWidth: 1)
                                            )
                                    )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
                
                // Color selection
                VStack(alignment: .leading, spacing: 12) {
                    Text("Color")
                        .font(.appFont(size: 16, weight: .bold))
                        .foregroundColor(theme.textColor)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 8), spacing: 12) {
                        ForEach(Tag.colorPalette, id: \.self) { colorHex in
                            Button(action: {
                                viewModel.selectedColor = colorHex
                            }) {
                                Circle()
                                    .fill(Color(hex: colorHex))
                                    .frame(width: 40, height: 40)
                                    .overlay(
                                        Circle()
                                            .stroke(viewModel.selectedColor == colorHex ? theme.accentColor : Color.clear, lineWidth: 3)
                                    )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
                
                // Preview
                if !viewModel.tagName.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Preview")
                            .font(.appFont(size: 16, weight: .bold))
                            .foregroundColor(theme.textColor)
                        
                        TagChip(
                            tag: Tag(
                                name: viewModel.tagName,
                                icon: viewModel.selectedIcon,
                                color: viewModel.selectedColor
                            )
                        ) {}
                    }
                }
                
                Spacer()
            }
            .padding(20)
            .navigationTitle("Create Tag")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(theme.accentColor)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Create") {
                        viewModel.createTag { tag in
                            onTagCreated(tag)
                            dismiss()
                        }
                    }
                    .foregroundColor(theme.accentColor)
                    .disabled(viewModel.tagName.isEmpty || viewModel.isCreating)
                }
            }
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK") { }
            } message: {
                Text(viewModel.errorMessage ?? "An error occurred")
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
    
    private let tagService: TagServiceProtocol = TagService()
    
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
