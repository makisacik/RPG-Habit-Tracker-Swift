import SwiftUI

struct QuestCreationView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var premiumManager: PremiumManager
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: QuestCreationViewModel
    @State private var showAlert: Bool = false
    @State private var alertTitle: String = ""
    @State private var alertMessage: String = ""
    @State private var isButtonPressed: Bool = false
    @State private var isTaskPopupVisible = false
    @State private var showSuccessAnimation = false
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
                
                // Animated background elements
                if currentStep == .questBoard && !hasSeenQuestCreation {
                    QuestBoardBackground(animate: animateQuestBoard)
                }
                
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
                            animate: animateParchment
                        )
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
                        animate: animateParchment
                    )
                }
                
                // Success animation
                if showSuccessAnimation {
                    SuccessAnimationOverlay(isVisible: $showSuccessAnimation)
                        .zIndex(20)
                }
                
                // Task popup
                if isTaskPopupVisible {
                    Color.black.opacity(0.6)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation {
                                isTaskPopupVisible = false
                            }
                        }
                        .transition(.opacity)
                        .zIndex(9)

                    TaskEditorPopup(tasks: $viewModel.tasks, isPresented: $isTaskPopupVisible)
                        .frame(width: 350, height: 450)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(theme.primaryColor)
                                .shadow(color: Color.black.opacity(0.2), radius: 6, x: 0, y: 4)
                        )
                        .cornerRadius(12)
                        .shadow(radius: 10)
                        .transition(.scale.combined(with: .opacity))
                        .zIndex(10)
                }
        }
            .animation(.easeInOut(duration: 0.25), value: isTaskPopupVisible)
            .onTapGesture {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text(alertTitle).font(.appFont(size: 16, weight: .black)),
                    message: Text(alertMessage).font(.appFont(size: 14)),
                    dismissButton: .default(Text(String.okButton.localized).font(.appFont(size: 14, weight: .black)))
                )
            }
            .onChange(of: viewModel.didSaveQuest) { didSave in
                if didSave {
                    showSuccessAnimation = true
                    viewModel.resetInputs()
                    viewModel.didSaveQuest = false
                    // Dismiss the view and return to previous screen after success
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        dismiss()
                    }
                }
            }
            .onChange(of: viewModel.shouldShowPaywall) { shouldShow in
                if shouldShow {
                    showPaywall = true
                }
            }
            .onChange(of: premiumManager.isPremium) { isPremium in
                if isPremium {
                    showPaywall = false
                }
            }
            .onAppear {
                // Check if user should see paywall when view appears
                if !premiumManager.isPremium && viewModel.currentQuestCount >= PremiumManager.freeQuestLimit {
                    showPaywall = true
                }
                // Start quest board animation
                withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                    animateQuestBoard = true
                }
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
    }
    
    // MARK: - Quest Creation Flow Methods
    
    private func startQuestCreation() {
        // Mark that user has seen quest creation
        hasSeenQuestCreation = true
        
        withAnimation(.easeInOut(duration: 0.5)) {
            currentStep = .questDetails
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            withAnimation(.easeInOut(duration: 0.8)) {
                animateParchment = true
            }
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
