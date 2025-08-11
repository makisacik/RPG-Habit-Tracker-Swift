import SwiftUI

struct QuestCreationView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @ObservedObject var viewModel: QuestCreationViewModel
    @State private var showAlert: Bool = false
    @State private var alertTitle: String = ""
    @State private var alertMessage: String = ""
    @State private var isButtonPressed: Bool = false
    @State private var isTaskPopupVisible = false
    @State private var showSuccessAnimation = false
    @State private var notifyMe = true

    var body: some View {
        let theme = themeManager.activeTheme
        NavigationView {
            ZStack {
                if showSuccessAnimation {
                    SuccessAnimationOverlay(isVisible: $showSuccessAnimation)
                        .zIndex(20)
                }
                RoundedRectangle(cornerRadius: 12)
                    .fill(theme.backgroundColor)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        QuestInputField(title: String.questTitle.localized, text: $viewModel.questTitle, icon: "pencil.circle.fill")
                        QuestInputField(title: String.questDescription.localized, text: $viewModel.questDescription, icon: "doc.text.fill")

                        ToggleCard(label: String.mainQuest.localized + "?", isOn: $viewModel.isMainQuest)

                        VStack(alignment: .leading, spacing: 20) {
                            HStack {
                                Text(String.questDueDate.localized)
                                    .font(.appFont(size: 16, weight: .black))
                                    .padding()
                                Spacer()
                                DatePicker("", selection: $viewModel.questDueDate, displayedComponents: [.date])
                                    .labelsHidden()
                                    .padding(.trailing, 10)
                            }
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(theme.secondaryColor)
                                        .shadow(color: Color.black.opacity(0.2), radius: 6, x: 0, y: 4)
                                )
                            AddTasksView(tasks: $viewModel.tasks) {
                                isTaskPopupVisible = true
                            }
                        }

                        VStack {
                            Text(String.questDifficulty.localized)
                                .font(.appFont(size: 16, weight: .black))
                            StarRatingView(rating: $viewModel.difficulty)
                        }
                        
                        ToggleCard(label: String.notifyMeAboutQuest.localized, isOn: $notifyMe)

                        Picker(String.repeatLabel.localized, selection: $viewModel.repeatType) {
                            Text(String.oneTime.localized).tag(QuestRepeatType.oneTime)
                            Text(String.daily.localized).tag(QuestRepeatType.daily)
                            Text(String.weekly.localized).tag(QuestRepeatType.weekly)
                        }
                        .pickerStyle(SegmentedPickerStyle())

                        Button(action: {
                            isButtonPressed = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                isButtonPressed = false
                            }
                            if viewModel.validateInputs() {
                                viewModel.saveQuest()
                            } else {
                                showAlert(title: String.warningTitle.localized, message: viewModel.errorMessage ?? String.unknownError.localized)
                            }
                        }) {
                            if viewModel.isSaving {
                                ProgressView()
                            } else {
                                HStack {
                                    Spacer()
                                    Image(systemName: "plus.circle.fill").font(.title2).foregroundColor(theme.textColor)
                                    Text(String.saveQuest.localized)
                                        .font(.appFont(size: 16, weight: .black))
                                        .foregroundColor(theme.textColor)
                                    Spacer()
                                }
                                .padding()
                                .background(
                                    Image(theme.buttonPrimary)
                                        .resizable(
                                            capInsets: EdgeInsets(
                                                top: 20,
                                                leading: 20,
                                                bottom: 20,
                                                trailing: 20
                                            ),
                                            resizingMode: .stretch
                                        )
                                        .opacity(isButtonPressed ? 0.7 : 1.0)
                                )
                                .frame(maxWidth: .infinity, minHeight: 44, maxHeight: 44)
                                .scaleEffect(isButtonPressed ? 0.97 : 1.0)
                                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isButtonPressed)
                            }
                        }
                        .disabled(viewModel.isSaving)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(themeManager.activeTheme.primaryColor)
                            .shadow(color: Color.black.opacity(0.2), radius: 6, x: 0, y: 4)
                            .allowsHitTesting(false)
                    )
                    .padding()
                }
                .scrollDismissesKeyboard(.interactively)

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
                }
            }
        }
    }

    private func showAlert(title: String, message: String) {
        alertTitle = title
        alertMessage = message
        showAlert = true
    }
    
    private func saveQuestAndShowAnimation() {
        viewModel.saveQuest()
        showSuccessAnimation = true
    }
}

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
