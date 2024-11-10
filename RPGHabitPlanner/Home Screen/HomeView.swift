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
        }
    }
}

#Preview {
    let questDataService = QuestCoreDataService()
    HomeView(questDataService: questDataService)
}
