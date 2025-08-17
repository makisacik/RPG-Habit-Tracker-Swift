import SwiftUI

// MARK: - Village Building View
struct VillageBuildingView: View {
    let building: Building
    let theme: Theme
    let onTap: () -> Void
    let customSize: CGSize?
    
    @State private var isAnimating = false
    @State private var showTooltip = false
    @State private var isReadyToCompleteAnimating = false
    @State private var hasAppeared = false
    
    init(building: Building, theme: Theme, customSize: CGSize? = nil, onTap: @escaping () -> Void) {
        self.building = building
        self.theme = theme
        self.customSize = customSize
        self.onTap = onTap
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Building Image
            let buildingSize = customSize ?? building.type.size

            // Building image
            Image(building.currentImageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: buildingSize.width, height: buildingSize.height)
                .scaleEffect(building.state == .construction && isAnimating ? 1.05 : 1.0)
                .animation(
                    hasAppeared && building.state == .construction ? .easeInOut(duration: 0.8).repeatForever(autoreverses: true) : .none,
                    value: isAnimating
                )
                .animation(.none, value: building.currentImageName) // Prevent animation when image changes
                .overlay(
                    // Ready to complete indicator
                    Group {
                        if building.state == .readyToComplete {
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.yellow, lineWidth: 3)
                                .scaleEffect(isReadyToCompleteAnimating ? 1.1 : 1.0)
                                .opacity(isReadyToCompleteAnimating ? 0.8 : 0.6)
                                .animation(
                                    hasAppeared ? .easeInOut(duration: 1.0).repeatForever(autoreverses: true) : .none,
                                    value: isReadyToCompleteAnimating
                                )
                        }
                    }
                )
            
            // Building Info (only show for active buildings, ready to complete, or when tapped)
            if building.state == .active || building.state == .readyToComplete || showTooltip {
                buildingInfoView
            }
        }
        .background(Color.clear)
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
        .onLongPressGesture(minimumDuration: 0.5) {
            withAnimation(.easeInOut(duration: 0.3)) {
                showTooltip.toggle()
            }
        }
        .onAppear {
            // Delay animations to prevent jumping when view first appears
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                hasAppeared = true
                
                if building.state == .construction {
                    isAnimating = true
                } else if building.state == .readyToComplete {
                    isReadyToCompleteAnimating = true
                }
            }
        }
        .onChange(of: building.state) { newState in
            // Handle state changes smoothly
            if newState == .construction {
                isAnimating = true
                isReadyToCompleteAnimating = false
            } else if newState == .readyToComplete {
                isAnimating = false
                isReadyToCompleteAnimating = true
            } else if newState == .active {
                // Stop all animations when building becomes active
                isAnimating = false
                isReadyToCompleteAnimating = false
            } else {
                isAnimating = false
                isReadyToCompleteAnimating = false
            }
        }
        .animation(.none, value: building.state) // Disable animation for state changes to prevent position jumping
    }
    
    private var buildingInfoView: some View {
        VStack(spacing: 4) {
            // Building name and level
            HStack(spacing: 4) {
                Text(building.type.displayName)
                    .font(.appFont(size: 10, weight: .medium))
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                if building.level > 1 {
                    Text("Lv.\(building.level)")
                        .font(.appFont(size: 8, weight: .bold))
                        .foregroundColor(.yellow)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 1)
                        .background(
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.black.opacity(0.6))
                        )
                }
            }
            
            // State indicator
            HStack(spacing: 4) {
                Circle()
                    .fill(building.state.color)
                    .frame(width: 6, height: 6)
                
                Text(building.state.displayName)
                    .font(.appFont(size: 8))
                    .foregroundColor(.white.opacity(0.8))
                    .lineLimit(1)
            }
            
            // Construction progress
            if building.state == .construction {
                ProgressView(value: building.constructionProgress)
                    .progressViewStyle(LinearProgressViewStyle(tint: .orange))
                    .frame(height: 4)
                    .scaleEffect(x: 0.8, y: 0.8)
            }
            
            // Ready to complete indicator
            if building.state == .readyToComplete {
                HStack(spacing: 4) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.yellow)
                        .font(.system(size: 10))
                    
                    Text("Tap to Complete!")
                        .font(.appFont(size: 8, weight: .bold))
                        .foregroundColor(.yellow)
                }
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.black.opacity(0.6))
                )
            }
            
            // Gold indicator for goldmines
            if building.type == .goldmine && building.state == .active {
                HStack(spacing: 2) {
                    Image(systemName: "dollarsign.circle.fill")
                        .font(.system(size: 8))
                        .foregroundColor(.yellow)
                    
                    Text("\(building.goldGenerationRate)")
                        .font(.appFont(size: 8))
                        .foregroundColor(.yellow)
                }
            }
        }
        .padding(6)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(Color.black.opacity(0.7))
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(building.state.color, lineWidth: 1)
                )
        )
        .transition(.opacity.combined(with: .scale))
    }
}

// MARK: - Legacy Building View (for compatibility)
struct BuildingView: View {
    let building: Building
    let onTap: () -> Void
    
    @State private var isAnimating = false
    @State private var hasAppeared = false
    
    var body: some View {
        VStack(spacing: 4) {
            // Building Image
            Image(building.currentImageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 60, height: 60)
                .scaleEffect(isAnimating ? 1.1 : 1.0)
                .animation(
                    hasAppeared ? .easeInOut(duration: 0.5).repeatForever(autoreverses: true) : .none,
                    value: isAnimating
                )
            
            // Building Info
            VStack(spacing: 2) {
                Text(building.type.displayName)
                    .font(.appFont(size: 10, weight: .medium))
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                // State indicator
                HStack(spacing: 4) {
                    Circle()
                        .fill(building.state.color)
                        .frame(width: 6, height: 6)
                    
                    Text(building.state.displayName)
                        .font(.appFont(size: 8))
                        .foregroundColor(.white.opacity(0.8))
                        .lineLimit(1)
                }
                
                // Construction progress
                if building.state == .construction {
                    ProgressView(value: building.constructionProgress)
                        .progressViewStyle(LinearProgressViewStyle(tint: .orange))
                        .frame(height: 4)
                        .scaleEffect(x: 0.8, y: 0.8)
                }
                
                // Gold indicator for goldmines
                if building.type == .goldmine && building.state == .active {
                    HStack(spacing: 2) {
                        Image(systemName: "dollarsign.circle.fill")
                            .font(.system(size: 8))
                            .foregroundColor(.yellow)
                        
                        Text("\(building.goldGenerationRate)")
                            .font(.appFont(size: 8))
                            .foregroundColor(.yellow)
                    }
                }
            }
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.black.opacity(0.3))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(building.state.color, lineWidth: 2)
                )
        )
        .onTapGesture {
            onTap()
        }
        .onAppear {
            // Delay animations to prevent jumping when view first appears
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                hasAppeared = true
                
                if building.state == .construction {
                    isAnimating = true
                }
            }
        }
        .onChange(of: building.state) { newState in
            // Handle state changes smoothly
            if newState == .construction {
                isAnimating = true
            } else {
                isAnimating = false
            }
        }
    }
}

// MARK: - Building Detail View

struct BuildingDetailView: View {
    let building: Building
    @ObservedObject var viewModel: BaseBuildingViewModel
    let theme: Theme
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Building Image
                Image(building.currentImageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 120, height: 120)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(theme.primaryColor)
                    )
                
                // Building Info
                VStack(spacing: 16) {
                    VStack(spacing: 8) {
                        HStack {
                            Text(building.type.displayName)
                                .font(.appFont(size: 24, weight: .bold))
                                .foregroundColor(theme.textColor)
                            
                            if building.level > 1 {
                                Text("Lv.\(building.level)")
                                    .font(.appFont(size: 16, weight: .bold))
                                    .foregroundColor(.yellow)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(Color.black.opacity(0.3))
                                    )
                            }
                        }
                        
                        Text(building.type.description)
                            .font(.appFont(size: 16))
                            .foregroundColor(theme.textColor.opacity(0.7))
                            .multilineTextAlignment(.center)
                    }
                    
                    // State Info
                    HStack {
                        Label(building.state.displayName, systemImage: "circle.fill")
                            .foregroundColor(building.state.color)
                            .font(.appFont(size: 16, weight: .medium))
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    // Construction Progress
                    if building.state == .construction {
                        VStack(spacing: 8) {
                            Text("Construction Progress")
                                .font(.appFont(size: 16, weight: .medium))
                                .foregroundColor(theme.textColor)
                            
                            ProgressView(value: building.constructionProgress)
                                .progressViewStyle(LinearProgressViewStyle(tint: theme.accentColor))
                                .frame(height: 8)
                            
                            Text("\(Int(building.constructionProgress * 100))%")
                                .font(.appFont(size: 14))
                                .foregroundColor(theme.textColor.opacity(0.7))
                        }
                        .padding(.horizontal)
                    }
                    
                    // Gold Generation Info
                    if building.type == .goldmine {
                        VStack(spacing: 8) {
                            Text("Gold Generation")
                                .font(.appFont(size: 16, weight: .medium))
                                .foregroundColor(theme.textColor)
                            
                            HStack {
                                Image(systemName: "dollarsign.circle.fill")
                                    .foregroundColor(.yellow)
                                
                                Text("\(building.goldGenerationRate) gold per hour")
                                    .font(.appFont(size: 14))
                                    .foregroundColor(theme.textColor)
                                
                                Spacer()
                            }
                            
                            if building.canGenerateGold && building.state == .active {
                                Button("Collect Gold") {
                                    viewModel.collectGold(from: building)
                                }
                                .font(.appFont(size: 16, weight: .medium))
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(.yellow)
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                Spacer()
                
                // Action Buttons
                VStack(spacing: 12) {
                    if building.state == .destroyed {
                        Button("Repair Building") {
                            viewModel.repairBuilding(building)
                            dismiss()
                        }
                        .font(.appFont(size: 16, weight: .medium))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(theme.accentColor)
                        )
                    }
                    
                    if building.canUpgrade && building.state == .active {
                        Button("Upgrade (Lv.\(building.level + 1)) - \(building.upgradeCost) Gold") {
                            viewModel.upgradeBuilding(building)
                            dismiss()
                        }
                        .font(.appFont(size: 16, weight: .medium))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(viewModel.canAffordUpgrade(building) ? .green : .gray)
                        )
                        .disabled(!viewModel.canAffordUpgrade(building))
                    }
                    
                    if building.state != .destroyed {
                        Button("Destroy Building") {
                            viewModel.destroyBuilding(building)
                            dismiss()
                        }
                        .font(.appFont(size: 16, weight: .medium))
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(.red, lineWidth: 2)
                        )
                    }
                }
                .padding(.horizontal)
            }
            .padding()
            .navigationTitle("Building Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}
