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
        QuestTrackingView(viewModel: QuestTrackingViewModel(questDataService: questDataService))
            .padding()
        
        Spacer()
    }
}

#Preview {
    let questDataService = QuestCoreDataService()
    HomeView(questDataService: questDataService)
}
