//
//  CharacterCreationView.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 10.11.2024.
//

import SwiftUI

struct CharacterCreationView: View {
    @ObservedObject var viewModel: CharacterCreationViewModel
    @Binding var isCharacterCreated: Bool

    var body: some View {
        ZStack {
            Image("pattern_grid_paper")
                .resizable(resizingMode: .tile)
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    Image("banner_hanging")
                        .resizable()
                        .frame(height: 60)
                        .overlay(
                            Text("Create Your Character")
                                .font(.appFont(size: 18, weight: .black))
                                .foregroundColor(.black)
                                .padding(.top, 10)
                        )

                    VStack(spacing: 16) {
                        Text("Enter Your Nickname")
                            .font(.appFont(size: 18))

                        TextField("Nickname", text: $viewModel.nickname)
                            .font(.appFont(size: 18))
                            .padding()
                            .background(
                                Image("panel_brown_dark")
                                    .resizable(capInsets: EdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20), resizingMode: .stretch)
                            )
                            .cornerRadius(8)
                            .padding(.horizontal)
                    }

                    VStack(spacing: 8) {
                        Text("Choose Your Class!")
                            .font(.appFont(size: 18))

                        classSelectionView
                    }

                    VStack(spacing: 8) {
                        Text("Choose Your Starter Weapon!")
                            .font(.appFont(size: 18))

                        weaponSelectionView
                    }

                    Button(action: {
                        viewModel.confirmSelection()
                    }) {
                        Text("Confirm Selection")
                            .font(.appFont(size: 18))
                            .foregroundColor(.brown)
                            .padding(.horizontal)
                            .frame(height: 44)
                            .background(
                                Image("button_brown")
                                    .resizable()
                                    .frame(height: 44)
                            )
                            .padding(.bottom)
                            .cornerRadius(8)
                    }
                }
                .padding()
                .background(
                    Image("panel_brown")
                        .resizable(capInsets: EdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20), resizingMode: .stretch)
                )
                .cornerRadius(20)
                .padding()
            }
            .onChange(of: viewModel.isCharacterCreated) { newValue in
                isCharacterCreated = newValue
            }
        }
    }

    private var classSelectionView: some View {
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
                        .foregroundColor(.gray)
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
                        .foregroundColor(.gray)
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

    private var weaponSelectionView: some View {
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
