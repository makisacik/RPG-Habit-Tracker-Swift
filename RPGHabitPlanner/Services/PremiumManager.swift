//
//  PremiumManager.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 28.10.2024.
//

import Foundation
import StoreKit
import Combine

@MainActor
final class PremiumManager: ObservableObject {
    static let shared = PremiumManager()

    // MARK: - Published Properties
    @Published var isPremium: Bool = false
    @Published var isSubscribed: Bool = false
    @Published var isLifetimePremium: Bool = false
    @Published var availableProducts: [Product] = []
    @Published var purchasedProducts: [Product] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    // MARK: - Private Properties
    private var products: [Product] = []
    private var updateListenerTask: Task<Void, Error>?
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Product Identifiers
    private let subscriptionProductID = "com.makisacik.RPGHabitPlanner.premium.monthly"
    private let lifetimeProductID = "com.makisacik.RPGHabitPlanner.premium.onetime"

    // MARK: - User Defaults Keys
    private let isPremiumKey = "isPremium"
    private let isSubscribedKey = "isSubscribed"
    private let isLifetimePremiumKey = "isLifetimePremium"
    private let subscriptionExpiryKey = "subscriptionExpiry"
    private let weeklyQuestCountKey = "weeklyQuestCount"
    private let weeklyQuestResetDateKey = "weeklyQuestResetDate"

    private init() {
        loadPremiumStatus()
        setupStoreKitListener()
        Task {
            await loadProducts()
            await updateCustomerProductStatus()
        }
    }

    deinit {
        updateListenerTask?.cancel()
    }

    // MARK: - Public Methods

    func purchaseSubscription() async throws {
        // Check if already premium
        if isPremium {
            throw PremiumError.alreadyPremium
        }
        
        guard let product = products.first(where: { $0.id == subscriptionProductID }) else {
            throw PremiumError.productNotFound
        }

        isLoading = true
        errorMessage = nil

        defer {
            isLoading = false
        }

        do {
            let result = try await product.purchase()

            switch result {
            case .success(let verification):
                await handlePurchaseSuccess(verification: verification, product: product)
            case .userCancelled:
                throw PremiumError.userCancelled
            case .pending:
                throw PremiumError.purchasePending
            @unknown default:
                throw PremiumError.unknown
            }
        } catch {
            self.errorMessage = error.localizedDescription
            throw error
        }
    }

    func purchaseLifetime() async throws {
        // Check if already premium
        if isPremium {
            throw PremiumError.alreadyPremium
        }
        
        guard let product = products.first(where: { $0.id == lifetimeProductID }) else {
            throw PremiumError.productNotFound
        }

        isLoading = true
        errorMessage = nil

        defer {
            isLoading = false
        }

        do {
            let result = try await product.purchase()

            switch result {
            case .success(let verification):
                await handlePurchaseSuccess(verification: verification, product: product)
            case .userCancelled:
                throw PremiumError.userCancelled
            case .pending:
                throw PremiumError.purchasePending
            @unknown default:
                throw PremiumError.unknown
            }
        } catch {
            self.errorMessage = error.localizedDescription
            throw error
        }
    }

    func restorePurchases() async throws {
        isLoading = true
        errorMessage = nil

        defer {
            isLoading = false
        }

        do {
            try await AppStore.sync()
            await updateCustomerProductStatus()
        } catch {
            self.errorMessage = error.localizedDescription
            throw error
        }
    }

    func checkPremiumStatus() async {
        await updateCustomerProductStatus()
    }

    func clearErrorMessage() {
        errorMessage = nil
    }

    // MARK: - Product Management

    func getProductDetails() -> [Product] {
        return availableProducts
    }
    
    // MARK: - Localized Pricing
    
    func getLocalizedPrice(for productID: String) -> String? {
        guard let product = products.first(where: { $0.id == productID }) else {
            return nil
        }
        return product.displayPrice
    }
    
    func getLocalizedPriceWithCurrency(for productID: String) -> String? {
        guard let product = products.first(where: { $0.id == productID }) else {
            return nil
        }
        return product.displayPrice
    }
    
    func getAllLocalizedPrices() -> [String: String] {
        var prices: [String: String] = [:]
        for product in products {
            prices[product.id] = product.displayPrice
        }
        return prices
    }

    func areProductsLoaded() -> Bool {
        return !products.isEmpty
    }

    // MARK: - Debug Methods

    func debugProductStatus() {
        print("🔍 PremiumManager Debug:")
        print("  - Products loaded: \(products.count)")
        print("  - Available products: \(availableProducts.count)")
        print("  - Is Premium: \(isPremium)")
        print("  - Is Subscribed: \(isSubscribed)")
        print("  - Is Lifetime: \(isLifetimePremium)")

        for product in products {
            print("  - Product: \(product.id) - \(product.displayName) - \(product.displayPrice)")
        }
    }
    
    func reloadProducts() async {
        print("🔄 PremiumManager: Manually reloading products...")
        await loadProducts()
        debugProductStatus()
    }

    // MARK: - Private Methods

    private func setupStoreKitListener() {
        updateListenerTask = listenForTransactions()
    }

    private func listenForTransactions() -> Task<Void, Error> {
        return Task.detached {
            for await result in Transaction.updates {
                await self.handleTransactionUpdate(result)
            }
        }
    }

    private func handleTransactionUpdate(_ result: VerificationResult<Transaction>) async {
        guard case .verified(let transaction) = result else {
            return
        }

        await self.updateCustomerProductStatus()

        if transaction.revocationDate == nil {
            await transaction.finish()
        }
    }

    private func loadProducts() async {
        print("🔄 PremiumManager: Starting to load products...")
        print("🔍 PremiumManager: Looking for products: \(subscriptionProductID), \(lifetimeProductID)")

        do {
            let productIDs = Set([subscriptionProductID, lifetimeProductID])
            print("📦 PremiumManager: Requesting products from StoreKit...")
            products = try await Product.products(for: productIDs)
            availableProducts = products

            // Log loaded products for debugging
            print("📱 PremiumManager: Loaded \(products.count) products")
            for product in products {
                print("💰 Product: \(product.id) - \(product.displayName) - \(product.displayPrice)")
            }

            if products.isEmpty {
                print("⚠️ PremiumManager: No products loaded! This could mean:")
                print("   - StoreKit configuration is not set up in scheme")
                print("   - Product IDs don't match StoreKit configuration")
                print("   - Running on device without TestFlight/App Store")
            }
        } catch {
            print("❌ PremiumManager: Failed to load products: \(error)")
            print("❌ PremiumManager: Error details: \(error.localizedDescription)")
            errorMessage = "Failed to load products: \(error.localizedDescription)"
        }
    }

    private func updateCustomerProductStatus() async {
        var isSubscribed = false
        var isLifetimePremium = false

        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else {
                continue
            }

            if transaction.productID == subscriptionProductID {
                isSubscribed = true
            } else if transaction.productID == lifetimeProductID {
                isLifetimePremium = true
            }
        }

        self.isSubscribed = isSubscribed
        self.isLifetimePremium = isLifetimePremium
        self.isPremium = isSubscribed || isLifetimePremium

        savePremiumStatus()
    }

    private func handlePurchaseSuccess(verification: VerificationResult<Transaction>, product: Product) async {
        guard case .verified(let transaction) = verification else {
            return
        }

        if product.id == subscriptionProductID {
            isSubscribed = true
        } else if product.id == lifetimeProductID {
            isLifetimePremium = true
        }

        isPremium = true
        savePremiumStatus()

        // Add 300 gems as a bonus for purchasing premium
        await addPurchaseBonusGems()

        await transaction.finish()
    }
    
    private func addPurchaseBonusGems() async {
        let currencyManager = CurrencyManager.shared
        let gemsToAdd = 300
        
        await withCheckedContinuation { continuation in
            currencyManager.addGems(gemsToAdd, source: .premium_purchase, description: "Premium purchase bonus") { error in
                if let error = error {
                    print("❌ PremiumManager: Failed to add bonus gems: \(error)")
                } else {
                    print("💰 PremiumManager: Successfully added \(gemsToAdd) bonus gems for premium purchase")
                }
                continuation.resume()
            }
        }
    }

    private func loadPremiumStatus() {
        let defaults = UserDefaults.standard
        isPremium = defaults.bool(forKey: isPremiumKey)
        isSubscribed = defaults.bool(forKey: isSubscribedKey)
        isLifetimePremium = defaults.bool(forKey: isLifetimePremiumKey)
    }

    private func savePremiumStatus() {
        let defaults = UserDefaults.standard
        defaults.set(isPremium, forKey: isPremiumKey)
        defaults.set(isSubscribed, forKey: isSubscribedKey)
        defaults.set(isLifetimePremium, forKey: isLifetimePremiumKey)
    }
}

// MARK: - Premium Error

enum PremiumError: LocalizedError {
    case productNotFound
    case userCancelled
    case purchasePending
    case alreadyPremium
    case unknown

    var errorDescription: String? {
        switch self {
        case .productNotFound:
            return "premium_error_product_not_found".localized
        case .userCancelled:
            return "premium_error_user_cancelled".localized
        case .purchasePending:
            return "premium_error_purchase_pending".localized
        case .alreadyPremium:
            return "premium_error_already_premium".localized
        case .unknown:
            return "premium_error_unknown".localized
        }
    }
}

// MARK: - Premium Features

extension PremiumManager {
    static let weeklyQuestLimit = 7
    // MARK: - Weekly Quest Tracking

    private func getCurrentWeekStart() -> Date {
        let calendar = Calendar.current
        let now = Date()
        let weekStart = calendar.dateInterval(of: .weekOfYear, for: now)?.start ?? now
        return calendar.startOfDay(for: weekStart)
    }

    private func shouldResetWeeklyCount() -> Bool {
        let defaults = UserDefaults.standard
        let lastResetDate = defaults.object(forKey: weeklyQuestResetDateKey) as? Date ?? Date.distantPast
        let currentWeekStart = getCurrentWeekStart()

        return !Calendar.current.isDate(lastResetDate, inSameDayAs: currentWeekStart)
    }

    private func resetWeeklyCountIfNeeded() {
        if shouldResetWeeklyCount() {
            let defaults = UserDefaults.standard
            defaults.set(0, forKey: weeklyQuestCountKey)
            defaults.set(getCurrentWeekStart(), forKey: weeklyQuestResetDateKey)
        }
    }

    func getWeeklyQuestCount() -> Int {
        resetWeeklyCountIfNeeded()
        return UserDefaults.standard.integer(forKey: weeklyQuestCountKey)
    }

    func incrementWeeklyQuestCount() {
        resetWeeklyCountIfNeeded()
        let currentCount = UserDefaults.standard.integer(forKey: weeklyQuestCountKey)
        UserDefaults.standard.set(currentCount + 1, forKey: weeklyQuestCountKey)
    }

    func canCreateQuest() -> Bool {
        return isPremium || getWeeklyQuestCount() < Self.weeklyQuestLimit
    }

    func remainingFreeQuests() -> Int {
        return max(0, Self.weeklyQuestLimit - getWeeklyQuestCount())
    }

    func shouldShowPaywall() -> Bool {
        return !isPremium && getWeeklyQuestCount() >= Self.weeklyQuestLimit
    }

    // MARK: - Legacy Support (for backward compatibility)

    func canCreateQuest(currentQuestCount: Int) -> Bool {
        return canCreateQuest()
    }

    func remainingFreeQuests(currentQuestCount: Int) -> Int {
        return remainingFreeQuests()
    }

    func shouldShowPaywall(currentQuestCount: Int) -> Bool {
        return shouldShowPaywall()
    }
}
