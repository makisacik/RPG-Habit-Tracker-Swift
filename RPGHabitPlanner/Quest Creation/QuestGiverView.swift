import SwiftUI

struct QuestGiverView: View {
    @EnvironmentObject var themeManager: ThemeManager
    let dialogue: String
    let showDialogue: Bool
    let onContinue: () -> Void
    let animate: Bool
    @State private var isButtonPressed = false
    
    var body: some View {
        let theme = themeManager.activeTheme
        VStack(spacing: 30) {
            Spacer()
            
            // Quest Giver Character
            VStack(spacing: 20) {
                Image(systemName: "person.fill.questionmark")
                    .font(.system(size: 80))
                    .foregroundColor(.yellow)
                    .scaleEffect(animate ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: animate)
                
                Text("Quest Master")
                    .font(.appFont(size: 24, weight: .black))
                    .foregroundColor(theme.textColor)
            }
            
            // Dialogue Box
            if showDialogue {
                VStack(spacing: 16) {
                    Text(dialogue)
                        .font(.appFont(size: 16, weight: .medium))
                        .foregroundColor(theme.textColor)
                        .multilineTextAlignment(.center)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(theme.secondaryColor)
                                .shadow(color: Color.black.opacity(0.2), radius: 6, x: 0, y: 4)
                        )
                        .transition(.scale.combined(with: .opacity))
                    
                    Button(action: {
                        isButtonPressed = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            isButtonPressed = false
                            onContinue()
                        }
                    }) {
                        HStack(spacing: 8) {
                            Text("Continue")
                                .font(.appFont(size: 16, weight: .black))
                            Image(systemName: "arrow.right")
                                .font(.title3)
                        }
                        .foregroundColor(.white)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 24)
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
                }
                .transition(.scale.combined(with: .opacity))
            }
            
            Spacer()
        }
        .padding()
    }
}
