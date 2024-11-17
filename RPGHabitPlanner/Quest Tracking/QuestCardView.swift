//
//  MainQuestCardView.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 10.11.2024.
//

import SwiftUI

struct QuestCardView: View {
    let quest: Quest
    let onMarkComplete: (UUID) -> Void
    
    @State private var isMenuPresented: Bool = false
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(alignment: .leading) {
                Text(quest.title)
                    .font(.headline)
                    .foregroundStyle(.black)
                if !quest.info.isEmpty {
                    Text(quest.info)
                        .font(.body)
                        .lineLimit(2)
                        .truncationMode(.tail)
                        .foregroundStyle(.black)
                }

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
            .frame(maxWidth: .infinity)
            
            Menu {
                Button("Mark as Completed") {
                    onMarkComplete(quest.id)
                }
            } label: {
                Image(systemName: "ellipsis")
                    .padding()
                    .foregroundColor(.gray)
            }
        }
    }
}
