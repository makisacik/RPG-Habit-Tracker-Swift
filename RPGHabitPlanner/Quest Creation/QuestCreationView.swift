import SwiftUI

struct QuestCreationView: View {
    @ObservedObject var viewModel: QuestCreationViewModel

    @State private var showAlert: Bool = false
    @State private var alertTitle: String = ""
    @State private var alertMessage: String = ""
    @State private var isButtonPressed: Bool = false

    var body: some View {
        NavigationView {
            ZStack {
                Image("pattern_grid_paper")
                    .resizable(resizingMode: .tile)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        Image("banner_hanging")
                            .resizable()
                            .frame(height: 60)
                            .overlay(
                                Text("Create New Quest")
                                    .font(.appFont(size: 18, weight: .black))
                                    .foregroundColor(.black)
                            )
                            .padding(.bottom, 10)

                        QuestInputField(title: "Quest Title", text: $viewModel.questTitle, icon: "pencil.circle.fill")
                        QuestInputField(title: "Quest Description", text: $viewModel.questDescription, icon: "doc.text.fill")

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Due Date")
                                .font(.appFont(size: 16, weight: .black))

                            DatePicker("", selection: $viewModel.questDueDate, displayedComponents: [.date])
                                .labelsHidden()
                                .padding()
                                .background(
                                    Image("panel_brown_dark")
                                        .resizable(capInsets: EdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20), resizingMode: .stretch)
                                )
                                .cornerRadius(10)
                        }

                        ToggleCard(label: "Main quest?", isOn: $viewModel.isMainQuest)
                        ToggleCard(label: "Activate the quest now?", isOn: $viewModel.isActiveQuest)

                        VStack {
                            Text("Quest Difficulty")
                                .font(.appFont(size: 16, weight: .black))
                            StarRatingView(rating: $viewModel.difficulty)
                        }
                        .padding()

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
                                        .foregroundColor(.white)
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
                        .padding(.top, 20)
                    }
                    .padding()
                    .background(
                        Image("panel_brown")
                            .resizable(capInsets: EdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20), resizingMode: .stretch)
                    )
                    .cornerRadius(16)
                    .padding()
                }
                .scrollDismissesKeyboard(.interactively)
            }
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
                .foregroundColor(.white)

            TextField("", text: $text, prompt: Text(title).foregroundColor(.white))
                .font(.appFont(size: 16))
                .foregroundColor(.white)
                .accentColor(.yellow)
        }
        .padding()
        .background(
            Image("panel_brown_dark")
                .resizable(capInsets: EdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20), resizingMode: .stretch)
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
            Image("panel_brown_dark")
                .resizable(capInsets: EdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20), resizingMode: .stretch)
        )
        .cornerRadius(10)
        .tint(Color.yellow)
    }
}
