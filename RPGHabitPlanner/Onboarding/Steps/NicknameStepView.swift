//
//  NicknameStepView.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 7.01.2025.
//

import SwiftUI

struct NicknameStepView: View {
    @ObservedObject var coordinator: OnboardingCoordinator
    let theme: Theme
    @FocusState private var isTextFieldFocused: Bool

    // Character name generation
    let characterNames: [String] = [
        // Heroic
        "Arion", "Kaelith", "Seraphis", "Thalor", "Veyra", "Draven", "Calidora", "Orwyn", "Branthor", "Cedric",
        "Eldrin", "Galanor", "Korath", "Alaric", "Fenric", "Dorian", "Lucien", "Kaelor", "Thandor", "Vorian",

        // Mystical
        "Eloria", "Sylthas", "Zoranel", "Lythera", "Nivara", "Morwyn", "Ithildor", "Zephyra", "Valindor", "Orthelia",
        "Eryndor", "Faylen", "Thalindra", "Seloria", "Melivor", "Aetheris", "Kyrandel", "Elvoria", "Nolwyn", "Quivara",

        // Dark
        "Duskbane", "Shadowrend", "Malrik", "Vorneth", "Ashborn", "Skalara", "Noctira", "Grimveil", "Zalthor", "Draemir",
        "Oblivara", "Ravengar", "Tharnok", "Morgrath", "Blackthorn", "Gorthak", "Venmar", "Xaldrith", "Omenis", "Kryvak",

        // Nature
        "Oakhelm", "Riveran", "Thornwyn", "Elaris", "Mossath", "Sunara", "Briarthorn", "Lunara", "Silverleaf", "Fernalis",
        "Rowanth", "Willowis", "Thalflora", "Starbloom", "Elenwyn", "Mistara", "Petalyn", "Greenveil", "Solenya", "Bramblethorn",

        // Noble
        "Aurelius", "Isolde", "Caelwyn", "Theodric", "Lysandra", "Valeria", "Octavian", "Seraphiel", "Marcellus", "Evelora",
        "Gaius", "Annelise", "Bellador", "Cassian", "Heliora", "Leontius", "Rosalith", "Aurion", "Dracella", "Ventorius",

        // Quirky
        "Sir Pickles", "Muffinbane", "Glitterfist", "Bongo the Brave", "Tofu Slayer", "Waffleheart", "Captain Snail", "Bananafang",
        "Lord Noodle", "Princess Pancake", "Burrito Knight", "Lady Cupcake", "Toastcrusher", "Sir Wobbles", "Baron Donut",
        "Count Sockula", "Jellybean the Bold", "Pineapple Wizard", "Ducklord Quackius", "Potatoeater",

        // Short
        "Zyra", "Kael", "Vorn", "Nyx", "Lira", "Thar", "Vex", "Kiro", "Ryn", "Oza",
        "Xel", "Zyn", "Krel", "Mora", "Dax", "Tyra", "Vel", "Zor", "Quin", "Jax"
    ]

    func randomName() -> String {
        characterNames.randomElement() ?? String(localized: "hero")
    }

    var body: some View {
        VStack(spacing: 40) {
            Spacer()

            // Header
            VStack(spacing: 16) {
                Text(String(localized: "name_your_hero"))
                    .font(.appFont(size: 24, weight: .black))
                    .foregroundColor(theme.textColor)
                    .multilineTextAlignment(.center)

                Text(String(localized: "choose_legendary_name_for_character"))
                    .font(.appFont(size: 16))
                    .foregroundColor(theme.textColor.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }

            // Name input
            VStack(spacing: 12) {
                TextField(String(localized: "enter_hero_name"), text: $coordinator.nickname)
                    .font(.appFont(size: 18, weight: .medium))
                    .foregroundColor(theme.textColor)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(theme.cardBackgroundColor)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(theme.primaryColor.opacity(0.3), lineWidth: 1)
                            )
                    )
                    .textFieldStyle(PlainTextFieldStyle())
                    .focused($isTextFieldFocused)
                    .onChange(of: coordinator.nickname) { newValue in
                        // Limit to 20 characters
                        if newValue.count > 20 {
                            coordinator.nickname = String(newValue.prefix(20))
                        }
                    }
                    .submitLabel(.done)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.words)

                // Random name button
                Button(action: {
                    coordinator.nickname = randomName()
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "dice.fill")
                            .font(.system(size: 16))
                        Text(String(localized: "random_name"))
                            .font(.appFont(size: 16, weight: .medium))
                    }
                    .foregroundColor(theme.accentColor)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(theme.accentColor.opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(theme.accentColor.opacity(0.3), lineWidth: 1)
                            )
                    )
                }

                Text(String(localized: "maximum_20_characters"))
                    .font(.appFont(size: 12))
                    .foregroundColor(theme.textColor.opacity(0.6))
            }
            .padding(.horizontal, 20)

            Spacer()
        }
        .padding(.horizontal, 20)
        .onAppear {
            // Listen for focus notification from coordinator
            NotificationCenter.default.addObserver(
                forName: NSNotification.Name("FocusNicknameTextField"),
                object: nil,
                queue: .main
            ) { _ in
                isTextFieldFocused = true
            }
        }
        .onDisappear {
            // Remove observer when view disappears
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name("FocusNicknameTextField"), object: nil)
        }
    }
}
