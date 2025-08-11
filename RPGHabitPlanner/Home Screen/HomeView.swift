import SwiftUI
import WidgetKit

struct HomeView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var localizationManager: LocalizationManager
    @Environment(\.colorScheme) private var colorScheme
    @ObservedObject var viewModel: HomeViewModel
    @State private var isCharacterDetailsPresented = false
    @State private var isCompletedQuestsPresented = false
    @State var showAchievements = false
    @StateObject private var damageHandler = DamageHandler()
    @State var selectedTab: HomeTab = .home
    @State private var goToSettings = false

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
                            heroSection
                            quickStatsSection(isCompletedQuestsPresented: $isCompletedQuestsPresented)
                            activeQuestsSection
                            recentAchievementsSection
                            quickActionsSection(isCompletedQuestsPresented: $isCompletedQuestsPresented)
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 10)
                    }
                }
                .navigationTitle(String.adventureHub.localized)
                .navigationBarTitleDisplayMode(.large)
                .toolbar {
                    // LEFT: Dropdown menu (native Menu)
                    ToolbarItem(placement: .topBarLeading) {
                        Menu {
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

                    // RIGHT: Calendar shortcut (kept from your code)
                    ToolbarItem(placement: .topBarTrailing) {
                        Button { selectedTab = .calendar } label: {
                            Image(systemName: "calendar")
                                .font(.title2)
                                .foregroundColor(theme.textColor)
                        }
                    }
                }
                // Push to Settings (not modal)
                .navigationDestination(isPresented: $goToSettings) {
                    SettingsView()
                        .environmentObject(themeManager)
                        .environmentObject(LocalizationManager.shared)
                }
                .sheet(isPresented: $isCharacterDetailsPresented) {
                    if let user = viewModel.user {
                        CharacterDetailsView(user: user)
                    }
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
                    WidgetCenter.shared.reloadAllTimelines()
                }
                // keep theme in sync with system changes
                .onChange(of: colorScheme) { newScheme in
                    themeManager.applyTheme(using: newScheme)
                }
                // re-apply when user switches between .light/.dark/.system
                .onChange(of: themeManager.currentTheme) { _ in
                    themeManager.applyTheme(using: colorScheme)
                }
            }
            .tabItem { Label("Home", systemImage: "house.fill") }
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
                    .navigationTitle("Quest Journal")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            NavigationLink(
                                destination: QuestCreationView(
                                    viewModel: QuestCreationViewModel(questDataService: questDataService)
                                )
                            ) {
                                Image(theme.paperSimple)
                                    .resizable()
                                    .frame(width: 40, height: 40)
                                    .colorMultiply(Color(red: 0.92, green: 0.80, blue: 0.55))
                            }
                        }
                    }
                }
            }
            .tabItem { Label("Quests", systemImage: "list.bullet.clipboard.fill") }
            .tag(HomeTab.tracking)

            // MARK: Character
            NavigationStack {
                if let user = viewModel.user {
                    CharacterView(user: user)
                } else {
                    Text("Loading character...")
                        .foregroundColor(theme.textColor)
                        .onAppear { viewModel.fetchUserData() }
                }
            }
            .tabItem { Label("Character", systemImage: "person.crop.circle.fill") }
            .tag(HomeTab.character)

            // MARK: Focus Timer
            NavigationStack {
                TimerView(userManager: viewModel.userManager, damageHandler: damageHandler)
                    .environmentObject(themeManager)
            }
            .tabItem { Label("Focus Timer", systemImage: "timer") }
            .tag(HomeTab.focusTimer)

            // MARK: Calendar
            NavigationStack {
                CalendarView(viewModel: CalendarViewModel(questDataService: questDataService))
                    .environmentObject(themeManager)
            }
            .tabItem { Label("Calendar", systemImage: "calendar") }
            .tag(HomeTab.calendar)
        }
        .accentColor(.red)
        // Achievements presentation (used by cards/stat tiles)
        .sheet(isPresented: $showAchievements) {
            NavigationStack {
                AchievementView()
                    .environmentObject(themeManager)
                    .navigationTitle("Achievements")
                    .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
}
