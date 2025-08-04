//
//  WeaponSelectionView.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 04.08.2025.
//

import SwiftUI

struct WeaponSelectionView: View {
    @ObservedObject var viewModel: CharacterCreationViewModel

    var body: some View {
        ZStack {
            GeometryReader { _ in
                TabView(selection: $viewModel.selectedWeapon) {
                    ForEach(viewModel.availableWeapons, id: \.self) { weapon in
                        VStack {
                            if let image = UIImage(named: weapon.iconName) {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 150)
                                    .padding()
                            }
                            Text(weapon.rawValue)
                                .font(.appFont(size: 18))
                        }
                        .tag(weapon)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(height: 230)
            }
            .gesture(
                DragGesture()
                    .onEnded { value in
                        viewModel.handleWeaponSwipe(value.translation)
                    }
            )

            HStack {
                if let previous = viewModel.previousWeapon(for: viewModel.selectedWeapon),
                   let previousImage = UIImage(named: previous.iconName)?.withRenderingMode(.alwaysTemplate) {
                    Image(uiImage: previousImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .foregroundColor(.gray)
                        .padding(.leading, 10)
                        .onTapGesture {
                            viewModel.selectPreviousWeapon()
                        }
                } else {
                    Color.clear.frame(width: 80, height: 80)
                }

                Spacer()

                if let next = viewModel.nextWeapon(for: viewModel.selectedWeapon),
                   let nextImage = UIImage(named: next.iconName)?.withRenderingMode(.alwaysTemplate) {
                    Image(uiImage: nextImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .foregroundColor(.gray)
                        .padding(.trailing, 10)
                        .onTapGesture {
                            viewModel.selectNextWeapon()
                        }
                } else {
                    Color.clear.frame(width: 80, height: 80)
                }
            }
            .frame(height: 230)
        }
    }
}
