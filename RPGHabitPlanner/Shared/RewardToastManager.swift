//
//  RewardToastManager.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 6.08.2025.
//

import SwiftUI
import Combine

// MARK: - Toast Models

struct RewardToast: Identifiable {
    let id = UUID()
    let title: String
    let experience: Int
    let coins: Int
    let type: RewardType
    let timestamp: Date
    var isVisible: Bool = false
    var offset: CGFloat = 200 // Start off-screen
}

// RewardType is defined in RewardTypes.swift

// MARK: - Toast Manager

class RewardToastManager: ObservableObject {
    static let shared = RewardToastManager()
    
    @Published var toasts: [RewardToast] = []
    @Published var isVisible: Bool = false
    
    private var toastQueue: [RewardToast] = []
    private var displayTimer: Timer?
    private let maxVisibleToasts = 3
    private let toastDuration: TimeInterval = 3.0
    private let animationDuration: TimeInterval = 0.3
    
    private init() {}
    
    // MARK: - Public Methods
    
    func showQuestReward(quest: Quest, reward: RewardCalculation) {
        let toast = RewardToast(
            title: quest.title,
            experience: reward.totalExperience,
            coins: reward.totalCoins,
            type: .quest,
            timestamp: Date()
        )
        
        addToast(toast)
    }
    
    func showTaskReward(task: QuestTask, quest: Quest, reward: RewardCalculation) {
        let toast = RewardToast(
            title: task.title,
            experience: reward.totalExperience,
            coins: reward.totalCoins,
            type: .task,
            timestamp: Date()
        )
        
        addToast(toast)
    }
    
    func dismissToast(_ toast: RewardToast) {
        if let index = toasts.firstIndex(where: { $0.id == toast.id }) {
            withAnimation(.easeInOut(duration: animationDuration)) {
                toasts[index].offset = 200
                toasts[index].isVisible = false
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration) {
                self.toasts.removeAll { $0.id == toast.id }
                self.processQueue()
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func addToast(_ toast: RewardToast) {
        toastQueue.append(toast)
        processQueue()
    }
    
    private func processQueue() {
        guard !toastQueue.isEmpty && toasts.count < maxVisibleToasts else { return }
        
        let toast = toastQueue.removeFirst()
        
        withAnimation(.easeOut(duration: animationDuration)) {
            toasts.append(toast)
            if let index = toasts.firstIndex(where: { $0.id == toast.id }) {
                toasts[index].offset = 0
                toasts[index].isVisible = true
            }
        }
        
        // Auto-dismiss after duration
        DispatchQueue.main.asyncAfter(deadline: .now() + toastDuration) {
            self.dismissToast(toast)
        }
    }
    
    func clearAllToasts() {
        withAnimation(.easeInOut(duration: animationDuration)) {
            for index in toasts.indices {
                toasts[index].offset = 200
                toasts[index].isVisible = false
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration) {
            self.toasts.removeAll()
            self.toastQueue.removeAll()
        }
    }
}
