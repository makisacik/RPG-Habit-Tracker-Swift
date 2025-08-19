import SwiftUI
import WidgetKit

struct HomeView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var localizationManager: LocalizationManager
    @EnvironmentObject var premiumManager: PremiumManager
    @Environment(\.colorScheme) private var colorScheme
    @ObservedObject var viewModel: HomeViewModel
    @State private var isCompletedQuestsPresented = false
    @State var showAchievements = false
    @StateObject private var damageHandler = DamageHandler()
    @State var selectedTab: HomeTab = .home
    @State private var goToSettings = false
    @State private var showPaywall = false
    @State private var shouldNavigateToQuestCreation = false
    @State private var currentQuestCount = 0
    @State private var showFocusTimer = false
    @StateObject private var healthManager = HealthManager.shared
    @StateObject private var questFailureHandler = QuestFailureHandler.shared

    let questDataService: QuestDataServiceProtocol

    var body: some View {
        let theme = themeManager.activeTheme

        TabView(selection: $selectedTab) {
            // MARK: Home
            NavigationStack {
                ZStack {
                    theme.backgroundColor.ignoresSafeArea()
                    ScrollView {
                        VStack(spacing: 20) {
                            heroSection(healthManager: healthManager)
                            StreakDisplayView(streakManager: viewModel.streakManager)
                                .environmentObject(themeManager)
                            quickStatsSection(isCompletedQuestsPresented: $isCompletedQuestsPresented)
                            MyQuestsSection(
                                viewModel: MyQuestsViewModel(questDataService: questDataService, userManager: viewModel.userManager),
                                selectedTab: $selectedTab,
                                questDataService: questDataService
                            )
                            .environmentObject(themeManager)
                            recentAchievementsSection
                            quickActionsSection(isCompletedQuestsPresented: $isCompletedQuestsPresented)
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 10)
                    }

                    // Quest Failure Notification
                    if questFailureHandler.showFailureNotification {
                        VStack {
                            QuestFailureNotificationView(
                                message: questFailureHandler.failureMessage,
                                isVisible: $questFailureHandler.showFailureNotification
                            )
                            .padding(.horizontal)
                            Spacer()
                        }
                        .zIndex(30)
                    }
                }
                .navigationTitle(String.adventureHub.localized)
                .navigationBarTitleDisplayMode(.large)

                .toolbar(content: homeToolbarContent)

                .navigationDestination(isPresented: $goToSettings) {
                    SettingsView()
                        .environmentObject(themeManager)
                        .environmentObject(LocalizationManager.shared)
                }
                .sheet(isPresented: $isCompletedQuestsPresented) {
                    NavigationStack {
                        CompletedQuestsView(
                            viewModel: CompletedQuestsViewModel(questDataService: questDataService)
                        )
                        .navigationTitle(String.completedQuests.localized)
                        .navigationBarTitleDisplayMode(.inline)
                    }
                }
                .onAppear {
                    // apply theme once on load
                    themeManager.applyTheme(using: colorScheme)
                    viewModel.fetchUserData()
                    viewModel.fetchDashboardData()
                    fetchCurrentQuestCount()
                    WidgetCenter.shared.reloadAllTimelines()

                    // Record streak activity when app is opened
                    viewModel.streakManager.recordActivity()

                    // Check for failed quests
                    questFailureHandler.performDailyQuestCheck()
                }
                .onReceive(NotificationCenter.default.publisher(for: .questCreated)) { _ in
                    fetchCurrentQuestCount()
                }
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                    viewModel.fetchDashboardData()
                }
                // keep theme in sync with system changes
                .onChange(of: colorScheme) { newScheme in
                    themeManager.applyTheme(using: newScheme)
                }
                // re-apply when user switches between .light/.dark/.system
                .onChange(of: themeManager.currentTheme) { _ in
                    themeManager.applyTheme(using: colorScheme)
                }
                .onChange(of: premiumManager.isPremium) { isPremium in
                    if isPremium {
                        showPaywall = false
                    }
                }
                .sheet(isPresented: $showPaywall) {
                    PaywallView()
                        .environmentObject(premiumManager)
                }
                .sheet(isPresented: $showFocusTimer) {
                    NavigationStack {
                        TimerView(userManager: viewModel.userManager, damageHandler: damageHandler)
                            .environmentObject(themeManager)
                            .navigationTitle(String.focusTimer.localized)
                            .navigationBarTitleDisplayMode(.inline)
                    }
                }
            }
            .tabItem { Label(String.home.localized, systemImage: "house.fill") }
            .tag(HomeTab.home)

            // MARK: Quests
            NavigationStack {
                ZStack {
                    theme.backgroundColor.ignoresSafeArea()
                    VStack(spacing: 0) {
                        QuestTrackingView(
                            viewModel: QuestTrackingViewModel(
                                questDataService: questDataService,
                                userManager: viewModel.userManager
                            )
                        )
                    }
                    .font(.appFont(size: 16))
                    .navigationTitle(String.questJournal.localized)
                    .navigationBarTitleDisplayMode(.inline)

                    .toolbar(content: questsToolbarContent)

                    // Push to Quest Creation (not modal)
                    .navigationDestination(isPresented: $shouldNavigateToQuestCreation) {
                        QuestCreationView(
                            viewModel: QuestCreationViewModel(questDataService: questDataService)
                        )
                    }
                }
            }
            .tabItem { Label(String.quests.localized, systemImage: "list.bullet.clipboard.fill") }
            .tag(HomeTab.tracking)

            // MARK: Character
            NavigationStack {
                if let user = viewModel.user {
                    CharacterView(user: user)
                } else {
                    Text(String.loadingCharacter.localized)
                        .foregroundColor(theme.textColor)
                        .onAppear { viewModel.fetchUserData() }
                }
            }
            .tabItem { Label(String.character.localized, systemImage: "person.crop.circle.fill") }
            .tag(HomeTab.character)

            // MARK: Base
            NavigationStack {
                ZStack {
                    theme.backgroundColor.ignoresSafeArea()
                    BaseBuildingView(
                        viewModel: BaseBuildingViewModel(
                            baseService: BaseBuildingService(context: PersistenceController.shared.container.viewContext),
                            userManager: viewModel.userManager
                        )
                    )
                    .environmentObject(themeManager)
                    .environmentObject(localizationManager)
                }
            }
            .tabItem { Label("Base", systemImage: "building.2.fill") }
            .tag(HomeTab.base)

            // MARK: Calendar
            NavigationStack {
                CalendarView(viewModel: CalendarViewModel(questDataService: questDataService, userManager: viewModel.userManager))
                    .environmentObject(themeManager)
            }
            .tabItem { Label(String.calendar.localized, systemImage: "calendar") }
            .tag(HomeTab.calendar)
        }
        .accentColor(.red)
        // Achievements presentation (used by cards/stat tiles)
        .sheet(isPresented: $showAchievements) {
            NavigationStack {
                AchievementView()
                    .environmentObject(themeManager)
                    .navigationTitle(String.achievements.localized)
                    .navigationBarTitleDisplayMode(.inline)
            }
        }
    }

    private func fetchCurrentQuestCount() {
        questDataService.fetchAllQuests { quests, _ in
            DispatchQueue.main.async {
                self.currentQuestCount = quests.count
            }
        }
    }

    func handleCreateQuestTap() {
        if premiumManager.canCreateQuest(currentQuestCount: currentQuestCount) {
            shouldNavigateToQuestCreation = true
        } else {
            showPaywall = true
        }
    }
    
    @ToolbarContentBuilder
    private func homeToolbarContent() -> some ToolbarContent {
        let theme = themeManager.activeTheme
        
        ToolbarItem(placement: .primaryAction) {
            Button { selectedTab = .calendar } label: {
                Image(systemName: "calendar")
                    .font(.title2)
                    .foregroundColor(theme.textColor)
            }
        }

        ToolbarItem(placement: .cancellationAction) {
            Menu {
                Button {
                    showFocusTimer = true
                } label: {
                    Label(String.focusTimer.localized, systemImage: "timer")
                }
                Button { goToSettings = true } label: {
                    Label(String.settings.localized, systemImage: "gearshape.fill")
                }
                Button { /* TODO: About */ } label: {
                    Label(String.about.localized, systemImage: "info.circle.fill")
                }
            } label: {
                Image(systemName: "line.3.horizontal")
                    .font(.title2)
                    .foregroundColor(theme.textColor)
            }
            .menuActionDismissBehavior(.automatic)
            .menuOrder(.fixed)
        }
    }
    
    @ToolbarContentBuilder
    private func questsToolbarContent() -> some ToolbarContent {
        let theme = themeManager.activeTheme
        
        ToolbarItem(placement: .destructiveAction) {
            Button(action: {
                handleCreateQuestTap()
            }) {
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
                    .foregroundColor(theme.textColor)
            }
        }

        ToolbarItem(placement: .confirmationAction) {
            if !premiumManager.isPremium {
                QuestLimitIndicatorView(currentQuestCount: currentQuestCount)
            }
        }
    }
}
