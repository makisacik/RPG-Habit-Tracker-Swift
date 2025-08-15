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
                            if let characterClass = CharacterClass(rawValue: user.characterClass ?? "knight") {
                                Image(characterClass.iconName)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 150, height: 150)
                                    .shadow(radius: 8)
                            }
                            
                            Text(user.nickname ?? "Unknown")
                                .font(.appFont(size: 28, weight: .black))
                                .foregroundColor(theme.textColor)
                            
                            if let characterClass = CharacterClass(rawValue: user.characterClass ?? "") {
                                Text(characterClass.displayName)
                                    .font(.appFont(size: 18))
                                    .foregroundColor(theme.textColor)
                            }
                        }
                        .padding(.top, 20)
                        .padding(.bottom, 20)
                    }
                    .frame(height: 250)
                    .clipped()
                    
                    VStack(spacing: 12) {
                        // Health Bar
                        HealthBarView(healthManager: healthManager, size: .large, showShineAnimation: false)
                            .padding(.horizontal)
                        
                        // Level and Experience
                        VStack(spacing: 8) {
                            HStack {
                                Image("minimap_icon_star_yellow")
                                    .resizable()
                                    .frame(width: 18, height: 18)
                                Text("\(String.level.localized) \(user.level)")
                                    .font(.appFont(size: 18))
                                    .foregroundColor(theme.textColor)
                                Spacer()
                                Text("\(String.exp.localized): \(user.exp)/100")
                                    .font(.appFont(size: 14))
                                    .foregroundColor(theme.textColor)
                            }
                            
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(theme.backgroundColor.opacity(0.7))
                                    .shadow(color: .black.opacity(0.15), radius: 2, x: 0, y: 1)
                                    .frame(height: 22)

                                GeometryReader { geometry in
                                    let expRatio = min(CGFloat(user.exp) / 100.0, 1.0)
                                    if expRatio > 0 {
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(
                                                LinearGradient(
                                                    gradient: Gradient(colors: [
                                                        Color.green.opacity(0.9),
                                                        Color.green.opacity(0.7),
                                                        Color.green.opacity(0.9)
                                                    ]),
                                                    startPoint: .leading,
                                                    endPoint: .trailing
                                                )
                                            )
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 8)
                                                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                            )
                                            .frame(width: geometry.size.width * expRatio, height: 22)
                                            .animation(.easeOut(duration: 0.3), value: expRatio)
                                    }
                                }
                                .frame(height: 22)

                                HStack {
                                    Spacer()
                                    Text("\(user.exp) / 100")
                                        .font(.appFont(size: 12, weight: .black))
                                        .foregroundColor(theme.textColor)
                                        .shadow(radius: 1)
                                    Spacer()
                                }
                            }
                            .frame(height: 22)
                        }
                    }
                    .padding(.horizontal)
                    
                    Divider()
                        .padding(.horizontal)
                    
                    InventoryView()
                    
                    Spacer()
                }
            }
        }
                        .navigationTitle(String.character.localized)
        .navigationBarTitleDisplayMode(.inline)
    }
}

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
