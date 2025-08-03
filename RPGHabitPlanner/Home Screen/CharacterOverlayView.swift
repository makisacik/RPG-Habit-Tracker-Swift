import SwiftUI

struct CharacterOverlayView: View {
    @EnvironmentObject var themeManager: ThemeManager
    let user: UserEntity

    var body: some View {
        let theme = themeManager.activeTheme

        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .stroke(theme.primaryColor, lineWidth: 3)
                    .frame(width: 60, height: 60)

                if let characterClass = CharacterClass(rawValue: user.characterClass ?? "knight") {
                    Image(characterClass.iconName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                }
            }
            .padding(.leading, 4)

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(user.nickname ?? "Adventurer")
                        .font(.appFont(size: 18, weight: .blackItalic))
                        .foregroundColor(theme.textColor)

                    Spacer()

                    Text("Level \(user.level)")
                        .font(.appFont(size: 14, weight: .black))
                        .foregroundColor(theme.textColor)
                }

                Text(user.characterClass?.capitalized ?? "Unknown")
                    .font(.appFont(size: 14, weight: .regular))
                    .foregroundColor(theme.textColor)

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
        }
        .padding(6)
        .background(
//            Image("frame_light_yellow")
//                .resizable(capInsets: EdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 12), resizingMode: .stretch)
//                .shadow(color: Color.black.opacity(0.2), radius: 6, x: 0, y: 4)
            RoundedRectangle(cornerRadius: 12)
                .fill(themeManager.activeTheme.secondaryColor)
                .shadow(color: Color.black.opacity(0.2), radius: 6, x: 0, y: 4)
        )
        .padding(10)
    }
}

struct CharacterOverlayView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext

        let mockUser = UserEntity(context: context)
        mockUser.nickname = "Mehmet"
        mockUser.characterClass = "archer"
        mockUser.exp = 30
        mockUser.level = 1
        mockUser.weapon = "Crossbow"
        mockUser.id = UUID()

        return CharacterOverlayView(user: mockUser)
            .environmentObject(ThemeManager.shared)
            .previewLayout(.sizeThatFits)
            .background(Color.gray.opacity(0.1))
    }
}
