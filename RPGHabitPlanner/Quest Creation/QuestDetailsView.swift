import SwiftUI

struct QuestDetailsView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @ObservedObject var viewModel: QuestCreationViewModel
    let onContinue: () -> Void
    @Binding var showTaskPopup: Bool
    @Binding var showTagPicker: Bool
    let animate: Bool
    @State private var isButtonPressed = false
    
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
                .padding(.top)
                
                // Premium indicator
                if !PremiumManager.shared.isPremium {
                    QuestLimitIndicatorView(currentQuestCount: viewModel.currentQuestCount)
                }
                
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
                
                // Main Quest Toggle
                GamifiedToggleCard(
                    label: "Is this a Main Quest?",
                    isOn: $viewModel.isMainQuest
                )
                
                // Due Date
                GamifiedDatePicker(
                    title: "Quest Deadline",
                    date: $viewModel.questDueDate
                )
                
                // Tasks
                GamifiedTasksSection(
                    tasks: $viewModel.tasks
                ) { showTaskPopup = true }
                
                // Difficulty
                GamifiedDifficultySection(difficulty: $viewModel.difficulty)
                
                // Coin Reward Preview
                CoinRewardPreviewSection(
                    difficulty: viewModel.difficulty,
                    isMainQuest: viewModel.isMainQuest,
                    taskCount: viewModel.tasks.filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }.count
                )
                
                // Repeat Type
                GamifiedRepeatTypeSection(
                    repeatType: $viewModel.repeatType,
                    selectedScheduledDays: $viewModel.selectedScheduledDays
                )
                
                // Tags
                GamifiedTagsSection(
                    selectedTags: $viewModel.selectedTags
                ) { showTagPicker = true }
                
                // Continue Button
                Button(action: {
                    isButtonPressed = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        isButtonPressed = false
                        onContinue()
                    }
                }) {
                    HStack(spacing: 12) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title2)
                        Text("REVIEW QUEST")
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
                .padding(.bottom)
            }
            .padding()
        }
    }
}
