import SwiftUI

struct HealthStatusView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @ObservedObject var healthManager: HealthManager
    let showDetails: Bool
    
    init(healthManager: HealthManager, showDetails: Bool = true) {
        self.healthManager = healthManager
        self.showDetails = showDetails
    }
    
    var body: some View {
        let theme = themeManager.activeTheme
        let healthPercentage = healthManager.getHealthPercentage()
        
        VStack(spacing: 8) {
            HStack {
                Image(systemName: healthIcon)
                    .font(.system(size: 16))
                    .foregroundColor(healthColor)
                    .scaleEffect(healthManager.isLowHealth ? 1.2 : 1.0)
                    .animation(
                        .easeInOut(duration: 1.0)
                        .repeatForever(autoreverses: true),
                        value: healthManager.isLowHealth
                    )
                
                Text("Health")
                    .font(.appFont(size: 14, weight: .black))
                    .foregroundColor(theme.textColor)
                
                Spacer()
                
                if showDetails {
                    Text("\(healthManager.currentHealth)/\(healthManager.maxHealth)")
                        .font(.appFont(size: 12, weight: .black))
                        .foregroundColor(theme.textColor)
                }
            }
            
            if showDetails {
                // Health Bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(theme.backgroundColor.opacity(0.3))
                            .frame(height: 12)
                        
                        RoundedRectangle(cornerRadius: 6)
                            .fill(healthGradient)
                            .frame(width: geometry.size.width * healthPercentage, height: 12)
                            .animation(.easeOut(duration: 0.5), value: healthPercentage)
                    }
                }
                .frame(height: 12)
                
                // Health Status Text
                HStack {
                    Text(healthStatusText)
                        .font(.appFont(size: 12, weight: .medium))
                        .foregroundColor(healthColor)
                    
                    Spacer()
                    
                    Text("\(Int(healthPercentage * 100))%")
                        .font(.appFont(size: 12, weight: .black))
                        .foregroundColor(theme.textColor.opacity(0.8))
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(theme.secondaryColor)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(healthColor.opacity(0.3), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Computed Properties
    
    private var healthIcon: String {
        if healthManager.isDead() {
            return "heart.slash.fill"
        } else if healthManager.isLowHealth {
            return "heart.fill"
        } else {
            return "heart.fill"
        }
    }
    
    private var healthColor: Color {
        let percentage = healthManager.getHealthPercentage()

        switch percentage {
        case 0.0:
            return .gray
        case 0.0..<0.25:
            return .red
        case 0.25..<0.5:
            return .red
        case 0.5..<0.75:
            return .red
        default:
            return .red
        }
    }

    private var healthGradient: LinearGradient {
        let percentage = healthManager.getHealthPercentage()

        let colors: [Color]
        switch percentage {
        case 0.0..<0.25:
            colors = [Color.red, Color.red.opacity(0.8)]
        case 0.25..<0.5:
            colors = [Color.red.opacity(0.9), Color.red.opacity(0.7)]
        case 0.5..<0.75:
            colors = [Color.red.opacity(0.8), Color.red.opacity(0.6)]
        default:
            colors = [Color.red.opacity(0.7), Color.red.opacity(0.5)]
        }

        return LinearGradient(
            gradient: Gradient(colors: colors),
            startPoint: .leading,
            endPoint: .trailing
        )
    }
    
    private var healthStatusText: String {
        let percentage = healthManager.getHealthPercentage()
        
        switch percentage {
        case 0.0:
            return "Dead"
        case 0.0..<0.25:
            return "Critical"
        case 0.25..<0.5:
            return "Injured"
        case 0.5..<0.75:
            return "Wounded"
        case 0.75..<1.0:
            return "Healthy"
        default:
            return "Full Health"
        }
    }
}

// MARK: - Compact Health Status View

struct CompactHealthStatusView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @ObservedObject var healthManager: HealthManager
    
    var body: some View {
        let theme = themeManager.activeTheme
        let healthPercentage = healthManager.getHealthPercentage()
        
        HStack(spacing: 6) {
            Image(systemName: "heart.fill")
                .font(.system(size: 12))
                .foregroundColor(healthColor(for: healthPercentage))
                .scaleEffect(healthManager.isLowHealth ? 1.2 : 1.0)
                .animation(
                    .easeInOut(duration: 1.0)
                    .repeatForever(autoreverses: true),
                    value: healthManager.isLowHealth
                )
            
            Text("\(healthManager.currentHealth)")
                .font(.appFont(size: 12, weight: .black))
                .foregroundColor(theme.textColor)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(healthColor(for: healthPercentage).opacity(0.2))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(healthColor(for: healthPercentage).opacity(0.3), lineWidth: 1)
                )
        )
    }
    
    private func healthColor(for percentage: Double) -> Color {
        switch percentage {
        case 0.0..<0.25:
            return .red
        case 0.25..<0.5:
            return .red
        case 0.5..<0.75:
            return .red
        default:
            return .red
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 20) {
        HealthStatusView(healthManager: HealthManager.shared)
        CompactHealthStatusView(healthManager: HealthManager.shared)
    }
    .padding()
    .background(Color.black)
    .environmentObject(ThemeManager.shared)
}
