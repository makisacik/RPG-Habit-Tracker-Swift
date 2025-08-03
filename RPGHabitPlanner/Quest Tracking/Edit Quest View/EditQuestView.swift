import SwiftUI

struct EditQuestView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    @ObservedObject var viewModel: EditQuestViewModel
    @State private var isButtonPressed: Bool = false
    @State private var showAlert: Bool = false
    @State private var alertTitle: String = ""
    @State private var alertMessage: String = ""
    @State private var isTaskPopupVisible = false

    var onSaveSuccess: (() -> Void)?
    var onCancel: (() -> Void)?
    
    var body: some View {
        let theme = themeManager.activeTheme

        NavigationView {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(theme.backgroundColor)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        QuestInputField(title: "Title", text: $viewModel.title, icon: "pencil.circle.fill")
                        QuestInputField(title: "Description", text: $viewModel.description, icon: "doc.text.fill")

                        ToggleCard(label: "Main Quest", isOn: $viewModel.isMainQuest)

                        VStack(alignment: .leading, spacing: 20) {
                            HStack {
                                Text("Due Date")
                                    .font(.appFont(size: 16, weight: .black))
                                    .padding()
                                Spacer()
                                DatePicker("", selection: $viewModel.dueDate, displayedComponents: [.date])
                                    .labelsHidden()
                                    .padding(.trailing, 10)
                            }
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(theme.primaryColor)
                            )
                            .cornerRadius(10)
                        }

                        VStack {
                            Text("Quest Difficulty")
                                .font(.appFont(size: 16, weight: .black))
                            StarRatingView(rating: $viewModel.difficulty)
                        }

                        AddTasksView(tasks: $viewModel.tasks) {
                            isTaskPopupVisible = true
                        }

                        Button(action: {
                            isButtonPressed = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                isButtonPressed = false
                            }
                            if viewModel.validateInputs() {
                                viewModel.updateQuest { success in
                                    if success {
                                        onSaveSuccess?()
                                        dismiss()
                                    } else {
                                        showAlert(title: "Error", message: viewModel.errorMessage ?? "Failed to update quest.")
                                    }
                                }
                            } else {
                                showAlert(title: "Warning", message: viewModel.errorMessage ?? "Unknown error")
                            }
                        }) {
                            if viewModel.isSaving {
                                ProgressView()
                            } else {
                                HStack {
                                    Spacer()
                                    Text("Update Quest")
                                        .font(.appFont(size: 16, weight: .black))
                                        .foregroundColor(theme.textColor)
                                    Spacer()
                                }
                                .padding()
                                .background(
                                    Image(theme.buttonPrimary)
                                        .resizable(capInsets: EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
                                        .opacity(isButtonPressed ? 0.7 : 1.0)
                                )
                                .cornerRadius(8)
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
                    )
                    .cornerRadius(16)
                    .padding()
                }
                
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
            .alert(isPresented: $showAlert) {
                Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
            .onChange(of: viewModel.didUpdateQuest) { updated in
                if updated { dismiss() }
            }
        }
    }

    private func showAlert(title: String, message: String) {
        alertTitle = title
        alertMessage = message
        showAlert = true
    }
}
