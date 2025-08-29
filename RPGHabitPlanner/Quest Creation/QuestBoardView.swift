import SwiftUI

struct QuestBoardView: View {
    @EnvironmentObject var themeManager: ThemeManager
    let onStartQuest: () -> Void
    let animate: Bool
    @State private var isButtonPressed = false

    var body: some View {
        let theme = themeManager.activeTheme
        VStack(spacing: 30) {
            Spacer()

            // Quest Board Title
            VStack(spacing: 8) {
                Image(systemName: "scroll.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.yellow)
                    .rotationEffect(.degrees(animate ? 5 : -5))
                    .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: animate)

                Text("quest_board".localized)
                    .font(.appFont(size: 28, weight: .black))
                    .foregroundColor(theme.textColor)
                    .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 2)

                Text("adventure_awaits_brave_one".localized)
                    .font(.appFont(size: 16))
                    .foregroundColor(theme.textColor.opacity(0.8))
                    .multilineTextAlignment(.center)
            }

            Spacer()

            // Start Quest Button
            Button(action: {
                isButtonPressed = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    isButtonPressed = false
                    onStartQuest()
                }
            }) {
                HStack(spacing: 12) {
                    Image("icon_sword")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                    Text("accept_new_quest".localized)
                        .font(.appFont(size: 18, weight: .black))
                }
                .foregroundColor(.white)
                .padding(.vertical, 16)
                .padding(.horizontal, 32)
                .background(
                    Image(theme.buttonPrimary)
                        .resizable(
                            capInsets: EdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20),
                            resizingMode: .stretch
                        )
                        .opacity(isButtonPressed ? 0.7 : 1.0)
                )
                .scaleEffect(isButtonPressed ? 0.95 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isButtonPressed)
            }
            .buttonStyle(PlainButtonStyle())

            Spacer()
        }
        .padding()
    }
}

struct QuestBoardBackground: View {
    let animate: Bool

    var body: some View {
        ZStack {
            // Simple animated background elements with fixed positions
            Circle()
                .fill(Color.yellow.opacity(0.1))
                .frame(width: 40, height: 40)
                .position(x: 80, y: 150)
                .scaleEffect(animate ? 1.1 : 0.9)
                .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: animate)

            Circle()
                .fill(Color.yellow.opacity(0.1))
                .frame(width: 60, height: 60)
                .position(x: 300, y: 300)
                .scaleEffect(animate ? 0.9 : 1.1)
                .animation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true), value: animate)

            Circle()
                .fill(Color.yellow.opacity(0.1))
                .frame(width: 30, height: 30)
                .position(x: 250, y: 500)
                .scaleEffect(animate ? 1.2 : 0.8)
                .animation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true), value: animate)
        }
    }
}
