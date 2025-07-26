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
                Image("pattern_grid_paper")
                    .resizable(resizingMode: .tile)
                    .ignoresSafeArea()

                VStack(spacing: 0) {
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

                    customTabBar
                        .padding(.bottom, 5)
                }
                .font(.appFont(size: 16))

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
                                    .foregroundColor(.primary)
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
    }

    private var customTabBar: some View {
        HStack {
            Button(action: { selectedTab = .tracking }) {
                VStack(spacing: 2) {
                    Image("panel_grey_bolts_red")
                        .resizable()
                        .frame(width: 120, height: 40)
                        .overlay(Text("Tracking")
                            .font(.appFont(size: 16, weight: .black))
                            .foregroundColor(.white)
                        )
                }
            }

            Button(action: { selectedTab = .completed }) {
                VStack(spacing: 2) {
                    Image("panel_grey_bolts_red")
                        .resizable()
                        .frame(width: 120, height: 40)
                        .overlay(Text("Completed")
                            .font(.appFont(size: 16, weight: .black))
                            .foregroundColor(.white)
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
