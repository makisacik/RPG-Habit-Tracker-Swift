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
                .textInputAutocapitalization(.sentences)
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
    @EnvironmentObject var localizationManager: LocalizationManager

    let title: String
    @Binding var date: Date

    @State private var showPicker = false
    @State private var tempDate = Date()

    private func formattedDateString(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = localizationManager.currentLocale
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.dateFormat = "d MMM yyyy"     // 12 Sep 2025 / 12 Eyl 2025
        return dateFormatter.string(from: date)
    }

    var body: some View {
        let theme = themeManager.activeTheme

        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "calendar.circle.fill")
                    .foregroundColor(.yellow)
                    .font(.system(size: 16, weight: .medium))
                Text(title)
                    .font(.appFont(size: 14, weight: .black))
                    .foregroundColor(theme.textColor)
            }

            Button {
                tempDate = date
                showPicker = true
            } label: {
                HStack {
                    Text(formattedDateString(date))
                        .font(.appFont(size: 14, weight: .black))
                        .foregroundColor(theme.textColor)
                    Spacer()
                    Image(systemName: "chevron.down")
                        .foregroundColor(theme.textColor.opacity(0.7))
                        .font(.system(size: 12, weight: .medium))
                        .rotationEffect(.degrees(showPicker ? 180 : 0))
                        .animation(.easeInOut(duration: 0.2), value: showPicker)
                }
                .frame(height: 44)
                .padding(.horizontal, 16)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(theme.primaryColor.opacity(0.3))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(Color.yellow.opacity(0.3), lineWidth: 1)
                        )
                        .shadow(color: theme.shadowColor.opacity(0.1), radius: 2, x: 0, y: 1)
                )
            }
            .buttonStyle(.plain)
        }
        // Localize the sheet content too
        .environment(\.locale, localizationManager.currentLocale)
        .environment(\.calendar, Calendar(identifier: .gregorian))
        .sheet(isPresented: $showPicker) {
            ThemedDatePickerSheet(
                title: title,
                date: $tempDate,
                onSave: {
                    // Ensure date is not in the past
                    let today = Calendar.current.startOfDay(for: Date())
                    let selectedDate = Calendar.current.startOfDay(for: tempDate)
                    
                    if selectedDate < today {
                        date = Date() // Set to today if past date selected
                    } else {
                        date = tempDate
                    }
                    showPicker = false
                },
                onCancel: {
                    showPicker = false
                }
            )
            .environmentObject(themeManager)
            .environmentObject(localizationManager)
        }
    }
}

// MARK: - Themed Date Picker Sheet
struct ThemedDatePickerSheet: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var localizationManager: LocalizationManager
    @Environment(\.dismiss) private var dismiss
    
    let title: String
    @Binding var date: Date
    let onSave: () -> Void
    let onCancel: () -> Void
    
    @State private var selectedDate: Date
    
    init(title: String, date: Binding<Date>, onSave: @escaping () -> Void, onCancel: @escaping () -> Void) {
        self.title = title
        self._date = date
        self.onSave = onSave
        self.onCancel = onCancel
        self._selectedDate = State(initialValue: date.wrappedValue)
    }

    var body: some View {
        let theme = themeManager.activeTheme
        
        NavigationView {
            ZStack {
                // Background using theme color
                theme.backgroundColor
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header with quest-like styling
                    VStack(spacing: 16) {
                        // Decorative icon
                        Image(systemName: "calendar.badge.clock")
                            .font(.system(size: 48, weight: .light))
                            .foregroundColor(.yellow)
                            .padding(.top, 20)
                        
                        // Title
                        Text(title)
                            .font(.appFont(size: 24, weight: .black))
                            .foregroundColor(theme.textColor)
                            .multilineTextAlignment(.center)
                        
                        // Subtitle
                        Text("select_your_quest_deadline".localized)
                            .font(.appFont(size: 16))
                            .foregroundColor(theme.textColor.opacity(0.7))
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, 20)
                    
                    // Date picker container
                    VStack(spacing: 20) {
                        // Current selection display
                        VStack(spacing: 8) {
                            Text("selected_date".localized)
                                .font(.appFont(size: 14, weight: .medium))
                                .foregroundColor(theme.textColor.opacity(0.8))
                            
                            Text(formattedSelectedDate)
                                .font(.appFont(size: 20, weight: .black))
                                .foregroundColor(theme.textColor)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(theme.primaryColor.opacity(0.3))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16)
                                                .stroke(Color.yellow.opacity(0.4), lineWidth: 2)
                                        )
                                        .shadow(color: theme.shadowColor.opacity(0.1), radius: 4, x: 0, y: 2)
                                )
                        }
                        
                        // Calendar picker
                        DatePicker("", selection: $selectedDate, in: Date()..., displayedComponents: [.date])
                            .datePickerStyle(.graphical)
                            .labelsHidden()
                            .environment(\.locale, localizationManager.currentLocale)
                            .environment(\.calendar, Calendar(identifier: .gregorian))
                            .padding(20)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(theme.secondaryColor.opacity(0.8))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(theme.borderColor.opacity(0.3), lineWidth: 1)
                                    )
                                    .shadow(color: theme.shadowColor.opacity(0.1), radius: 8, x: 0, y: 4)
                            )
                            .padding(.horizontal, 20)
                    }
                    .padding(.top, 20)
                    
                    Spacer()
                    
                    // Action buttons
                    VStack(spacing: 12) {
                        // Save button
                        Button(action: {
                            date = selectedDate
                            onSave()
                        }) {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 16, weight: .medium))
                                Text("confirm_date".localized)
                                    .font(.appFont(size: 18, weight: .black))
                            }
                            .foregroundColor(theme.textColor)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                Image(theme.buttonPrimary)
                                    .resizable(
                                        capInsets: EdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20),
                                        resizingMode: .stretch
                                    )
                            )
                        }
                        .buttonStyle(.plain)
                        
                        // Cancel button
                        Button(action: {
                            onCancel()
                        }) {
                            Text("cancel".localized)
                                .font(.appFont(size: 16, weight: .medium))
                                .foregroundColor(theme.textColor.opacity(0.7))
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
                }
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    private var formattedSelectedDate: String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = localizationManager.currentLocale
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.dateFormat = "EEEE, d MMMM yyyy"
        return dateFormatter.string(from: selectedDate)
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
                                    Text("quest_tasks".localized)
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
                            .fill(theme.accentColor)
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
                    Text("manage_tasks".localized)
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
                                    Text("quest_difficulty".localized)
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
                Text("repeat_type".localized)
                    .font(.appFont(size: 14, weight: .black))
                    .foregroundColor(theme.textColor)
            }

            // Custom segmented control for better touch response
            HStack(spacing: 0) {
                ForEach([QuestRepeatType.oneTime, .daily, .weekly, .scheduled], id: \.self) { type in
                    Button(action: {
                        repeatType = type
                        print("Repeat type changed to: \(type)")
                    }) {
                        Text(type.localizedTitle)
                            .font(.appFont(size: 14, weight: repeatType == type ? .black : .medium))
                            .foregroundColor(repeatType == type ? .white : theme.textColor)
                            .padding(.vertical, 12)
                            .padding(.horizontal, 16)
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(repeatType == type ? Color.yellow : Color.clear)
                            )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(4)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(theme.primaryColor.opacity(0.3))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.yellow.opacity(0.3), lineWidth: 1)
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

struct QuestRewardPreviewSection: View {
    @EnvironmentObject var themeManager: ThemeManager
    let difficulty: Int
    let isMainQuest: Bool
    let taskCount: Int

    private var reward: RewardCalculation {
        // Create tasks for the quest
        var tasks: [QuestTask] = []
        for i in 0..<taskCount {
            let task = QuestTask(
                id: UUID(),
                title: "Task \(i + 1)",
                isCompleted: false,
                order: i
            )
            tasks.append(task)
        }

        // Create a temporary quest for reward calculation with tasks included
        let tempQuest = Quest(
            title: "Preview Quest",
            isMainQuest: isMainQuest,
            info: "Preview quest for reward calculation",
            difficulty: difficulty,
            creationDate: Date(),
            dueDate: Date().addingTimeInterval(86400),
            isActive: true,
            progress: 0,
            isCompleted: false,
            completionDate: nil,
            tasks: tasks,
            repeatType: .oneTime,
            tags: [],
            scheduledDays: [],
            reminderTimes: [],
            enableReminders: false
        )

        return RewardSystem.shared.calculateQuestReward(quest: tempQuest)
    }

    var body: some View {
        let theme = themeManager.activeTheme
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image("icon_gold")
                    .resizable()
                    .frame(width: 20, height: 20)
                Text("quest_reward".localized)
                    .font(.appFont(size: 14, weight: .black))
                    .foregroundColor(theme.textColor)

                Spacer()

                HStack(spacing: 8) {
                    HStack(spacing: 4) {
                        Image("icon_gold")
                            .resizable()
                            .frame(width: 16, height: 16)
                        Text("\(reward.totalCoins)")
                            .font(.appFont(size: 16, weight: .black))
                            .foregroundColor(.yellow)
                    }

                    HStack(spacing: 4) {
                        Image("icon_gem")
                            .resizable()
                            .frame(width: 16, height: 16)
                        Text("\(reward.totalGems)")
                            .font(.appFont(size: 16, weight: .black))
                            .foregroundColor(.purple)
                    }
                }
            }

            VStack(spacing: 8) {
                HStack {
                    Text("base_reward".localized + ":")
                        .font(.appFont(size: 12, weight: .medium))
                        .foregroundColor(theme.textColor.opacity(0.7))
                    Spacer()
                    Text("\(reward.baseCoins)")
                        .font(.appFont(size: 12, weight: .black))
                        .foregroundColor(theme.textColor)
                }

                HStack {
                    Text("task_bonus".localized + ":")
                        .font(.appFont(size: 12, weight: .medium))
                        .foregroundColor(theme.textColor.opacity(0.7))
                    Spacer()
                    Text("+\(taskCount * 5)")
                        .font(.appFont(size: 12, weight: .black))
                        .foregroundColor(.blue)
                }

                HStack {
                    Text("gem_reward".localized + ":")
                        .font(.appFont(size: 12, weight: .medium))
                        .foregroundColor(theme.textColor.opacity(0.7))
                    Spacer()
                    Text("\(reward.baseGems)")
                        .font(.appFont(size: 12, weight: .black))
                        .foregroundColor(.purple)
                }

                // Show premium multiplier if user is premium
                if UserDefaults.standard.bool(forKey: "isPremium") {
                    HStack {
                        Text("premium_bonus".localized + ":")
                            .font(.appFont(size: 12, weight: .medium))
                            .foregroundColor(theme.textColor.opacity(0.7))
                        Spacer()
                        Text("×2")
                            .font(.appFont(size: 12, weight: .black))
                            .foregroundColor(.orange)
                    }
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
                                    Text("quest_tags".localized)
                    .font(.appFont(size: 14, weight: .black))
                    .foregroundColor(theme.textColor)

                Spacer()

                                    Button("add_tags".localized) {
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
                                        Text("no_tags_selected".localized)
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

// MARK: - Time Picker Component

struct GamifiedTimePicker: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var localizationManager: LocalizationManager
    
    let title: String
    @Binding var selectedTimes: Set<Date>
    @Binding var isEnabled: Bool
    
    @State private var showTimePicker = false
    @State private var tempTime: Date
    
    private let calendar = Calendar.current
    
    init(title: String, selectedTimes: Binding<Set<Date>>, isEnabled: Binding<Bool>) {
        self.title = title
        self._selectedTimes = selectedTimes
        self._isEnabled = isEnabled
        
        // Default to 12 PM
        let defaultTime = Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: Date()) ?? Date()
        self._tempTime = State(initialValue: defaultTime)
        
        // If no times are selected, set the default time
        if selectedTimes.wrappedValue.isEmpty {
            selectedTimes.wrappedValue.insert(defaultTime)
        }
    }
    
    private func formattedTimeString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = localizationManager.currentLocale
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func updateTime() {
        let roundedTime = calendar.date(bySetting: .second, value: 0, of: tempTime) ?? tempTime
        selectedTimes.removeAll()
        selectedTimes.insert(roundedTime)
        showTimePicker = false
    }
    
    var body: some View {
        let theme = themeManager.activeTheme
        
        VStack(alignment: .leading, spacing: 12) {
            // Header with toggle
            HStack {
                Image(systemName: "clock.circle.fill")
                    .foregroundColor(.yellow)
                    .font(.system(size: 16, weight: .medium))
                
                Text(title)
                    .font(.appFont(size: 14, weight: .black))
                    .foregroundColor(theme.textColor)
                
                Spacer()
                
                Toggle("", isOn: $isEnabled)
                    .tint(.yellow)
            }
            
            if isEnabled {
                // Time selection area
                VStack(spacing: 12) {
                    // Current time display with edit button
                    HStack {
                        HStack {
                            Image(systemName: "clock.fill")
                                .foregroundColor(.blue)
                                .font(.system(size: 16, weight: .medium))
                            
                            if let selectedTime = selectedTimes.first {
                                Text(formattedTimeString(selectedTime))
                                    .font(.appFont(size: 16, weight: .medium))
                                    .foregroundColor(theme.textColor)
                            }
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            if let selectedTime = selectedTimes.first {
                                tempTime = selectedTime
                            }
                            showTimePicker = true
                        }) {
                            Text("change_time".localized)
                                .font(.appFont(size: 14, weight: .medium))
                                .foregroundColor(.blue)
                                .padding(.vertical, 6)
                                .padding(.horizontal, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.blue.opacity(0.1))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                                        )
                                )
                        }
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(theme.secondaryColor.opacity(0.8))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(theme.borderColor.opacity(0.3), lineWidth: 1)
                            )
                    )
                }
            }
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
        .sheet(isPresented: $showTimePicker) {
            TimePickerSheet(
                selectedTime: $tempTime,
                onAdd: updateTime
            ) { showTimePicker = false }
            .environmentObject(themeManager)
            .environmentObject(localizationManager)
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        }
    }
}

struct TimePickerSheet: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var localizationManager: LocalizationManager
    @Environment(\.dismiss) private var dismiss
    
    @Binding var selectedTime: Date
    let onAdd: () -> Void
    let onCancel: () -> Void
    
    var body: some View {
        let theme = themeManager.activeTheme
        
        VStack(spacing: 20) {
            // Header
            VStack(spacing: 8) {
                Text("select_reminder_time".localized)
                    .font(.appFont(size: 20, weight: .black))
                    .foregroundColor(theme.textColor)
                    .multilineTextAlignment(.center)
                
                Text("reminder_will_be_sent_30_min_before".localized)
                    .font(.appFont(size: 16))
                    .foregroundColor(theme.textColor.opacity(0.7))
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 20)
            
            // Time picker
            DatePicker("", selection: $selectedTime, displayedComponents: [.hourAndMinute])
                .datePickerStyle(.wheel)
                .labelsHidden()
                .environment(\.locale, localizationManager.currentLocale)
                .environment(\.calendar, Calendar(identifier: .gregorian))
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(theme.secondaryColor.opacity(0.8))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(theme.borderColor.opacity(0.3), lineWidth: 1)
                        )
                )
            
            // Action buttons
            HStack(spacing: 16) {
                Button(action: onCancel) {
                    Text("cancel".localized)
                        .font(.appFont(size: 16, weight: .medium))
                        .foregroundColor(theme.textColor.opacity(0.7))
                        .padding(.vertical, 12)
                        .padding(.horizontal, 24)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(theme.primaryColor.opacity(0.3))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(theme.borderColor.opacity(0.3), lineWidth: 1)
                                )
                        )
                }
                
                Button(action: onAdd) {
                    Text("add_time".localized)
                        .font(.appFont(size: 16, weight: .black))
                        .foregroundColor(.white)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 24)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.green)
                                .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                        )
                }
            }
            .padding(.bottom, 20)
        }
        .background(theme.backgroundColor)
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
