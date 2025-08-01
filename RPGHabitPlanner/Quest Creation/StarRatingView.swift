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
    let offImageName: String
    let starSize: CGFloat
    let spacing: CGFloat
    
    init(rating: Binding<Int>,
         maxRating: Int = 5,
         onImageName: String = "minimap_icon_star_yellow",
         offImageName: String = "minimap_icon_star_white",
         starSize: CGFloat = 24,
         spacing: CGFloat = 6) {
        self._rating = rating
        self.maxRating = maxRating
        self.onImageName = onImageName
        self.offImageName = offImageName
        self.starSize = starSize
        self.spacing = spacing
    }
    
    var body: some View {
        HStack(spacing: spacing) {
            ForEach(1...maxRating, id: \.self) { number in
                Image(number <= rating ? onImageName : offImageName)
                    .resizable()
                    .frame(width: starSize, height: starSize)
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
