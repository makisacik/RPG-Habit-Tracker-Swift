//
//  StarRatingView.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 4.11.2024.
//

import SwiftUI

struct StarRatingView: View {
    @Binding var rating: Int
    
    let maxRating: Int
    let onImageName: String
    let starSize: CGFloat
    let spacing: CGFloat
    
    init(rating: Binding<Int>,
         maxRating: Int = 5,
         onImageName: String = "icon_star_fill",
         starSize: CGFloat = 24,
         spacing: CGFloat = 6) {
        self._rating = rating
        self.maxRating = maxRating
        self.onImageName = onImageName
        self.starSize = starSize
        self.spacing = spacing
    }
    
    var body: some View {
        HStack(spacing: spacing) {
            ForEach(1...maxRating, id: \.self) { number in
                Image(onImageName)
                    .resizable()
                    .frame(width: starSize, height: starSize)
                    .opacity(number <= rating ? 1.0 : 0.3) // dim if not selected
                    .onTapGesture {
                        rating = number
                    }
            }
        }
    }
}

#Preview {
    StarRatingView(rating: .constant(3))
}
