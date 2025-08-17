import SwiftUI

// MARK: - Village Building View
struct VillageBuildingView: View {
    let building: Building
    let theme: Theme
    let onTap: () -> Void
    let customSize: CGSize?
    
    @State private var showTooltip = false
    @State private var hasAppeared = false
    
    // Computed properties for animations
    private var shouldAnimateConstruction: Bool {
        return hasAppeared && building.state == .construction
    }
    
    private var shouldAnimateReadyToComplete: Bool {
        return hasAppeared && building.state == .readyToComplete
    }
    
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
                .overlay(
                    // Ready to complete indicator
                    Group {
                        if building.state == .readyToComplete {
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.yellow, lineWidth: 3)
                                .scaleEffect(shouldAnimateReadyToComplete ? 1.1 : 1.0)
                                .opacity(shouldAnimateReadyToComplete ? 0.8 : 0.6)
                                .animation(
                                    shouldAnimateReadyToComplete ? .easeInOut(duration: 1.0).repeatForever(autoreverses: true) : .none,
                                    value: shouldAnimateReadyToComplete
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
            }
        }
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
    
    @State private var hasAppeared = false
    
    // Computed property for animation
    private var shouldAnimateConstruction: Bool {
        return hasAppeared && building.state == .construction
    }
    
    var body: some View {
        VStack(spacing: 4) {
            // Building Image
            Image(building.currentImageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 60, height: 60)
            
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
            }
        }
    }
}

// MARK: - Modern Bottom Sheet Building Detail View

struct BuildingDetailBottomSheet: View {
    let building: Building
    @ObservedObject var viewModel: BaseBuildingViewModel
    let theme: Theme
    @Environment(\.dismiss) private var dismiss
    
    @State private var isConstructButtonPressed = false
    @State private var isCompleteButtonPressed = false
    @State private var isUpgradeButtonPressed = false
    @State private var isDestroyButtonPressed = false
    @State private var isCollectButtonPressed = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Handle bar
            RoundedRectangle(cornerRadius: 2.5)
                .fill(Color.gray.opacity(0.3))
                .frame(width: 36, height: 5)
                .padding(.top, 8)
                .padding(.bottom, 16)
            
            // Content
            ScrollView {
                VStack(spacing: 24) {
                    // Building Header
                    buildingHeaderView
                    
                    // Building Info
                    buildingInfoSection
                    
                    // Action Buttons
                    actionButtonsSection
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(theme.primaryColor)
                .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: -10)
        )
        .frame(maxHeight: UIScreen.main.bounds.height * 0.7)
    }
    
    private var buildingHeaderView: some View {
        HStack(spacing: 16) {
            // Building Image
            Image(building.currentImageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 80, height: 80)
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(theme.secondaryColor.opacity(0.3))
                )
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(building.type.displayName)
                        .font(.appFont(size: 24, weight: .bold))
                        .foregroundColor(theme.textColor)
                    
                    if building.level > 1 {
                        Text("Lv.\(building.level)")
                            .font(.appFont(size: 14, weight: .bold))
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
                    .font(.appFont(size: 14))
                    .foregroundColor(theme.textColor.opacity(0.7))
                    .lineLimit(2)
                
                // State indicator
                HStack(spacing: 6) {
                    Circle()
                        .fill(building.state.color)
                        .frame(width: 8, height: 8)
                    
                    Text(building.state.displayName)
                        .font(.appFont(size: 14, weight: .medium))
                        .foregroundColor(building.state.color)
                }
            }
            
            Spacer()
        }
    }
    
    private var buildingInfoSection: some View {
        VStack(spacing: 16) {
            // Construction Progress
            if building.state == .construction {
                VStack(spacing: 12) {
                    HStack {
                        Text("Construction Progress")
                            .font(.appFont(size: 16, weight: .medium))
                            .foregroundColor(theme.textColor)
                        
                        Spacer()
                        
                        Text("\(Int(building.constructionProgress * 100))%")
                            .font(.appFont(size: 16, weight: .bold))
                            .foregroundColor(theme.accentColor)
                    }
                    
                    ProgressView(value: building.constructionProgress)
                        .progressViewStyle(LinearProgressViewStyle(tint: theme.accentColor))
                        .frame(height: 8)
                        .background(
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.gray.opacity(0.2))
                        )
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(theme.secondaryColor.opacity(0.2))
                )
            }
            
            // Gold Generation Info
            if building.type == .goldmine && building.state == .active {
                VStack(spacing: 12) {
                    HStack {
                        Image(systemName: "dollarsign.circle.fill")
                            .foregroundColor(.yellow)
                            .font(.system(size: 20))
                        
                        Text("Gold Generation")
                            .font(.appFont(size: 16, weight: .medium))
                            .foregroundColor(theme.textColor)
                        
                        Spacer()
                        
                        Text("\(building.goldGenerationRate) gold/hr")
                            .font(.appFont(size: 16, weight: .bold))
                            .foregroundColor(.yellow)
                    }
                    
                    if building.canGenerateGold {
                        Button("Collect Gold") {
                            viewModel.collectGold(from: building)
                        }
                        .font(.appFont(size: 16, weight: .medium))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            Image(theme.buttonPrimary)
                                .resizable(
                                    capInsets: EdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20),
                                    resizingMode: .stretch
                                )
                                .opacity(isCollectButtonPressed ? 0.7 : 1.0)
                        )
                        .buttonStyle(PlainButtonStyle())
                        .simultaneousGesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { _ in isCollectButtonPressed = true }
                                .onEnded { _ in isCollectButtonPressed = false }
                        )
                    }
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(theme.secondaryColor.opacity(0.2))
                )
            }
        }
    }
    
    private var actionButtonsSection: some View {
        VStack(spacing: 12) {
            if building.state == .destroyed {
                // Show construction info for destroyed buildings
                VStack(spacing: 16) {
                    // Construction Info
                    VStack(spacing: 12) {
                        HStack {
                            Image(systemName: "hammer.fill")
                                .foregroundColor(theme.accentColor)
                                .font(.system(size: 18))
                            
                            Text("Construction Cost")
                                .font(.appFont(size: 16, weight: .medium))
                                .foregroundColor(theme.textColor)
                            
                            Spacer()
                            
                            Text("\(building.type.baseCost) Gold")
                                .font(.appFont(size: 16, weight: .bold))
                                .foregroundColor(.yellow)
                        }
                        
                        HStack {
                            Image(systemName: "clock.fill")
                                .foregroundColor(theme.accentColor)
                                .font(.system(size: 18))
                            
                            Text("Construction Time")
                                .font(.appFont(size: 16, weight: .medium))
                                .foregroundColor(theme.textColor)
                            
                            Spacer()
                            
                            Text(formatTime(building.type.constructionTime))
                                .font(.appFont(size: 16, weight: .bold))
                                .foregroundColor(theme.textColor)
                        }
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(theme.secondaryColor.opacity(0.2))
                    )
                    
                    // Construct Button
                    Button("Construct Building") {
                        let screenSize = UIScreen.main.bounds.size
                        let fixedPositions = VillageLayout.getFixedPositions(for: screenSize)
                        if let fixedPosition = fixedPositions[building.type] {
                            viewModel.buildStructure(building.type, at: fixedPosition)
                        }
                        dismiss()
                    }
                    .font(.appFont(size: 16, weight: .medium))
                    .foregroundColor(viewModel.canAffordBuilding(building.type) ? .white : .gray)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        Image(theme.buttonPrimary)
                            .resizable(
                                capInsets: EdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20),
                                resizingMode: .stretch
                            )
                            .opacity(
                                viewModel.canAffordBuilding(building.type)
                                ? (isConstructButtonPressed ? 0.7 : 1.0)
                                : 0.5
                            )
                    )
                    .buttonStyle(PlainButtonStyle())
                    .simultaneousGesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { _ in
                                if viewModel.canAffordBuilding(building.type) {
                                    isConstructButtonPressed = true
                                }
                            }
                            .onEnded { _ in isConstructButtonPressed = false }
                    )
                    .disabled(!viewModel.canAffordBuilding(building.type))
                }
            }
            
            if building.state == .readyToComplete {
                Button("Complete Construction") {
                    viewModel.completeConstruction(for: building)
                    dismiss()
                }
                .font(.appFont(size: 16, weight: .medium))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    Image(theme.buttonPrimary)
                        .resizable(
                            capInsets: EdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20),
                            resizingMode: .stretch
                        )
                        .opacity(isCompleteButtonPressed ? 0.7 : 1.0)
                )
                .buttonStyle(PlainButtonStyle())
                .simultaneousGesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { _ in isCompleteButtonPressed = true }
                        .onEnded { _ in isCompleteButtonPressed = false }
                )
            }
            
            if building.canUpgrade && building.state == .active {
                Button("Upgrade (Lv.\(building.level + 1)) - \(building.upgradeCost) Gold") {
                    viewModel.upgradeBuilding(building)
                    dismiss()
                }
                .font(.appFont(size: 16, weight: .medium))
                .foregroundColor(viewModel.canAffordUpgrade(building) ? .white : .gray)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    Image(theme.buttonPrimary)
                        .resizable(
                            capInsets: EdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20),
                            resizingMode: .stretch
                        )
                        .opacity(
                            viewModel.canAffordUpgrade(building)
                            ? (isUpgradeButtonPressed ? 0.7 : 1.0)
                            : 0.5
                        )
                )
                .buttonStyle(PlainButtonStyle())
                .simultaneousGesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { _ in
                            if viewModel.canAffordUpgrade(building) {
                                isUpgradeButtonPressed = true
                            }
                        }
                        .onEnded { _ in isUpgradeButtonPressed = false }
                )
                .disabled(!viewModel.canAffordUpgrade(building))
            }
            
            if building.state != .destroyed && building.state != .construction {
                Button("Destroy Building") {
                    viewModel.destroyBuilding(building)
                    dismiss()
                }
                .font(.appFont(size: 16, weight: .medium))
                .foregroundColor(.red)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    Image(theme.buttonPrimary)
                        .resizable(
                            capInsets: EdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20),
                            resizingMode: .stretch
                        )
                        .opacity(isDestroyButtonPressed ? 0.7 : 1.0)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(.red, lineWidth: 2)
                )
                .buttonStyle(PlainButtonStyle())
                .simultaneousGesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { _ in isDestroyButtonPressed = true }
                        .onEnded { _ in isDestroyButtonPressed = false }
                )
            }
        }
    }
    
    private func formatTime(_ timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        
        if minutes > 0 {
            return "\(minutes)m \(seconds)s"
        } else {
            return "\(seconds)s"
        }
    }
}

// MARK: - Building Detail View (Legacy - keeping for compatibility)

struct BuildingDetailView: View {
    let building: Building
    @ObservedObject var viewModel: BaseBuildingViewModel
    let theme: Theme
    @Environment(\.dismiss) private var dismiss
    
    @State private var isCollectButtonPressed = false
    @State private var isRepairButtonPressed = false
    @State private var isUpgradeButtonPressed = false
    @State private var isDestroyButtonPressed = false
    
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
                        
                        // Show booster info for active buildings
                        if building.state == .active {
                            BoosterInfoView(building: building)
                        }
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
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(
                                    Image(theme.buttonPrimary)
                                        .resizable(
                                            capInsets: EdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20),
                                            resizingMode: .stretch
                                        )
                                        .opacity(isCollectButtonPressed ? 0.7 : 1.0)
                                )
                                .buttonStyle(PlainButtonStyle())
                                .simultaneousGesture(
                                    DragGesture(minimumDistance: 0)
                                        .onChanged { _ in isCollectButtonPressed = true }
                                        .onEnded { _ in isCollectButtonPressed = false }
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
                            Image(theme.buttonPrimary)
                                .resizable(
                                    capInsets: EdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20),
                                    resizingMode: .stretch
                                )
                                .opacity(isRepairButtonPressed ? 0.7 : 1.0)
                        )
                        .buttonStyle(PlainButtonStyle())
                        .simultaneousGesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { _ in isRepairButtonPressed = true }
                                .onEnded { _ in isRepairButtonPressed = false }
                        )
                    }
                    
                    if building.canUpgrade && building.state == .active {
                        Button("Upgrade (Lv.\(building.level + 1)) - \(building.upgradeCost) Gold") {
                            viewModel.upgradeBuilding(building)
                            dismiss()
                        }
                        .font(.appFont(size: 16, weight: .medium))
                        .foregroundColor(viewModel.canAffordUpgrade(building) ? .white : .gray)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            Image(theme.buttonPrimary)
                                .resizable(
                                    capInsets: EdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20),
                                    resizingMode: .stretch
                                )
                                .opacity(
                                    viewModel.canAffordUpgrade(building)
                                    ? (isUpgradeButtonPressed ? 0.7 : 1.0)
                                    : 0.5
                                )
                        )
                        .buttonStyle(PlainButtonStyle())
                        .simultaneousGesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { _ in
                                    if viewModel.canAffordUpgrade(building) {
                                        isUpgradeButtonPressed = true
                                    }
                                }
                                .onEnded { _ in isUpgradeButtonPressed = false }
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
                            Image(theme.buttonPrimary)
                                .resizable(
                                    capInsets: EdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20),
                                    resizingMode: .stretch
                                )
                                .opacity(isDestroyButtonPressed ? 0.7 : 1.0)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(.red, lineWidth: 2)
                        )
                        .buttonStyle(PlainButtonStyle())
                        .simultaneousGesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { _ in isDestroyButtonPressed = true }
                                .onEnded { _ in isDestroyButtonPressed = false }
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
