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
    @AppStorage("isCharacterCreated") private var isCharacterCreated: Bool = false
    @AppStorage("selectedCharacterClass") private var selectedCharacterClass: String = ""
    @AppStorage("selectedWeapon") private var selectedWeapon: String = ""
    
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
                                if value.translation.width < -100, let nextClass = viewModel.nextClass {
                                    withAnimation {
                                        viewModel.selectedClass = nextClass
                                    }
                                } else if value.translation.width > 100, let previousClass = viewModel.previousClass {
                                    withAnimation {
                                        viewModel.selectedClass = previousClass
                                    }
                                }
                            }
                    )
                }

                HStack {
                    if let previousClass = viewModel.previousClass {
                        Image(uiImage: UIImage(named: previousClass.iconName)?.withRenderingMode(.alwaysTemplate) ?? UIImage())
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .foregroundColor(.gray)
                            .padding(.leading, 10)
                            .onTapGesture {
                                withAnimation {
                                    viewModel.selectedClass = previousClass
                                }
                            }
                    } else {
                        Color.clear.frame(width: 80, height: 80)
                    }

                    Spacer()

                    if let nextClass = viewModel.nextClass {
                        Image(uiImage: UIImage(named: nextClass.iconName)?.withRenderingMode(.alwaysTemplate) ?? UIImage())
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .foregroundColor(.gray)
                            .padding(.trailing, 10)
                            .onTapGesture {
                                withAnimation {
                                    viewModel.selectedClass = nextClass
                                }
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
                                // Detect swipe direction for changing weapon
                                if value.translation.width < -100, let nextWeapon = viewModel.nextWeapon(for: viewModel.selectedWeapon) {
                                    withAnimation {
                                        viewModel.selectedWeapon = nextWeapon
                                    }
                                } else if value.translation.width > 100, let previousWeapon = viewModel.previousWeapon(for: viewModel.selectedWeapon) {
                                    withAnimation {
                                        viewModel.selectedWeapon = previousWeapon
                                    }
                                }
                            }
                    )
                }

                HStack {
                    if let previousWeapon = viewModel.previousWeapon(for: viewModel.selectedWeapon) {
                        Image(uiImage: UIImage(named: previousWeapon.iconName)?.withRenderingMode(.alwaysTemplate) ?? UIImage())
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .foregroundColor(.gray)
                            .padding(.leading, 10)
                            .onTapGesture {
                                withAnimation {
                                    viewModel.selectedWeapon = previousWeapon
                                }
                            }
                    } else {
                        Color.clear.frame(width: 80, height: 80)
                    }

                    Spacer()

                    if let nextWeapon = viewModel.nextWeapon(for: viewModel.selectedWeapon) {
                        Image(uiImage: UIImage(named: nextWeapon.iconName)?.withRenderingMode(.alwaysTemplate) ?? UIImage())
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .foregroundColor(.gray)
                            .padding(.trailing, 10)
                            .onTapGesture {
                                withAnimation {
                                    viewModel.selectedWeapon = nextWeapon
                                }
                            }
                    } else {
                        Color.clear.frame(width: 80, height: 80)
                    }
                }
                .frame(height: 230)
            }

            Button(action: {
                selectedCharacterClass = viewModel.selectedClass.rawValue
                selectedWeapon = viewModel.selectedWeapon.rawValue
                isCharacterCreated = true
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
