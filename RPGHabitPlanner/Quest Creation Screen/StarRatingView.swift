//
//  StarRatingView.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 4.11.2024.
//

import SwiftUI

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
    StarRatingView(rating: .constant(3))
}
