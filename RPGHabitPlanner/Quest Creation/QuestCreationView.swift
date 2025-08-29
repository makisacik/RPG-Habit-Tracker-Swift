import SwiftUI

struct QuestCreationView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var premiumManager: PremiumManager
    @EnvironmentObject var localizationManager: LocalizationManager
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: QuestCreationViewModel
    @State private var showAlert: Bool = false
    @State private var alertTitle: String = ""
    @State private var alertMessage: String = ""
    @State private var isButtonPressed: Bool = false
    @State private var isTaskPopupVisible = false

    @State private var notifyMe = true
    @State private var showPaywall = false
    @State private var showTagPicker = false

    // UserDefaults for first-time visit
    @AppStorage("hasSeenQuestCreation") private var hasSeenQuestCreation = false

    // Gamified quest creation states
    @State private var currentStep: QuestCreationStep = .questBoard
    @State private var showQuestGiver = false
    @State private var questGiverDialogue = ""
    @State private var showDialogue = false
    @State private var showParchmentEffect = false

    // Animation states
    @State private var animateQuestBoard = false
    @State private var animateQuestGiver = false
    @State private var animateParchment = false

    var body: some View {
        let theme = themeManager.activeTheme
        ZStack {
                // Background with RPG atmosphere
                RoundedRectangle(cornerRadius: 12)
                    .fill(theme.backgroundColor)
                    .ignoresSafeArea()


                // Main content based on current step
                switch currentStep {
                case .questBoard:
                    if !hasSeenQuestCreation {
                        QuestBoardView(
                            onStartQuest: startQuestCreation,
                            animate: animateQuestBoard
                        )
                    } else {
                        // Skip directly to quest details for returning users
                        QuestDetailsView(
                            viewModel: viewModel,
                            onContinue: moveToNextStep,
                            showTaskPopup: $isTaskPopupVisible,
                            showTagPicker: $showTagPicker,
                            showPaywall: $showPaywall,
                            animate: false
                        )
                        .environmentObject(premiumManager)
                    }

                case .questGiver:
                    QuestGiverView(
                        dialogue: questGiverDialogue,
                        showDialogue: showDialogue,
                        onContinue: moveToNextStep,
                        animate: animateQuestGiver
                    )

                case .questDetails:
                    QuestDetailsView(
                        viewModel: viewModel,
                        onContinue: moveToNextStep,
                        showTaskPopup: $isTaskPopupVisible,
                        showTagPicker: $showTagPicker,
                        showPaywall: $showPaywall,
                        animate: false
                    )
                    .environmentObject(premiumManager)
                }
        }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text(alertTitle).font(.appFont(size: 16, weight: .black)),
                    message: Text(alertMessage).font(.appFont(size: 14)),
                    dismissButton: .default(Text("ok".localized).font(.appFont(size: 14, weight: .black)))
                )
            }
            .onChange(of: viewModel.didSaveQuest) { didSave in
                if didSave {
                    viewModel.resetInputs()
                    viewModel.didSaveQuest = false
                    // Dismiss the view and return to previous screen after success
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        dismiss()
                    }
                }
            }

            .onChange(of: premiumManager.isPremium) { isPremium in
                if isPremium {
                    showPaywall = false
                    // Refresh the view model to update quest count after premium purchase
                    viewModel.fetchCurrentQuestCount()
                }
            }

            .onAppear {
                // No animations to prevent layout issues
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView()
                    .environmentObject(premiumManager)
            }
            .sheet(isPresented: $showTagPicker) {
                TagPickerView(selectedTags: viewModel.selectedTags) { selectedTags in
                    viewModel.selectedTags = selectedTags
                }
                .environmentObject(themeManager)
            }
            .sheet(isPresented: $isTaskPopupVisible) {
                TaskEditorPopup(tasks: $viewModel.tasks, isPresented: $isTaskPopupVisible)
                    .environmentObject(themeManager)
                    .presentationDetents([.medium])
            }
    }

    // MARK: - Quest Creation Flow Methods

    private func startQuestCreation() {
        // Mark that user has seen quest creation
        hasSeenQuestCreation = true

        withAnimation(.easeInOut(duration: 0.5)) {
            currentStep = .questDetails
        }
    }

    private func moveToNextStep() {
        // This function is no longer needed for the direct creation flow
        // Keeping it for potential future use
    }

    private func moveToPreviousStep() {
        withAnimation(.easeInOut(duration: 0.5)) {
            switch currentStep {
            case .questBoard:
                break
            case .questGiver:
                currentStep = .questBoard
            case .questDetails:
                currentStep = .questBoard
            }
        }
    }

    private func showAlert(title: String, message: String) {
        alertTitle = title
        alertMessage = message
        showAlert = true
    }
}

// MARK: - Quest Creation Steps

enum QuestCreationStep {
    case questBoard
    case questGiver
    case questDetails
}
