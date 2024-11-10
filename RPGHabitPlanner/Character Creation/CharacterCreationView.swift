//
//  CharacterCreationView.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 10.11.2024.
//

import SwiftUI

struct CharacterCreationView: View {
    @StateObject private var viewModel = CharacterCreationViewModel()
    @GestureState private var dragOffset: CGSize = .zero
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Choose Your Class!")
                .font(.title2)
                .bold()

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
                                    .font(.title3)
                                    .bold()
                            }
                            .tag(characterClass)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .frame(height: 230)
                    .gesture(
                        DragGesture()
                            .onEnded { value in
                                viewModel.handleClassSwipe(value.translation)
                            }
                    )
                }

                HStack {
                    if let previousClass = viewModel.previousClass,
                    let previousClassImage = UIImage(named: previousClass.iconName)?.withRenderingMode(.alwaysTemplate) {
                        Image(uiImage: previousClassImage)
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
                    let nextClassImage = UIImage(named: nextClass.iconName)?.withRenderingMode(.alwaysTemplate) {
                        Image(uiImage: nextClassImage)
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

            Text("Choose Your Starter Weapon!")
                .font(.title2)
                .bold()

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
                                    .font(.title3)
                                    .bold()
                            }
                            .tag(weapon)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .frame(height: 230)
                    .gesture(
                        DragGesture()
                            .onEnded { value in
                                viewModel.handleWeaponSwipe(value.translation)
                            }
                    )
                }

                HStack {
                    if let previousWeapon = viewModel.previousWeapon(for: viewModel.selectedWeapon),
                    let previousWeaponImage = UIImage(named: previousWeapon.iconName)?.withRenderingMode(.alwaysTemplate) {
                        Image(uiImage: previousWeaponImage)
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

                    if let nextWeapon = viewModel.nextWeapon(for: viewModel.selectedWeapon),
                    let nextWeaponImage = UIImage(named: nextWeapon.iconName)?.withRenderingMode(.alwaysTemplate) {
                        Image(uiImage: nextWeaponImage)
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

            Button(action: {
                viewModel.confirmSelection()
            }) {
                Text("Confirm Selection")
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
        .padding()
    }
}


#Preview {
    CharacterCreationView()
}
