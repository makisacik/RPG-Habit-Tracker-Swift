import SwiftUI
import WidgetKit

struct HomeView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.colorScheme) private var colorScheme
    @ObservedObject var viewModel: HomeViewModel
    @State private var isCharacterDetailsPresented: Bool = false
    let questDataService: QuestDataServiceProtocol

    var body: some View {
        let theme = themeManager.activeTheme
        
        TabView {
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

            NavigationStack {
                if let user = viewModel.user {
                    CharacterView(user: user)
                } else {
                    Text("Loading character...")
                        .foregroundColor(.gray)
                        .onAppear {
                            viewModel.fetchUserData()
                        }
                }
            }
            .tabItem {
                Label("Character", systemImage: "person.crop.circle.fill")
            }
            .tag(HomeTab.character)
        }
        .accentColor(.red)
    }
}

enum HomeTab: Hashable {
    case tracking
    case completed
    case character
}
