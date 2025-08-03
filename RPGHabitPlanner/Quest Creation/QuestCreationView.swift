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
                        QuestInputField(title: "Title", text: $viewModel.questTitle, icon: "pencil.circle.fill")
                        QuestInputField(title: "Description", text: $viewModel.questDescription, icon: "doc.text.fill")

                        ToggleCard(label: "Main quest?", isOn: $viewModel.isMainQuest)

                        VStack(alignment: .leading, spacing: 20) {
                            HStack {
                                Text("Due Date")
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
                                )
                                .cornerRadius(10)
                            AddTasksView(tasks: $viewModel.tasks) {
                                isTaskPopupVisible = true
                            }
                        }

                        VStack {
                            Text("Quest Difficulty")
                                .font(.appFont(size: 16, weight: .black))
                            StarRatingView(rating: $viewModel.difficulty)
                        }
                        
                        ToggleCard(label: "Notify me about this quest", isOn: $notifyMe)

                        Picker("Repeat", selection: $viewModel.repeatType) {
                            Text("One Time").tag(QuestRepeatType.oneTime)
                            Text("Daily").tag(QuestRepeatType.daily)
                            Text("Weekly").tag(QuestRepeatType.weekly)
                            Text("Every X Weeks").tag(QuestRepeatType.everyXWeeks)
                        }
                        .pickerStyle(SegmentedPickerStyle())

                        if viewModel.repeatType == .everyXWeeks {
                            Stepper("Repeat every \(viewModel.repeatIntervalWeeks) weeks", value: $viewModel.repeatIntervalWeeks, in: 1...12)
                        }

                        Button(action: {
                            isButtonPressed = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                isButtonPressed = false
                            }
                            if viewModel.validateInputs() {
                                viewModel.saveQuest()
                            } else {
                                showAlert(title: "Warning", message: viewModel.errorMessage ?? "Unknown error")
                            }
                        }) {
                            if viewModel.isSaving {
                                ProgressView()
                            } else {
                                HStack {
                                    Spacer()
                                    Text("Save Quest")
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
                            .allowsHitTesting(false)
                    )
                    .cornerRadius(16)
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
                    dismissButton: .default(Text("OK").font(.appFont(size: 14, weight: .black)))
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
        .cornerRadius(10)
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
        .cornerRadius(10)
        .tint(Color.yellow)
    }
}
