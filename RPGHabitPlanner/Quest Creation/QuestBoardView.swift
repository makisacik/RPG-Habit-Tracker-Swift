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
            // Animated background elements
            ForEach(0..<5) { index in
                Circle()
                    .fill(Color.yellow.opacity(0.1))
                    .frame(width: CGFloat.random(in: 20...60))
                    .position(
                        x: CGFloat.random(in: 50...350),
                        y: CGFloat.random(in: 100...700)
                    )
                    .scaleEffect(animate ? 1.2 : 0.8)
                    .animation(
                        .easeInOut(duration: Double.random(in: 2...4))
                        .repeatForever(autoreverses: true)
                        .delay(Double(index) * 0.5),
                        value: animate
                    )
            }
        }
    }
}
