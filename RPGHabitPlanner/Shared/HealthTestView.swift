import SwiftUI

struct HealthTestView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @StateObject private var healthManager = HealthManager.shared
    @State private var damageAmount: Int16 = 10
    @State private var healAmount: Int16 = 20
    @State private var showTestResults = false
    @State private var testMessage = ""
    
    var body: some View {
        let theme = themeManager.activeTheme
        
        VStack(spacing: 20) {
            // Health Display
            HealthBarView(healthManager: healthManager, size: .large)
                .padding()
            
            // Test Controls
            VStack(spacing: 16) {
                // Damage Test
                VStack(spacing: 8) {
                    Text("Test Damage")
                        .font(.appFont(size: 16, weight: .black))
                        .foregroundColor(theme.textColor)
                    
                    HStack {
                        Text("Damage Amount:")
                            .font(.appFont(size: 14))
                            .foregroundColor(theme.textColor)
                        
                        Stepper("\(damageAmount)", value: $damageAmount, in: 1...50)
                            .font(.appFont(size: 14, weight: .black))
                            .foregroundColor(theme.textColor)
                    }
                    
                    Button("Take Damage") {
                        healthManager.takeDamage(damageAmount) { error in
                            if error == nil {
                                testMessage = "Took \(damageAmount) damage!"
                                showTestResults = true
                            }
                        }
                    }
                    .buttonStyle(TestButtonStyle(color: .red))
                }
                
                // Healing Test
                VStack(spacing: 8) {
                    Text("Test Healing")
                        .font(.appFont(size: 16, weight: .black))
                        .foregroundColor(theme.textColor)
                    
                    HStack {
                        Text("Heal Amount:")
                            .font(.appFont(size: 14))
                            .foregroundColor(theme.textColor)
                        
                        Stepper("\(healAmount)", value: $healAmount, in: 1...50)
                            .font(.appFont(size: 14, weight: .black))
                            .foregroundColor(theme.textColor)
                    }
                    
                    Button("Heal") {
                        healthManager.heal(healAmount) { error in
                            if error == nil {
                                testMessage = "Healed \(healAmount) HP!"
                                showTestResults = true
                            }
                        }
                    }
                    .buttonStyle(TestButtonStyle(color: .green))
                }
                
                // Full Heal Test
                Button("Full Heal") {
                    healthManager.restoreFullHealth { error in
                        if error == nil {
                            testMessage = "Fully healed!"
                            showTestResults = true
                        }
                    }
                }
                .buttonStyle(TestButtonStyle(color: .blue))
                
                // Quest Failure Test
                Button("Simulate Quest Failure (5★)") {
                    healthManager.handleQuestFailure(questDifficulty: 5) { error in
                        if error == nil {
                            testMessage = "Quest failed! Took 10 damage!"
                            showTestResults = true
                        }
                    }
                }
                .buttonStyle(TestButtonStyle(color: .orange))
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(theme.secondaryColor)
                    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
            )
            
            Spacer()
        }
        .padding()
        .background(theme.backgroundColor.ignoresSafeArea())
        .navigationTitle("Health System Test")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Test Result", isPresented: $showTestResults) {
            Button("OK") { }
        } message: {
            Text(testMessage)
        }
    }
}

// MARK: - Test Button Style

struct TestButtonStyle: ButtonStyle {
    let color: Color
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.appFont(size: 14, weight: .black))
            .foregroundColor(.white)
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(color)
                    .opacity(configuration.isPressed ? 0.7 : 1.0)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        HealthTestView()
            .environmentObject(ThemeManager.shared)
    }
}
