import SwiftUI
import WidgetKit

struct HomeView: View {
    @ObservedObject var viewModel: HomeViewModel
    let questDataService: QuestDataServiceProtocol

    @State private var isCharacterDetailsPresented: Bool = false

    var body: some View {
        TabView {
            NavigationStack {
                ZStack {
                    Image("pattern_grid_paper")
                        .resizable(resizingMode: .tile)
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
            .onAppear {
                NotificationManager.shared.requestPermission()
            }

            
            NavigationStack {
                ZStack {
                    Image("pattern_grid_paper")
                        .resizable(resizingMode: .tile)
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
                                    Image("banner_hanging")
                                        .resizable()
                                        .frame(width: 40, height: 40)
                                    Text("Level \(viewModel.user?.level ?? 1)")
                                        .font(.appFont(size: 16, weight: .black))
                                        .foregroundColor(.black)
                                }
                            }
                        }

                        ToolbarItem(placement: .navigationBarTrailing) {
                            NavigationLink(destination: QuestCreationView(
                                viewModel: QuestCreationViewModel(questDataService: questDataService)
                            )) {
                                Image("cursorSword_bronze")
                                    .resizable()
                                    .frame(width: 40, height: 40)
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
