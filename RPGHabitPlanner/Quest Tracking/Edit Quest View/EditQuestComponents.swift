//
//  EditQuestComponents.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 11.11.2024.
//

import SwiftUI

// MARK: - Header Section Component
struct EditQuestHeaderSection: View {
    @ObservedObject var viewModel: EditQuestViewModel
    let theme: Theme
    
    var body: some View {
        VStack(spacing: 16) {
            // Quest Icon and Status
            HStack {
                questIcon
                Spacer()
                statusBadge
            }
            
            // Quest Title Preview
            Text(viewModel.title.isEmpty ? "Untitled Quest" : viewModel.title)
                .font(.appFont(size: 24, weight: .black))
                .foregroundColor(theme.textColor)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(theme.primaryColor)
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
    }
    
    private var questIcon: some View {
        ZStack {
            Circle()
                .fill(questTypeColor.opacity(0.2))
                .frame(width: 60, height: 60)
            
            Image(systemName: questIconName)
                .font(.system(size: 24, weight: .medium))
                .foregroundColor(questTypeColor)
        }
    }
    
    private var statusBadge: some View {
        let (text, color) = statusInfo
        
        return Text(text)
            .font(.appFont(size: 12, weight: .black))
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(color)
            )
    }
    
    private var questIconName: String {
        if viewModel.isMainQuest {
            return "crown.fill"
        } else {
            switch viewModel.repeatType {
            case .daily: return "sun.max.fill"
            case .weekly: return "calendar.badge.clock"
            case .oneTime: return "target"
            }
        }
    }
    
    private var questTypeColor: Color {
        if viewModel.isMainQuest {
            return .yellow
        } else {
            switch viewModel.repeatType {
            case .daily: return .orange
            case .weekly: return .blue
            case .oneTime: return .purple
            }
        }
    }
    
    private var statusInfo: (String, Color) {
        if viewModel.quest.isFinished {
            return ("Finished", .gray)
        } else {
            return ("Active", .blue)
        }
    }
}

// MARK: - Basic Info Section Component
struct EditQuestBasicInfoSection: View {
    @ObservedObject var viewModel: EditQuestViewModel
    let theme: Theme
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Basic Information")
                    .font(.appFont(size: 18, weight: .bold))
                    .foregroundColor(theme.textColor)
                Spacer()
            }
            
            VStack(spacing: 12) {
                // Title Field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Quest Title")
                        .font(.appFont(size: 14, weight: .medium))
                        .foregroundColor(theme.textColor.opacity(0.8))
                    
                    TextField("Enter quest title", text: $viewModel.title)
                        .font(.appFont(size: 16))
                        .foregroundColor(theme.textColor)
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(theme.primaryColor.opacity(0.3))
                        )
                }
                
                // Description Field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Description")
                        .font(.appFont(size: 14, weight: .medium))
                        .foregroundColor(theme.textColor.opacity(0.8))
                    
                    TextField("Enter quest description", text: $viewModel.description, axis: .vertical)
                        .font(.appFont(size: 16))
                        .foregroundColor(theme.textColor)
                        .lineLimit(3...6)
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(theme.primaryColor.opacity(0.3))
                        )
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(theme.primaryColor)
                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
    }
}

// MARK: - Quest Settings Section Component
struct EditQuestSettingsSection: View {
    @ObservedObject var viewModel: EditQuestViewModel
    let theme: Theme
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Quest Settings")
                    .font(.appFont(size: 18, weight: .bold))
                    .foregroundColor(theme.textColor)
                Spacer()
            }
            
            VStack(spacing: 16) {
                // Main Quest Toggle
                HStack {
                    Image(systemName: "crown.fill")
                        .foregroundColor(.yellow)
                        .font(.system(size: 16))
                    
                    Text("Main Quest")
                        .font(.appFont(size: 16, weight: .medium))
                        .foregroundColor(theme.textColor)
                    
                    Spacer()
                    
                    Toggle("", isOn: $viewModel.isMainQuest)
                        .tint(.yellow)
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(theme.primaryColor.opacity(0.3))
                )
                
                // Due Date
                VStack(alignment: .leading, spacing: 8) {
                    Text("Due Date")
                        .font(.appFont(size: 14, weight: .medium))
                        .foregroundColor(theme.textColor.opacity(0.8))
                    
                    DatePicker("", selection: $viewModel.dueDate, displayedComponents: [.date])
                        .labelsHidden()
                        .datePickerStyle(.compact)
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(theme.primaryColor.opacity(0.3))
                        )
                }
                
                // Repeat Type
                VStack(alignment: .leading, spacing: 8) {
                    Text("Repeat Type")
                        .font(.appFont(size: 14, weight: .medium))
                        .foregroundColor(theme.textColor.opacity(0.8))
                    
                    Picker("Repeat Type", selection: $viewModel.repeatType) {
                        Text("One Time").tag(QuestRepeatType.oneTime)
                        Text("Daily").tag(QuestRepeatType.daily)
                        Text("Weekly").tag(QuestRepeatType.weekly)
                    }
                    .pickerStyle(.segmented)
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(theme.primaryColor.opacity(0.3))
                    )
                }
                
                // Difficulty
                VStack(alignment: .leading, spacing: 8) {
                    Text("Difficulty")
                        .font(.appFont(size: 14, weight: .medium))
                        .foregroundColor(theme.textColor.opacity(0.8))
                    
                    StarRatingView(rating: $viewModel.difficulty)
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(theme.primaryColor.opacity(0.3))
                        )
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(theme.primaryColor)
                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
    }
}

// MARK: - Tasks Section Component
struct EditQuestTasksSection: View {
    @ObservedObject var viewModel: EditQuestViewModel
    let theme: Theme
    let onEditTasks: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Tasks")
                    .font(.appFont(size: 18, weight: .bold))
                    .foregroundColor(theme.textColor)
                Spacer()
                
                Text("\(validTaskCount)")
                    .font(.appFont(size: 14, weight: .medium))
                    .foregroundColor(theme.textColor.opacity(0.7))
            }
            
            Button(action: onEditTasks) {
                HStack(spacing: 12) {
                    Image(systemName: "list.bullet.clipboard")
                        .font(.title2)
                        .foregroundColor(.yellow)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Manage Tasks")
                            .font(.appFont(size: 16, weight: .medium))
                            .foregroundColor(theme.textColor)
                        
                        Text("\(validTaskCount) task\(validTaskCount == 1 ? "" : "s")")
                            .font(.appFont(size: 12))
                            .foregroundColor(theme.textColor.opacity(0.7))
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(theme.textColor.opacity(0.6))
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(theme.primaryColor.opacity(0.3))
                )
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(theme.primaryColor)
                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
    }
    
    private var validTaskCount: Int {
        viewModel.tasks.filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }.count
    }
}

// MARK: - Action Buttons Section Component
struct EditQuestActionButtonsSection: View {
    @ObservedObject var viewModel: EditQuestViewModel
    let theme: Theme
    let isButtonPressed: Bool
    let onSave: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            // Save Button
            Button(action: onSave) {
                HStack {
                    if viewModel.isSaving {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 18))
                        Text("Save Changes")
                            .font(.appFont(size: 16, weight: .bold))
                    }
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.green)
                        .opacity(isButtonPressed ? 0.7 : 1.0)
                )
            }
            .buttonStyle(PlainButtonStyle())
            .disabled(viewModel.isSaving)
            .scaleEffect(isButtonPressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isButtonPressed)
        }
    }
}

// MARK: - Task Editor Sheet Component
struct EditQuestTaskEditorSheet: View {
    @ObservedObject var viewModel: EditQuestViewModel
    let theme: Theme
    let isPresented: Binding<Bool>
    
    var body: some View {
        NavigationStack {
            ZStack {
                theme.backgroundColor.ignoresSafeArea()
                
                VStack(spacing: 16) {
                    // Task List
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.tasks.indices, id: \.self) { index in
                                taskRow(index: index, theme: theme)
                            }
                            
                            // Add Task Button
                            Button(action: addNewTask) {
                                HStack(spacing: 8) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.title3)
                                    Text("Add New Task")
                                        .font(.appFont(size: 16, weight: .medium))
                                }
                                .foregroundColor(.yellow)
                                .padding(16)
                                .frame(maxWidth: .infinity)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(theme.primaryColor.opacity(0.3))
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                    }
                }
            }
            .navigationTitle("Edit Tasks")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented.wrappedValue = false
                    }
                    .foregroundColor(theme.textColor)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        cleanupBlankTasks()
                        isPresented.wrappedValue = false
                    }
                    .foregroundColor(theme.textColor)
                    .fontWeight(.medium)
                }
            }
        }
    }
    
    private func taskRow(index: Int, theme: Theme) -> some View {
        HStack(spacing: 12) {
            Text("\(index + 1)")
                .font(.appFont(size: 14, weight: .black))
                .foregroundColor(theme.textColor)
                .frame(width: 28, height: 28)
                .background(
                    Circle()
                        .fill(.yellow.opacity(0.2))
                )
            
            TextField("Enter task description", text: $viewModel.tasks[index])
                .font(.appFont(size: 16))
                .foregroundColor(theme.textColor)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(theme.primaryColor.opacity(0.3))
                )
            
            Button(action: {
                withAnimation {
                    if index < viewModel.tasks.count {
                        viewModel.tasks.remove(at: index)
                    }
                }
            }) {
                Image(systemName: "trash.circle.fill")
                    .font(.title3)
                    .foregroundColor(.red.opacity(0.8))
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.horizontal, 4)
    }
    
    private func addNewTask() {
        withAnimation(.easeInOut(duration: 0.2)) {
            viewModel.tasks.append("")
        }
    }
    
    private func cleanupBlankTasks() {
        viewModel.tasks = viewModel.tasks.filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    }
}
