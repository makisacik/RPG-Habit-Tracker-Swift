//
//  RewardView.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 5.08.2025.
//

import SwiftUI

struct RewardView: View {
    @Binding var isVisible: Bool
    @State private var chestOpened = false
    @State private var rewardGiven = false

    var body: some View {
        if isVisible {
            ZStack {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture { isVisible = false }

                VStack {
                    Image(chestOpened ? "icon_chest_open" : "icon_chest")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                chestOpened = true
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                rewardGiven = true
                            }
                        }

                    if rewardGiven {
                        Image("icon_armor")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .transition(.scale.combined(with: .opacity))
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white)
                        .shadow(radius: 8)
                )
            }
            .animation(.easeInOut, value: rewardGiven)
        }
    }
}
