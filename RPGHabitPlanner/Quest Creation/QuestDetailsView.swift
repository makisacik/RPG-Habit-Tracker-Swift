import SwiftUI

struct QuestDetailsView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var premiumManager: PremiumManager
    @EnvironmentObject var localizationManager: LocalizationManager
    @ObservedObject var viewModel: QuestCreationViewModel
    let onContinue: () -> Void
    @Binding var showTaskPopup: Bool
    @Binding var showTagPicker: Bool
    @Binding var showPaywall: Bool
    let animate: Bool
    @State private var isButtonPressed = false
    @State private var showErrorAlert = false

    var body: some View {
        let theme = themeManager.activeTheme
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                // Removed quest details header

                // Add top padding for better spacing
                Spacer()
                    .frame(height: 12)

                // Quest Title
                GamifiedInputField(
                    title: "quest_title".localized,
                    text: $viewModel.questTitle,
                    icon: "pencil.circle.fill",
                    placeholder: "enter_quest_name".localized
                )

                // Quest Description
                GamifiedInputField(
                    title: "quest_description".localized,
                    text: $viewModel.questDescription,
                    icon: "doc.text.fill",
                    placeholder: "describe_quest".localized
                )

                // Repeat Type
                GamifiedRepeatTypeSection(
                    repeatType: $viewModel.repeatType,
                    selectedScheduledDays: $viewModel.selectedScheduledDays
                )

                // Tasks
                GamifiedTasksSection(
                    tasks: $viewModel.tasks
                ) { showTaskPopup = true }

                // Quest Deadline
                GamifiedDatePicker(
                    title: "quest_deadline".localized,
                    date: $viewModel.questDueDate
                )

                // Specific Time
                GamifiedTimePicker(
                    title: "specific_reminder_time".localized,
                    selectedTimes: $viewModel.reminderTimes,
                    isEnabled: $viewModel.enableReminders
                )

                // Tags
                GamifiedTagsSection(
                    selectedTags: $viewModel.selectedTags
                ) { showTagPicker = true }

                // Difficulty
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "star.circle.fill")
                            .foregroundColor(.yellow)
                        Text("quest_difficulty".localized)
                            .font(.appFont(size: 14, weight: .black))
                            .foregroundColor(theme.textColor)
                    }

                    StarRatingView(rating: $viewModel.difficulty)
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(theme.primaryColor.opacity(0.3))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.yellow.opacity(0.3), lineWidth: 1)
                                )
                        )
                }

                // Quest Reward
                QuestRewardPreviewSection(
                    difficulty: viewModel.difficulty,
                    isMainQuest: true,
                    taskCount: viewModel.tasks.filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }.count
                )

                // Continue Button
                Button(action: {
                    isButtonPressed = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        isButtonPressed = false
                        // Check if user can create quest or should show paywall
                        if !premiumManager.canCreateQuest() {
                            // Show paywall
                            showPaywall = true
                            return
                        }
                        // Directly save the quest instead of going to review
                        if viewModel.validateInputs() {
                            viewModel.saveQuest()
                        } else {
                            showErrorAlert = true
                        }
                    }
                }) {
                    HStack(spacing: 12) {
                        if viewModel.isSaving {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.8)
                        } else {
                            Image(systemName: !premiumManager.canCreateQuest() ? "lock.fill" : "checkmark.circle.fill")
                                .font(.title2)
                        }
                        Text(viewModel.isSaving ? "creating".localized : (!premiumManager.canCreateQuest() ? "unlock".localized : "create_quest".localized))
                            .font(.appFont(size: 16, weight: .black))
                    }
                    .foregroundColor(.white)
                    .padding(.vertical, 16)
                    .padding(.horizontal, 32)
                    .background(
                        Image(theme.buttonPrimary)
                            .resizable(
                                capInsets: EdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20),
                                resizingMode: .stretch
                            )
                            .opacity(isButtonPressed ? 0.7 : 1.0)
                    )
                    .scaleEffect(isButtonPressed ? 0.95 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isButtonPressed)
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(viewModel.isSaving)
                .padding(.bottom)
            }
            .padding(.horizontal)
            .padding(.top, 8)
        }
        .alert("error".localized, isPresented: $showErrorAlert) {
            Button("ok".localized) { }
        } message: {
            Text(viewModel.errorMessage ?? "unknown_error".localized)
        }
        .onTapGesture {
            hideKeyboard()
        }
        .onChange(of: viewModel.didSaveQuest) { didSave in
            if didSave {
                // Quest was successfully created, dismiss the view
                // This will be handled by the parent view
            }
        }
    }

    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
