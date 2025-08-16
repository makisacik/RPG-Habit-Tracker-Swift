import SwiftUI

struct ConstructionCompletionAnimation: View {
    let building: Building
    let onAnimationComplete: () -> Void
    
    @State private var showParticles = false
    @State private var showSparkles = false
    @State private var scaleBuilding = false
    @State private var showCompletionText = false
    @State private var particleOffset: CGFloat = 0
    
    var body: some View {
        ZStack {
            // Building completion effect
            VStack(spacing: 0) {
                // Building image with scale animation
                Image(building.imageName) // Use the final active image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: building.type.size.width, height: building.type.size.height)
                    .scaleEffect(scaleBuilding ? 1.2 : 0.8)
                    .animation(.spring(response: 0.6, dampingFraction: 0.6), value: scaleBuilding)
                
                // Completion text
                if showCompletionText {
                    Text("Construction Complete!")
                        .font(.appFont(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.green.opacity(0.8))
                        )
                        .transition(.scale.combined(with: .opacity))
                }
            }
            
            // Particle effects
            if showParticles {
                ForEach(0..<12, id: \.self) { index in
                    Circle()
                        .fill(Color.yellow)
                        .frame(width: 8, height: 8)
                        .offset(x: cos(Double(index) * .pi / 6) * 60, y: sin(Double(index) * .pi / 6) * 60)
                        .scaleEffect(showParticles ? 0 : 1)
                        .opacity(showParticles ? 0 : 1)
                        .animation(.easeOut(duration: 1.0).delay(Double(index) * 0.1), value: showParticles)
                }
            }
            
            // Sparkle effects
            if showSparkles {
                ForEach(0..<8, id: \.self) { index in
                    Image(systemName: "sparkle")
                        .foregroundColor(.yellow)
                        .font(.system(size: 16))
                        .offset(x: cos(Double(index) * .pi / 4) * 40, y: sin(Double(index) * .pi / 4) * 40)
                        .scaleEffect(showSparkles ? 0 : 1.5)
                        .opacity(showSparkles ? 0 : 1)
                        .animation(.easeOut(duration: 0.8).delay(Double(index) * 0.15), value: showSparkles)
                }
            }
        }
        .onAppear {
            startAnimation()
        }
    }
    
    private func startAnimation() {
        // Start with building scale animation
        withAnimation(.easeInOut(duration: 0.3)) {
            scaleBuilding = true
        }
        
        // Show particles after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            showParticles = true
        }
        
        // Show sparkles
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            showSparkles = true
        }
        
        // Show completion text
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) {
                showCompletionText = true
            }
        }
        
        // Complete animation and call completion handler
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            onAnimationComplete()
        }
    }
}

// MARK: - Particle Effect View
struct ParticleEffect: View {
    let color: Color
    let count: Int
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            ForEach(0..<count, id: \.self) { index in
                Circle()
                    .fill(color)
                    .frame(width: 4, height: 4)
                    .offset(x: cos(Double(index) * 2 * .pi / Double(count)) * 30,
                           y: sin(Double(index) * 2 * .pi / Double(count)) * 30)
                    .scaleEffect(isAnimating ? 0 : 1)
                    .opacity(isAnimating ? 0 : 1)
                    .animation(.easeOut(duration: 1.0).delay(Double(index) * 0.1), value: isAnimating)
            }
        }
        .onAppear {
            isAnimating = true
        }
    }
}
