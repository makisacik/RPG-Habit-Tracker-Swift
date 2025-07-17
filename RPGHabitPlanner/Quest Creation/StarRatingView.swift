//
//  StarRatingView.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 4.11.2024.
//

import SwiftUI

struct StarRatingView: View {
    @Binding var rating: Int

    let maxRating = 5
    let onImageName = "minimap_icon_star_yellow"
    let offImageName = "minimap_icon_star_white"

    var body: some View {
        HStack(spacing: 6) {
            ForEach(1...maxRating, id: \.self) { number in
                Image(number <= rating ? onImageName : offImageName)
                    .resizable()
                    .frame(width: 24, height: 24)
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
