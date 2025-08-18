import SwiftUI

struct StepTransitionOverlay: View {
    let text: String
    @State private var showText = false
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.7)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                ProgressView()
                    .scaleEffect(1.5)
                    .tint(.yellow)
                
                Text(text)
                    .font(.appFont(size: 18, weight: .black))
                    .foregroundColor(.white)
                    .opacity(showText ? 1.0 : 0.0)
                    .animation(.easeInOut(duration: 0.5), value: showText)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.5).delay(0.3)) {
                showText = true
            }
        }
    }
}
