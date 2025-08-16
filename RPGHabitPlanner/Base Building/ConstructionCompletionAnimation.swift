import SwiftUI

struct ConstructionCompletionAnimation: View {
    let building: Building
    let buildingPosition: CGPoint
    let onAnimationComplete: () -> Void

    @State private var showParticles = false
    @State private var showSparkles = false
    @State private var scaleBuilding = false
    @State private var showCompletionText = false
    @State private var particleOffset: CGFloat = 0
    @State private var isTransitioning = false
    @State private var animationPosition: CGPoint = .zero
    @State private var animationScale: CGFloat = 1.0
    @State private var animationOpacity: Double = 1.0

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
                    .shadow(color: isTransitioning ? .yellow.opacity(0.6) : .clear, radius: isTransitioning ? 20 : 0)
                    .animation(.easeInOut(duration: 0.3), value: isTransitioning)

                // Completion text
                if showCompletionText && !isTransitioning {
                    Text("Tap to Complete!")
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
            .position(animationPosition)
            .scaleEffect(animationScale)
            .opacity(animationOpacity)
            .animation(.easeInOut(duration: 0.8), value: animationPosition)
            .animation(.easeInOut(duration: 0.8), value: animationScale)
            .animation(.easeInOut(duration: 0.8), value: animationOpacity)
            .onTapGesture {
                if !isTransitioning {
                    startTransitionToBuilding()
                }
            }

            // Particle effects
            if showParticles && !isTransitioning {
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
            if showSparkles && !isTransitioning {
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
        // Set initial position to center of screen immediately (no animation)
        animationPosition = CGPoint(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2)

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
    }

    private func startTransitionToBuilding() {
        isTransitioning = true

        // Animate the building to its final position
        withAnimation(.easeInOut(duration: 0.8)) {
            animationPosition = buildingPosition
            animationScale = 1.0 // Return to normal scale
        }

        // Fade out the animation
        withAnimation(.easeInOut(duration: 0.6).delay(0.4)) {
            animationOpacity = 0.0
        }

        // Complete the transition
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
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
