//
//  QuestCreationView.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 28.10.2024.
//

import SwiftUI

struct QuestCreationView: View {
    @StateObject private var viewModel: QuestCreationViewModel
    
    @State private var questTitle: String = ""
    @State private var questDescription: String = ""
    @State private var questDueDate = Date()
    @State private var isMainQuest: Bool = false
    @State private var difficulty: Int = 3
    @State private var isRepetitiveQuest: Bool = false
    @State private var showAlert: Bool = false
    @State private var showSuccessMessage: Bool = false
    
    init(viewModel: QuestCreationViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    TextField("Quest Title", text: $questTitle)
                        .autocorrectionDisabled()
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .shadow(radius: 3)
                    
                    TextField("Quest Description", text: $questDescription)
                        .autocorrectionDisabled()
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .shadow(radius: 3)
                    
                    DatePicker("Due Date", selection: $questDueDate, displayedComponents: [.date])
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .shadow(radius: 3)
                    
                    Toggle(isOn: $isMainQuest) {
                        Text("Is this a main quest?")
                            .font(.headline)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .shadow(radius: 3)
                    
                    Toggle(isOn: $isRepetitiveQuest) {
                        Text("Is this a repetitive quest?")
                            .font(.headline)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .shadow(radius: 3)
                    
                    VStack {
                        Text("Quest Difficulty")
                            .font(.headline)
                        
                        StarRatingView(rating: $difficulty)
                    }
                    .padding()

                    Button(action: {
                        viewModel.saveQuest(
                            title: questTitle,
                            isMainQuest: isMainQuest,
                            info: questDescription,
                            difficulty: difficulty,
                            dueDate: questDueDate
                        )
                    }) {
                        Text("Save Quest")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(8)
                            .shadow(radius: 3)
                    }
                    .padding(.top, 20)
                    .alert(isPresented: $showAlert) {
                        Alert(
                            title: Text("Error"),
                            message: Text(viewModel.errorMessage ?? "Unknown error"),
                            dismissButton: .default(Text("OK"))
                        )
                    }
                    .alert(isPresented: $showSuccessMessage) {
                        Alert(
                            title: Text("Success"),
                            message: Text("Quest saved successfully!"),
                            dismissButton: .default(Text("OK"))
                        )
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .scrollDismissesKeyboard(.interactively)
            .navigationTitle("Create New Quest")
            .onTapGesture {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
            .onReceive(viewModel.$didSaveQuest) { success in
                if success {
                    showSuccessMessage = true
                    resetFields()
                }
            }
        }
    }
    
    private func resetFields() {
        questTitle = ""
        questDescription = ""
        questDueDate = Date()
        isMainQuest = false
        difficulty = 3
        isRepetitiveQuest = false
    }
}


#Preview {
    let questDataService = QuestCoreDataService()
    let viewModel = QuestCreationViewModel(questDataService: questDataService)
    QuestCreationView(viewModel: viewModel)
}
