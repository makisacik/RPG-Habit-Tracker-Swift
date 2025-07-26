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
        ZStack {
            Image("pattern_grid_paper")
                .resizable(resizingMode: .tile)
                .ignoresSafeArea()

            VStack {
                Image("banner_hanging")
                    .resizable()
                    .frame(height: 60)
                    .overlay(
                        Text("Completed Quests 🏆")
                            .font(.appFont(size: 18, weight: .black))
                            .foregroundColor(.black)
                    )
                    .padding(.bottom, 5)

                if viewModel.completedQuests.isEmpty {
                    Text("No completed quests yet!")
                        .font(.appFont(size: 16, weight: .black))
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    ScrollView {
                        VStack(spacing: 10) {
                            ForEach(viewModel.completedQuests) { quest in
                                CompletedQuestCardView(quest: quest)
                                    .frame(maxWidth: .infinity)
                                    .padding(.horizontal, 16)
                            }
                        }
                        .padding()
                        .background(
                            Image("panel_brown")
                                .resizable(capInsets: EdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20), resizingMode: .stretch)
                        )
                        .cornerRadius(16)
                        .padding()
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
                    title: Text("Error").font(.appFont(size: 16, weight: .black)),
                    message: Text(viewModel.errorMessage ?? "An unknown error occurred").font(.appFont(size: 14)),
                    dismissButton: .default(Text("OK").font(.appFont(size: 14, weight: .black))) {
                        viewModel.errorMessage = nil
                    }
                )
            }
        }
    }
}

struct CompletedQuestCardView: View {
    let quest: Quest

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(quest.title)
                .font(.appFont(size: 16, weight: .black))
                .foregroundColor(.green)

            if !quest.info.isEmpty {
                Text(quest.info)
                    .font(.appFont(size: 14))
                    .lineLimit(2)
                    .truncationMode(.tail)
                    .foregroundColor(.black)
            }

            HStack {
                HStack(spacing: 2) {
                    ForEach(1...5, id: \.self) { index in
                        Image(systemName: "star.fill")
                            .resizable()
                            .frame(width: 12, height: 12)
                            .foregroundColor(index <= quest.difficulty ? Color(.appYellow) : .gray)
                    }
                }
                Spacer()
                Text(quest.dueDate, format: .dateTime.day().month(.abbreviated))
                    .font(.appFont(size: 12))
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(
            Image("panel_brown_dark")
                .resizable(capInsets: EdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20), resizingMode: .stretch)
        )
        .cornerRadius(12)
    }
}


#Preview {
    let questDataService = QuestCoreDataService()
    let viewModel = CompletedQuestsViewModel(questDataService: questDataService)
    CompletedQuestsView(viewModel: viewModel)
}
