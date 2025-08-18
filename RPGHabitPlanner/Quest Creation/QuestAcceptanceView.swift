import SwiftUI

struct QuestAcceptanceView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @ObservedObject var viewModel: QuestCreationViewModel
    let onAcceptQuest: () -> Void
    let onGoBack: () -> Void
    let animate: Bool
    @State private var isAcceptPressed = false
    @State private var isBackPressed = false
    
    private var repeatTypeDisplayValue: String {
        switch viewModel.repeatType {
        case .oneTime: return "One Time"
        case .daily: return "Daily"
        case .weekly: return "Weekly"
        case .scheduled: return "Scheduled"
        }
    }
    
    private var scheduledDaysDisplayValue: String {
        let weekdays = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
        let selectedDayNames = viewModel.selectedScheduledDays
            .sorted()
            .compactMap { (dayNumber: Int) -> String? in
                guard dayNumber >= 1 && dayNumber <= 7 else { return nil }
                return weekdays[dayNumber - 1]
            }
        return selectedDayNames.joined(separator: ", ")
    }
    
    var body: some View {
        let theme = themeManager.activeTheme
        VStack(spacing: 30) {
            // Quest Summary Header
            VStack(spacing: 16) {
                Image(systemName: "scroll.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.yellow)
                    .scaleEffect(animate ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: animate)
                
                Text("QUEST SUMMARY")
                    .font(.appFont(size: 24, weight: .black))
                    .foregroundColor(theme.textColor)
            }
            
            // Quest Details Summary
            ScrollView {
                VStack(spacing: 16) {
                    QuestSummaryCard(
                        title: "Quest Name",
                        value: viewModel.questTitle.isEmpty ? "Untitled Quest" : viewModel.questTitle,
                        icon: "pencil.circle.fill"
                    )
                    
                    QuestSummaryCard(
                        title: "Description",
                        value: viewModel.questDescription.isEmpty ? "No description" : viewModel.questDescription,
                        icon: "doc.text.fill"
                    )
                    
                    QuestSummaryCard(
                        title: "Quest Type",
                        value: viewModel.isMainQuest ? "Main Quest" : "Side Quest",
                        icon: "star.fill"
                    )
                    
                    QuestSummaryCard(
                        title: "Difficulty",
                        value: "\(viewModel.difficulty)/5 Stars",
                        icon: "star.circle.fill"
                    )
                    
                    QuestSummaryCard(
                        title: "Due Date",
                        value: viewModel.questDueDate.formatted(date: .abbreviated, time: .omitted),
                        icon: "calendar.circle.fill"
                    )
                    
                    QuestSummaryCard(
                        title: "Tasks",
                        value: "\(viewModel.tasks.filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }.count) tasks",
                        icon: "list.bullet.circle.fill"
                    )
                    
                    QuestSummaryCard(
                        title: "Repeat Type",
                        value: repeatTypeDisplayValue,
                        icon: "repeat.circle.fill"
                    )
                    
                    if viewModel.repeatType == .scheduled && !viewModel.selectedScheduledDays.isEmpty {
                        QuestSummaryCard(
                            title: "Scheduled Days",
                            value: scheduledDaysDisplayValue,
                            icon: "calendar.badge.clock"
                        )
                    }
                    
                    QuestSummaryCard(
                        title: "Reward",
                        value: "\(CurrencyManager.shared.calculateQuestReward(difficulty: viewModel.difficulty, isMainQuest: viewModel.isMainQuest, taskCount: viewModel.tasks.filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }.count)) coins",
                        icon: "icon_gold"
                    )
                }
                .padding()
            }
            
            // Action Buttons
            HStack(spacing: 20) {
                // Back Button
                Button(action: {
                    isBackPressed = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        isBackPressed = false
                        onGoBack()
                    }
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.left")
                            .font(.title3)
                        Text("BACK")
                            .font(.appFont(size: 16, weight: .black))
                    }
                    .foregroundColor(theme.textColor)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 24)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(theme.secondaryColor)
                            .opacity(isBackPressed ? 0.7 : 1.0)
                    )
                    .scaleEffect(isBackPressed ? 0.95 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isBackPressed)
                }
                .buttonStyle(PlainButtonStyle())
                
                // Accept Quest Button
                Button(action: {
                    isAcceptPressed = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        isAcceptPressed = false
                        onAcceptQuest()
                    }
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title3)
                        Text("ACCEPT QUEST")
                            .font(.appFont(size: 16, weight: .black))
                    }
                    .foregroundColor(.white)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 24)
                    .background(
                        Image(theme.buttonPrimary)
                            .resizable(
                                capInsets: EdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20),
                                resizingMode: .stretch
                            )
                            .opacity(isAcceptPressed ? 0.7 : 1.0)
                    )
                    .scaleEffect(isAcceptPressed ? 0.95 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isAcceptPressed)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding()
    }
}

struct QuestSummaryCard: View {
    @EnvironmentObject var themeManager: ThemeManager
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        let theme = themeManager.activeTheme
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.yellow)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.appFont(size: 12, weight: .medium))
                    .foregroundColor(theme.textColor.opacity(0.7))
                
                Text(value)
                    .font(.appFont(size: 14, weight: .black))
                    .foregroundColor(theme.textColor)
            }
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(theme.secondaryColor)
                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        )
    }
}
