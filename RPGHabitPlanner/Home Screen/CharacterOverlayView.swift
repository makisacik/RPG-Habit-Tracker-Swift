import SwiftUI

struct CharacterOverlayView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @StateObject private var customizationManager = CharacterCustomizationManager()
    let user: UserEntity
    
    var body: some View {
        let theme = themeManager.activeTheme

        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .stroke(theme.primaryColor, lineWidth: 3)
                    .frame(width: 60, height: 60)

                // Custom Character Avatar
                CustomizedCharacterPreviewCard(
                    customization: customizationManager.currentCustomization,
                    theme: theme,
                    showTitle: false
                )
                .frame(width: 50, height: 50)
                .clipShape(Circle())
            }
            .padding(.leading, 4)

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(user.nickname ?? String.adventurer.localized)
                        .font(.appFont(size: 18, weight: .blackItalic))
                        .foregroundColor(theme.textColor)

                    Spacer()

                    Text("\(String.level.localized) \(user.level)")
                        .font(.appFont(size: 14, weight: .black))
                        .foregroundColor(theme.textColor)
                }

                Text("Adventurer")
                    .font(.appFont(size: 14, weight: .regular))
                    .foregroundColor(theme.textColor)

                // Coins display
                HStack(spacing: 4) {
                    Image(systemName: "coins")
                        .font(.system(size: 12))
                        .foregroundColor(.yellow)
                    
                    Text("\(user.coins)")
                        .font(.appFont(size: 12, weight: .medium))
                        .foregroundColor(theme.textColor)
                }
            }

            Spacer()
        }
        .onAppear {
            customizationManager.loadCustomization()
        }
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
