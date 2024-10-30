//
//  QuestCreationView.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 28.10.2024.
//

import SwiftUI

struct QuestCreationView: View {
    @State private var questTitle: String = ""
    @State private var questDescription: String = ""
    @State private var questDueDate = Date()
    @State private var isMainQuest: Bool = false
    @State private var questHardness: Int = 3
    @State private var isRepetitiveQuest: Bool = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                TextField("Quest Title", text: $questTitle)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .shadow(radius: 3)
                
                TextField("Quest Description", text: $questDescription)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .shadow(radius: 3)
                
                DatePicker("Due Date", selection: $questDueDate, displayedComponents: [.date])
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .shadow(radius: 3)
                
                Toggle(isOn: $isMainQuest) {
                    Text("Is this a main quest?")
                        .font(.headline)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .shadow(radius: 3)
                
                Toggle(isOn: $isRepetitiveQuest) {
                    Text("Is this a repetitive quest?")
                        .font(.headline)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .shadow(radius: 3)
                
                // Hardness Input (Star Rating)
                VStack {
                    Text("Quest Hardness")
                        .font(.headline)
                    
                    StarRatingView(rating: $questHardness)
                }
                .padding()
                
                Button(action: {
                    print("Quest saved: \(questTitle), Hardness: \(questHardness), Repetitive: \(isRepetitiveQuest)")
                }) {
                    Text("Save Quest")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(8)
                        .shadow(radius: 3)
                }
                .padding(.top, 20)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Create New Quest")
        }
    }
}

struct StarRatingView: View {
    @Binding var rating: Int
    
    var maxRating = 5
    var offImage: Image?
    var onImage = Image(systemName: "star.fill")
    
    var offColor = Color.gray
    var onColor = Color.yellow
    
    var body: some View {
        HStack {
            ForEach(1..<maxRating + 1, id: \.self) { number in
                image(for: number)
                    .foregroundColor(number > rating ? offColor : onColor)
                    .onTapGesture {
                        rating = number
                    }
            }
        }
        .font(.largeTitle)
    }
    
    func image(for number: Int) -> Image {
        if number > rating {
            return offImage ?? onImage
        } else {
            return onImage
        }
    }
}

#Preview {
    QuestCreationView()
}
