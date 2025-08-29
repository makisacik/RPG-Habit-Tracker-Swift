//
//  AddTasksView.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 27.07.2025.
//

import SwiftUI

struct AddTasksView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Binding var tasks: [String]
    var onEditTapped: () -> Void
    @State private var isButtonPressed = false

    private var validTaskCount: Int {
        return tasks.filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }.count
    }

    var body: some View {
        let theme = themeManager.activeTheme
        VStack(alignment: .leading, spacing: 8) {
            Button(action: {
                onEditTapped()
            }) {
                HStack(spacing: 12) {
                    Image(systemName: "list.bullet.clipboard")
                        .font(.title2)
                        .foregroundColor(.yellow)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("tasks".localized)
                            .font(.appFont(size: 16, weight: .black))
                            .foregroundColor(theme.textColor)

                        Text("\(validTaskCount) \(validTaskCount == 1 ? "task".localized : "tasks".localized)")
                            .font(.appFont(size: 12, weight: .regular))
                            .foregroundColor(theme.textColor.opacity(0.7))
                    }

                    Spacer()

                    HStack(spacing: 8) {
                        Text("\(validTaskCount)")
                            .font(.appFont(size: 14, weight: .black))
                            .foregroundColor(theme.textColor)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(theme.accentColor.opacity(0.2))
                            )

                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(theme.textColor.opacity(0.6))
                    }
                }
                .padding()
                .background(
                    Image(theme.buttonPrimary)
                        .resizable(
                            capInsets: EdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20),
                            resizingMode: .stretch
                        )
                        .opacity(isButtonPressed ? 0.7 : 1.0)
                )
            }
            .buttonStyle(PlainButtonStyle())
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in isButtonPressed = true }
                    .onEnded { _ in isButtonPressed = false }
            )
        }
    }
}

// Extracted row to remove init ambiguity
struct TaskRow: View {
    @Binding var task: String
    var index: Int
    var onDelete: () -> Void
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        let theme = themeManager.activeTheme
        HStack(spacing: 8) {
            Text("\(index + 1)")
                .font(.appFont(size: 11, weight: .black))
                .foregroundColor(theme.textColor)
                .frame(width: 20, height: 20)
                .background(Circle().fill(theme.accentColor.opacity(0.2)))

            TextField("enter_task_description".localized, text: $task)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .font(.appFont(size: 14))
                .foregroundColor(theme.textColor)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(theme.primaryColor.opacity(0.3))
                )

            Button(action: onDelete) {
                Image(systemName: "trash.circle.fill")
                    .font(.title2)
                    .foregroundColor(.red.opacity(0.8))
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}

struct TaskEditorPopup: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Binding var tasks: [String]
    @Binding var isPresented: Bool
    @State private var isDonePressed = false
    @State private var isAddPressed = false

    var body: some View {
        let theme = themeManager.activeTheme
        VStack(spacing: 0) {
            // Header
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "list.bullet.clipboard")
                        .font(.title2)
                        .foregroundColor(.yellow)

                    Text("edit_tasks".localized)
                        .font(.appFont(size: 18, weight: .black))
                        .foregroundColor(theme.textColor)
                }

                Spacer()

                Button(action: {
                    isPresented = false
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(theme.textColor.opacity(0.6))
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 12)

            Divider()
                .background(theme.textColor.opacity(0.3))

            // Task List
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 12) {
                    ForEach(tasks.indices, id: \.self) { index in
                        TaskRow(
                            task: $tasks[index],
                            index: index
                        ) { tasks.remove(at: index) }
                    }

                    // Add task button
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            tasks.append("")
                        }
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title3)
                            Text("add_new_task".localized)
                                .font(.appFont(size: 14, weight: .black))
                        }
                        .foregroundColor(theme.textColor)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            Image(theme.buttonPrimary)
                                .resizable(
                                    capInsets: EdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20),
                                    resizingMode: .stretch
                                )
                                .opacity(isAddPressed ? 0.7 : 1.0)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    .simultaneousGesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { _ in isAddPressed = true }
                            .onEnded { _ in isAddPressed = false }
                    )
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }

            // Done button
            VStack {
                Button(action: {
                    cleanupBlankTasks()
                    isPresented = false
                }) {
                    Text("done".localized)
                        .font(.appFont(size: 16, weight: .black))
                        .foregroundColor(.white)
                        .padding(.vertical, 16)
                        .frame(maxWidth: .infinity)
                        .background(
                            Image(theme.buttonPrimary)
                                .resizable(
                                    capInsets: EdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20),
                                    resizingMode: .stretch
                                )
                                .opacity(isDonePressed ? 0.7 : 1.0)
                        )
                }
                .buttonStyle(PlainButtonStyle())
                .simultaneousGesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { _ in isDonePressed = true }
                        .onEnded { _ in isDonePressed = false }
                )
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
            .background(theme.backgroundColor)
        }
        .background(theme.backgroundColor)
        .onTapGesture {
            hideKeyboard()
        }
    }

    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }

    private func cleanupBlankTasks() {
        tasks = tasks.filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    }
}
