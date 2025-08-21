//
//  CharacterView.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 5.08.2025.
//

import SwiftUI

struct CharacterView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @StateObject private var healthManager = HealthManager.shared
    @StateObject private var inventoryManager = InventoryManager.shared
    @StateObject private var boosterManager = BoosterManager.shared
    @StateObject private var customizationManager = CharacterCustomizationManager()
    @State private var showBoosterInfo = false
    @State private var refreshTrigger = false
    @State private var showShop = false
    let user: UserEntity
    
    var body: some View {
        let theme = themeManager.activeTheme
        
        ZStack {
            theme.backgroundColor
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    ZStack {
                        ParticleBackground(
                            color: Color.blue.opacity(0.2),
                            count: 15,
                            sizeRange: 8...16,
                            speedRange: 12...20
                        )
                        
                        ParticleBackground(
                            color: Color.blue.opacity(0.3),
                            count: 20,
                            sizeRange: 5...10,
                            speedRange: 6...12
                        )
                        
                        VStack(spacing: 12) {
                            // Custom Character Display
                            CustomizedCharacterPreviewCard(
                                customization: customizationManager.currentCustomization,
                                theme: theme,
                                showTitle: false
                            )
                            .frame(height: 150)
                            
                            Text(user.nickname ?? "Unknown")
                                .font(.appFont(size: 28, weight: .black))
                                .foregroundColor(theme.textColor)
                            
                            Text("Level \(user.level)")
                                .font(.appFont(size: 18))
                                .foregroundColor(theme.textColor)
                        }
                        .padding(.top, 20)
                    }
                    
                    // Health Bar
                    VStack(spacing: 8) {
                        HStack {
                            Text(String.health.localized)
                                .font(.appFont(size: 14, weight: .medium))
                                .foregroundColor(theme.textColor)
                            
                            Spacer()
                            
                            Text("\(user.health)/\(user.maxHealth)")
                                .font(.appFont(size: 14, weight: .medium))
                                .foregroundColor(theme.textColor)
                        }
                        
                        ProgressView(value: Double(user.health), total: Double(user.maxHealth))
                            .progressViewStyle(LinearProgressViewStyle(tint: .green))
                            .scaleEffect(x: 1, y: 2, anchor: .center)
                    }
                    .padding(.horizontal)
                    
                    // Experience Bar
                    VStack(spacing: 8) {
                        HStack {
                            Text(String.experience.localized)
                                .font(.appFont(size: 14, weight: .medium))
                                .foregroundColor(theme.textColor)
                            
                            Spacer()
                            
                            Text("\(user.exp)/100")
                                .font(.appFont(size: 14, weight: .medium))
                                .foregroundColor(theme.textColor)
                        }
                        
                        ProgressView(value: Double(user.exp), total: 100.0)
                            .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                            .scaleEffect(x: 1, y: 2, anchor: .center)
                    }
                    .padding(.horizontal)
                    
                    // Coins Display
                    HStack {
                        Image(systemName: "coins")
                            .foregroundColor(.yellow)
                            .font(.title2)
                        
                        Text("\(user.coins)")
                            .font(.appFont(size: 18, weight: .bold))
                            .foregroundColor(theme.textColor)
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    Divider()
                        .padding(.horizontal)
                    
                    // Collectible Items Display
                    CollectibleDisplayView()
                        .environmentObject(inventoryManager)
                        .environmentObject(themeManager)
                    
                    Divider()
                        .padding(.horizontal)
                    
                    InventoryView()
                    
                    Spacer()
                }
            }
        }
        .navigationTitle(String.character.localized)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            // LEFT: Active booster indicator
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    showBoosterInfo = true
                }) {
                    HStack(spacing: 6) {
                        Image("icon_lightning")
                            .resizable()
                            .frame(width: 18, height: 18)
                        
                        Text("\(boosterManager.activeBoosterCount)")
                            .font(.appFont(size: 12, weight: .bold))
                            .foregroundColor(theme.textColor)
                            .frame(width: 16, height: 16)
                            .background(
                                Circle()
                                    .fill(Color.red)
                            )
                    }
                }
                .disabled(boosterManager.activeBoosterCount == 0)
            }
            
            // RIGHT: Shop button
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showShop = true
                }) {
                    Image(systemName: "cart.fill")
                        .foregroundColor(theme.textColor)
                }
            }
        }
        .sheet(isPresented: $showBoosterInfo, content: {
            BoosterInfoModalView()
                .environmentObject(boosterManager)
                .environmentObject(themeManager)
        })
        .sheet(isPresented: $showShop, content: {
            ShopView()
                .environmentObject(themeManager)
        })
        .onAppear {
            customizationManager.loadCustomization()
        }
    }
}

// MARK: - Particle Background

struct ParticleBackground: View {
    var color: Color
    var count: Int
    var sizeRange: ClosedRange<CGFloat>
    var speedRange: ClosedRange<Double>
    
    var body: some View {
        GeometryReader { geo in
            ForEach(0..<count, id: \.self) { _ in
                let size = CGFloat.random(in: sizeRange)
                let xPos = CGFloat.random(in: 0...geo.size.width)
                
                let startY = CGFloat.random(in: geo.size.height...(geo.size.height + 100))
                
                let endYPosition: CGFloat = -geo.size.height * 1.5
                
                let speed = Double.random(in: speedRange) * 1.8
                
                Circle()
                    .fill(color)
                    .frame(width: size, height: size)
                    .position(x: xPos, y: startY)
                    .modifier(VerticalFloat(from: startY, to: endYPosition, duration: speed))
            }
        }
    }
}

struct VerticalFloat: ViewModifier {
    @State private var y: CGFloat
    var endYPosition: CGFloat
    var duration: Double
    
    init(from startY: CGFloat, to endY: CGFloat, duration: Double) {
        self._y = State(initialValue: startY)
        self.endYPosition = endY
        self.duration = duration
    }
    
    func body(content: Content) -> some View {
        content
            .offset(y: y)
            .onAppear {
                withAnimation(Animation.linear(duration: duration).repeatForever(autoreverses: false)) {
                    y = endYPosition
                }
            }
    }
}
