//
//  CharacterCreationView.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 10.11.2024.
//

import SwiftUI

struct CharacterCreationView: View {
    @StateObject private var viewModel = CharacterCreationViewModel()
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Choose Your Class!")
                .font(.title2)
                .bold()
            
            // TabView for character classes
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
                        
                        HStack {
                            Text(viewModel.previousClassName(for: characterClass))
                                .font(.caption)
                                .foregroundColor(.gray)
                            Spacer()
                            Text(viewModel.nextClassName(for: characterClass))
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .padding(.horizontal)
                    }
                    .tag(characterClass)
                }
            }
            .tabViewStyle(PageTabViewStyle())
            .frame(height: 200)
            .onChange(of: viewModel.selectedClass) { newClass in
                viewModel.selectClass(newClass)
            }
            
                Text("Choose Your Starter Weapon!")
                    .font(.title2)
                    .bold()
                
                TabView(selection: $viewModel.selectedWeapon) {
                    ForEach(viewModel.availableWeapons, id: \.self) { weapon in
                        VStack {
                            if let image = UIImage(named: weapon) {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 150)
                                    .padding()
                            }
                            Text(weapon)
                                .font(.title3)
                                .bold()
                            
                            HStack {
                                Text(viewModel.previousWeaponName(for: weapon))
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                Spacer()
                                Text(viewModel.nextWeaponName(for: weapon))
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            .padding(.horizontal)
                        }
                        .tag(weapon)
                    }
                }
                .tabViewStyle(PageTabViewStyle())
                .frame(height: 200)
            
            
            Spacer()
            
            if viewModel.selectedClass != nil && viewModel.selectedWeapon != nil {
                Button(action: {
                    // Handle confirmation logic
                }) {
                    Text("Confirm Selection")
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
        }
        .padding()
    }
}

#Preview {
    CharacterCreationView()
}
