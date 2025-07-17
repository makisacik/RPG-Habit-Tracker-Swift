import SwiftUI

struct EditQuestView: View {
    @Binding var quest: Quest
    @State private var localQuest: Quest

    var onSave: (Quest) -> Void
    var onCancel: () -> Void

    init(quest: Binding<Quest>, onSave: @escaping (Quest) -> Void, onCancel: @escaping () -> Void) {
        self._quest = quest
        self._localQuest = State(initialValue: quest.wrappedValue)
        self.onSave = onSave
        self.onCancel = onCancel
    }

    var body: some View {
        NavigationView {
            ZStack {
                Image("pattern_grid_paper")
                    .resizable(resizingMode: .tile)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        Image("banner_hanging")
                            .resizable()
                            .frame(height: 60)
                            .overlay(
                                Text("Edit Quest")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.black)
                            )
                            .padding(.bottom, 10)

                        InputField(title: "Title", text: $localQuest.title)
                        InputField(title: "Description", text: $localQuest.info)

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Difficulty")
                                .font(.headline)

                            Picker("Difficulty", selection: $localQuest.difficulty) {
                                ForEach(1...5, id: \.self) {
                                    Text("\($0)").tag($0)
                                }
                            }
                            .pickerStyle(.segmented)
                        }
                        .padding()
                        .background(
                            Image("panel_brown_dark")
                                .resizable(capInsets: EdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20), resizingMode: .stretch)
                        )
                        .cornerRadius(10)

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Due Date")
                                .font(.headline)

                            DatePicker("", selection: $localQuest.dueDate, displayedComponents: [.date])
                                .labelsHidden()
                                .padding()
                                .background(
                                    Image("panel_brown_dark")
                                        .resizable(capInsets: EdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20), resizingMode: .stretch)
                                )
                                .cornerRadius(10)
                        }

                        ToggleCard(label: "Main Quest", isOn: $localQuest.isMainQuest)
                        ToggleCard(label: "Active", isOn: $localQuest.isActive)

                        HStack {
                            Button(action: { onCancel() }) {
                                Text("Cancel")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding(.horizontal)
                                    .frame(height: 44)
                                    .background(
                                        Image("button_brown")
                                            .resizable()
                                            .frame(height: 44)
                                    )
                                    .cornerRadius(8)
                            }

                            Spacer()

                            Button(action: {
                                quest = localQuest
                                onSave(localQuest)
                            }) {
                                Text("Save")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding(.horizontal)
                                    .frame(height: 44)
                                    .background(
                                        Image("button_brown")
                                            .resizable()
                                            .frame(height: 44)
                                    )
                                    .cornerRadius(8)
                            }
                        }
                        .padding(.top, 10)
                    }
                    .padding()
                    .background(
                        Image("panel_brown")
                            .resizable(capInsets: EdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20), resizingMode: .stretch)
                    )
                    .cornerRadius(16)
                    .padding()
                }
            }
        }
    }
}

// MARK: - Reusable Views

struct InputField: View {
    var title: String
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.headline)
            TextField(title, text: $text)
                .autocorrectionDisabled()
                .padding()
                .background(
                    Image("panel_brown_dark")
                        .resizable(capInsets: EdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20), resizingMode: .stretch)
                )
                .cornerRadius(10)
        }
    }
}
