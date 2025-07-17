import SwiftUI
import WidgetKit

struct HomeView: View {
    @ObservedObject var viewModel: HomeViewModel
    let questDataService: QuestDataServiceProtocol

    @State private var selectedTab: HomeTab = .tracking
    @State private var isCharacterDetailsPresented: Bool = false

    var body: some View {
        NavigationStack {
            ZStack {
                // Background pattern
                Image("pattern_grid_paper")
                    .resizable(resizingMode: .tile)
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Content area with panel style
                    ZStack {
                        switch selectedTab {
                        case .tracking:
                            QuestTrackingView(
                                viewModel: QuestTrackingViewModel(
                                    questDataService: questDataService,
                                    userManager: viewModel.userManager
                                )
                            )
                        case .completed:
                            CompletedQuestsView(
                                viewModel: CompletedQuestsViewModel(
                                    questDataService: questDataService
                                )
                            )
                        }
                    }
                    .padding()
                    .background(
                        Image("panel_brown")
                            .resizable(capInsets: EdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20), resizingMode: .stretch)
                            .cornerRadius(12)
                    )
                    .padding([.horizontal, .top])

                    Spacer()

                    // Custom TabBar pinned to bottom
                    customTabBar
                        .padding(.bottom, 5)
                }
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
                                    .font(.headline)
                                    .foregroundColor(.primary)
                            }
                        }
                    }

                    ToolbarItem(placement: .navigationBarTrailing) {
                        NavigationLink(destination: QuestCreationView(
                            viewModel: QuestCreationViewModel(questDataService: questDataService)
                        )) {
                            Image("button_brown")
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
    }

    private var customTabBar: some View {
        HStack {
            Button(action: { selectedTab = .tracking }) {
                VStack(spacing: 2) {
                    Image("panel_brown_arrows")
                        .resizable()
                        .frame(width: 100, height: 40)
                        .overlay(Text("Tracking")
                            .font(.caption)
                            .foregroundColor(.black)
                        )
                }
            }

            Button(action: { selectedTab = .completed }) {
                VStack(spacing: 2) {
                    Image("panel_grey_bolts_red")
                        .resizable()
                        .frame(width: 100, height: 40)
                        .overlay(Text("Completed")
                            .font(.caption)
                            .foregroundColor(.black)
                        )
                }
            }
        }
        .frame(maxWidth: .infinity)
        .background(Color.clear)
    }
}

enum HomeTab: Hashable {
    case tracking
    case completed
}
