//
//  MainQuestCardView.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 10.11.2024.
//

import SwiftUI

struct MainQuestCardView: View {
    let quest: Quest
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(quest.title)
                .font(.headline)
            
            HStack {
                Text("Difficulty: \(quest.difficulty)")
                    .font(.subheadline)
                
                Text("Due: \(quest.dueDate, style: .date)")
                    .font(.caption)
            }
            Text(quest.info)
                .font(.body)
                .lineLimit(2)
                .truncationMode(.tail)
            
            Text("Main Quest")
                .font(.footnote)
                .bold()
                .foregroundColor(.red)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 3)
        .frame(maxWidth: .infinity)
    }
}
