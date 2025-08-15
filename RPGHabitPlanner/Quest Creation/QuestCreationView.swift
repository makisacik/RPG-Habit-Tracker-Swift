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
    
    // Gamified quest creation states
    @State private var currentStep: QuestCreationStep = .questBoard
    @State private var showQuestGiver = false
    @State private var questGiverDialogue = ""
    @State private var showDialogue = false
    @State private var showStepTransition = false
    @State private var stepTransitionText = ""
    @State private var showParchmentEffect = false
    @State private var showQuestAcceptance = false
    
    // Animation states
    @State private var animateQuestBoard = false
    @State private var animateQuestGiver = false
    @State private var animateParchment = false
    @State private var animateAcceptance = false

    var body: some View {
        let theme = themeManager.activeTheme
        NavigationView {
            ZStack {
                // Background with RPG atmosphere
                RoundedRectangle(cornerRadius: 12)
                    .fill(theme.backgroundColor)
                    .ignoresSafeArea()
                
                // Animated background elements
                if currentStep == .questBoard {
                    QuestBoardBackground(animate: animateQuestBoard)
                }
                
                // Main content based on current step
                switch currentStep {
                case .questBoard:
                    QuestBoardView(
                        onStartQuest: startQuestCreation,
                        animate: animateQuestBoard
                    )
                    
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
                    
                case .questAcceptance:
                    QuestAcceptanceView(
                        viewModel: viewModel,
                        onAcceptQuest: acceptQuest,
                        onGoBack: moveToPreviousStep,
                        animate: animateAcceptance
                    )
                }
                
                // Step transition overlay
                if showStepTransition {
                    StepTransitionOverlay(text: stepTransitionText)
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
    }
    
    // MARK: - Quest Creation Flow Methods
    
    private func startQuestCreation() {
        withAnimation(.easeInOut(duration: 0.5)) {
            currentStep = .questGiver
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            questGiverDialogue = "Greetings, brave adventurer! I have a quest that requires your attention. Are you ready to embark on this journey?"
            withAnimation(.easeInOut(duration: 0.3)) {
                showDialogue = true
                animateQuestGiver = true
            }
        }
    }
    
    private func moveToNextStep() {
        withAnimation(.easeInOut(duration: 0.3)) {
            showDialogue = false
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            showStepTransition = true
            stepTransitionText = "Preparing your quest..."
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation(.easeInOut(duration: 0.5)) {
                    showStepTransition = false
                    
                    switch currentStep {
                    case .questBoard:
                        currentStep = .questGiver
                    case .questGiver:
                        currentStep = .questDetails
                        withAnimation(.easeInOut(duration: 0.8)) {
                            animateParchment = true
                        }
                    case .questDetails:
                        currentStep = .questAcceptance
                        withAnimation(.easeInOut(duration: 0.8)) {
                            animateAcceptance = true
                        }
                    case .questAcceptance:
                        break
                    }
                }
            }
        }
    }
    
    private func moveToPreviousStep() {
        withAnimation(.easeInOut(duration: 0.5)) {
            switch currentStep {
            case .questBoard:
                break
            case .questGiver:
                currentStep = .questBoard
            case .questDetails:
                currentStep = .questGiver
            case .questAcceptance:
                currentStep = .questDetails
            }
        }
    }
    
    private func acceptQuest() {
        if viewModel.validateInputs() {
            viewModel.saveQuest()
        } else {
            showAlert(title: String.warningTitle.localized, message: viewModel.errorMessage ?? String.unknownError.localized)
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
    case questAcceptance
}

// MARK: - Quest Board View

struct QuestBoardView: View {
    @EnvironmentObject var themeManager: ThemeManager
    let onStartQuest: () -> Void
    let animate: Bool
    @State private var isButtonPressed = false
    
    var body: some View {
        let theme = themeManager.activeTheme
        VStack(spacing: 30) {
            Spacer()
            
            // Quest Board Title
            VStack(spacing: 16) {
                Image(systemName: "scroll.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.yellow)
                    .rotationEffect(.degrees(animate ? 5 : -5))
                    .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: animate)
                
                Text("QUEST BOARD")
                    .font(.appFont(size: 32, weight: .black))
                    .foregroundColor(theme.textColor)
                    .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 2)
                
                Text("Adventure awaits, brave one!")
                    .font(.appFont(size: 18, weight: .medium))
                    .foregroundColor(theme.textColor.opacity(0.8))
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
            
            // Start Quest Button
            Button(action: {
                isButtonPressed = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    isButtonPressed = false
                    onStartQuest()
                }
            }) {
                HStack(spacing: 12) {
                    Image(systemName: "sword.fill")
                        .font(.title2)
                    Text("ACCEPT NEW QUEST")
                        .font(.appFont(size: 18, weight: .black))
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
            
            Spacer()
        }
        .padding()
    }
}

// MARK: - Quest Giver View

struct QuestGiverView: View {
    @EnvironmentObject var themeManager: ThemeManager
    let dialogue: String
    let showDialogue: Bool
    let onContinue: () -> Void
    let animate: Bool
    @State private var isButtonPressed = false
    
    var body: some View {
        let theme = themeManager.activeTheme
        VStack(spacing: 30) {
            Spacer()
            
            // Quest Giver Character
            VStack(spacing: 20) {
                Image(systemName: "person.fill.questionmark")
                    .font(.system(size: 80))
                    .foregroundColor(.yellow)
                    .scaleEffect(animate ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: animate)
                
                Text("Quest Master")
                    .font(.appFont(size: 24, weight: .black))
                    .foregroundColor(theme.textColor)
            }
            
            // Dialogue Box
            if showDialogue {
                VStack(spacing: 16) {
                    Text(dialogue)
                        .font(.appFont(size: 16, weight: .medium))
                        .foregroundColor(theme.textColor)
                        .multilineTextAlignment(.center)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(theme.secondaryColor)
                                .shadow(color: Color.black.opacity(0.2), radius: 6, x: 0, y: 4)
                        )
                        .transition(.scale.combined(with: .opacity))
                    
                    Button(action: {
                        isButtonPressed = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            isButtonPressed = false
                            onContinue()
                        }
                    }) {
                        HStack(spacing: 8) {
                            Text("Continue")
                                .font(.appFont(size: 16, weight: .black))
                            Image(systemName: "arrow.right")
                                .font(.title3)
                        }
                        .foregroundColor(.white)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 24)
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
                }
                .transition(.scale.combined(with: .opacity))
            }
            
            Spacer()
        }
        .padding()
    }
}

// MARK: - Quest Details View

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
                
                // Repeat Type
                GamifiedRepeatTypeSection(repeatType: $viewModel.repeatType)
                
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

// MARK: - Quest Acceptance View

struct QuestAcceptanceView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @ObservedObject var viewModel: QuestCreationViewModel
    let onAcceptQuest: () -> Void
    let onGoBack: () -> Void
    let animate: Bool
    @State private var isAcceptPressed = false
    @State private var isBackPressed = false
    
    var body: some View {
        let theme = themeManager.activeTheme
        VStack(spacing: 30) {
            // Quest Summary Header
            VStack(spacing: 16) {
                Image(systemName: "scroll.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.yellow)
                    .scaleEffect(animate ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: animate)
                
                Text("QUEST SUMMARY")
                    .font(.appFont(size: 24, weight: .black))
                    .foregroundColor(theme.textColor)
            }
            
            // Quest Details Summary
            ScrollView {
                VStack(spacing: 16) {
                    QuestSummaryCard(
                        title: "Quest Name",
                        value: viewModel.questTitle.isEmpty ? "Untitled Quest" : viewModel.questTitle,
                        icon: "pencil.circle.fill"
                    )
                    
                    QuestSummaryCard(
                        title: "Description",
                        value: viewModel.questDescription.isEmpty ? "No description" : viewModel.questDescription,
                        icon: "doc.text.fill"
                    )
                    
                    QuestSummaryCard(
                        title: "Quest Type",
                        value: viewModel.isMainQuest ? "Main Quest" : "Side Quest",
                        icon: "star.fill"
                    )
                    
                    QuestSummaryCard(
                        title: "Difficulty",
                        value: "\(viewModel.difficulty)/5 Stars",
                        icon: "star.circle.fill"
                    )
                    
                    QuestSummaryCard(
                        title: "Due Date",
                        value: viewModel.questDueDate.formatted(date: .abbreviated, time: .omitted),
                        icon: "calendar.circle.fill"
                    )
                    
                    QuestSummaryCard(
                        title: "Tasks",
                        value: "\(viewModel.tasks.filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }.count) tasks",
                        icon: "list.bullet.circle.fill"
                    )
                }
                .padding()
            }
            
            // Action Buttons
            HStack(spacing: 20) {
                // Back Button
                Button(action: {
                    isBackPressed = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        isBackPressed = false
                        onGoBack()
                    }
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.left")
                            .font(.title3)
                        Text("BACK")
                            .font(.appFont(size: 16, weight: .black))
                    }
                    .foregroundColor(theme.textColor)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 24)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(theme.secondaryColor)
                            .opacity(isBackPressed ? 0.7 : 1.0)
                    )
                    .scaleEffect(isBackPressed ? 0.95 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isBackPressed)
                }
                .buttonStyle(PlainButtonStyle())
                
                // Accept Quest Button
                Button(action: {
                    isAcceptPressed = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        isAcceptPressed = false
                        onAcceptQuest()
                    }
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title3)
                        Text("ACCEPT QUEST")
                            .font(.appFont(size: 16, weight: .black))
                    }
                    .foregroundColor(.white)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 24)
                    .background(
                        Image(theme.buttonPrimary)
                            .resizable(
                                capInsets: EdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20),
                                resizingMode: .stretch
                            )
                            .opacity(isAcceptPressed ? 0.7 : 1.0)
                    )
                    .scaleEffect(isAcceptPressed ? 0.95 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isAcceptPressed)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding()
    }
}

// MARK: - Supporting Views

struct QuestBoardBackground: View {
    let animate: Bool
    
    var body: some View {
        ZStack {
            // Animated background elements
            ForEach(0..<5) { index in
                Circle()
                    .fill(Color.yellow.opacity(0.1))
                    .frame(width: CGFloat.random(in: 20...60))
                    .position(
                        x: CGFloat.random(in: 50...350),
                        y: CGFloat.random(in: 100...700)
                    )
                    .scaleEffect(animate ? 1.2 : 0.8)
                    .animation(
                        .easeInOut(duration: Double.random(in: 2...4))
                        .repeatForever(autoreverses: true)
                        .delay(Double(index) * 0.5),
                        value: animate
                    )
            }
        }
    }
}

struct StepTransitionOverlay: View {
    let text: String
    @State private var showText = false
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.7)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                ProgressView()
                    .scaleEffect(1.5)
                    .tint(.yellow)
                
                Text(text)
                    .font(.appFont(size: 18, weight: .black))
                    .foregroundColor(.white)
                    .opacity(showText ? 1.0 : 0.0)
                    .animation(.easeInOut(duration: 0.5), value: showText)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.5).delay(0.3)) {
                showText = true
            }
        }
    }
}

struct QuestSummaryCard: View {
    @EnvironmentObject var themeManager: ThemeManager
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        let theme = themeManager.activeTheme
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.yellow)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.appFont(size: 12, weight: .medium))
                    .foregroundColor(theme.textColor.opacity(0.7))
                
                Text(value)
                    .font(.appFont(size: 14, weight: .black))
                    .foregroundColor(theme.textColor)
            }
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(theme.secondaryColor)
                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        )
    }
}

// MARK: - Gamified Input Components

struct GamifiedInputField: View {
    @EnvironmentObject var themeManager: ThemeManager
    let title: String
    @Binding var text: String
    let icon: String
    let placeholder: String
    
    var body: some View {
        let theme = themeManager.activeTheme
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.yellow)
                Text(title)
                    .font(.appFont(size: 14, weight: .black))
                    .foregroundColor(theme.textColor)
            }
            
            TextField("", text: $text, prompt: Text(placeholder).foregroundColor(theme.textColor.opacity(0.6)))
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .font(.appFont(size: 16))
                .foregroundColor(theme.textColor)
                .accentColor(.yellow)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(theme.primaryColor.opacity(0.3))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.yellow.opacity(0.3), lineWidth: 1)
                        )
                )
        }
    }
}

struct GamifiedToggleCard: View {
    @EnvironmentObject var themeManager: ThemeManager
    let label: String
    @Binding var isOn: Bool
    
    var body: some View {
        let theme = themeManager.activeTheme
        HStack {
            Text(label)
                .font(.appFont(size: 16, weight: .black))
                .foregroundColor(theme.textColor)
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .tint(.yellow)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(theme.secondaryColor)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.yellow.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

struct GamifiedDatePicker: View {
    @EnvironmentObject var themeManager: ThemeManager
    let title: String
    @Binding var date: Date
    
    var body: some View {
        let theme = themeManager.activeTheme
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "calendar.circle.fill")
                    .foregroundColor(.yellow)
                Text(title)
                    .font(.appFont(size: 14, weight: .black))
                    .foregroundColor(theme.textColor)
            }
            
            DatePicker("", selection: $date, displayedComponents: [.date])
                .labelsHidden()
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(theme.primaryColor.opacity(0.3))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.yellow.opacity(0.3), lineWidth: 1)
                        )
                )
        }
    }
}

struct GamifiedTasksSection: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Binding var tasks: [String]
    let onEditTapped: () -> Void
    @State private var isButtonPressed = false
    
    var body: some View {
        let theme = themeManager.activeTheme
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "list.bullet.clipboard")
                    .foregroundColor(.yellow)
                Text("Quest Tasks")
                    .font(.appFont(size: 14, weight: .black))
                    .foregroundColor(theme.textColor)
                
                Spacer()
                
                Text("\(tasks.filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }.count)")
                    .font(.appFont(size: 12, weight: .black))
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.yellow)
                    )
            }
            
            Button(action: {
                isButtonPressed = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    isButtonPressed = false
                    onEditTapped()
                }
            }) {
                HStack {
                    Text("Manage Tasks")
                        .font(.appFont(size: 16, weight: .black))
                        .foregroundColor(theme.textColor)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(theme.textColor.opacity(0.6))
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(theme.secondaryColor)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.yellow.opacity(0.3), lineWidth: 1)
                        )
                        .opacity(isButtonPressed ? 0.7 : 1.0)
                )
                .scaleEffect(isButtonPressed ? 0.95 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isButtonPressed)
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}

struct GamifiedDifficultySection: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Binding var difficulty: Int
    
    var body: some View {
        let theme = themeManager.activeTheme
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "star.circle.fill")
                    .foregroundColor(.yellow)
                Text("Quest Difficulty")
                    .font(.appFont(size: 14, weight: .black))
                    .foregroundColor(theme.textColor)
            }
            
            HStack(spacing: 8) {
                ForEach(1...5, id: \.self) { star in
                    Button(action: {
                        difficulty = star
                    }) {
                        Image(systemName: star <= difficulty ? "star.fill" : "star")
                            .font(.title2)
                            .foregroundColor(star <= difficulty ? .yellow : .gray)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(theme.primaryColor.opacity(0.3))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.yellow.opacity(0.3), lineWidth: 1)
                    )
            )
        }
    }
}

struct GamifiedRepeatTypeSection: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Binding var repeatType: QuestRepeatType
    
    var body: some View {
        let theme = themeManager.activeTheme
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "repeat.circle.fill")
                    .foregroundColor(.yellow)
                Text("Repeat Type")
                    .font(.appFont(size: 14, weight: .black))
                    .foregroundColor(theme.textColor)
            }
            
            Picker("", selection: $repeatType) {
                Text("One Time").tag(QuestRepeatType.oneTime)
                Text("Daily").tag(QuestRepeatType.daily)
                Text("Weekly").tag(QuestRepeatType.weekly)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(theme.primaryColor.opacity(0.3))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.yellow.opacity(0.3), lineWidth: 1)
                    )
            )
        }
    }
}

struct GamifiedTagsSection: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Binding var selectedTags: [Tag]
    let onAddTags: () -> Void
    @State private var isButtonPressed = false
    
    var body: some View {
        let theme = themeManager.activeTheme
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "tag.circle.fill")
                    .foregroundColor(.yellow)
                Text("Quest Tags")
                    .font(.appFont(size: 14, weight: .black))
                    .foregroundColor(theme.textColor)
                
                Spacer()
                
                Button("Add Tags") {
                    isButtonPressed = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        isButtonPressed = false
                        onAddTags()
                    }
                }
                .font(.appFont(size: 14, weight: .medium))
                .foregroundColor(.yellow)
                .opacity(isButtonPressed ? 0.7 : 1.0)
                .scaleEffect(isButtonPressed ? 0.95 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isButtonPressed)
            }
            
            if selectedTags.isEmpty {
                Text("No tags selected")
                    .font(.appFont(size: 14, weight: .regular))
                    .foregroundColor(theme.textColor.opacity(0.6))
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(theme.primaryColor.opacity(0.3))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.yellow.opacity(0.3), lineWidth: 1)
                            )
                    )
            } else {
                TagChipRow(
                    tags: selectedTags,
                    isSelectable: false,
                    selectedTags: [],
                    onTagTap: { _ in },
                    onTagRemove: { tag in
                        if let index = selectedTags.firstIndex(of: tag) {
                            selectedTags.remove(at: index)
                        }
                    }
                )
            }
        }
    }
}

// MARK: - Legacy Components (keeping for compatibility)

struct QuestInputField: View {
    @EnvironmentObject var themeManager: ThemeManager
    var title: String
    @Binding var text: String
    var icon: String

    var body: some View {
        let theme = themeManager.activeTheme
        HStack {
            Image(systemName: icon)
                .foregroundColor(theme.textColor)

            TextField("", text: $text, prompt: Text(title).foregroundColor(theme.textColor))
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .font(.appFont(size: 16))
                .foregroundColor(theme.textColor)
                .accentColor(.yellow)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(themeManager.activeTheme.secondaryColor)
                .shadow(color: Color.black.opacity(0.2), radius: 6, x: 0, y: 4)
        )
    }
}

struct ToggleCard: View {
    var label: String
    @Binding var isOn: Bool
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        let theme = themeManager.activeTheme
        Toggle(isOn: $isOn) {
            Text(label)
                .font(.appFont(size: 16, weight: .black))
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(themeManager.activeTheme.secondaryColor)
                .shadow(color: Color.black.opacity(0.2), radius: 6, x: 0, y: 4)
        )
        .tint(Color.yellow)
    }
}
