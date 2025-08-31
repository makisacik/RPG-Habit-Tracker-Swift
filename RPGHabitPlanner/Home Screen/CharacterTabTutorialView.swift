//
//  CharacterTabTutorialView.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 6.08.2025.
//

import SwiftUI

struct CharacterTabTutorialView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var localizationManager: LocalizationManager
    @Binding var isPresented: Bool
    
    @State private var currentPage = 0
    @State private var viewAppeared = false
    
    private let totalPages = 5
    
    var body: some View {
        let theme = themeManager.activeTheme
        
        // Full screen overlay to capture taps outside
        Color.clear
            .contentShape(Rectangle())
            .onTapGesture {
                // Dismiss when tapping outside
                dismissTutorial()
            }
            .overlay(
                // Tutorial content positioned in center
                VStack(spacing: 0) {
                    // Progress indicator
                    HStack(spacing: 8) {
                        ForEach(0..<totalPages, id: \.self) { index in
                            Circle()
                                .fill(index <= currentPage ? theme.accentColor : theme.textColor.opacity(0.3))
                                .frame(width: 8, height: 8)
                                .scaleEffect(index == currentPage ? 1.2 : 1.0)
                                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentPage)
                        }
                    }
                    .padding(.top, 24)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 16)

                    // Content area
                    TabView(selection: $currentPage) {
                        // Page 1: Welcome to Your Character
                        CharacterTutorialPageView(
                            title: "character_tutorial_welcome_title".localized,
                            subtitle: "character_tutorial_welcome_subtitle".localized,
                            imageName: "person.crop.circle.fill",
                            isSystemImage: true,
                            theme: theme
                        )
                        .tag(0)

                        // Page 2: Health and Damage System
                        CharacterTutorialPageView(
                            title: "character_tutorial_health_title".localized,
                            subtitle: "character_tutorial_health_subtitle".localized,
                            imageName: "heart.fill",
                            isSystemImage: true,
                            theme: theme
                        )
                        .tag(1)

                        // Page 3: Damage Types and Consequences
                        CharacterTutorialPageView(
                            title: "character_tutorial_damage_title".localized,
                            subtitle: "character_tutorial_damage_subtitle".localized,
                            imageName: "exclamationmark.triangle.fill",
                            isSystemImage: true,
                            theme: theme
                        )
                        .tag(2)

                        // Page 4: Protection and Recovery
                        CharacterTutorialPageView(
                            title: "character_tutorial_protection_title".localized,
                            subtitle: "character_tutorial_protection_subtitle".localized,
                            imageName: "shield.fill",
                            isSystemImage: true,
                            theme: theme
                        )
                        .tag(3)
                        
                        // Page 5: Critical Health Warning
                        CharacterTutorialPageView(
                            title: "character_tutorial_critical_title".localized,
                            subtitle: "character_tutorial_critical_subtitle".localized,
                            imageName: "exclamationmark.octagon.fill",
                            isSystemImage: true,
                            theme: theme
                        )
                        .tag(4)
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    .animation(.easeInOut(duration: 0.3), value: currentPage)
                    .frame(height: 480)

                    // Navigation buttons
                    HStack {
                        // Skip button
                        Button(action: {
                            dismissTutorial()
                        }) {
                            Text("character_tutorial_skip".localized)
                                .font(.appFont(size: 16, weight: .medium))
                                .foregroundColor(theme.textColor.opacity(0.7))
                        }

                        Spacer()

                        // Next/Get Started button
                        Button(action: {
                            if currentPage < totalPages - 1 {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    currentPage += 1
                                }
                            } else {
                                dismissTutorial()
                            }
                        }) {
                            Text(currentPage < totalPages - 1 ? "character_tutorial_next".localized : "character_tutorial_begin_adventure".localized)
                                .font(.appFont(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 12)
                                .background(theme.accentColor)
                                .cornerRadius(25)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)
                }
                .background(theme.backgroundColor)
                .cornerRadius(20)
                .shadow(color: Color.black.opacity(0.15), radius: 20, x: 0, y: 10)
                .frame(width: 380, height: 580)
                .scaleEffect(viewAppeared ? 1.0 : 0.8)
                .opacity(viewAppeared ? 1.0 : 0.0)
                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: viewAppeared)
            )
            .onAppear {
                withAnimation(.easeInOut(duration: 0.3)) {
                    viewAppeared = true
                }
            }
    }
    
    private func dismissTutorial() {
        withAnimation(.easeInOut(duration: 0.3)) {
            viewAppeared = false
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.easeInOut(duration: 0.2)) {
                isPresented = false
            }
        }
    }
}

struct CharacterTutorialPageView: View {
    let title: String
    let subtitle: String
    let imageName: String
    let isSystemImage: Bool
    let theme: Theme
    
    var body: some View {
        VStack(spacing: 32) {
            // Image in card container with border
            VStack(spacing: 0) {
                if isSystemImage {
                    Image(systemName: imageName)
                        .font(.system(size: 120))
                        .foregroundColor(theme.accentColor)
                        .frame(width: 240, height: 240)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(theme.cardBackgroundColor)
                        )
                } else {
                    Image(imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 240, height: 240)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(theme.cardBackgroundColor)
                    .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 3)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(theme.accentColor.opacity(0.3), lineWidth: 1)
            )
            
            // Text content
            VStack(spacing: 12) {
                Text(title)
                    .font(.appFont(size: 24, weight: .bold))
                    .foregroundColor(theme.textColor)
                    .multilineTextAlignment(.center)
                
                if !subtitle.isEmpty {
                    Text(parseBoldText(subtitle))
                        .font(.appFont(size: 16, weight: .regular))
                        .foregroundColor(theme.textColor)
                        .multilineTextAlignment(.center)
                        .lineLimit(6)
                }
            }
            .padding(.horizontal, 20)
            
            Spacer()
        }
    }
    
    private func parseBoldText(_ text: String) -> AttributedString {
        var attributedString = AttributedString(text)
        
        // Find and apply bold formatting to text between ** markers
        let pattern = "\\*\\*(.*?)\\*\\*"
        let regex = try? NSRegularExpression(pattern: pattern, options: [])
        
        if let regex = regex {
            let nsString = text as NSString
            let matches = regex.matches(in: text, options: [], range: NSRange(location: 0, length: nsString.length))
            
            for match in matches.reversed() {
                if let range = Range(match.range, in: text) {
                    let boldRange = Range(match.range(at: 1), in: text)!
                    let boldText = String(text[boldRange])
                    
                    // Convert String range to AttributedString range
                    if let attributedRange = attributedString.range(of: String(text[range])) {
                        // Replace the **text** with just the text
                        attributedString.replaceSubrange(attributedRange, with: AttributedString(boldText))
                        
                        // Apply bold formatting to the replaced text
                        if let newRange = attributedString.range(of: boldText) {
                            attributedString[newRange].font = .appFont(size: 16, weight: .bold)
                        }
                    }
                }
            }
        }
        
        return attributedString
    }
}

#Preview {
    CharacterTabTutorialView(isPresented: .constant(true))
        .environmentObject(ThemeManager.shared)
        .environmentObject(LocalizationManager.shared)
}
