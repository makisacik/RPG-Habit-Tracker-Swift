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
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                if let characterClass = CharacterClass(rawValue: user.characterClass ?? "knight") {
                    Image(characterClass.iconName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(user.nickname ?? "Unknown")
                        .font(.title)
                        .bold()

                    if let characterClass = CharacterClass(rawValue: user.characterClass ?? "") {
                        Text(characterClass.displayName)
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                }
                Spacer()
            }

            // Level and EXP
            HStack {
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                    Text("Level \(user.level)")
                        .font(.headline)
                }

                Spacer()

                Text("EXP: \(user.exp)")
                    .font(.headline)
                    .foregroundColor(.secondary)
            }

            Divider()

            if let weapon = Weapon(rawValue: user.weapon ?? "") {
                HStack {
                    Text("Weapon:")
                        .font(.headline)
                        .frame(width: 80, alignment: .leading)
                    HStack(spacing: 10) {
                        Image(weapon.iconName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)

                        Text(weapon.rawValue)
                            .font(.body)
                            .foregroundColor(.primary)
                    }
                    Spacer()
                }
            }

            Divider()

            HStack {
                Text("Character ID:")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(width: 100, alignment: .leading)
                Text(user.id?.uuidString ?? "N/A")
                    .font(.footnote)
                    .foregroundColor(.gray)
                    .lineLimit(1)
                    .truncationMode(.middle)
                Spacer()
            }
        }
        .padding(20)
        .presentationDetents([.fraction(0.4)])
        .navigationTitle("Character Details")
    }
}
