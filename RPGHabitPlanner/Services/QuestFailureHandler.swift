import SwiftUI
import CoreData

final class QuestFailureHandler: ObservableObject {
    static let shared = QuestFailureHandler()
    private let persistentContainer: NSPersistentContainer
    private let healthManager: HealthManager
    
    @Published var showFailureNotification = false
    @Published var failureMessage = ""
    
    private init(container: NSPersistentContainer = PersistenceController.shared.container) {
        self.persistentContainer = container
        self.healthManager = HealthManager.shared
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
        let difficulty = Int(quest.difficulty)
        
        // Apply damage based on quest difficulty
        healthManager.handleQuestFailure(questDifficulty: difficulty) { error in
            if error == nil {
                DispatchQueue.main.async {
                    self.showFailureNotification = true
                    self.failureMessage = "Quest failed: \(quest.title ?? "Unknown Quest") - You took \(difficulty * 2) damage!"
                    
                    // Hide notification after 3 seconds
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        self.showFailureNotification = false
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
                    
                    Text("Quest Failed!")
                        .font(.appFont(size: 16, weight: .black))
                        .foregroundColor(theme.textColor)
                    
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
