import SwiftUI

struct CharacterOverlayView: View {
    let user: UserEntity

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Image("minimap_ring_white")
                    .resizable()
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
                        .foregroundColor(.white)

                    Spacer()

                    Text("Level \(user.level)")
                        .font(.appFont(size: 14, weight: .black))
                        .foregroundColor(.appYellow)
                }

                Text(user.characterClass?.capitalized ?? "Unknown")
                    .font(.appFont(size: 14, weight: .regular))
                    .foregroundColor(.white)

                ZStack(alignment: .leading) {
                    Image("progress_transparent")
                        .resizable(capInsets: EdgeInsets(top: 15, leading: 15, bottom: 15, trailing: 15), resizingMode: .stretch)
                        .frame(height: 20)

                    GeometryReader { geometry in
                        let expRatio = min(CGFloat(user.exp) / 100.0, 1.0)
                        if expRatio > 0 {
                            Image("progress_green")
                                .resizable(capInsets: EdgeInsets(top: 15, leading: 15, bottom: 15, trailing: 15), resizingMode: .stretch)
                                .frame(width: geometry.size.width * expRatio, height: 20)
                        }
                    }
                    .frame(height: 20)

                    HStack {
                        Spacer()
                        Text("\(user.exp) / 100")
                            .font(.appFont(size: 12, weight: .black))
                            .foregroundColor(.white)
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
            Image("panelInset_brown")
                .resizable(capInsets: EdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20), resizingMode: .stretch)
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
            .previewLayout(.sizeThatFits)
            .background(Color.gray.opacity(0.1))
    }
}
