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
            Text("Select Your Character Class")
                .font(.headline)
            
            ForEach(CharacterClass.allCases) { characterClass in
                Button(action: {
                    viewModel.selectClass(characterClass)
                }) {
                    HStack {
                        if let image = UIImage(named: characterClass.iconName) {
                            Image(uiImage: image)
                                .resizable()
                                .frame(width: 40, height: 40)
                        }
                        Text(characterClass.rawValue)
                            .padding()
                    }
                    .background(viewModel.selectedClass == characterClass ? Color.blue : Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
            }
            
            if let selectedClass = viewModel.selectedClass {
                Text("Select a Starter Weapon for \(selectedClass.rawValue)")
                    .font(.subheadline)
                
                ForEach(viewModel.availableWeapons, id: \.self) { weapon in
                    Button(action: {
                        viewModel.selectedWeapon = weapon
                    }) {
                        HStack {
                            if let image = UIImage(named: weapon) {
                                Image(uiImage: image)
                                    .resizable()
                                    .frame(width: 40, height: 40)
                            }
                            Text(weapon)
                                .padding()
                        }
                        .background(viewModel.selectedWeapon == weapon ? Color.blue : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                }
            }
            
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
