//
//  HomeView.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 10.11.2024.
//

import SwiftUI

struct HomeView: View {
    let questDataService: QuestDataServiceProtocol
    
    var body: some View {
        NavigationStack {
            ScrollView {
                QuestTrackingView(viewModel: QuestTrackingViewModel(questDataService: questDataService))
                    .padding()
                
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: QuestCreationView(viewModel: QuestCreationViewModel(questDataService: questDataService))) {
                        Image(systemName: "plus")
                            .font(.title2)
                            .foregroundStyle(.yellow)
                    }
                }
            }
        }
    }
}

#Preview {
    let questDataService = QuestCoreDataService()
    HomeView(questDataService: questDataService)
}
