import SwiftUI
import CoreData

final class QuestFailureHandler: ObservableObject {
    static let shared = QuestFailureHandler()
    private let persistentContainer: NSPersistentContainer
    private let healthManager: HealthManager
    private let damageTrackingManager: QuestDamageTrackingManager

    @Published var showFailureNotification = false
    @Published var failureMessage = ""

    private init(container: NSPersistentContainer = PersistenceController.shared.container) {
        self.persistentContainer = container
        self.healthManager = HealthManager.shared
        self.damageTrackingManager = QuestDamageTrackingManager.shared
    }

    // MARK: - Quest Failure Handling

    func checkForFailedQuests() {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<QuestEntity> = QuestEntity.fetchRequest()

        // Get all active quests
        fetchRequest.predicate = NSPredicate(format: "isActive == YES")

        do {
            let activeQuests = try context.fetch(fetchRequest)
            let today = Calendar.current.startOfDay(for: Date())

            for quest in activeQuests {
                if let dueDate = quest.dueDate {
                    let questDueDate = Calendar.current.startOfDay(for: dueDate)

                    // Check if quest is overdue
                    if questDueDate < today && !quest.isCompleted {
                        handleQuestFailure(quest: quest)
                    }
                }
            }
        } catch {
            print("Error checking for failed quests: \(error)")
        }
    }

    private func handleQuestFailure(quest: QuestEntity) {
        // Use the new damage tracking system instead of the old difficulty-based system
        // Convert QuestEntity to Quest model for damage calculation
        let questModel = mapQuestEntityToQuest(quest)

        damageTrackingManager.calculateDamageForQuest(questModel) { [weak self] damageAmount, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error calculating quest damage: \(error)")
                    return
                }

                if damageAmount > 0 {
                    self?.showFailureNotification = true
                    self?.failureMessage = "Quest failed: \(quest.title ?? "Unknown Quest") - You took \(damageAmount) damage!"

                    // Post notification for quest failure
                    NotificationCenter.default.post(
                        name: .questFailed,
                        object: nil,
                        userInfo: ["questId": quest.id as Any, "damage": damageAmount]
                    )

                    // Hide notification after 3 seconds
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        self?.showFailureNotification = false
                    }
                }
            }
        }

        // Mark quest as failed
        quest.isActive = false
        quest.isCompleted = false

        do {
            try persistentContainer.viewContext.save()
        } catch {
            print("Error saving failed quest: \(error)")
        }
    }

    private func mapQuestEntityToQuest(_ entity: QuestEntity) -> Quest {
        let tasks = (entity.tasks?.array as? [TaskEntity])?.map { taskEntity in
            QuestTask(
                id: taskEntity.id ?? UUID(),
                title: taskEntity.title ?? "",
                isCompleted: taskEntity.isCompleted,
                order: Int(taskEntity.order)
            )
        } ?? []

        let completions = (entity.completions?.allObjects as? [QuestCompletionEntity])?.compactMap { $0.date } ?? []
        let tags = (entity.tags?.allObjects as? [TagEntity])?.map { tagEntity in
            Tag(
                id: tagEntity.id ?? UUID(),
                name: tagEntity.name ?? "",
                icon: tagEntity.icon,
                color: tagEntity.color
            )
        } ?? []

        let scheduledDays = entity.scheduledDays?.components(separatedBy: ",").compactMap { Int($0) } ?? []

        return Quest(
            id: entity.id ?? UUID(),
            title: entity.title ?? "",
            isMainQuest: entity.isMainQuest,
            info: entity.info ?? "",
            difficulty: Int(entity.difficulty),
            creationDate: entity.creationDate ?? Date(),
            dueDate: entity.dueDate ?? Date(),
            isActive: entity.isActive,
            progress: Int(entity.progress),
            isCompleted: entity.isCompleted,
            completionDate: entity.completionDate,
            isFinished: entity.isFinished,
            isFinishedDate: entity.isFinishedDate,
            tasks: tasks,
            repeatType: QuestRepeatType(rawValue: entity.repeatType) ?? .oneTime,
            completions: Set(completions),
            tags: Set(tags),
            showProgress: entity.showProgress,
            scheduledDays: Set(scheduledDays)
        )
    }

    // MARK: - Daily Quest Check

    func performDailyQuestCheck() {
        // This should be called daily to check for failed quests
        checkForFailedQuests()
    }

    // MARK: - Manual Quest Failure (for testing)

    func manuallyFailQuest(questId: UUID, completion: @escaping (Error?) -> Void) {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<QuestEntity> = QuestEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", questId as CVarArg)

        do {
            let quests = try context.fetch(fetchRequest)
            if let quest = quests.first {
                handleQuestFailure(quest: quest)
                completion(nil)
            } else {
                completion(NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "Quest not found"]))
            }
        } catch {
            completion(error)
        }
    }
}

// MARK: - Quest Failure Notification View

struct QuestFailureNotificationView: View {
    @EnvironmentObject var themeManager: ThemeManager
    let message: String
    @Binding var isVisible: Bool

    var body: some View {
        let theme = themeManager.activeTheme

        if isVisible {
            VStack(spacing: 8) {
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.red)
                        .font(.title2)

                    Text(String(localized: "quest_failed"))
                        .font(.appFont(size: 24, weight: .black))
                        .foregroundColor(.red)

                    Spacer()
                }

                Text(message)
                    .font(.appFont(size: 14))
                    .foregroundColor(theme.textColor.opacity(0.9))
                    .multilineTextAlignment(.leading)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.red.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.red.opacity(0.3), lineWidth: 1)
                    )
            )
            .transition(.move(edge: .top).combined(with: .opacity))
            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: isVisible)
        }
    }
}
