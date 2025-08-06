//
//  CharacterDetailsView.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 17.11.2024.
//

import SwiftUI

struct CharacterDetailsView: View {
    @EnvironmentObject var themeManager: ThemeManager
    let user: UserEntity
    
    var body: some View {
        let theme = themeManager.activeTheme
        
        ZStack {
            theme.backgroundColor
                .ignoresSafeArea()
            
            VStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(theme.primaryColor)
                        .shadow(color: .black.opacity(0.3), radius: 6, x: 0, y: 3)
                    
                    VStack(spacing: 20) {
                        HStack(spacing: 16) {
                            if let characterClass = CharacterClass(rawValue: user.characterClass ?? "knight") {
                                Image(characterClass.iconName)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 80, height: 80)
                                    .padding(.leading, 10)
                            }
                            
                            VStack(alignment: .leading, spacing: 6) {
                                Text(user.nickname ?? "Unknown")
                                    .font(.appFont(size: 20, weight: .black))
                                    .foregroundColor(theme.textColor)
                                
                                if let characterClass = CharacterClass(rawValue: user.characterClass ?? "") {
                                    Text(characterClass.displayName)
                                        .font(.appFont(size: 16, weight: .regular))
                                        .foregroundColor(theme.textColor)
                                }
                            }
                            Spacer()
                        }
                        
                        VStack(spacing: 8) {
                            HStack {
                                Image("minimap_icon_star_yellow")
                                    .resizable()
                                    .frame(width: 16, height: 16)
                                Text("Level \(user.level)")
                                    .font(.appFont(size: 16))
                                Spacer()
                                Text("EXP: \(user.exp)/100")
                                    .font(.appFont(size: 14))
                                    .foregroundColor(theme.textColor)
                            }
                            
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(theme.backgroundColor)
                                    .shadow(color: .black.opacity(0.15), radius: 2, x: 0, y: 1)
                                    .frame(height: 20)

                                GeometryReader { geometry in
                                    let expRatio = min(CGFloat(user.exp) / 100.0, 1.0)
                                    if expRatio > 0 {
                                        RoundedRectangle(cornerRadius: 6)
                                            .fill(
                                                LinearGradient(
                                                    gradient: Gradient(colors: [
                                                        Color.green.opacity(0.9),
                                                        Color.green.opacity(0.7),
                                                        Color.green.opacity(0.9)
                                                    ]),
                                                    startPoint: .leading,
                                                    endPoint: .trailing
                                                )
                                            )
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 6)
                                                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                            )
                                            .frame(width: geometry.size.width * expRatio, height: 20)
                                            .animation(.easeOut(duration: 0.3), value: expRatio)
                                    }
                                }
                                .frame(height: 20)

                                HStack {
                                    Spacer()
                                    Text("\(user.exp) / 100")
                                        .font(.appFont(size: 12, weight: .black))
                                        .foregroundColor(theme.textColor)
                                        .shadow(radius: 1)
                                    Spacer()
                                }
                            }
                            .frame(height: 20)
                            .padding(.bottom, 6)
                        }
                        
                        Divider()

                        if let weapon = Weapon(rawValue: user.weapon ?? "") {
                            HStack {
                                Text("Weapon:")
                                    .font(.appFont(size: 16, weight: .regular))
                                    .frame(width: 80, alignment: .leading)
                                HStack(spacing: 10) {
                                    Image(weapon.iconName)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 40, height: 40)
                                    
                                    Text(weapon.rawValue)
                                        .font(.appFont(size: 16))
                                }
                                Spacer()
                            }
                        }
                        
                        Divider()

                        HStack {
                            Text("Character ID:")
                                .font(.appFont(size: 14))
                                .foregroundColor(theme.textColor)
                                .frame(width: 100, alignment: .leading)
                            Text(user.id?.uuidString ?? "N/A")
                                .font(.appFont(size: 14))
                                .foregroundColor(theme.textColor)
                                .lineLimit(1)
                                .truncationMode(.middle)
                            Spacer()
                        }
                    }
                    .padding(20)
                }
                .padding()
            }
        }
        .presentationDetents([.fraction(0.45)])
        .navigationTitle("Character Details")
    }
}
