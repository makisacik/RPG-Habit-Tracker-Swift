import SwiftUI

struct QuestDetailsView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @ObservedObject var viewModel: QuestCreationViewModel
    let onContinue: () -> Void
    @Binding var showTaskPopup: Bool
    @Binding var showTagPicker: Bool
    let animate: Bool
    @State private var isButtonPressed = false
    @State private var showErrorAlert = false

    var body: some View {
        let theme = themeManager.activeTheme
        ScrollView {
            VStack(spacing: 24) {
                // Parchment Header
                VStack(spacing: 16) {
                    Image(systemName: "doc.text.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.yellow)
                        .scaleEffect(animate ? 1.05 : 1.0)
                        .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: animate)

                    Text("QUEST DETAILS")
                        .font(.appFont(size: 24, weight: .black))
                        .foregroundColor(theme.textColor)
                }
                .padding(.top, 8)

                // Quest Title
                GamifiedInputField(
                    title: "Quest Title",
                    text: $viewModel.questTitle,
                    icon: "pencil.circle.fill",
                    placeholder: "Enter your quest's name..."
                )

                // Quest Description
                GamifiedInputField(
                    title: "Quest Description",
                    text: $viewModel.questDescription,
                    icon: "doc.text.fill",
                    placeholder: "Describe your quest..."
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
                    title: "Quest Deadline",
                    date: $viewModel.questDueDate
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
                        Text("Quest Difficulty")
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
                CoinRewardPreviewSection(
                    difficulty: viewModel.difficulty,
                    isMainQuest: true,
                    taskCount: viewModel.tasks.filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }.count
                )

                // Continue Button
                Button(action: {
                    isButtonPressed = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        isButtonPressed = false
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
                            Image(systemName: "checkmark.circle.fill")
                                .font(.title2)
                        }
                        Text(viewModel.isSaving ? "CREATING..." : "CREATE QUEST")
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
        .alert("Error", isPresented: $showErrorAlert) {
            Button("OK") { }
        } message: {
            Text(viewModel.errorMessage ?? "An unknown error occurred")
        }
        .onChange(of: viewModel.didSaveQuest) { didSave in
            if didSave {
                // Quest was successfully created, dismiss the view
                // This will be handled by the parent view
            }
        }
    }
}
