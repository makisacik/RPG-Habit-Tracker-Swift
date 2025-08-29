import SwiftUI
import WidgetKit
import StoreKit

struct HomeView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var localizationManager: LocalizationManager
    @EnvironmentObject var premiumManager: PremiumManager
    @Environment(\.colorScheme) private var colorScheme
    @ObservedObject var viewModel: HomeViewModel

    // ✅ Hold MyQuests VM here so we can listen for completions
    @StateObject private var myQuestsVM: MyQuestsViewModel

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

    // ✅ Overlays live at Home level
    @State private var showReward = false
    @State private var completedQuest: Quest?
    @State private var showLevelUp = false
    @State private var levelUpLevel: Int = 0

    // Tutorial state
    @AppStorage("hasSeenHomeTutorial") private var hasSeenHomeTutorial = false
    @State private var showTutorial = false

    let questDataService: QuestDataServiceProtocol

    // ✅ Custom init to build StateObject with dependencies
    init(viewModel: HomeViewModel, questDataService: QuestDataServiceProtocol) {
        self.viewModel = viewModel
        self.questDataService = questDataService
        _myQuestsVM = StateObject(wrappedValue: MyQuestsViewModel(
            questDataService: questDataService,
            userManager: viewModel.userManager
        ))
    }

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

                            // ✅ Use the shared VM instance
                            MyQuestsSection(
                                viewModel: myQuestsVM,
                                selectedTab: $selectedTab,
                                questDataService: questDataService
                            )
                            .environmentObject(themeManager)

                            StreakDisplayView(streakManager: viewModel.streakManager)
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

                    // ✅ Reward + Level overlays (now shown on Home)
                    if let quest = completedQuest, showReward {
                        RewardView(isVisible: $showReward, quest: quest)
                            .id("reward-\(quest.id)")
                            .zIndex(50)
                    }
                    LevelUpView(isVisible: $showLevelUp, level: levelUpLevel)
                        .zIndex(50)

                    // Quest completion is finished check popup (when completion is toggled)
                    if myQuestsVM.showCompletionIsFinishedCheck, let quest = myQuestsVM.questToCheckCompletion {
                        QuestCompletionIsFinishedCheckPopup(
                            quest: quest,
                            onConfirm: {
                                myQuestsVM.handleCompletionIsFinishedCheck(questId: quest.id)
                            },
                            onCancel: {
                                myQuestsVM.showCompletionIsFinishedCheck = false
                                myQuestsVM.questToCheckCompletion = nil
                            }
                        )
                        .zIndex(60)
                    }

                    // Quest finish confirmation popup (when finished button is tapped)
                    if myQuestsVM.showFinishConfirmation, let quest = myQuestsVM.questToFinish {
                        QuestFinishConfirmationPopup(
                            quest: quest,
                            onConfirm: {
                                myQuestsVM.markQuestAsFinished(questId: quest.id)
                                myQuestsVM.showFinishConfirmation = false
                                myQuestsVM.questToFinish = nil
                            },
                            onCancel: {
                                myQuestsVM.showFinishConfirmation = false
                                myQuestsVM.questToFinish = nil
                            }
                        )
                        .zIndex(60)
                    }

                    // Reward Toast Container
                    RewardToastContainerView()
                        .zIndex(70)

                    // Tutorial overlay
                    if showTutorial {
                        TutorialView(isPresented: $showTutorial)
                            .zIndex(100)
                    }
                }
                .navigationTitle("adventure_hub".localized)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar(content: homeToolbarContent)

                .navigationDestination(isPresented: $goToSettings) {
                    SettingsView()
                        .environmentObject(themeManager)
                        .environmentObject(LocalizationManager.shared)
                }
                .navigationDestination(isPresented: $shouldNavigateToQuestCreation) {
                    QuestCreationView(
                        viewModel: QuestCreationViewModel(questDataService: questDataService)
                    )
                    .environmentObject(themeManager)
                    .environmentObject(premiumManager)
                }
                .sheet(isPresented: $isCompletedQuestsPresented) {
                    NavigationStack {
                        CompletedQuestsView(
                            viewModel: CompletedQuestsViewModel(questDataService: questDataService)
                        )
                        .navigationTitle("completed_quests".localized)
                        .navigationBarTitleDisplayMode(.inline)
                    }
                }
                .onAppear {
                    themeManager.applyTheme(using: colorScheme)

                    // Use a small delay to prevent flashing when returning from navigation
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        viewModel.fetchUserData()
                        viewModel.fetchDashboardData()
                        fetchCurrentQuestCount()
                        WidgetCenter.shared.reloadAllTimelines()

                        // Record streak activity when app is opened
                        viewModel.streakManager.recordActivity()

                        // Check for failed quests
                        questFailureHandler.performDailyQuestCheck()

                        // Show tutorial if user hasn't seen it before
                        if !hasSeenHomeTutorial {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                showTutorial = true
                            }
                        }
                    }
                }
                .onReceive(NotificationCenter.default.publisher(for: .questCreated)) { _ in
                    fetchCurrentQuestCount()
                }
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                    viewModel.fetchDashboardData()
                }
                .onChange(of: colorScheme) { newScheme in
                    themeManager.applyTheme(using: newScheme)
                }
                .onChange(of: themeManager.currentTheme) { _ in
                    themeManager.applyTheme(using: colorScheme)
                }
                .onChange(of: premiumManager.isPremium) { isPremium in
                    if isPremium { showPaywall = false }
                }
                .onChange(of: showTutorial) { visible in
                    if !visible && !hasSeenHomeTutorial {
                        hasSeenHomeTutorial = true
                    }
                }
                .sheet(isPresented: $showPaywall) {
                    PaywallView().environmentObject(premiumManager)
                }
                .sheet(isPresented: $showFocusTimer) {
                    NavigationStack {
                        TimerView(userManager: viewModel.userManager, damageHandler: damageHandler)
                            .environmentObject(themeManager)
                            .navigationTitle("focus_timer".localized)
                            .navigationBarTitleDisplayMode(.inline)
                    }
                }

                // ✅ Listen to MyQuestsViewModel signals → show overlays
                .onChange(of: myQuestsVM.questCompleted) { completed in
                    if completed && !showReward {
                        if let quest = myQuestsVM.lastCompletedQuest {
                            completedQuest = quest
                        } else if
                            let id = myQuestsVM.lastCompletedQuestId,
                            let quest = myQuestsVM.allQuests.first(where: { $0.id == id }) {
                            completedQuest = quest
                        }
                        showReward = (completedQuest != nil)
                        // Reset flag so we don't re-trigger when list refreshes
                        myQuestsVM.questCompleted = false
                    }
                }
                .onChange(of: showReward) { visible in
                    if !visible, myQuestsVM.didLevelUp, let lvl = myQuestsVM.newLevel {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            levelUpLevel = Int(lvl)
                            showLevelUp = true
                        }
                    }
                }
            }
                            .tabItem { Label("home".localized, systemImage: "house.fill") }
            .tag(HomeTab.home)

            // MARK: Quests
            NavigationStack {
                QuestsView(
                    viewModel: QuestsViewModel(
                        questDataService: questDataService,
                        userManager: viewModel.userManager
                    ),
                    questDataService: questDataService
                )
                .environmentObject(themeManager)
                .toolbar(content: questsToolbarContent)
                .navigationDestination(isPresented: $shouldNavigateToQuestCreation) {
                    QuestCreationView(
                        viewModel: QuestCreationViewModel(questDataService: questDataService)
                    )
                    .environmentObject(themeManager)
                    .environmentObject(premiumManager)
                }
            }
                            .tabItem { Label("quests".localized, systemImage: "list.bullet.clipboard.fill") }
            .tag(HomeTab.tracking)


            // MARK: Character
            NavigationStack {
                if let user = viewModel.user {
                    CharacterView(homeViewModel: viewModel)
                } else {
                    Text("loading_character".localized)
                        .foregroundColor(theme.textColor)
                        .onAppear { viewModel.fetchUserData() }
                }
            }
                            .tabItem { Label("character".localized, systemImage: "person.crop.circle.fill") }
            .tag(HomeTab.character)


            // MARK: Progress
            NavigationStack {
                AnalyticsView()
                    .environmentObject(themeManager)
            }
                            .tabItem { Label("progress".localized, systemImage: "chart.bar.xaxis") }
            .tag(HomeTab.progress)
        }
        .accentColor(.red)
        .sheet(isPresented: $showAchievements) {
            NavigationStack {
                AchievementView()
                    .environmentObject(themeManager)
                    .navigationTitle("achievements".localized)
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
        // Always allow access to quest creation form
        shouldNavigateToQuestCreation = true
    }

    @ToolbarContentBuilder
    private func homeToolbarContent() -> some ToolbarContent {
        let theme = themeManager.activeTheme

        ToolbarItem(placement: .cancellationAction) {
            Menu {
                Button { goToSettings = true } label: {
                    Label("settings".localized, systemImage: "gearshape.fill")
                }
                Button { requestAppReview() } label: {
                    Label("add_a_review".localized, systemImage: "star.fill")
                }
            } label: {
                Image(systemName: "line.3.horizontal")
                    .font(.title2)
                    .foregroundColor(theme.accentColor)
            }
            .menuOrder(.fixed)
        }

        ToolbarItem(placement: .primaryAction) {
            if !premiumManager.isPremium {
                Button(action: { showPaywall = true }) {
                    Image(systemName: "crown.fill")
                        .font(.title2)
                        .foregroundColor(theme.accentColor)
                }
            }
        }
    }

    @ToolbarContentBuilder
    private func questsToolbarContent() -> some ToolbarContent {
        let theme = themeManager.activeTheme

        ToolbarItem(placement: .destructiveAction) {
            Button(action: { handleCreateQuestTap() }) {
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
                    .foregroundColor(theme.textColor)
            }
        }
    }
    
    private func requestAppReview() {
        if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
            SKStoreReviewController.requestReview(in: scene)
        }
    }
}
