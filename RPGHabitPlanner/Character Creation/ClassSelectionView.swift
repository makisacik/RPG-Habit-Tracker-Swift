//
//  ClassSelectionView.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 04.08.2025.
//

import SwiftUI

struct ClassSelectionView: View {
    @ObservedObject var viewModel: CharacterCreationViewModel
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        let theme = themeManager.activeTheme
        ZStack {
            GeometryReader { _ in
                TabView(selection: $viewModel.selectedClass) {
                    ForEach(CharacterClass.allCases, id: \.self) { characterClass in
                        VStack {
                            if let image = UIImage(named: characterClass.iconName) {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 150)
                                    .padding()
                            }
                            Text(characterClass.rawValue)
                                .font(.appFont(size: 18, weight: .black))
                        }
                        .tag(characterClass)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(height: 230)
            }
            .gesture(
                DragGesture()
                    .onEnded { value in
                        viewModel.handleClassSwipe(value.translation)
                    }
            )

            HStack {
                if let previousClass = viewModel.previousClass,
                   let previousImage = UIImage(named: previousClass.iconName)?.withRenderingMode(.alwaysTemplate) {
                    Image(uiImage: previousImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .foregroundColor(theme.textColor)
                        .padding(.leading, 10)
                        .onTapGesture {
                            viewModel.selectPreviousClass()
                        }
                } else {
                    Color.clear.frame(width: 80, height: 80)
                }

                Spacer()

                if let nextClass = viewModel.nextClass,
                   let nextImage = UIImage(named: nextClass.iconName)?.withRenderingMode(.alwaysTemplate) {
                    Image(uiImage: nextImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .foregroundColor(theme.textColor)
                        .padding(.trailing, 10)
                        .onTapGesture {
                            viewModel.selectNextClass()
                        }
                } else {
                    Color.clear.frame(width: 80, height: 80)
                }
            }
            .frame(height: 200)
        }
    }
}
