//
//  CompletedQuestsView.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 17.11.2024.
//

import SwiftUI

struct CompletedQuestsView: View {
    @StateObject var viewModel: CompletedQuestsViewModel
    @State private var showAlert: Bool = false

    var body: some View {
        VStack {
            if viewModel.completedQuests.isEmpty {
                Text("No completed quests yet!")
                    .font(.headline)
                    .foregroundColor(.gray)
                    .padding()
            } else {
                ScrollView {
                    VStack {
                        ForEach(viewModel.completedQuests) { quest in
                            CompletedQuestCardView(quest: quest)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .padding(.horizontal, 16)
                        }
                    }
                }
                .scrollIndicators(.hidden)
            }
        }
        .onAppear {
            viewModel.fetchCompletedQuests()
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
        .navigationTitle("Completed Quests 🏆")
    }
}

struct CompletedQuestCardView: View {
    let quest: Quest

    var body: some View {
        VStack(alignment: .leading) {
            Text(quest.title)
                .font(.headline)
                .foregroundColor(.green)

            Text(quest.info)
                .font(.body)
                .lineLimit(2)
                .truncationMode(.tail)
                .foregroundStyle(.black)

            Spacer()

            HStack {
                HStack(spacing: 2) {
                    ForEach(1...5, id: \.self) { index in
                        Image(systemName: "star.fill")
                            .resizable()
                            .frame(width: 12, height: 12)
                            .foregroundColor(index <= quest.difficulty ? .yellow : .gray)
                    }
                }
                Spacer()
                Text(quest.dueDate, format: .dateTime.day().month(.abbreviated))
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding(.top, 4)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 3)
    }
}

#Preview {
    let questDataService = QuestCoreDataService()
    let viewModel = CompletedQuestsViewModel(questDataService: questDataService)
    CompletedQuestsView(viewModel: viewModel)
}
