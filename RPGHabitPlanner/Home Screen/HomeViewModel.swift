//
//  HomeViewModel.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 11.11.2024.
//

import SwiftUI
import CoreData

class HomeViewModel: ObservableObject {
    @Published var user: UserEntity?
    private let userManager: UserManager
    
    init(userManager: UserManager) {
        self.userManager = userManager
    }
    
    func fetchUserData() {
        userManager.fetchUser { [weak self] user, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Failed to fetch user data: \(error)")
                } else {
                    self?.user = user
                }
            }
        }
    }
}
