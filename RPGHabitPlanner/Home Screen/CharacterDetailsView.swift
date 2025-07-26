//
//  CharacterDetailsView.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 17.11.2024.
//

import SwiftUI

struct CharacterDetailsView: View {
    let user: UserEntity

    var body: some View {
        ZStack {
            Image("pattern_grid_paper")
                .resizable(resizingMode: .tile)
                .ignoresSafeArea()

            VStack {
                Image("panel_brown_corners_b")
                    .resizable(capInsets: EdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20), resizingMode: .stretch)
                    .overlay(
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
                                        .foregroundColor(.black)

                                    if let characterClass = CharacterClass(rawValue: user.characterClass ?? "") {
                                        Text(characterClass.displayName)
                                            .font(.appFont(size: 16, weight: .regular))
                                            .foregroundColor(.gray)
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
                                        .foregroundColor(.gray)
                                }

                                ZStack(alignment: .leading) {
                                    Image("progress_transparent")
                                        .resizable(capInsets: EdgeInsets(top: 10, leading: 18, bottom: 10, trailing: 20), resizingMode: .stretch)
                                        .frame(height: 20)

                                    GeometryReader { geometry in
                                        let expRatio = min(CGFloat(user.exp) / 100.0, 1.0)
                                        if expRatio > 0 {
                                            Image("progress_green")
                                                .resizable(capInsets: EdgeInsets(top: 10, leading: 18, bottom: 10, trailing: 20), resizingMode: .stretch)
                                                .frame(width: geometry.size.width * expRatio, height: 20)
                                        }
                                    }
                                    .frame(height: 20)
                                    .clipped()
                                }
                                .frame(height: 20)
                            }


                            Divider()

                            // Weapon display
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

                            // Character ID
                            HStack {
                                Text("Character ID:")
                                    .font(.appFont(size: 14))
                                    .foregroundColor(.gray)
                                    .frame(width: 100, alignment: .leading)
                                Text(user.id?.uuidString ?? "N/A")
                                    .font(.appFont(size: 14))
                                    .foregroundColor(.gray)
                                    .lineLimit(1)
                                    .truncationMode(.middle)
                                Spacer()
                            }
                        }
                        .padding(20)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .strokeBorder(ImagePaint(image: Image("panel_border_grey"), scale: 1.0), lineWidth: 6)
                    )
                    .padding()
            }
        }
        .presentationDetents([.fraction(0.45)])
        .navigationTitle("Character Details")
    }
}
