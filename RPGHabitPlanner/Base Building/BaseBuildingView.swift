import SwiftUI

struct BaseBuildingView: View {
    @ObservedObject var viewModel: BaseBuildingViewModel
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var localizationManager: LocalizationManager
    @State private var showingConstructionAnimation = false
    @State private var animatingBuilding: Building?
    @State private var showVillageInfo = false

    var body: some View {
        let theme = themeManager.activeTheme

        ZStack {
            // Background
            theme.backgroundColor.ignoresSafeArea()

            VStack(spacing: 0) {
                // Minimal Header with just title and info button
                minimalHeaderView(theme: theme)

                // Village View - now takes full remaining space
                villageView(theme: theme)
            }

            // Village Info Overlay
            if showVillageInfo {
                villageInfoOverlay(theme: theme)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }

            // Building Menu
            if viewModel.showingBuildingMenu {
                buildingMenuView(theme: theme)
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
        .overlay(
            // Construction completion animation overlay
            Group {
                if showingConstructionAnimation, let building = animatingBuilding {
                    ConstructionCompletionAnimation(building: building) {
                        // Animation completed
                    }
                    .allowsHitTesting(false)
                }
            }
        )
        .onAppear {
            viewModel.loadBase()
            // Ensure both towers exist
            ensureBothTowersExist()
        }
    }

    // MARK: - Minimal Header View

    private func minimalHeaderView(theme: Theme) -> some View {
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

            // Village Info Button
            Button(action: {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    showVillageInfo.toggle()
                }
            }) {
                Image(systemName: showVillageInfo ? "info.circle.fill" : "info.circle")
                    .font(.title2)
                    .foregroundColor(showVillageInfo ? theme.accentColor : theme.textColor.opacity(0.7))
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 12)
    }

    // MARK: - Village Info Overlay

    private func villageInfoOverlay(theme: Theme) -> some View {
        VStack(spacing: 16) {
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
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(theme.primaryColor)
                .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
        )
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
                // Village Background - now fills the entire available space
                villageBackgroundView(theme: theme)
                    .frame(width: screenSize.width, height: screenSize.height)

                // Buildings - render castle last so it appears on top
                ForEach(viewModel.base.buildings.sorted { building1, building2 in
                    // First sort by state priority
                    if building1.state.priority != building2.state.priority {
                        return building1.state.priority < building2.state.priority
                    }
                    // Then sort by building type to put castle last
                    if building1.type == .castle {
                        return false // Castle goes last
                    }
                    if building2.type == .castle {
                        return true // Other buildings go before castle
                    }
                    return building1.type.rawValue < building2.type.rawValue
                }) { building in
                    if let position = fixedPositions[building.type] {
                        VillageBuildingView(
                            building: building,
                            theme: theme,
                            customSize: VillageLayout.getBuildingSize(for: building.type, in: screenSize)
                        ) {
                            handleBuildingTap(building)
                        }
                        .position(position)
                        .animation(.none, value: position) // Disable animation for position changes
                        .animation(.none, value: building.state) // Disable animation for state changes
                        .animation(.none, value: building.constructionProgress) // Disable animation for progress changes
                        .animation(.none, value: building.currentImageName) // Disable animation for image changes
                    }
                }
            }
        }
    }

    private func villageBackgroundView(theme: Theme) -> some View {
        // Village background asset
        Image("village_background")
            .resizable()
            .aspectRatio(contentMode: .fill)
            .clipped()
    }

    private func handleBuildingTap(_ building: Building) {
        if building.state == .destroyed {
            // Show building menu for destroyed buildings
            // Use the fixed position instead of stored position
            if let fixedPosition = VillageLayout.getFixedPositions(for: UIScreen.main.bounds.size)[building.type] {
                viewModel.selectedGridPosition = fixedPosition
            }
            viewModel.showingBuildingMenu = true
        } else if building.state == .readyToComplete {
            // Complete construction with animation
            completeConstructionWithAnimation(for: building)
        } else {
            // Show building details for other states
            viewModel.selectBuilding(building)
        }
    }

    private func completeConstructionWithAnimation(for building: Building) {
        // Show construction completion animation
        animatingBuilding = building
        showingConstructionAnimation = true

        // Trigger the completion after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            viewModel.completeConstruction(for: building)
            showingConstructionAnimation = false
            animatingBuilding = nil
        }
    }

    private func ensureBothTowersExist() {
        let screenSize = UIScreen.main.bounds.size
        let fixedPositions = VillageLayout.getFixedPositions(for: screenSize)

        // Check if tower2 exists
        let hasTower2 = viewModel.base.buildings.contains { $0.type == .tower2 }

        if !hasTower2 {
            // Add tower2 if it doesn't exist
            if let tower2Position = fixedPositions[.tower2] {
                let tower2 = Building(
                    type: .tower2,
                    state: .destroyed,
                    position: tower2Position
                )
                viewModel.base.addBuilding(tower2)
            }
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
