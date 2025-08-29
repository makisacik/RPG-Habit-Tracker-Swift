import SwiftUI
import Foundation

struct QuickQuestsView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @ObservedObject var viewModel: QuickQuestsViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showAlert: Bool = false
    @State private var alertTitle: String = ""
    @State private var alertMessage: String = ""

    @State private var showPaywall = false

    var body: some View {
        let theme = themeManager.activeTheme

        NavigationView {
            ZStack {
                theme.backgroundColor
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        // Header
                        VStack(spacing: 8) {
                            Text("quick_quests".localized)
                                .font(.appFont(size: 28, weight: .black))
                                .foregroundColor(theme.textColor)

                            Text("choose_from_curated_quest_templates".localized)
                                .font(.appFont(size: 16))
                                .foregroundColor(theme.textColor.opacity(0.7))
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 20)

                        // Quest Type Segments
                        Picker("quest_type".localized, selection: $viewModel.selectedQuestType) {
                            Text("daily".localized).tag(QuestType.daily)
                            Text("weekly".localized).tag(QuestType.weekly)
                            Text("one_time".localized).tag(QuestType.oneTime)
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
            .navigationTitle("quick_quests".localized)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("cancel".localized) {
                    dismiss()
                }
                .foregroundColor(theme.textColor),
                trailing: Button("done".localized) {
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
                    }
                    .environmentObject(themeManager)
                }
            }

            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text(alertTitle).font(.appFont(size: 16, weight: .black)),
                    message: Text(alertMessage).font(.appFont(size: 14)),
                    dismissButton: .default(Text("ok".localized).font(.appFont(size: 14, weight: .black)))
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
    @EnvironmentObject var localizationManager: LocalizationManager
    @Environment(\.dismiss) private var dismiss
    let template: QuickQuestTemplate
    let questType: QuestType
    let onSave: (Date) -> Void
    @State private var showPaywall = false

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
                    // Quest Info with enhanced styling
                    VStack(spacing: 20) {
                        // Quest icon with decorative background
                        ZStack {
                            Circle()
                                .fill(template.category.color.opacity(0.1))
                                .frame(width: 80, height: 80)

                            Image(systemName: template.iconName)
                                .font(.system(size: 36, weight: .medium))
                                .foregroundColor(template.category.color)
                        }
                        .padding(.top, 20)

                        // Quest title with enhanced typography
                        Text(template.title)
                            .font(.appFont(size: 28, weight: .black))
                            .foregroundColor(theme.textColor)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)

                        // Quest description with better styling
                        Text(template.description)
                            .font(.appFont(size: 16))
                            .foregroundColor(theme.textColor.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                            .padding(.bottom, 10)
                    }

                    // Enhanced Due Date Selection
                    VStack(alignment: .leading, spacing: 16) {
                        // Section header
                        HStack {
                            Image(systemName: "calendar.badge.clock")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.yellow)

                            Text("due_date".localized)
                                .font(.appFont(size: 20, weight: .black))
                                .foregroundColor(theme.textColor)
                        }
                        .padding(.horizontal, 20)

                        // Current selection display
                        VStack(spacing: 8) {
                            Text("selected_deadline".localized)
                                .font(.appFont(size: 14, weight: .medium))
                                .foregroundColor(theme.textColor.opacity(0.8))

                            Text(formattedSelectedDate)
                                .font(.appFont(size: 18, weight: .black))
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
                        .padding(.horizontal, 20)

                        // Enhanced Date Picker
                        DatePicker("", selection: $selectedDueDate, displayedComponents: [.date])
                            .datePickerStyle(WheelDatePickerStyle())
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

                    // Enhanced Default Duration Info
                    VStack(spacing: 12) {
                        HStack {
                            Image(systemName: "clock.arrow.circlepath")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(theme.textColor.opacity(0.6))

                            Text("default_duration".localized)
                                .font(.appFont(size: 16, weight: .medium))
                                .foregroundColor(theme.textColor.opacity(0.8))
                        }

                        Text(defaultDurationText)
                            .font(.appFont(size: 14))
                            .foregroundColor(theme.textColor.opacity(0.6))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(theme.primaryColor.opacity(0.2))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(theme.borderColor.opacity(0.2), lineWidth: 1)
                                    )
                            )
                    }
                    .padding(.horizontal, 20)

                    Spacer()

                    // Enhanced Action Buttons
                    VStack(spacing: 16) {
                        // Primary action button
                        Button(action: {
                            if PremiumManager.shared.canCreateQuest() {
                                onSave(selectedDueDate)
                                dismiss()
                            } else {
                                showPaywall = true
                            }
                        }) {
                            HStack {
                                Image(systemName: PremiumManager.shared.canCreateQuest() ? "plus.circle.fill" : "lock.fill")
                                    .font(.system(size: 18, weight: .medium))

                                Text(PremiumManager.shared.canCreateQuest() ? "add_quest".localized : "unlock".localized)
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

                        // Cancel button with enhanced styling
                        Button("cancel".localized) {
                            dismiss()
                        }
                        .font(.appFont(size: 16, weight: .medium))
                        .foregroundColor(theme.textColor.opacity(0.7))
                        .padding(.vertical, 8)
                        .padding(.horizontal, 20)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(theme.primaryColor.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(theme.borderColor.opacity(0.2), lineWidth: 1)
                                )
                        )
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
                }
            }
            .navigationTitle("set_due_date".localized)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("cancel".localized) {
                dismiss()
            })
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    private var formattedSelectedDate: String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = localizationManager.currentLocale
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.dateFormat = "EEEE, d MMMM yyyy"
        return dateFormatter.string(from: selectedDueDate)
    }

    private var defaultDurationText: String {
        switch questType {
        case .daily:
            return "5 \("days_from_today".localized)"
        case .weekly:
            return "3 \("weeks_from_today".localized)"
        case .oneTime:
            return "1 \("months_from_today".localized)"
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
            return "health_and_wellness".localized
        case .productivity:
            return "productivity".localized
        case .learning:
            return "learning_and_growth".localized
        case .mindfulness:
            return "mindfulness".localized
        case .fitness:
            return "fitness".localized
        case .social:
            return "social".localized
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
