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
            Button("Reset Character Data") {
                resetCharacterCreationData()
            }
        }
    }
    
    
    func resetCharacterCreationData() {
        UserDefaults.standard.removeObject(forKey: "isCharacterCreated")
        UserDefaults.standard.removeObject(forKey: "selectedCharacterClass")
        UserDefaults.standard.removeObject(forKey: "selectedWeapon")
    }
}

#Preview {
    let questDataService = QuestCoreDataService()
    HomeView(questDataService: questDataService)
}
