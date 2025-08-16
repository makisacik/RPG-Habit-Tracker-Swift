import SwiftUI

struct BaseBuildingView: View {
    @ObservedObject var viewModel: BaseBuildingViewModel
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var localizationManager: LocalizationManager
    
    var body: some View {
        let theme = themeManager.activeTheme
        
        ZStack {
            // Background
            theme.backgroundColor.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                headerView(theme: theme)
                
                // Village View
                villageView(theme: theme)
                
                // Building Menu
                if viewModel.showingBuildingMenu {
                    buildingMenuView(theme: theme)
                }
            }
        }
        .sheet(isPresented: $viewModel.showingBuildingDetails) {
            if let building = viewModel.selectedBuilding {
                BuildingDetailView(
                    building: building,
                    viewModel: viewModel,
                    theme: theme
                )
            }
        }
        .onAppear {
            viewModel.loadBase()
        }
    }
    
    // MARK: - Header View
    
    private func headerView(theme: Theme) -> some View {
        VStack(spacing: 16) {
            // Village Title and Level
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(viewModel.base.villageName)
                        .font(.appFont(size: 24, weight: .bold))
                        .foregroundColor(theme.textColor)
                    
                    Text("Level \(viewModel.base.level) Village")
                        .font(.appFont(size: 14))
                        .foregroundColor(theme.textColor.opacity(0.7))
                }
                
                Spacer()
                
                // Gold Display
                HStack(spacing: 8) {
                    Image(systemName: "dollarsign.circle.fill")
                        .foregroundColor(.yellow)
                        .font(.title2)
                    
                    Text("\(viewModel.getAvailableGold())")
                        .font(.appFont(size: 20, weight: .bold))
                        .foregroundColor(theme.textColor)
                }
            }
            
            // Village Progress
            VStack(spacing: 8) {
                HStack {
                    Text("Village Progress")
                        .font(.appFont(size: 14, weight: .medium))
                        .foregroundColor(theme.textColor)
                    
                    Spacer()
                    
                    Text("\(Int(viewModel.getVillageProgress() * 100))%")
                        .font(.appFont(size: 14, weight: .bold))
                        .foregroundColor(theme.accentColor)
                }
                
                ProgressView(value: viewModel.getVillageProgress())
                    .progressViewStyle(LinearProgressViewStyle(tint: theme.accentColor))
                    .frame(height: 8)
            }
            
            // Village Stats
            let stats = viewModel.getVillageStats()
            HStack(spacing: 20) {
                StatItem(
                    icon: "building.2.fill",
                    value: "\(stats.active)",
                    label: "Active",
                    color: .green,
                    theme: theme
                )
                
                StatItem(
                    icon: "hammer.fill",
                    value: "\(stats.construction)",
                    label: "Building",
                    color: .orange,
                    theme: theme
                )
                
                StatItem(
                    icon: "xmark.circle.fill",
                    value: "\(stats.destroyed)",
                    label: "Destroyed",
                    color: .red,
                    theme: theme
                )
                
                StatItem(
                    icon: "dollarsign.circle.fill",
                    value: "\(stats.totalGold)",
                    label: "Gold/hr",
                    color: .yellow,
                    theme: theme
                )
                
                Spacer()
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }
    
    // MARK: - Village View
    
    private func villageView(theme: Theme) -> some View {
        GeometryReader { geometry in
            let screenSize = geometry.size
            let villageSize = VillageLayout.getVillageSize(for: screenSize)
            let fixedPositions = VillageLayout.getFixedPositions(for: screenSize)

            ZStack {
                // Village Background
                villageBackgroundView(theme: theme)
                    .frame(width: villageSize.width, height: villageSize.height)
                    .position(x: screenSize.width / 2, y: villageSize.height / 2)
                
                // Buildings
                ForEach(viewModel.base.buildings.sorted { $0.state.priority < $1.state.priority }) { building in
                    if let position = fixedPositions[building.type] {
                        VillageBuildingView(
                            building: building,
                            theme: theme
                        ) {
                            handleBuildingTap(building)
                        }
                        .position(position)
                    }
                }
            }
            .frame(width: screenSize.width, height: screenSize.height)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func villageBackgroundView(theme: Theme) -> some View {
        // Simple green background
        Color.green.opacity(0.3)
    }
    
    private func handleBuildingTap(_ building: Building) {
        if building.state == .destroyed {
            // Show building menu for destroyed buildings
            // Use the building type to find the correct position
            viewModel.selectedGridPosition = building.position
            viewModel.showingBuildingMenu = true
        } else {
            // Show building details for other states
            viewModel.selectBuilding(building)
        }
    }
    
    // MARK: - Building Menu View
    
    private func buildingMenuView(theme: Theme) -> some View {
        VStack(spacing: 20) {
            // Header
            VStack(spacing: 8) {
                Text("Construct Building")
                    .font(.appFont(size: 20, weight: .bold))
                    .foregroundColor(theme.textColor)
                
                Text("Choose a building type to construct")
                    .font(.appFont(size: 14))
                    .foregroundColor(theme.textColor.opacity(0.7))
            }
            
            // Get the building type at the selected position
            let buildingAtPosition = viewModel.getBuildingAtPosition(viewModel.selectedGridPosition)
            let buildingType = buildingAtPosition?.type
            
            if let type = buildingType {
                // Show only the specific building type
                VStack(spacing: 16) {
                    BuildingTypeCard(
                        type: type,
                        canAfford: viewModel.canAffordBuilding(type),
                        theme: theme
                    ) {
                        viewModel.buildStructure(type, at: viewModel.selectedGridPosition)
                        viewModel.showingBuildingMenu = false
                    }
                    
                    // Color Selection
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Building Color")
                            .font(.appFont(size: 16, weight: .medium))
                            .foregroundColor(theme.textColor)
                        
                        HStack(spacing: 16) {
                            ForEach(BuildingColor.allCases, id: \.self) { color in
                                Circle()
                                    .fill(color.color)
                                    .frame(width: 40, height: 40)
                                    .overlay(
                                        Circle()
                                            .stroke(viewModel.selectedBuildingColor == color ? theme.accentColor : Color.clear, lineWidth: 3)
                                    )
                                    .scaleEffect(viewModel.selectedBuildingColor == color ? 1.1 : 1.0)
                                    .animation(.easeInOut(duration: 0.2), value: viewModel.selectedBuildingColor)
                                    .onTapGesture {
                                        viewModel.selectedBuildingColor = color
                                    }
                            }
                        }
                    }
                }
            }
            
            // Cancel Button
            Button("Cancel") {
                viewModel.showingBuildingMenu = false
            }
            .font(.appFont(size: 16, weight: .medium))
            .foregroundColor(theme.textColor.opacity(0.7))
            .padding(.top, 8)
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(theme.primaryColor)
                .shadow(color: .black.opacity(0.3), radius: 15, x: 0, y: 8)
        )
        .padding(.horizontal, 20)
    }
}

// MARK: - Supporting Views

struct StatItem: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    let theme: Theme
    
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.title3)
            
            Text(value)
                .font(.appFont(size: 18, weight: .bold))
                .foregroundColor(theme.textColor)
            
            Text(label)
                .font(.appFont(size: 12))
                .foregroundColor(theme.textColor.opacity(0.7))
        }
    }
}

struct BuildingTypeCard: View {
    let type: BuildingType
    let canAfford: Bool
    let theme: Theme
    let action: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: type.iconName)
                .font(.system(size: 36))
                .foregroundColor(canAfford ? theme.accentColor : .gray)
            
            VStack(spacing: 4) {
                Text(type.displayName)
                    .font(.appFont(size: 16, weight: .medium))
                    .foregroundColor(theme.textColor)
                
                Text("\(type.baseCost) Gold")
                    .font(.appFont(size: 14))
                    .foregroundColor(canAfford ? theme.textColor.opacity(0.7) : .red)
            }
        }
        .frame(height: 100)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(canAfford ? theme.primaryColor : theme.primaryColor.opacity(0.5))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(canAfford ? theme.accentColor.opacity(0.3) : Color.clear, lineWidth: 2)
                )
        )
        .scaleEffect(canAfford ? 1.0 : 0.95)
        .animation(.easeInOut(duration: 0.2), value: canAfford)
        .onTapGesture {
            if canAfford {
                action()
            }
        }
    }
}
