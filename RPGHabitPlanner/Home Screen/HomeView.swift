import SwiftUI
import WidgetKit
import StoreKit

// MARK: - Notification Names
extension Notification.Name {
    static let showQuestCreation = Notification.Name("showQuestCreation")
}

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

        ZStack {
            TabView(selection: $selectedTab) {
                homeTabView(theme: theme).tag(HomeTab.home)
                questsTabView(theme: theme).tag(HomeTab.tracking)
                characterTabView(theme: theme).tag(HomeTab.character)
                progressTabView(theme: theme).tag(HomeTab.log)
            }
            .background(theme.backgroundColor.ignoresSafeArea())
            .toolbar(.hidden, for: .tabBar) // Hide system Tab Bar

            // Custom tab bar anchored to bottom
            VStack(spacing: 0) {
                Spacer()
                CustomTabBar(
                    selected: $selectedTab,
                    theme: theme
                ) { handleCreateQuestTap() }
            }
            .ignoresSafeArea(.container, edges: .bottom)
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
        // Move quest creation to top level - full screen presentation
        .fullScreenCover(isPresented: $shouldNavigateToQuestCreation) {
            NavigationStack {
                QuestCreationView(
                    viewModel: QuestCreationViewModel(questDataService: questDataService)
                )
                .environmentObject(themeManager)
                .environmentObject(premiumManager)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .showQuestCreation)) { _ in
            shouldNavigateToQuestCreation = true
        }

        .onAppear {
            // Record streak activity when home view appears
            viewModel.streakManager.recordActivity()

            // Show tutorial for first-time users
            if !hasSeenHomeTutorial {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    showTutorial = true
                }
            }

            // Check for damage on app launch
            viewModel.checkForDamageOnAppLaunch()
        }
        .overlay(
            Group {
                if showTutorial {
                    TutorialView(isPresented: $showTutorial)
                        .environmentObject(themeManager)
                        .environmentObject(localizationManager)
                        .onDisappear {
                            // Mark tutorial as seen when dismissed
                            hasSeenHomeTutorial = true
                        }
                        .zIndex(100)
                }
            }
        )
    }

    // MARK: - Tab View Builders

    @ViewBuilder
    private func homeTabView(theme: Theme) -> some View {
        NavigationStack {
            ZStack {
                // Set the background color for the entire home tab
                theme.backgroundColor
                    .ignoresSafeArea()

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
                            .environmentObject(localizationManager)

                        recentAchievementsSection
                        quickActionsSection(isCompletedQuestsPresented: $isCompletedQuestsPresented)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 10)
                    .padding(.bottom, 100) // Add bottom padding to prevent content from going under tab bar
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

                // Reward and level-up overlays
                if let quest = completedQuest, showReward {
                    RewardView(isVisible: $showReward, quest: quest)
                        .id("reward-\(quest.id)")
                        .zIndex(50)
                }

                LevelUpView(isVisible: $showLevelUp, level: levelUpLevel)
                    .zIndex(50)

                // Reward Toast Container
                RewardToastContainerView()
                    .zIndex(70)

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

                                // Damage Summary Overlay
                if viewModel.showDamageSummary, let damageData = viewModel.damageSummaryData {
                    Color.black.opacity(0.5)
                        .ignoresSafeArea()
                        .zIndex(80)
                        .transition(.opacity)
                        .animation(.easeInOut(duration: 0.3), value: viewModel.showDamageSummary)

                    DamageSummaryView(
                        damageData: damageData
                    ) {
                        viewModel.dismissDamageSummary()
                    }
                    .environmentObject(themeManager)
                    .zIndex(81)
                    .transition(.scale.combined(with: .opacity))
                    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: viewModel.showDamageSummary)
                }
            }
            .navigationTitle("adventure_hub".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(content: homeToolbarContent)
            .navigationDestination(isPresented: $isCompletedQuestsPresented) {
                CompletedQuestsView(
                    viewModel: CompletedQuestsViewModel(questDataService: questDataService)
                )
                .environmentObject(themeManager)
            }
            .navigationDestination(isPresented: $goToSettings) {
                SettingsView()
                    .environmentObject(themeManager)
                    .environmentObject(localizationManager)
            }
            .navigationDestination(isPresented: $showFocusTimer) {
                TimerView(userManager: viewModel.userManager, damageHandler: damageHandler)
                    .environmentObject(themeManager)
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
            .sheet(isPresented: $showPaywall) {
                PaywallView()
                    .environmentObject(premiumManager)
            }
        }
    }

    @ViewBuilder
    private func questsTabView(theme: Theme) -> some View {
        NavigationStack {
            ZStack {
                // Set the background color for the quests tab
                theme.backgroundColor
                    .ignoresSafeArea()

                QuestsView(
                    viewModel: QuestsViewModel(
                        questDataService: questDataService,
                        userManager: viewModel.userManager
                    ),
                    questDataService: questDataService
                )
                .environmentObject(themeManager)
            }
        }
    }

    @ViewBuilder
    private func characterTabView(theme: Theme) -> some View {
        NavigationStack {
            ZStack {
                // Set the background color for the character tab
                theme.backgroundColor
                    .ignoresSafeArea()

                if let user = viewModel.user {
                    CharacterView(homeViewModel: viewModel)
                        .environmentObject(localizationManager)
                } else {
                    Text("loading_character".localized)
                        .foregroundColor(theme.textColor)
                        .onAppear { viewModel.fetchUserData() }
            }
            }
        }
    }

    @ViewBuilder
    private func progressTabView(theme: Theme) -> some View {
        NavigationStack {
            ZStack {
                // Set the background color for the progress tab
                theme.backgroundColor
                    .ignoresSafeArea()

                AnalyticsView()
                    .environmentObject(themeManager)
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

    private func requestAppReview() {
        if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
            SKStoreReviewController.requestReview(in: scene)
        }
    }
}
