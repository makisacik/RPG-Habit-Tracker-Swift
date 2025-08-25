import SwiftUI

// MARK: - Gamified Input Components

struct GamifiedInputField: View {
    @EnvironmentObject var themeManager: ThemeManager
    let title: String
    @Binding var text: String
    let icon: String
    let placeholder: String

    var body: some View {
        let theme = themeManager.activeTheme
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.yellow)
                Text(title)
                    .font(.appFont(size: 14, weight: .black))
                    .foregroundColor(theme.textColor)
            }

            TextField("", text: $text, prompt: Text(placeholder).foregroundColor(theme.textColor.opacity(0.6)))
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .font(.appFont(size: 16))
                .foregroundColor(theme.textColor)
                .accentColor(.yellow)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(theme.primaryColor.opacity(0.3))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.yellow.opacity(0.3), lineWidth: 1)
                        )
                )
        }
    }
}

struct GamifiedToggleCard: View {
    @EnvironmentObject var themeManager: ThemeManager
    let label: String
    @Binding var isOn: Bool

    var body: some View {
        let theme = themeManager.activeTheme
        HStack {
            Text(label)
                .font(.appFont(size: 16, weight: .black))
                .foregroundColor(theme.textColor)

            Spacer()

            Toggle("", isOn: $isOn)
                .tint(.yellow)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(theme.secondaryColor)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.yellow.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

struct GamifiedDatePicker: View {
    @EnvironmentObject var themeManager: ThemeManager
    let title: String
    @Binding var date: Date

    var body: some View {
        let theme = themeManager.activeTheme
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "calendar.circle.fill")
                    .foregroundColor(.yellow)
                Text(title)
                    .font(.appFont(size: 14, weight: .black))
                    .foregroundColor(theme.textColor)
            }

            DatePicker("", selection: $date, displayedComponents: [.date])
                .labelsHidden()
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(theme.primaryColor.opacity(0.3))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.yellow.opacity(0.3), lineWidth: 1)
                        )
                )
        }
    }
}

struct GamifiedTasksSection: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Binding var tasks: [String]
    let onEditTapped: () -> Void
    @State private var isButtonPressed = false

    var body: some View {
        let theme = themeManager.activeTheme
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "list.bullet.clipboard")
                    .foregroundColor(.yellow)
                                    Text(String(localized: "quest_tasks"))
                    .font(.appFont(size: 14, weight: .black))
                    .foregroundColor(theme.textColor)

                Spacer()

                Text("\(tasks.filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }.count)")
                    .font(.appFont(size: 12, weight: .black))
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.yellow)
                    )
            }

            Button(action: {
                isButtonPressed = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    isButtonPressed = false
                    onEditTapped()
                }
            }) {
                HStack {
                    Text(String(localized: "manage_tasks"))
                        .font(.appFont(size: 16, weight: .black))
                        .foregroundColor(theme.textColor)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(theme.textColor.opacity(0.6))
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(theme.secondaryColor)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.yellow.opacity(0.3), lineWidth: 1)
                        )
                        .opacity(isButtonPressed ? 0.7 : 1.0)
                )
                .scaleEffect(isButtonPressed ? 0.95 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isButtonPressed)
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}

struct GamifiedDifficultySection: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Binding var difficulty: Int

    var body: some View {
        let theme = themeManager.activeTheme
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "star.circle.fill")
                    .foregroundColor(.yellow)
                                    Text(String(localized: "quest_difficulty"))
                    .font(.appFont(size: 14, weight: .black))
                    .foregroundColor(theme.textColor)
            }

            HStack(spacing: 8) {
                ForEach(1...5, id: \.self) { star in
                    Button(action: {
                        difficulty = star
                    }) {
                        Image(systemName: star <= difficulty ? "star.fill" : "star")
                            .font(.title2)
                            .foregroundColor(star <= difficulty ? .yellow : .gray)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(theme.primaryColor.opacity(0.3))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.yellow.opacity(0.3), lineWidth: 1)
                    )
            )
        }
    }
}

struct GamifiedRepeatTypeSection: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Binding var repeatType: QuestRepeatType
    @Binding var selectedScheduledDays: Set<Int>

    var body: some View {
        let theme = themeManager.activeTheme
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "repeat.circle.fill")
                    .foregroundColor(.yellow)
                                    Text(String(localized: "repeat_type"))
                    .font(.appFont(size: 14, weight: .black))
                    .foregroundColor(theme.textColor)
            }

            Picker("", selection: $repeatType) {
                                        Text(String(localized: "one_time")).tag(QuestRepeatType.oneTime)
                        Text(String(localized: "daily")).tag(QuestRepeatType.daily)
                        Text(String(localized: "weekly")).tag(QuestRepeatType.weekly)
                        Text(String(localized: "scheduled")).tag(QuestRepeatType.scheduled)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(theme.primaryColor.opacity(0.3))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.yellow.opacity(0.3), lineWidth: 1)
                    )
            )

            // Show scheduled days selection when scheduled is selected
            if repeatType == .scheduled {
                ScheduledDaysSelectionView(selectedDays: $selectedScheduledDays)
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .move(edge: .top)),
                        removal: .opacity.combined(with: .move(edge: .top))
                    ))
            }
        }
    }
}

struct CoinRewardPreviewSection: View {
    @EnvironmentObject var themeManager: ThemeManager
    let difficulty: Int
    let isMainQuest: Bool
    let taskCount: Int

    private var coinReward: Int {
        // Calculate reward without random bonus for quest creation preview
        let baseReward = difficulty * 10
        let taskBonus = taskCount * 5
        return baseReward + taskBonus
    }

    var body: some View {
        let theme = themeManager.activeTheme
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image("icon_gold")
                    .resizable()
                    .frame(width: 20, height: 20)
                                    Text(String(localized: "quest_reward"))
                    .font(.appFont(size: 14, weight: .black))
                    .foregroundColor(theme.textColor)

                Spacer()

                HStack(spacing: 4) {
                    Image("icon_gold")
                        .resizable()
                        .frame(width: 16, height: 16)
                    Text("\(coinReward)")
                        .font(.appFont(size: 16, weight: .black))
                        .foregroundColor(.yellow)
                }
            }

            VStack(spacing: 8) {
                HStack {
                                            Text(String(localized: "base_reward") + ":")
                        .font(.appFont(size: 12, weight: .medium))
                        .foregroundColor(theme.textColor.opacity(0.7))
                    Spacer()
                    Text("\(difficulty * 10)")
                        .font(.appFont(size: 12, weight: .black))
                        .foregroundColor(theme.textColor)
                }

                HStack {
                                            Text(String(localized: "task_bonus") + ":")
                        .font(.appFont(size: 12, weight: .medium))
                        .foregroundColor(theme.textColor.opacity(0.7))
                    Spacer()
                    Text("+\(taskCount * 5)")
                        .font(.appFont(size: 12, weight: .black))
                        .foregroundColor(.blue)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(theme.primaryColor.opacity(0.3))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.yellow.opacity(0.3), lineWidth: 1)
                    )
            )
        }
    }
}

struct GamifiedTagsSection: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Binding var selectedTags: [Tag]
    let onAddTags: () -> Void
    @State private var isButtonPressed = false

    var body: some View {
        let theme = themeManager.activeTheme
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "tag.circle.fill")
                    .foregroundColor(.yellow)
                                    Text(String(localized: "quest_tags"))
                    .font(.appFont(size: 14, weight: .black))
                    .foregroundColor(theme.textColor)

                Spacer()

                                    Button(String(localized: "add_tags")) {
                    isButtonPressed = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        isButtonPressed = false
                        onAddTags()
                    }
                                    }
                .font(.appFont(size: 14, weight: .medium))
                .foregroundColor(theme.textColor)
                .opacity(isButtonPressed ? 0.7 : 1.0)
                .scaleEffect(isButtonPressed ? 0.95 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isButtonPressed)
            }

            if selectedTags.isEmpty {
                                        Text(String(localized: "no_tags_selected"))
                    .font(.appFont(size: 14, weight: .regular))
                    .foregroundColor(theme.textColor.opacity(0.6))
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(theme.primaryColor.opacity(0.3))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.yellow.opacity(0.3), lineWidth: 1)
                            )
                    )
            } else {
                TagChipRow(
                    tags: selectedTags,
                    isSelectable: false,
                    selectedTags: [],
                    onTagTap: { _ in },
                    onTagRemove: { tag in
                        if let index = selectedTags.firstIndex(of: tag) {
                            selectedTags.remove(at: index)
                        }
                    }
                )
            }
        }
    }
}

// MARK: - Legacy Components (keeping for compatibility)

struct QuestInputField: View {
    @EnvironmentObject var themeManager: ThemeManager
    var title: String
    @Binding var text: String
    var icon: String

    var body: some View {
        let theme = themeManager.activeTheme
        HStack {
            Image(systemName: icon)
                .foregroundColor(theme.textColor)

            TextField("", text: $text, prompt: Text(title).foregroundColor(theme.textColor))
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .font(.appFont(size: 16))
                .foregroundColor(theme.textColor)
                .accentColor(.yellow)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(themeManager.activeTheme.secondaryColor)
                .shadow(color: Color.black.opacity(0.2), radius: 6, x: 0, y: 4)
        )
    }
}

struct ToggleCard: View {
    var label: String
    @Binding var isOn: Bool
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        let theme = themeManager.activeTheme
        Toggle(isOn: $isOn) {
            Text(label)
                .font(.appFont(size: 16, weight: .black))
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(themeManager.activeTheme.secondaryColor)
                .shadow(color: Color.black.opacity(0.2), radius: 6, x: 0, y: 4)
        )
        .tint(Color.yellow)
    }
}
