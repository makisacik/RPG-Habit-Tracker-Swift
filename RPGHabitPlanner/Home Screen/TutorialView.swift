import SwiftUI

struct TutorialView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var localizationManager: LocalizationManager
    @Binding var isPresented: Bool
    
    @State private var currentPage = 0
    @State private var viewAppeared = false
    
    private let totalPages = 5
    
    var body: some View {
        let theme = themeManager.activeTheme
        
        ZStack {
            // Background with fade animation
            Color.black.opacity(viewAppeared ? 0.4 : 0)
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 0.5), value: viewAppeared)
            
            // Main content with scale and opacity animation
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
                .padding(.top, 20)
                .padding(.horizontal, 20)
                
                // Content area
                TabView(selection: $currentPage) {
                    // Page 1: Welcome
                    TutorialPageView(
                        title: "tutorial_welcome_title".localized,
                        subtitle: "tutorial_welcome_subtitle".localized,
                        imageName: "scroll.fill",
                        isSystemImage: true,
                        theme: theme
                    )
                    .tag(0)
                    
                    // Page 2: Create Quests
                    TutorialPageView(
                        title: "tutorial_create_quests_title".localized,
                        subtitle: "",
                        imageName: "tutorial_quest",
                        isSystemImage: false,
                        theme: theme
                    )
                    .tag(1)
                    
                    // Page 3: Complete & Earn Rewards
                    TutorialPageView(
                        title: "tutorial_complete_rewards_title".localized,
                        subtitle: "tutorial_complete_rewards_subtitle".localized,
                        imageName: "tutorial_reward",
                        isSystemImage: false,
                        theme: theme
                    )
                    .tag(2)
                    
                    // Page 4: Grow Your Character
                    TutorialPageView(
                        title: "tutorial_grow_character_title".localized,
                        subtitle: "tutorial_grow_character_subtitle".localized,
                        imageName: "tutorial_shop",
                        isSystemImage: false,
                        theme: theme
                    )
                    .tag(3)
                    
                    // Page 5: Gear & Legend
                    TutorialPageView(
                        title: "tutorial_gear_legend_title".localized,
                        subtitle: "tutorial_gear_legend_subtitle".localized,
                        imageName: "tutorial_gear",
                        isSystemImage: false,
                        theme: theme
                    )
                    .tag(4)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.3), value: currentPage)
                
                // Navigation buttons
                HStack {
                    // Skip button
                    Button(action: {
                        dismissTutorial()
                    }) {
                        Text("tutorial_skip".localized)
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
                        Text(currentPage < totalPages - 1 ? "tutorial_next".localized : "tutorial_get_started".localized)
                            .font(.appFont(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(theme.accentColor)
                            .cornerRadius(25)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(theme.backgroundColor)
                    .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 10)
            )
            .padding(.horizontal, 20)
            .padding(.top, 40)
            .padding(.bottom, 40)
            .scaleEffect(viewAppeared ? 1.0 : 0.8)
            .opacity(viewAppeared ? 1.0 : 0.0)
            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: viewAppeared)
        }
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

struct TutorialPageView: View {
    let title: String
    let subtitle: String
    let imageName: String
    let isSystemImage: Bool
    let theme: Theme
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Image in card container with border
            VStack(spacing: 0) {
                if isSystemImage {
                    Image(systemName: imageName)
                        .font(.system(size: 120))
                        .foregroundColor(theme.accentColor)
                        .frame(width: 280, height: 280)
                        .background(
                            RoundedRectangle(cornerRadius: 24)
                                .fill(theme.cardBackgroundColor)
                        )
                } else {
                    Image(imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 280, height: 280)
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(theme.cardBackgroundColor)
                    .shadow(color: Color.black.opacity(0.05), radius: 12, x: 0, y: 4)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(theme.accentColor.opacity(0.3), lineWidth: 2)
            )
            .padding(.horizontal, 16)
            
            // Text content outside the card
            VStack(spacing: 16) {
                Text(title)
                    .font(.appFont(size: 24, weight: .black))
                    .foregroundColor(theme.textColor)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 16)
                
                if !subtitle.isEmpty {
                    Text(subtitle)
                        .font(.appFont(size: 16))
                        .foregroundColor(theme.textColor.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal, 16)
                }
            }
            
            Spacer()
        }
    }
}

#Preview {
    TutorialView(isPresented: .constant(true))
        .environmentObject(ThemeManager.shared)
        .environmentObject(LocalizationManager.shared)
}
