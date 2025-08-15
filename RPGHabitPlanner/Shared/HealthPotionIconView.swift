import SwiftUI

struct HealthPotionIconView: View {
    let rarity: ItemRarity
    let size: CGFloat
    
    init(rarity: ItemRarity = .common, size: CGFloat = 24) {
        self.rarity = rarity
        self.size = size
    }
    
    var body: some View {
        ZStack {
            // Potion bottle background
            RoundedRectangle(cornerRadius: size * 0.3)
                .fill(bottleColor)
                .frame(width: size * 0.6, height: size)
            
            // Potion liquid
            RoundedRectangle(cornerRadius: size * 0.25)
                .fill(liquidColor)
                .frame(width: size * 0.5, height: size * 0.8)
                .offset(y: -size * 0.05)
            
            // Bottle neck
            RoundedRectangle(cornerRadius: size * 0.1)
                .fill(bottleColor)
                .frame(width: size * 0.3, height: size * 0.2)
                .offset(y: -size * 0.6)
            
            // Heart symbol
            Image(systemName: "heart.fill")
                .font(.system(size: size * 0.3))
                .foregroundColor(.white)
                .offset(y: -size * 0.1)
        }
    }
    
    private var bottleColor: Color {
        switch rarity {
        case .common:
            return .gray
        case .uncommon:
            return .green
        case .rare:
            return .blue
        case .epic:
            return .purple
        case .legendary:
            return .orange
        }
    }
    
    private var liquidColor: Color {
        switch rarity {
        case .common:
            return .red.opacity(0.7)
        case .uncommon:
            return .red
        case .rare:
            return .red
        case .epic:
            return .red
        case .legendary:
            return .red
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 20) {
        HStack(spacing: 20) {
            HealthPotionIconView(rarity: .common, size: 30)
            HealthPotionIconView(rarity: .uncommon, size: 30)
            HealthPotionIconView(rarity: .rare, size: 30)
        }
        
        HStack(spacing: 20) {
            HealthPotionIconView(rarity: .epic, size: 30)
            HealthPotionIconView(rarity: .legendary, size: 30)
        }
    }
    .padding()
    .background(Color.black)
}
