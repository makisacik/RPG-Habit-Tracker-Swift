//
//  SideBarView.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 11.11.2024.
//

import SwiftUI

struct BottomBarCharacterView: View {
    let user: UserEntity?
    
    var body: some View {
        HStack(spacing: 20) {
            if let user = user {
                if let characterClass = CharacterClass(rawValue: user.characterClass ?? "knight"),
                let classImage = UIImage(named: characterClass.iconName) {
                    Image(uiImage: classImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                        .padding()
                }
                
                if let weapon = Weapon(rawValue: user.weapon ?? "sword-broad"),
                let weaponImage = UIImage(named: weapon.iconName) {
                    Image(uiImage: weaponImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                        .padding()
                }
                
                VStack(alignment: .leading) {
                    Text(user.nickname ?? "Unknown")
                        .font(.headline)
                    
                    HStack {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                        Text("Level \(user.level)")
                            .font(.subheadline)
                    }
                }
                .padding(.leading, 10)
            } else {
                Text("No Character Data")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Spacer()
        }
        .padding(.horizontal, 20)
    }
}
