//
//  SideQuestCardView.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 10.11.2024.
//

import SwiftUI

struct SideQuestCardView: View {
    let quest: Quest
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(quest.title)
                .font(.headline)
            
            Text("Difficulty: \(quest.difficulty)")
                .font(.subheadline)
            
            Text("Due: \(quest.dueDate, style: .date)")
                .font(.caption)
            
            Text("Side Quest")
                .font(.footnote)
                .bold()
                .foregroundColor(.blue)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 3)
    }
}
