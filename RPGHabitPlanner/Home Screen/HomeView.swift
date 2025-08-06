import SwiftUI
import WidgetKit

struct HomeView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.colorScheme) private var colorScheme
    @ObservedObject var viewModel: HomeViewModel
    @State private var isCharacterDetailsPresented: Bool = false
    @State private var selectedTab: HomeTab = .home
    let questDataService: QuestDataServiceProtocol

    var body: some View {
        let theme = themeManager.activeTheme
        
        TabView(selection: $selectedTab) {
            // Home Dashboard Tab
            NavigationStack {
                ZStack {
                    theme.backgroundColor
                        .ignoresSafeArea()
                    
                    ScrollView {
                        VStack(spacing: 20) {
                            // Hero Section with Character
                            heroSection
                            
                            // Quick Stats Cards
                            quickStatsSection
                            
                            // Active Quests Preview
                            activeQuestsSection
                            
                            // Recent Achievements
                            recentAchievementsSection
                            
                            // Quick Actions
                            quickActionsSection
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 10)
                    }
                }
                .navigationTitle("Adventure Hub")
                .navigationBarTitleDisplayMode(.large)
                .navigationBarItems(trailing:
                    Button(action: {
                        isCharacterDetailsPresented = true
                    }) {
                        Image(systemName: "person.circle.fill")
                            .font(.title2)
                            .foregroundColor(theme.textColor)
                    }
                )
                .sheet(isPresented: $isCharacterDetailsPresented) {
                    if let user = viewModel.user {
                        CharacterDetailsView(user: user)
                    }
                }
                .onAppear {
                    viewModel.fetchUserData()
                    viewModel.fetchDashboardData()
                    WidgetCenter.shared.reloadAllTimelines()
                }
            }
            .tabItem {
                Label("Home", systemImage: "house.fill")
            }
            .tag(HomeTab.home)

            // Quest Tracking Tab
            NavigationStack {
                ZStack {
                    theme.backgroundColor
                        .ignoresSafeArea()

                    VStack(spacing: 0) {
                        QuestTrackingView(
                            viewModel: QuestTrackingViewModel(
                                questDataService: questDataService,
                                userManager: viewModel.userManager
                            )
                        )
                    }
                    .font(.appFont(size: 16))
                    .navigationTitle("Quest Journal")
                    .navigationBarTitleDisplayMode(.inline)
                    .navigationBarItems(trailing:
                        NavigationLink(destination: QuestCreationView(
                            viewModel: QuestCreationViewModel(questDataService: questDataService)
                        )) {
                            Image(theme.paperSimple)
                                .resizable()
                                .frame(width: 40, height: 40)
                                .colorMultiply(Color(red: 0.92, green: 0.80, blue: 0.55))
                        }
                    )
                }
            }
            .tabItem {
                Label("Quests", systemImage: "list.bullet.clipboard.fill")
            }
            .tag(HomeTab.tracking)

            // Completed Tab
            NavigationStack {
                CompletedQuestsView(
                    viewModel: CompletedQuestsViewModel(
                        questDataService: questDataService
                    )
                )
                .navigationTitle("Completed Quests")
                .navigationBarTitleDisplayMode(.inline)
            }
            .tabItem {
                Label("Completed", systemImage: "checkmark.seal.fill")
            }
            .tag(HomeTab.completed)

            // Character Tab
            NavigationStack {
                if let user = viewModel.user {
                    CharacterView(user: user)
                } else {
                    Text("Loading character...")
                        .foregroundColor(theme.textColor)
                        .onAppear {
                            viewModel.fetchUserData()
                        }
                }
            }
            .tabItem {
                Label("Character", systemImage: "person.crop.circle.fill")
            }
            .tag(HomeTab.character)

            // Achievements Tab
            NavigationStack {
                AchievementView()
                    .environmentObject(themeManager)
            }
            .tabItem {
                Label("Achievements", systemImage: "trophy.fill")
            }
            .tag(HomeTab.achievements)
        }
        .accentColor(.red)
    }
    
    // MARK: - Home Dashboard Sections
    
    private var heroSection: some View {
        let theme = themeManager.activeTheme
        
        return VStack(spacing: 16) {
            if let user = viewModel.user {
                HStack(spacing: 16) {
                    // Character Avatar
                    ZStack {
                        Circle()
                            .fill(theme.primaryColor)
                            .frame(width: 80, height: 80)
                            .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                        
                        if let characterClass = CharacterClass(rawValue: user.characterClass ?? "knight") {
                            Image(characterClass.iconName)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 60, height: 60)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(user.nickname ?? "Adventurer")
                            .font(.appFont(size: 24, weight: .black))
                            .foregroundColor(theme.textColor)
                        
                        if let characterClass = CharacterClass(rawValue: user.characterClass ?? "") {
                            Text(characterClass.displayName)
                                .font(.appFont(size: 16))
                                .foregroundColor(theme.textColor.opacity(0.8))
                        }
                        
                        HStack {
                            Text("Level \(user.level)")
                                .font(.appFont(size: 18, weight: .bold))
                                .foregroundColor(theme.textColor)
                            
                            Spacer()
                            
                            Text("\(user.exp)/100 XP")
                                .font(.appFont(size: 14))
                                .foregroundColor(theme.textColor.opacity(0.7))
                        }
                        
                        // Experience Bar
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(theme.backgroundColor.opacity(0.3))
                                .frame(height: 12)
                            
                            let expRatio = min(CGFloat(user.exp) / 100.0, 1.0)
                            RoundedRectangle(cornerRadius: 6)
                                .fill(
                                    LinearGradient(
                                        colors: [Color.green, Color.green.opacity(0.7)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: 120 * expRatio, height: 12)
                                .animation(.easeInOut(duration: 0.5), value: user.exp)
                        }
                    }
                    
                    Spacer()
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(theme.primaryColor)
                        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                )
            } else {
                // Loading state
                HStack {
                    ProgressView()
                        .scaleEffect(1.2)
                    Text("Loading character...")
                        .font(.appFont(size: 16))
                        .foregroundColor(theme.textColor)
                }
                .frame(height: 120)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(theme.primaryColor)
                        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                )
            }
        }
    }
    
    private var quickStatsSection: some View {
        let theme = themeManager.activeTheme
        
        return LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 12) {
            StatCard(
                icon: "list.bullet.clipboard",
                title: "Active",
                value: "\(viewModel.activeQuestsCount)",
                color: .blue,
                theme: theme
            )
            
            StatCard(
                icon: "checkmark.seal.fill",
                title: "Completed",
                value: "\(viewModel.completedQuestsCount)",
                color: .green,
                theme: theme
            )
            
            StatCard(
                icon: "trophy.fill",
                title: "Achievements",
                value: "\(viewModel.achievementsCount)",
                color: .orange,
                theme: theme
            )
        }
    }
    
    private var activeQuestsSection: some View {
        let theme = themeManager.activeTheme
        
        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Active Quests")
                    .font(.appFont(size: 20, weight: .bold))
                    .foregroundColor(theme.textColor)
                
                Spacer()
                
                Button("View All") {
                    selectedTab = .tracking
                }
                .font(.appFont(size: 14, weight: .medium))
                .foregroundColor(.blue)
            }
            
            if !viewModel.recentActiveQuests.isEmpty {
                VStack(spacing: 8) {
                    ForEach(viewModel.recentActiveQuests.prefix(3), id: \.id) { quest in
                        QuestPreviewCard(quest: quest, theme: theme)
                    }
                }
            } else {
                VStack(spacing: 8) {
                    Image(systemName: "list.bullet.clipboard")
                        .font(.system(size: 32))
                        .foregroundColor(theme.textColor.opacity(0.5))
                    
                    Text("No active quests")
                        .font(.appFont(size: 16))
                        .foregroundColor(theme.textColor.opacity(0.7))
                    
                    NavigationLink(destination: QuestCreationView(
                        viewModel: QuestCreationViewModel(questDataService: questDataService)
                    )) {
                        Text("Create Quest")
                            .font(.appFont(size: 14, weight: .medium))
                            .foregroundColor(.blue)
                    }
                    .font(.appFont(size: 14, weight: .medium))
                    .foregroundColor(.blue)
                }
                .frame(height: 100)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(theme.primaryColor.opacity(0.5))
                )
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(theme.primaryColor)
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
    }
    
    private var recentAchievementsSection: some View {
        let theme = themeManager.activeTheme
        
        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Recent Achievements")
                    .font(.appFont(size: 20, weight: .bold))
                    .foregroundColor(theme.textColor)
                
                Spacer()
                
                Button("View All") {
                    selectedTab = .achievements
                }
                .font(.appFont(size: 14, weight: .medium))
                .foregroundColor(.blue)
            }
            
            if !viewModel.recentAchievements.isEmpty {
                VStack(spacing: 8) {
                    ForEach(viewModel.recentAchievements.prefix(2), id: \.id) { achievement in
                        AchievementPreviewCard(achievement: achievement, theme: theme)
                    }
                }
            } else {
                VStack(spacing: 8) {
                    Image(systemName: "trophy")
                        .font(.system(size: 32))
                        .foregroundColor(theme.textColor.opacity(0.5))
                    
                    Text("No achievements yet")
                        .font(.appFont(size: 16))
                        .foregroundColor(theme.textColor.opacity(0.7))
                    
                    Text("Complete quests to earn achievements!")
                        .font(.appFont(size: 14))
                        .foregroundColor(theme.textColor.opacity(0.5))
                        .multilineTextAlignment(.center)
                }
                .frame(height: 100)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(theme.primaryColor.opacity(0.5))
                )
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(theme.primaryColor)
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
    }
    
    private var quickActionsSection: some View {
        let theme = themeManager.activeTheme
        
        return VStack(alignment: .leading, spacing: 12) {
            Text("Quick Actions")
                .font(.appFont(size: 20, weight: .bold))
                .foregroundColor(theme.textColor)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                NavigationLink(destination: QuestCreationView(
                    viewModel: QuestCreationViewModel(questDataService: questDataService)
                )) {
                    QuickActionCard(
                        icon: "plus.circle.fill",
                        title: "New Quest",
                        subtitle: "Create a new adventure",
                        color: .green,
                        theme: theme
                    ) {
                        // Action handled by NavigationLink
                    }
                }
                .buttonStyle(PlainButtonStyle())
                
                QuickActionCard(
                    icon: "person.crop.circle.fill",
                    title: "Character",
                    subtitle: "View your stats",
                    color: .blue,
                    theme: theme
                ) {
                    selectedTab = .character
                }
                
                QuickActionCard(
                    icon: "checkmark.seal.fill",
                    title: "Completed",
                    subtitle: "View completed quests",
                    color: .orange,
                    theme: theme
                ) {
                    selectedTab = .completed
                }
                
                QuickActionCard(
                    icon: "trophy.fill",
                    title: "Achievements",
                    subtitle: "View your trophies",
                    color: .purple,
                    theme: theme
                ) {
                    selectedTab = .achievements
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(theme.primaryColor)
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
    }
}

// MARK: - Supporting Views

struct StatCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    let theme: Theme
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
            
            Text(value)
                .font(.appFont(size: 24, weight: .bold))
                .foregroundColor(theme.textColor)
            
            Text(title)
                .font(.appFont(size: 12))
                .foregroundColor(theme.textColor.opacity(0.7))
        }
        .frame(height: 80)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(theme.primaryColor)
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        )
    }
}

struct QuestPreviewCard: View {
    let quest: Quest
    let theme: Theme
    
    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(quest.title)
                    .font(.appFont(size: 16, weight: .medium))
                    .foregroundColor(theme.textColor)
                    .lineLimit(1)
                
                let completedTasks = quest.tasks.filter { $0.isCompleted }.count
                Text("\(completedTasks)/\(quest.tasks.count) tasks")
                    .font(.appFont(size: 12))
                    .foregroundColor(theme.textColor.opacity(0.7))
            }
            
            Spacer()
            
            // Progress indicator
            ZStack {
                Circle()
                    .stroke(theme.backgroundColor.opacity(0.3), lineWidth: 3)
                    .frame(width: 24, height: 24)
                
                let completedTasks = quest.tasks.filter { $0.isCompleted }.count
                let progress = quest.tasks.isEmpty ? 0 : Double(completedTasks) / Double(quest.tasks.count)
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(Color.green, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                    .frame(width: 24, height: 24)
                    .rotationEffect(.degrees(-90))
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(theme.primaryColor.opacity(0.5))
        )
    }
}

struct AchievementPreviewCard: View {
    let achievement: AchievementDefinition
    let theme: Theme
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: achievement.iconName)
                .font(.system(size: 20))
                .foregroundColor(.orange)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(achievement.title)
                    .font(.appFont(size: 14, weight: .medium))
                    .foregroundColor(theme.textColor)
                    .lineLimit(1)
                
                Text(achievement.description)
                    .font(.appFont(size: 12))
                    .foregroundColor(theme.textColor.opacity(0.7))
                    .lineLimit(2)
            }
            
            Spacer()
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(theme.primaryColor.opacity(0.5))
        )
    }
}

struct QuickActionCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let theme: Theme
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 28))
                    .foregroundColor(color)
                
                Text(title)
                    .font(.appFont(size: 14, weight: .medium))
                    .foregroundColor(theme.textColor)
                
                Text(subtitle)
                    .font(.appFont(size: 12))
                    .foregroundColor(theme.textColor.opacity(0.7))
                    .multilineTextAlignment(.center)
            }
            .frame(height: 80)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(theme.primaryColor)
                    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

enum HomeTab: Hashable {
    case home
    case tracking
    case completed
    case character
    case achievements
}
