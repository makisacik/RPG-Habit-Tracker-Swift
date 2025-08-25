//
//  PaywallView.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 28.10.2024.
//

import SwiftUI
import StoreKit

struct PaywallView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var premiumManager: PremiumManager
    @Environment(\.dismiss) private var dismiss

    @State private var selectedPlan: PremiumPlan = .monthly
    @State private var showingError = false

    private let theme: Theme

    init() {
        self.theme = ThemeManager.shared.activeTheme
    }

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    theme.backgroundColor,
                    theme.backgroundColor.opacity(0.8),
                    theme.accentColor.opacity(0.1)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header with close button
                HStack {
                    Spacer()
                    Button(String(localized: "close")) {
                        dismiss()
                    }
                    .font(.appFont(size: 16, weight: .medium))
                    .foregroundColor(theme.textColor)
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                }

                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        headerSection

                        // Premium features
                        featuresSection

                        // Pricing plans
                        pricingSection

                        // Action buttons
                        actionSection

                        // Terms and restore
                        footerSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 20)
                }
            }
        }
        .alert(String(localized: "purchase_error"), isPresented: $showingError) {
            Button(String(localized: "ok_button")) { }
        } message: {
            Text(premiumManager.errorMessage ?? String(localized: "an_error_occurred_during_purchase"))
        }
        .onReceive(premiumManager.$errorMessage) { errorMessage in
            showingError = errorMessage != nil
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(spacing: 16) {
            // Premium crown icon
            ZStack {
                Circle()
                    .fill(theme.accentColor.opacity(0.2))
                    .frame(width: 80, height: 80)

                Image(systemName: "crown.fill")
                    .font(.system(size: 40))
                    .foregroundColor(theme.accentColor)
            }

            VStack(spacing: 8) {
                Text(String(localized: "unlock_premium"))
                    .font(.appFont(size: 28, weight: .black))
                    .foregroundColor(theme.textColor)
                    .multilineTextAlignment(.center)

                Text(String(localized: "transform_quest_planning_experience"))
                    .font(.appFont(size: 16))
                    .foregroundColor(theme.textColor.opacity(0.8))
                    .multilineTextAlignment(.center)
            }
        }
    }

    // MARK: - Features Section

    private var featuresSection: some View {
        VStack(spacing: 16) {
            Text(String(localized: "premium_features"))
                .font(.appFont(size: 20, weight: .black))
                .foregroundColor(theme.textColor)
                .frame(maxWidth: .infinity, alignment: .leading)

            VStack(spacing: 12) {
                PremiumFeatureRow(icon: "infinity", title: String(localized: "premium_unlimited_quests"), description: String(localized: "premium_unlimited_quests_description"))
                PremiumFeatureRow(icon: "chart.bar.fill", title: String(localized: "premium_advanced_analytics"), description: String(localized: "premium_advanced_analytics_description"))
                PremiumFeatureRow(icon: "paintbrush.fill", title: String(localized: "premium_custom_themes"), description: String(localized: "premium_custom_themes_description"))
                PremiumFeatureRow(icon: "icloud.fill", title: String(localized: "premium_cloud_sync"), description: String(localized: "premium_cloud_sync_description"))
                PremiumFeatureRow(icon: "bell.badge.fill", title: String(localized: "premium_advanced_notifications"), description: String(localized: "premium_advanced_notifications_description"))
                PremiumFeatureRow(icon: "trophy.fill", title: String(localized: "premium_exclusive_achievements"), description: String(localized: "premium_exclusive_achievements_description"))
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(theme.cardBackgroundColor)
                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
    }

    // MARK: - Pricing Section

    private var pricingSection: some View {
        VStack(spacing: 16) {
            Text(String(localized: "choose_your_plan"))
                .font(.appFont(size: 20, weight: .black))
                .foregroundColor(theme.textColor)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 12) {
                PricingCard(
                    plan: .monthly,
                    isSelected: selectedPlan == .monthly
                ) { selectedPlan = .monthly }

                PricingCard(
                    plan: .lifetime,
                    isSelected: selectedPlan == .lifetime
                ) { selectedPlan = .lifetime }
            }
        }
    }

    // MARK: - Action Section

    private var actionSection: some View {
        VStack(spacing: 16) {
            Button(action: {
                Task {
                    do {
                        switch selectedPlan {
                        case .monthly:
                            try await premiumManager.purchaseSubscription()
                        case .lifetime:
                            try await premiumManager.purchaseLifetime()
                        }
                        dismiss()
                    } catch {
                        // Error is handled by the alert
                    }
                }
            }) {
                HStack {
                    if premiumManager.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                    } else {
                        Text(String(localized: "get_premium"))
                            .font(.appFont(size: 18, weight: .black))
                            .foregroundColor(.white)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    LinearGradient(
                        colors: [theme.accentColor, theme.accentColor.opacity(0.8)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .foregroundColor(.white)
                .cornerRadius(16)
            }
            .disabled(premiumManager.isLoading)

            Button(String(localized: "restore_purchases")) {
                Task {
                    do {
                        try await premiumManager.restorePurchases()
                        dismiss()
                    } catch {
                        // Error is handled by the alert
                    }
                }
            }
            .font(.appFont(size: 16, weight: .medium))
            .foregroundColor(theme.accentColor)
            .disabled(premiumManager.isLoading)
        }
    }

    // MARK: - Footer Section

    private var footerSection: some View {
        VStack(spacing: 12) {
            HStack(spacing: 20) {
                Button(String(localized: "terms_of_service")) {
                    // Handle terms of service
                }
                .font(.appFont(size: 14, weight: .medium))
                .foregroundColor(theme.textColor.opacity(0.6))

                Button(String(localized: "privacy_policy")) {
                    // Handle privacy policy
                }
                .font(.appFont(size: 14, weight: .medium))
                .foregroundColor(theme.textColor.opacity(0.6))
            }

            Text(String(localized: "subscription_terms"))
                .font(.appFont(size: 12))
                .foregroundColor(theme.textColor.opacity(0.6))
                .multilineTextAlignment(.center)
                .lineLimit(3)
        }
    }
}

// MARK: - Supporting Views

struct PremiumFeatureRow: View {
    let icon: String
    let title: String
    let description: String

    @EnvironmentObject var themeManager: ThemeManager

    private var theme: Theme {
        themeManager.activeTheme
    }

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(theme.accentColor)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.appFont(size: 16, weight: .bold))
                    .foregroundColor(theme.textColor)

                Text(description)
                    .font(.appFont(size: 14, weight: .medium))
                    .foregroundColor(theme.textColor.opacity(0.7))
            }

            Spacer()
        }
    }
}

struct PricingCard: View {
    let plan: PremiumPlan
    let isSelected: Bool
    let onTap: () -> Void

    @EnvironmentObject var themeManager: ThemeManager

    private var theme: Theme {
        themeManager.activeTheme
    }

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 12) {
                Text(plan.title)
                    .font(.appFont(size: 18, weight: .bold))
                    .foregroundColor(isSelected ? .white : theme.textColor)

                Text(plan.price)
                    .font(.appFont(size: 24, weight: .bold))
                    .foregroundColor(isSelected ? .white : theme.accentColor)

                Text(plan.description)
                    .font(.appFont(size: 14, weight: .medium))
                    .foregroundColor(isSelected ? .white.opacity(0.8) : theme.textColor.opacity(0.7))
                    .multilineTextAlignment(.center)

                if plan.isPopular {
                    Text(String(localized: "most_popular"))
                        .font(.appFont(size: 12, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.orange)
                        .cornerRadius(8)
                } else {
                    // Add invisible spacer to maintain same height when no badge
                    Color.clear
                        .frame(height: 28) // Height of the "MOST POPULAR" badge
                }
            }
            .frame(maxWidth: .infinity)
            .frame(minHeight: 140) // Ensure minimum consistent height
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? theme.accentColor : theme.cardBackgroundColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(isSelected ? theme.accentColor : theme.textColor.opacity(0.2), lineWidth: 2)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Premium Plan

enum PremiumPlan {
    case monthly
    case lifetime

    var title: String {
        switch self {
        case .monthly:
            return String(localized: "monthly")
        case .lifetime:
            return String(localized: "lifetime")
        }
    }

    var price: String {
        switch self {
        case .monthly:
            return "$4.99"
        case .lifetime:
            return "$29.99"
        }
    }

    var description: String {
        switch self {
        case .monthly:
            return String(localized: "per_month")
        case .lifetime:
            return String(localized: "one_time_payment")
        }
    }

    var isPopular: Bool {
        switch self {
        case .monthly:
            return true
        case .lifetime:
            return false
        }
    }
}
