import SwiftUI

struct QuestCreationView: View {
    @ObservedObject var viewModel: QuestCreationViewModel

    @State private var showAlert: Bool = false
    @State private var alertTitle: String = ""
    @State private var alertMessage: String = ""
    @State private var isButtonPressed: Bool = false
    @State private var isTaskPopupVisible = false

    var body: some View {
        NavigationView {
            ZStack {
                Image("pattern_grid_paper")
                    .resizable(resizingMode: .tile)
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
                                    .padding()
                            }
                                .background(
                                    Image("panel_beigeLight")
                                        .resizable(capInsets: EdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20), resizingMode: .stretch)
                                        .allowsHitTesting(false)
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
                        // .padding()
                        
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
                                        .foregroundColor(.black)
                                    Spacer()
                                }
                                .padding()
                                .background(
                                    Image("buttonLong_brown")
                                        .resizable(capInsets: EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10), resizingMode: .stretch)
                                        .frame(maxWidth: .infinity, minHeight: 44, maxHeight: 44)
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
                        Image("panel_brown_plus")
                            .resizable(capInsets: EdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20), resizingMode: .stretch)
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

                    TaskEditorPopup(tasks: $viewModel.tasks, isPresented: $isTaskPopupVisible)
                        .frame(width: 350, height: 450)
                        .background(
                            Image("panel_beigeLight")
                                .resizable(capInsets: EdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20))
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
                    showAlert(title: "Success", message: "Quest saved successfully!")
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
}

struct QuestInputField: View {
    var title: String
    @Binding var text: String
    var icon: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.black)

            TextField("", text: $text, prompt: Text(title).foregroundColor(.black))
                .font(.appFont(size: 16))
                .foregroundColor(.black)
                .accentColor(.yellow)
        }
        .padding()
        .background(
            Image("panel_beigeLight")
                .resizable(capInsets: EdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20), resizingMode: .stretch)
                .allowsHitTesting(false)
        )
        .cornerRadius(10)
    }
}

struct ToggleCard: View {
    var label: String
    @Binding var isOn: Bool

    var body: some View {
        Toggle(isOn: $isOn) {
            Text(label)
                .font(.appFont(size: 16, weight: .black))
        }
        .padding()
        .background(
            Image("panel_beigeLight")
                .resizable(capInsets: EdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20), resizingMode: .stretch)
                .allowsHitTesting(false)
        )
        .cornerRadius(10)
        .tint(Color.yellow)
    }
}
