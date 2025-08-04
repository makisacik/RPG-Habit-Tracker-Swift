//
//  CharacterCreationView.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 10.11.2024.
//

import SwiftUI

struct CharacterCreationView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @ObservedObject var viewModel: CharacterCreationViewModel
    @Binding var isCharacterCreated: Bool
    @State private var showNicknamePopup = false
    @State private var tempNickname = ""

    var body: some View {
        let theme = themeManager.activeTheme
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(theme.backgroundColor)

            ScrollView {
                VStack(spacing: 24) {
                    Image("banner_hanging")
                        .resizable()
                        .frame(height: 60)
                        .overlay(
                            Text("Create Your Character")
                                .font(.appFont(size: 18, weight: .black))
                                .foregroundColor(theme.textColor)
                                .padding(.top, 10)
                        )

                    VStack(spacing: 8) {
                        Text("Choose Your Class!")
                            .font(.appFont(size: 18))

                        ClassSelectionView(viewModel: viewModel)
                    }

                    Button(action: {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                            showNicknamePopup = true
                        }
                    }) {
                        Text("Confirm Selection")
                            .font(.appFont(size: 18))
                            .foregroundColor(theme.textColor)
                            .padding(.horizontal)
                            .frame(height: 44)
                            .background(
                                Image(theme.buttonPrimary)
                                    .resizable(
                                        capInsets: EdgeInsets(
                                            top: 20,
                                            leading: 20,
                                            bottom: 20,
                                            trailing: 20
                                        ),
                                        resizingMode: .stretch
                                    )
                            )
                            .padding(.bottom)
                            .cornerRadius(8)
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(theme.primaryColor)
                )
                .cornerRadius(20)
                .padding()
            }
            .onChange(of: viewModel.isCharacterCreated) { newValue in
                isCharacterCreated = newValue
            }

            if showNicknamePopup {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .zIndex(0.9)
                    .onTapGesture {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                            showNicknamePopup = false
                        }
                    }

                ZStack {
                    NicknamePopupView(
                        nickname: $tempNickname,
                        onConfirm: {
                            viewModel.nickname = tempNickname
                            viewModel.confirmSelection()
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                showNicknamePopup = false
                            }
                        },
                        onCancel: {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                showNicknamePopup = false
                            }
                        }
                    )
                    .environmentObject(themeManager)
                }
                .transition(.scale(scale: 0.8).combined(with: .opacity))
                .zIndex(1)
            }
        }
    }
}
