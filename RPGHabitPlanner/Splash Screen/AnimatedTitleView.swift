//
//  AnimatedTitleView.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 26.10.2024.
//

import SwiftUI

struct AnimatedTitleView: View {
    let title: String
    let color: Color
    let initialDelay: Double
    let animationType: Animation

    @State var scale = false
    @State private var show = false
    private var delayStep = 0.1

    init(title: String, color: Color, initialDelay: Double, animationType: Animation) {
        self.title = title
        self.color = color
        self.initialDelay = initialDelay
        self.animationType = animationType
    }

    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<title.count, id: \.self) { index in
                Text(String(title[title.index(title.startIndex, offsetBy: index)]))
                    .font(.system(size: 50))
                    .bold()
                    .opacity(show ? 1 : 0)
                    .offset(y: show ? -30 : 30)
                    .animation(animationType.delay(Double(index) * delayStep + initialDelay), value: show)
                    .foregroundStyle(color)
            }
        }
        .scaleEffect(scale ? 1 : 1.2)
        .onAppear {
            show.toggle()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                withAnimation {
                    scale.toggle()
                }
            }
        }
    }
}
