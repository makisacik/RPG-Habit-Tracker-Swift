//
//  CompletedQuestsView.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 17.11.2024.
//

import SwiftUI

struct CompletedQuestsView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @StateObject var viewModel: CompletedQuestsViewModel
    @State private var showAlert: Bool = false

    var body: some View {
        let theme = themeManager.activeTheme
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(theme.backgroundColor)
                .ignoresSafeArea()

            VStack(spacing: 5) {
                VStack {
                    if viewModel.completedQuests.isEmpty {
                        Text("No completed quests yet!")
                            .font(.appFont(size: 16, weight: .black))
                            .foregroundColor(.gray)
                            .padding()
                    } else {
                        questList
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(theme.primaryColor)
                )
                .padding(.horizontal)
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
                    message: Text(viewModel.errorMessage ?? "An unknown error occurred")
                        .font(.appFont(size: 14)),
                    dismissButton: .default(Text("OK").font(.appFont(size: 14, weight: .black))) {
                        viewModel.errorMessage = nil
                    }
                )
            }
        }
    }

    private var questList: some View {
        ScrollView {
            VStack(spacing: 10) {
                ForEach(viewModel.completedQuests) { quest in
                    CompletedQuestCardView(quest: quest)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding()
        }
        .scrollIndicators(.hidden)
    }
}

struct CompletedQuestCardView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @State private var isExpanded: Bool = false
    let quest: Quest

    var body: some View {
        let theme = themeManager.activeTheme
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(quest.title)
                    .font(.appFont(size: 16, weight: .black))
                    .foregroundColor(theme.textColor)

                Spacer()

                Text("Created: \(quest.creationDate.formatted(date: .abbreviated, time: .omitted))")
                    .font(.appFont(size: 12))
                    .foregroundColor(theme.textColor)
            }

            if !quest.info.isEmpty {
                Text(quest.info)
                    .font(.appFont(size: 14))
                    .lineLimit(isExpanded ? nil : 2)
                    .truncationMode(.tail)
                    .foregroundColor(theme.textColor)
            }

            let tasks = quest.tasks
            if !tasks.isEmpty {
                Button(action: {
                    withAnimation {
                        isExpanded.toggle()
                    }
                }) {
                    HStack {
                        Text("\(tasks.count) Tasks")
                            .font(.appFont(size: 14, weight: .regular))
                            .foregroundColor(theme.textColor)
                        Spacer()
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .foregroundColor(theme.textColor)
                            .imageScale(.small)
                    }
                }

                if isExpanded {
                    VStack(alignment: .leading, spacing: 4) {
                        ForEach(tasks, id: \.id) { task in
                            HStack {
                                Image(task.isCompleted ? "checkbox_beige_checked" : "checkbox_beige_empty")
                                    .resizable()
                                    .frame(width: 18, height: 18)
                                    .foregroundColor(task.isCompleted ? .green : .gray)

                                Text(task.title)
                                    .font(.appFont(size: 13))
                                    .foregroundColor(theme.textColor)

                                Spacer()
                            }
                        }
                    }
                    .padding(.top, 4)
                    .transition(.opacity.combined(with: .slide))
                }
            }

            Spacer()

            HStack {
                StarRatingView(rating: .constant(quest.difficulty), starSize: 14, spacing: 4)
                    .disabled(true)

                Spacer()

                Text("Due: \(quest.dueDate.formatted(date: .abbreviated, time: .omitted))")
                    .font(.appFont(size: 12))
                    .foregroundColor(theme.textColor)
            }
            .padding(.top, 4)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(themeManager.activeTheme.secondaryColor)
                .shadow(color: Color.black.opacity(0.2), radius: 6, x: 0, y: 4)
        )
        .cornerRadius(10)
        .shadow(radius: 3)
        .frame(maxWidth: .infinity)
    }
}


#Preview {
    let questDataService = QuestCoreDataService()
    let viewModel = CompletedQuestsViewModel(questDataService: questDataService)
    CompletedQuestsView(viewModel: viewModel)
}
