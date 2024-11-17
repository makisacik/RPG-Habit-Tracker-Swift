//
//  QuestCreationView.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 28.10.2024.
//

import SwiftUI

struct QuestCreationView: View {
    @ObservedObject var viewModel: QuestCreationViewModel

    @State private var showAlert: Bool = false
    @State private var alertTitle: String = ""
    @State private var alertMessage: String = ""

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    QuestInputField(title: "Quest Title", text: $viewModel.questTitle, icon: "pencil.circle.fill")
                    
                    QuestInputField(title: "Quest Description", text: $viewModel.questDescription, icon: "doc.text.fill")
                    
                    DatePicker("Due Date", selection: $viewModel.questDueDate, displayedComponents: [.date])
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .shadow(radius: 3)
                    
                    Toggle(isOn: $viewModel.isMainQuest) {
                        Text("Main quest?")
                            .font(.headline)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .shadow(radius: 3)
                    
                    Toggle(isOn: $viewModel.isActiveQuest) {
                        Text("Activate the quest now?")
                            .font(.headline)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .shadow(radius: 3)
                    
                    VStack {
                        Text("Quest Difficulty")
                            .font(.headline)
                        
                        StarRatingView(rating: $viewModel.difficulty)
                    }
                    .padding()

                    Button(action: {
                        if viewModel.validateInputs() {
                            viewModel.saveQuest()
                        } else {
                            showAlert(title: "Warning", message: viewModel.errorMessage ?? "Unknown error")
                        }
                    }) {
                        if viewModel.isSaving {
                            ProgressView()
                        } else {
                            Text("Save Quest")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(8)
                                .shadow(radius: 3)
                        }
                    }
                    .disabled(viewModel.isSaving)
                    .padding(.top, 20)
                }
                .padding()
            }
            .scrollDismissesKeyboard(.interactively)
            .navigationTitle("Create New Quest")
            .onTapGesture {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text(alertTitle),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK"))
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
            TextField(title, text: $text)
                .autocorrectionDisabled()
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .shadow(radius: 3)
    }
}
