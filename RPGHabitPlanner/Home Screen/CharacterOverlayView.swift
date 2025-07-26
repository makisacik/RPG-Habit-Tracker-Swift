// MOCKED VERSION FOR PREVIEW ONLY — DO NOT USE IN PRODUCTION
// This lets you preview CharacterOverlayView safely without CoreData runtime issues

import SwiftUI

struct MockUserEntity {
    let nickname: String
    let characterClass: String
    let exp: Int
    let level: Int
    let weapon: String
    let id: UUID
}

struct CharacterOverlayPreview: View {
    let user: MockUserEntity

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Image("minimap_ring_white")
                    .resizable()
                    .frame(width: 60, height: 60)

                Image(user.characterClass)
                    .resizable()
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
            }


            VStack(alignment: .leading, spacing: 4) {
                Text(user.nickname)
                    .font(.appFont(size: 18, weight: .blackItalic))
                    .foregroundColor(.white)
                Text(user.characterClass.capitalized)
                    .font(.appFont(size: 14, weight: .regular))
                    .foregroundColor(.white)
                
                // exp bar
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
                    .clipped()
                }
                .frame(height: 35)
            }

            Spacer()

            Button(action: {}) {
                Image(systemName: "info.circle")
                    .foregroundColor(.black)
                    .font(.title2)
            }
        }
        .padding(5)
        .background(
            Image("panel_blue")
                .resizable(capInsets: EdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20), resizingMode: .stretch)
        )
    }
}

struct CharacterOverlayPreview_Previews: PreviewProvider {
    static var previews: some View {
        CharacterOverlayPreview(user: MockUserEntity(
            nickname: "Mehmet",
            characterClass: "archer",
            exp: 30,
            level: 1,
            weapon: "Crossbow",
            id: UUID()
        ))
        .previewLayout(.sizeThatFits)
        .background(Color.gray.opacity(0.1))
    }
}
