import SwiftUI
import Foundation

struct QuickQuestsView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @ObservedObject var viewModel: QuickQuestsViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showAlert: Bool = false
    @State private var alertTitle: String = ""
    @State private var alertMessage: String = ""
    @State private var showSuccessAnimation = false

    var body: some View {
        let theme = themeManager.activeTheme

        NavigationView {
            ZStack {
                if showSuccessAnimation {
                    SuccessAnimationOverlay(isVisible: $showSuccessAnimation)
                        .zIndex(20)
                }

                theme.backgroundColor
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        // Header
                        VStack(spacing: 8) {
                            Text(String.quickQuests.localized)
                                .font(.appFont(size: 28, weight: .black))
                                .foregroundColor(theme.textColor)

                            Text(String.chooseFromCuratedQuestTemplates.localized)
                                .font(.appFont(size: 16))
                                .foregroundColor(theme.textColor.opacity(0.7))
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 20)

                        // Quest Type Segments
                        Picker(String.questType.localized, selection: $viewModel.selectedQuestType) {
                            Text(String.daily.localized).tag(QuestType.daily)
                            Text(String.weekly.localized).tag(QuestType.weekly)
                            Text(String.oneTime.localized).tag(QuestType.oneTime)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(.horizontal, 16)

                        // Quest Templates
                        LazyVStack(spacing: 16) {
                            ForEach(viewModel.questsForSelectedType, id: \.id) { template in
                                QuickQuestTemplateCard(
                                    template: template,
                                    theme: theme
                                ) {
                                        viewModel.selectedTemplate = template
                                        viewModel.showDueDatePicker = true
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                    .padding(.bottom, 20)
                }
            }
            .navigationTitle(String.quickQuests.localized)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button(String.cancelButton.localized) {
                    dismiss()
                }
                .foregroundColor(theme.textColor),
                trailing: Button(String.doneButton.localized) {
                    dismiss()
                }
                .foregroundColor(theme.textColor)
            )
            .sheet(isPresented: $viewModel.showDueDatePicker) {
                if let template = viewModel.selectedTemplate {
                    DueDateSelectionView(
                        template: template,
                        questType: viewModel.selectedQuestType
                    ) { dueDate in
                            viewModel.addQuickQuest(template: template, dueDate: dueDate)
                            showSuccessAnimation = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                showSuccessAnimation = false
                            }
                    }
                    .environmentObject(themeManager)
                }
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text(alertTitle).font(.appFont(size: 16, weight: .black)),
                    message: Text(alertMessage).font(.appFont(size: 14)),
                    dismissButton: .default(Text(String.okButton.localized).font(.appFont(size: 14, weight: .black)))
                )
            }
        }
    }
}

struct QuickQuestTemplateCard: View {
    let template: QuickQuestTemplate
    let theme: Theme
    let onAddQuest: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: template.iconName)
                    .font(.title2)
                    .foregroundColor(template.category.color)

                VStack(alignment: .leading, spacing: 4) {
                    Text(template.title)
                        .font(.appFont(size: 18, weight: .bold))
                        .foregroundColor(theme.textColor)

                    Text(template.description)
                        .font(.appFont(size: 14))
                        .foregroundColor(theme.textColor.opacity(0.7))
                        .lineLimit(2)
                }

                Spacer()

                Button(action: onAddQuest) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundColor(.green)
                }
            }

            HStack {
                Label("\(template.difficulty)", systemImage: "star.fill")
                    .font(.appFont(size: 12))
                    .foregroundColor(.yellow)

                Spacer()

                Text(template.category.displayName)
                    .font(.appFont(size: 12, weight: .medium))
                    .foregroundColor(template.category.color)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(template.category.color.opacity(0.2))
                    )
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(theme.primaryColor)
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
    }
}

struct DueDateSelectionView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.dismiss) private var dismiss
    let template: QuickQuestTemplate
    let questType: QuestType
    let onSave: (Date) -> Void

    @State private var selectedDueDate: Date

    init(template: QuickQuestTemplate, questType: QuestType, onSave: @escaping (Date) -> Void) {
        self.template = template
        self.questType = questType
        self.onSave = onSave

        // Set default due date based on quest type
        let calendar = Calendar.current
        let now = Date()

        switch questType {
        case .daily:
            // 5 days from now
            self._selectedDueDate = State(initialValue: calendar.date(byAdding: .day, value: 5, to: now) ?? now)
        case .weekly:
            // 3 weeks from now
            self._selectedDueDate = State(initialValue: calendar.date(byAdding: .weekOfYear, value: 3, to: now) ?? now)
        case .oneTime:
            // 1 month from now
            self._selectedDueDate = State(initialValue: calendar.date(byAdding: .month, value: 1, to: now) ?? now)
        }
    }

    var body: some View {
        let theme = themeManager.activeTheme

        NavigationView {
            ZStack {
                theme.backgroundColor
                    .ignoresSafeArea()

                VStack(spacing: 24) {
                    // Quest Info
                    VStack(spacing: 16) {
                        Image(systemName: template.iconName)
                            .font(.system(size: 48))
                            .foregroundColor(template.category.color)

                        Text(template.title)
                            .font(.appFont(size: 24, weight: .black))
                            .foregroundColor(theme.textColor)
                            .multilineTextAlignment(.center)

                        Text(template.description)
                            .font(.appFont(size: 16))
                            .foregroundColor(theme.textColor.opacity(0.7))
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 20)

                    // Due Date Selection
                    VStack(alignment: .leading, spacing: 12) {
                        Text(String.dueDate.localized)
                            .font(.appFont(size: 18, weight: .bold))
                            .foregroundColor(theme.textColor)

                        DatePicker("", selection: $selectedDueDate, displayedComponents: [.date])
                            .datePickerStyle(WheelDatePickerStyle())
                            .labelsHidden()
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(theme.secondaryColor)
                            )
                    }
                    .padding(.horizontal, 20)

                    // Default Duration Info
                    VStack(spacing: 8) {
                        Text(String.defaultDuration.localized)
                            .font(.appFont(size: 16, weight: .medium))
                            .foregroundColor(theme.textColor.opacity(0.7))

                        Text(defaultDurationText)
                            .font(.appFont(size: 14))
                            .foregroundColor(theme.textColor.opacity(0.5))
                    }

                    Spacer()

                    // Action Buttons
                    VStack(spacing: 12) {
                        Button(action: {
                            onSave(selectedDueDate)
                            dismiss()
                        }) {
                            HStack {
                                Spacer()
                                Text(String.addQuest.localized)
                                    .font(.appFont(size: 18, weight: .black))
                                    .foregroundColor(theme.textColor)
                                Spacer()
                            }
                            .padding()
                            .background(
                                Image(theme.buttonPrimary)
                                    .resizable(
                                        capInsets: EdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20),
                                        resizingMode: .stretch
                                    )
                            )
                        }

                        Button(String.cancelButton.localized) {
                            dismiss()
                        }
                        .font(.appFont(size: 16))
                        .foregroundColor(theme.textColor.opacity(0.7))
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            }
                            .navigationTitle(String.setDueDate.localized)
            .navigationBarTitleDisplayMode(.inline)
                            .navigationBarItems(trailing: Button(String.cancelButton.localized) {
                dismiss()
                            })
        }
    }

    private var defaultDurationText: String {
        switch questType {
        case .daily:
            return "5 \(String.daysFromToday.localized)"
        case .weekly:
            return "3 \(String.weeksFromToday.localized)"
        case .oneTime:
            return "1 \(String.monthsFromToday.localized)"
        }
    }
}

enum QuestType: String, CaseIterable {
    case daily = "daily"
    case weekly = "weekly"
    case oneTime = "oneTime"
}

struct QuickQuestTemplate: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let category: QuickQuestCategory
    let difficulty: Int
    let iconName: String
    let tasks: [QuestTask]
}

enum QuickQuestCategory: String, CaseIterable {
    case health = "health"
    case productivity = "productivity"
    case learning = "learning"
    case mindfulness = "mindfulness"
    case fitness = "fitness"
    case social = "social"

    var displayName: String {
        switch self {
        case .health:
            return String.healthAndWellness.localized
        case .productivity:
            return String.productivity.localized
        case .learning:
            return String.learningAndGrowth.localized
        case .mindfulness:
            return String.mindfulness.localized
        case .fitness:
            return String.fitness.localized
        case .social:
            return String.social.localized
        }
    }

    var color: Color {
        switch self {
        case .health:
            return .red
        case .productivity:
            return .blue
        case .learning:
            return .purple
        case .mindfulness:
            return .indigo
        case .fitness:
            return .green
        case .social:
            return .orange
        }
    }
}
