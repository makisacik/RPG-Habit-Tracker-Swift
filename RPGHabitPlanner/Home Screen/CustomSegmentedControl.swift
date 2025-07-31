//
//  CustomSegmentedControl.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 26.07.2025.
//

import SwiftUI

struct CustomSegmentedControl<T: Hashable>: View {
    @Binding var selected: T
    let options: [T]
    let titleForOption: (T) -> String
    let backgroundColor: Color
    let selectedColor: Color
    let textColor: Color
    let selectedTextColor: Color

    var body: some View {
        HStack(spacing: 5) {
            ForEach(options, id: \.self) { option in
                Text(titleForOption(option))
                    .font(.appFont(size: 14, weight: .black))
                    .foregroundColor(selected == option ? selectedTextColor : textColor)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(selected == option ? selectedColor : backgroundColor)
                    .cornerRadius(8)
                    .onTapGesture {
                        withAnimation {
                            selected = option
                        }
                    }
            }
        }
        .padding(4)
        .background(backgroundColor)
        .cornerRadius(10)
    }
}
