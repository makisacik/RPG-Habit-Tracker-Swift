import SwiftUI

struct HealthBarView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @ObservedObject var healthManager: HealthManager
    let size: HealthBarSize
    let showText: Bool
    let showShineAnimation: Bool

    @State private var animateHealth: Bool = false
    @State private var pulseAnimation: Bool = false

    init(healthManager: HealthManager, size: HealthBarSize = .medium, showText: Bool = true, showShineAnimation: Bool = true) {
        self.healthManager = healthManager
        self.size = size
        self.showText = showText
        self.showShineAnimation = showShineAnimation
    }

    var body: some View {
        let theme = themeManager.activeTheme
        let healthPercentage = healthManager.getHealthPercentage()

        VStack(spacing: size.textSpacing) {
            // Health Bar Container
            ZStack(alignment: .leading) {
                // Background - match home character card style
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.red.opacity(0.2))
                    .frame(height: size.height)

                // Health Fill
                GeometryReader { geometry in
                    let healthWidth = geometry.size.width * healthPercentage

                    RoundedRectangle(cornerRadius: 8)
                        .fill(healthGradient(for: healthPercentage))
                        .overlay(
                            // Animated shine effect - contained within health bar
                            Group {
                                if showShineAnimation {
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color.white.opacity(0.3),
                                            Color.clear,
                                            Color.white.opacity(0.3)
                                        ]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                    .frame(width: healthWidth * 0.3) // Shine effect width
                                    .offset(x: animateHealth ? healthWidth : -healthWidth * 0.3)
                                    .clipped() // Clip to health bar bounds
                                    .animation(
                                        .linear(duration: 2.0)
                                        .repeatForever(autoreverses: false),
                                        value: animateHealth
                                    )
                                }
                            }
                        )
                        .frame(width: healthWidth)
                        .clipped() // Ensure health bar doesn't overflow
                        .animation(.easeOut(duration: 0.8), value: healthPercentage)
                }
                .frame(height: size.height)

                // Damage/Heal Animation Overlay
                if healthManager.showDamageAnimation {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.red.opacity(0.6))
                        .frame(height: size.height)
                        .transition(.scale.combined(with: .opacity))
                }

                if healthManager.showHealAnimation {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.green.opacity(0.6))
                        .frame(height: size.height)
                        .transition(.scale.combined(with: .opacity))
                }

                // Health Icon
                HStack {
                    Image(systemName: healthIcon(for: healthPercentage))
                        .font(.system(size: size.iconSize))
                        .foregroundColor(healthColor(for: healthPercentage))
                        .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
                        .scaleEffect(pulseAnimation ? 1.2 : 1.0)
                        .animation(
                            .easeInOut(duration: 1.0)
                            .repeatForever(autoreverses: true),
                            value: pulseAnimation
                        )

                    Spacer()
                }
                .padding(.leading, size.iconPadding)

                // HP Amount in the middle of the bar
                if showText {
                    HStack {
                        Spacer()
                        Text("\(healthManager.currentHealth)/\(healthManager.maxHealth)")
                            .font(.appFont(size: size.textSize, weight: .black))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.8), radius: 2, x: 0, y: 1)
                        Spacer()
                    }
                }
            }
            .frame(height: size.height)
        }
        .onAppear {
            if showShineAnimation {
                animateHealth = true
            }
            if healthManager.isLowHealth {
                pulseAnimation = true
            }
        }
        .onChange(of: healthManager.isLowHealth) { isLow in
            pulseAnimation = isLow
        }
    }

    // MARK: - Helper Methods

    private func healthGradient(for percentage: Double) -> LinearGradient {
        // Use the same red gradient as the home character card
        let colors = [Color.red, Color.red.opacity(0.8)]

        return LinearGradient(
            gradient: Gradient(colors: colors),
            startPoint: .leading,
            endPoint: .trailing
        )
    }

    private func healthColor(for percentage: Double) -> Color {
        // Use red color to match home character card
        return .red
    }

    private func healthIcon(for percentage: Double) -> String {
        switch percentage {
        case 0.0:
            return "heart.slash.fill"
        case 0.0..<0.25:
            return "heart.fill"
        case 0.25..<0.5:
            return "heart.fill"
        case 0.5..<0.75:
            return "heart.fill"
        default:
            return "heart.fill"
        }
    }
}

// MARK: - Health Bar Sizes

enum HealthBarSize {
    case small
    case medium
    case large

    var height: CGFloat {
        switch self {
        case .small: return 20
        case .medium: return 28
        case .large: return 36
        }
    }

    var cornerRadius: CGFloat {
        switch self {
        case .small: return 10
        case .medium: return 14
        case .large: return 18
        }
    }

    var iconSize: CGFloat {
        switch self {
        case .small: return 12
        case .medium: return 16
        case .large: return 20
        }
    }

    var iconPadding: CGFloat {
        switch self {
        case .small: return 6
        case .medium: return 8
        case .large: return 10
        }
    }

    var textSize: CGFloat {
        switch self {
        case .small: return 12
        case .medium: return 14
        case .large: return 16
        }
    }

    var textSpacing: CGFloat {
        switch self {
        case .small: return 4
        case .medium: return 6
        case .large: return 8
        }
    }
}

// MARK: - Compact Health Bar

struct CompactHealthBarView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @ObservedObject var healthManager: HealthManager

    var body: some View {
        let theme = themeManager.activeTheme
        let healthPercentage = healthManager.getHealthPercentage()

        HStack(spacing: 8) {
            // Health Icon
            Image(systemName: "heart.fill")
                .font(.system(size: 14))
                .foregroundColor(healthColor(for: healthPercentage))
                .scaleEffect(healthManager.isLowHealth ? 1.2 : 1.0)
                .animation(
                    .easeInOut(duration: 1.0)
                    .repeatForever(autoreverses: true),
                    value: healthManager.isLowHealth
                )

            // Health Bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(theme.backgroundColor.opacity(0.3))
                        .frame(height: 12)

                    RoundedRectangle(cornerRadius: 6)
                        .fill(healthGradient(for: healthPercentage))
                        .frame(width: geometry.size.width * healthPercentage, height: 12)
                        .animation(.easeOut(duration: 0.5), value: healthPercentage)
                }
            }
            .frame(width: 60, height: 12)

            // Health Text
            Text("\(healthManager.currentHealth)")
                .font(.appFont(size: 12, weight: .black))
                .foregroundColor(theme.textColor)
                .frame(minWidth: 25, alignment: .trailing)
        }
    }

    private func healthGradient(for percentage: Double) -> LinearGradient {
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
        HealthBarView(healthManager: HealthManager.shared, size: .large)
        HealthBarView(healthManager: HealthManager.shared, size: .medium)
        HealthBarView(healthManager: HealthManager.shared, size: .small)
        CompactHealthBarView(healthManager: HealthManager.shared)
    }
    .padding()
    .background(Color.black)
    .environmentObject(ThemeManager.shared)
}
