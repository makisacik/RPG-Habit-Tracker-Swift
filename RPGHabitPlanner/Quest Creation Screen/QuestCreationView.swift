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
    @State private var errorMessage: String?

    init(viewModel: QuestCreationViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationView {
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

                Button(action: saveQuest) {
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
                    Alert(title: Text("Error"), message: Text(errorMessage ?? "Unknown error"), dismissButton: .default(Text("OK")))
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Create New Quest")
        }
    }
    
    private func saveQuest() {
        viewModel.createQuest(
            title: questTitle,
            isMainQuest: isMainQuest,
            info: questDescription,
            difficulty: difficulty,
            creationDate: Date(),
            dueDate: questDueDate
        ) { error in
            if let error = error {
                errorMessage = error.localizedDescription
                showAlert = true
            } else {
                // Clear input fields after saving successfully
                questTitle = ""
                questDescription = ""
                questDueDate = Date()
                isMainQuest = false
                difficulty = 3
                isRepetitiveQuest = false
            }
        }
    }
}


#Preview {
    let questDataService = QuestCoreDataService()
    let viewModel = QuestCreationViewModel(questDataService: questDataService)
    QuestCreationView(viewModel: viewModel)
}
