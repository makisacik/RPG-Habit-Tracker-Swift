//
//  CharacterCustomizationView.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 10.11.2024.
//

import SwiftUI

struct CharacterCustomizationView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @StateObject private var customizationManager = CharacterCustomizationManager()
    @Binding var isCustomizationCompleted: Bool
    @State private var selectedCategory: CustomizationCategory = .body
    
    private let categories: [CustomizationCategory] = [
        .body, .skin, .hair, .eyes, .outfit, .weapon, .accessory
    ]
    
    var body: some View {
        let theme = themeManager.activeTheme
        
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(theme.backgroundColor)
            
            VStack(spacing: 0) {
                // Header
                headerView(theme: theme)
                
                // Character Preview
                characterPreviewView(theme: theme)
                
                // Category Selector
                categorySelectorView(theme: theme)
                
                // Options Grid
                optionsGridView(theme: theme)
                
                // Continue Button
                continueButtonView(theme: theme)
            }
            .padding()
        }
    }
    
    // MARK: - Header View
    @ViewBuilder
    private func headerView(theme: Theme) -> some View {
        VStack(spacing: 16) {
            Image("banner_hanging")
                .resizable()
                .frame(height: 60)
                .overlay(
                    Text(String.customizeYourHero.localized)
                        .font(.appFont(size: 18, weight: .black))
                        .foregroundColor(theme.textColor)
                        .padding(.top, 10)
                )
            
            Text(String.createYourUniqueCharacter.localized)
                .font(.appFont(size: 16))
                .foregroundColor(theme.textColor.opacity(0.8))
                .multilineTextAlignment(.center)
        }
        .padding(.bottom, 20)
    }
    
    // MARK: - Character Preview View
    @ViewBuilder
    private func characterPreviewView(theme: Theme) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(theme.cardBackgroundColor)
                .shadow(color: theme.textColor.opacity(0.1), radius: 8, x: 0, y: 4)
            
            VStack(spacing: 12) {
                // Character Image Stack
                ZStack {
                    // Wings (Accessory) - Draw first so it appears behind everything
                    if let accessory = customizationManager.currentCustomization.accessory {
                        Image(accessory.rawValue)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 120)
                    }
                    
                    // Body
                    Image(customizationManager.currentCustomization.bodyType.rawValue)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 120)
                        .colorMultiply(customizationManager.currentCustomization.skinColor.color)
                    
                    // Hair
                    Image(customizationManager.currentCustomization.hairStyle.rawValue)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 120)
                        .colorMultiply(customizationManager.currentCustomization.hairColor.color)
                    
                    // Eyes
                    Image(customizationManager.currentCustomization.eyeColor.rawValue)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 120)
                    
                    // Outfit
                    Image(customizationManager.currentCustomization.outfit.rawValue)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 120)
                    
                    // Weapon
                    Image(customizationManager.currentCustomization.weapon.rawValue)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 120)
                    
                    // Other Accessories (non-wings) - Draw last so they appear on top
                    if let accessory = customizationManager.currentCustomization.accessory,
                       accessory != .wingsWhite {
                        Image(accessory.rawValue)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 120)
                    }
                }
                
                Text(String.preview.localized)
                    .font(.appFont(size: 14, weight: .medium))
                    .foregroundColor(theme.textColor.opacity(0.7))
            }
            .padding(20)
        }
        .frame(height: 180)
        .padding(.bottom, 20)
    }
    
    // MARK: - Category Selector View
    @ViewBuilder
    private func categorySelectorView(theme: Theme) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(categories, id: \.self) { category in
                    CategoryButton(
                        category: category,
                        isSelected: selectedCategory == category,
                        theme: theme
                    ) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedCategory = category
                        }
                    }
                }
            }
            .padding(.horizontal, 4)
        }
        .padding(.bottom, 20)
    }
    
    // MARK: - Options Grid View
    @ViewBuilder
    private func optionsGridView(theme: Theme) -> some View {
        ScrollView {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3), spacing: 12) {
                ForEach(getOptionsForCategory(), id: \.id) { option in
                    OptimizedCustomizationOptionCard(
                        option: option,
                        isSelected: isOptionSelected(option),
                        theme: theme
                    ) {
                        handleOptionSelection(option)
                    }
                }
            }
            .padding(.horizontal, 4)
        }
        .frame(maxHeight: 300)
    }
    
    // MARK: - Continue Button View
    @ViewBuilder
    private func continueButtonView(theme: Theme) -> some View {
        Button(action: {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                isCustomizationCompleted = true
            }
        }) {
            Text(String.continueButton.localized)
                .font(.appFont(size: 18, weight: .bold))
                .foregroundColor(theme.buttonTextColor)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(
                    RoundedRectangle(cornerRadius: 25)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [theme.gradientStart, theme.gradientEnd]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .shadow(color: theme.primaryColor.opacity(0.3), radius: 8, x: 0, y: 4)
                )
        }
        .padding(.top, 20)
    }
    
    // MARK: - Helper Methods
    private func getOptionsForCategory() -> [CustomizationOption] {
        switch selectedCategory {
        case .body:
            return BodyType.allCases.map { CustomizationOption(id: $0.rawValue, name: $0.displayName, isPremium: $0.isPremium, imageName: $0.previewImageName) }
        case .skin:
            return SkinColor.allCases.map { CustomizationOption(id: $0.rawValue, name: $0.displayName, isPremium: false, color: $0.color) }
        case .hair:
            return HairStyle.allCases.map { CustomizationOption(id: $0.rawValue, name: $0.displayName, isPremium: $0.isPremium, imageName: $0.previewImageName) }
        case .eyes:
            return EyeColor.allCases.map { CustomizationOption(id: $0.rawValue, name: $0.displayName, isPremium: $0.isPremium, imageName: $0.previewImageName) }
        case .outfit:
            return Outfit.allCases.map { CustomizationOption(id: $0.rawValue, name: $0.displayName, isPremium: $0.isPremium, imageName: $0.previewImageName) }
        case .weapon:
            return CharacterWeapon.allCases.map { CustomizationOption(id: $0.rawValue, name: $0.displayName, isPremium: $0.isPremium, imageName: $0.previewImageName) }
        case .accessory:
            return Accessory.allCases.map { CustomizationOption(id: $0.rawValue, name: $0.displayName, isPremium: $0.isPremium, imageName: $0.previewImageName) }
        }
    }
    
    private func isOptionSelected(_ option: CustomizationOption) -> Bool {
        switch selectedCategory {
        case .body:
            return customizationManager.currentCustomization.bodyType.rawValue == option.id
        case .skin:
            return customizationManager.currentCustomization.skinColor.rawValue == option.id
        case .hair:
            return customizationManager.currentCustomization.hairStyle.rawValue == option.id
        case .eyes:
            return customizationManager.currentCustomization.eyeColor.rawValue == option.id
        case .outfit:
            return customizationManager.currentCustomization.outfit.rawValue == option.id
        case .weapon:
            return customizationManager.currentCustomization.weapon.rawValue == option.id
        case .accessory:
            return customizationManager.currentCustomization.accessory?.rawValue == option.id
        }
    }
    
    private func handleOptionSelection(_ option: CustomizationOption) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            switch selectedCategory {
            case .body:
                if let bodyType = BodyType(rawValue: option.id) {
                    customizationManager.updateBodyType(bodyType)
                }
            case .skin:
                if let skinColor = SkinColor(rawValue: option.id) {
                    customizationManager.updateSkinColor(skinColor)
                }
            case .hair:
                if let hairStyle = HairStyle(rawValue: option.id) {
                    customizationManager.updateHairStyle(hairStyle)
                }
            case .eyes:
                if let eyeColor = EyeColor(rawValue: option.id) {
                    customizationManager.updateEyeColor(eyeColor)
                }
            case .outfit:
                if let outfit = Outfit(rawValue: option.id) {
                    customizationManager.updateOutfit(outfit)
                }
            case .weapon:
                if let weapon = CharacterWeapon(rawValue: option.id) {
                    customizationManager.updateWeapon(weapon)
                }
            case .accessory:
                if let accessory = Accessory(rawValue: option.id) {
                    customizationManager.updateAccessory(accessory)
                }
            }
        }
    }
}

// MARK: - Supporting Types and Views

enum CustomizationCategory: String, CaseIterable {
    case body = "Body"
    case skin = "Skin"
    case hair = "Hair"
    case eyes = "Eyes"
    case outfit = "Outfit"
    case weapon = "Weapon"
    case accessory = "Accessory"
    
    var icon: String {
        switch self {
        case .body: return "person.fill"
        case .skin: return "paintbrush.fill"
        case .hair: return "scissors"
        case .eyes: return "eye.fill"
        case .outfit: return "tshirt.fill"
        case .weapon: return "sword.fill"
        case .accessory: return "crown.fill"
        }
    }
}

struct CustomizationOption: Identifiable {
    let id: String
    let name: String
    let isPremium: Bool
    let imageName: String?
    let color: Color?
    
    init(id: String, name: String, isPremium: Bool, imageName: String? = nil, color: Color? = nil) {
        self.id = id
        self.name = name
        self.isPremium = isPremium
        self.imageName = imageName
        self.color = color
    }
}

struct CategoryButton: View {
    let category: CustomizationCategory
    let isSelected: Bool
    let theme: Theme
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: category.icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(isSelected ? theme.buttonTextColor : theme.textColor)
                
                Text(category.rawValue)
                    .font(.appFont(size: 12, weight: .medium))
                    .foregroundColor(isSelected ? theme.buttonTextColor : theme.textColor)
            }
            .frame(width: 80, height: 60)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? theme.primaryColor : theme.cardBackgroundColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? theme.primaryColor : Color.clear, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct OptimizedCustomizationOptionCard: View {
    let option: CustomizationOption
    let isSelected: Bool
    let theme: Theme
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    if let imageName = option.imageName {
                        OptimizedImageLoader(imageName: imageName, height: 40)
                    } else if let color = option.color {
                        Circle()
                            .fill(color)
                            .frame(width: 40, height: 40)
                    }
                }
                
                Text(option.name)
                    .font(.appFont(size: 10, weight: .medium))
                    .foregroundColor(theme.textColor)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
            }
            .frame(height: 80)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? theme.primaryColor.opacity(0.2) : theme.cardBackgroundColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? theme.primaryColor : Color.clear, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Simple Image Cache
class ImageCache {
    static let shared = ImageCache()
    private var cache: [String: UIImage] = [:]
    private let queue = DispatchQueue(label: "imageCache", qos: .userInitiated)
    
    func getImage(_ name: String) -> UIImage? {
        return queue.sync { cache[name] }
    }
    
    func setImage(_ image: UIImage, for name: String) {
        queue.async {
            self.cache[name] = image
        }
    }
    
    func clearCache() {
        queue.async {
            self.cache.removeAll()
        }
    }
}

// MARK: - Optimized Image Loader
struct OptimizedImageLoader: View {
    let imageName: String
    let height: CGFloat
    @State private var image: UIImage?
    @State private var isLoading = true
    
    var body: some View {
        Group {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: height)
                    .clipped()
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: height)
                    .overlay(
                        Group {
                            if isLoading {
                                ProgressView()
                                    .scaleEffect(0.6)
                            } else {
                                Image(systemName: "photo")
                                    .foregroundColor(.gray)
                            }
                        }
                    )
            }
        }
        .onAppear {
            loadImage()
        }
    }
    
    private func loadImage() {
        guard image == nil else { return }
        
        // Check cache first
        if let cachedImage = ImageCache.shared.getImage(imageName) {
            self.image = cachedImage
            self.isLoading = false
            return
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            // Load and resize image on background thread
            if let originalImage = UIImage(named: imageName) {
                let resizedImage = resizeImage(originalImage, to: CGSize(width: height * 2, height: height * 2))
                
                // Cache the resized image
                ImageCache.shared.setImage(resizedImage, for: imageName)
                
                DispatchQueue.main.async {
                    self.image = resizedImage
                    self.isLoading = false
                }
            } else {
                DispatchQueue.main.async {
                    self.isLoading = false
                }
            }
        }
    }
    
    private func resizeImage(_ image: UIImage, to size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: size))
        }
    }
}

// MARK: - Optimized Character Preview Component
struct CustomizedCharacterPreviewCard: View {
    let customization: CharacterCustomization
    let theme: Theme
    let showTitle: Bool
    
    init(customization: CharacterCustomization, theme: Theme, showTitle: Bool = true) {
        self.customization = customization
        self.theme = theme
        self.showTitle = showTitle
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Optimized character visual
            OptimizedCharacterView(customization: customization)
                .frame(height: 120)
            
            if showTitle {
                VStack(spacing: 4) {
                    Text(String.yourCharacter.localized)
                        .font(.appFont(size: 12))
                        .foregroundColor(theme.textColor.opacity(0.7))
                    
                    Text(String.customized.localized)
                        .font(.appFont(size: 16, weight: .bold))
                        .foregroundColor(theme.textColor)
                }
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(theme.cardBackgroundColor)
                .shadow(color: theme.textColor.opacity(0.1), radius: 10, x: 0, y: 5)
        )
    }
}

// MARK: - Memory-Efficient Character View
struct OptimizedCharacterView: View {
    let customization: CharacterCustomization
    @State private var cachedImage: UIImage?
    
    var body: some View {
        Group {
            if let cachedImage = cachedImage {
                Image(uiImage: cachedImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else {
                // Fallback while loading
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .overlay(
                        ProgressView()
                            .scaleEffect(0.8)
                    )
            }
        }
        .onAppear {
            generateCharacterImage()
        }
        .onChange(of: customization) { _ in
            generateCharacterImage()
        }
    }
    
    private func generateCharacterImage() {
        DispatchQueue.global(qos: .userInitiated).async {
            let image = createCharacterImage()
            DispatchQueue.main.async {
                self.cachedImage = image
            }
        }
    }
    
    private func createCharacterImage() -> UIImage? {
        let size = CGSize(width: 240, height: 240) // Fixed size for consistency
        UIGraphicsBeginImageContextWithOptions(size, false, 2.0) // 2x scale for retina
        
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        
        // Clear background
        context.setFillColor(UIColor.clear.cgColor)
        context.fill(CGRect(origin: .zero, size: size))
        
        // Draw wings first (if present) so they appear behind everything
        if let accessory = customization.accessory, accessory == .wingsWhite {
            let accessoryImage = ImageCache.shared.getImage(accessory.rawValue) ?? UIImage(named: accessory.rawValue)
            if let accessoryImage = accessoryImage {
                drawImage(accessoryImage, in: CGRect(origin: .zero, size: size), tintColor: nil)
            }
        }
        
        // Draw character layers in order
        let layers = [
            (customization.bodyType.rawValue, nil),
            (customization.hairStyle.rawValue, customization.hairColor.color),
            (customization.outfit.rawValue, nil),
            (customization.weapon.rawValue, nil)
        ]
        
        for (imageName, tintColor) in layers {
            // Try cache first, then load from bundle
            let image = ImageCache.shared.getImage(imageName) ?? UIImage(named: imageName)
            if let image = image {
                drawImage(image, in: CGRect(origin: .zero, size: size), tintColor: tintColor)
            }
        }
        
        // Draw other accessories (non-wings) last so they appear on top
        if let accessory = customization.accessory, accessory != .wingsWhite {
            let accessoryImage = ImageCache.shared.getImage(accessory.rawValue) ?? UIImage(named: accessory.rawValue)
            if let accessoryImage = accessoryImage {
                drawImage(accessoryImage, in: CGRect(origin: .zero, size: size), tintColor: nil)
            }
        }
        
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return result
    }
    
    private func drawImage(_ image: UIImage, in rect: CGRect, tintColor: Color?) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        context.saveGState()
        
        // Apply tint if specified
        if let tintColor = tintColor {
            context.setBlendMode(.multiply)
            context.setFillColor(UIColor(tintColor).cgColor)
            context.fill(rect)
        }
        
        // Draw image
        image.draw(in: rect, blendMode: .normal, alpha: 1.0)
        
        context.restoreGState()
    }
}

// MARK: - String Extensions
extension String {
    static let createYourUniqueCharacter = "createYourUniqueCharacter"
    static let preview = "preview"
    static let yourCharacter = "yourCharacter"
    static let customized = "customized"
}
