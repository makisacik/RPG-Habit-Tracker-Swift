import SwiftUI
import WidgetKit

struct HomeView: View {
    @ObservedObject var viewModel: HomeViewModel
    let questDataService: QuestDataServiceProtocol
    @EnvironmentObject var themeManager: ThemeManager
    @State private var isCharacterDetailsPresented: Bool = false
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        let theme = themeManager.activeTheme
        
        TabView {
            NavigationStack {
                ZStack {
                    theme.backgroundColor
                        .ignoresSafeArea()

                    VStack {
                        PlayerBaseView()
                            .navigationTitle("Your Base")
                            .navigationBarTitleDisplayMode(.large)
                        Spacer()
                        if let user = viewModel.user {
                            CharacterOverlayView(user: user)
                        }
                    }
                    .padding(.bottom, 20)
                }
            }
            .tabItem {
                Label("Base", systemImage: "house.fill")
            }
            .tag(HomeTab.base)
            
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
                        .padding(.bottom, 20)
                    }
                    .font(.appFont(size: 16))
                    .navigationTitle("Quest Journal")
                    .navigationBarTitleDisplayMode(.large)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button(action: {
                                isCharacterDetailsPresented.toggle()
                            }) {
                                HStack {
                                    Image(theme.paperSimple)
                                        .resizable()
                                        .frame(width: 40, height: 40)
                                        .colorMultiply(Color(red: 0.92, green: 0.80, blue: 0.55))
                                    Text("Level \(viewModel.user?.level ?? 1)")
                                        .font(.appFont(size: 16, weight: .black))
                                        .foregroundColor(theme.textColor)
                                }
                            }
                        }

                        ToolbarItem(placement: .navigationBarTrailing) {
                            NavigationLink(destination: QuestCreationView(
                                viewModel: QuestCreationViewModel(questDataService: questDataService)
                            )) {
                                Image(theme.paperSimple)
                                            .resizable()
                                            .frame(width: 40, height: 40)
                                            .colorMultiply(Color(red: 0.92, green: 0.80, blue: 0.55))
                            }
                        }
                    }
                    .sheet(isPresented: $isCharacterDetailsPresented) {
                        if let user = viewModel.user {
                            CharacterDetailsView(user: user)
                        }
                    }
                    .onAppear {
                        viewModel.fetchUserData()
                        WidgetCenter.shared.reloadAllTimelines()
                        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
                            print("📋 Pending Notifications:")
                            for req in requests {
                                print("🆔 ID:", req.identifier)
                                print("📌 Title:", req.content.title)
                                print("📝 Body:", req.content.body)
                                print("⏰ Trigger:", req.trigger ?? "No trigger")
                                print("------")
                            }
                        }
                    }
                }
            }
            .tabItem {
                Label("Tracking", systemImage: "list.bullet.clipboard.fill")
            }
            .tag(HomeTab.tracking)

            NavigationStack {
                CompletedQuestsView(
                    viewModel: CompletedQuestsViewModel(
                        questDataService: questDataService
                    )
                )
                .navigationTitle("Completed Quests")
                .navigationBarTitleDisplayMode(.large)
            }
            .tabItem {
                Label("Completed", systemImage: "checkmark.seal.fill")
            }
            .tag(HomeTab.completed)
        }
        .accentColor(.red)
    }
}

enum HomeTab: Hashable {
    case tracking
    case completed
    case base
}
