import SwiftUI
import WidgetKit

struct HomeView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.colorScheme) private var colorScheme
    @ObservedObject var viewModel: HomeViewModel
    @State private var isCharacterDetailsPresented: Bool = false
    @State private var isCompletedQuestsPresented: Bool = false
    @State var selectedTab: HomeTab = .home
    let questDataService: QuestDataServiceProtocol

    var body: some View {
        let theme = themeManager.activeTheme
        
        TabView(selection: $selectedTab) {
            NavigationStack {
                ZStack {
                    theme.backgroundColor
                        .ignoresSafeArea()
                    
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
                .sheet(isPresented: $isCompletedQuestsPresented) {
                    NavigationStack {
                        CompletedQuestsView(
                            viewModel: CompletedQuestsViewModel(
                                questDataService: questDataService
                            )
                        )
                        .navigationTitle("Completed Quests")
                        .navigationBarTitleDisplayMode(.inline)
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
}
