//
//  QuestTrackingView.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 10.11.2024.
//

import SwiftUI

struct QuestTrackingView: View {
    @ObservedObject var viewModel: QuestTrackingViewModel
    @State private var showAlert: Bool = false
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Quests")
                .font(.title)
                .bold()
                .padding(.horizontal)
            
            ScrollView {
                ForEach(viewModel.quests) { quest in
                    QuestCardView(quest: quest)
                        .padding(.horizontal)
                        .padding(.vertical, 4)
                }
            }
        }
        .onAppear {
            viewModel.fetchQuests()
        }
        .onChange(of: viewModel.errorMessage) { errorMessage in
            showAlert = errorMessage != nil
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Error"),
                message: Text(viewModel.errorMessage ?? "An unknown error occurred"),
                dismissButton: .default(Text("OK")) {
                    viewModel.errorMessage = nil
                }
            )
        }
    }
}

struct QuestCardView: View {
    let quest: Quest
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(quest.title)
                .font(.headline)
            Text("Difficulty: \(quest.difficulty)")
                .font(.subheadline)
            Text("Due: \(quest.dueDate, style: .date)")
                .font(.caption)
            
            if quest.isMainQuest {
                Text("Main Quest")
                    .font(.footnote)
                    .bold()
                    .foregroundColor(.red)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 3)
    }
}


#Preview {
    let questDataService = QuestCoreDataService()
    QuestTrackingView(viewModel: QuestTrackingViewModel(questDataService: questDataService))
}
