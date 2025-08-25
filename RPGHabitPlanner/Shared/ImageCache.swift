//
//  ImageCache.swift
//  RPGHabitPlanner
//
//  Created by Assistant on 7.01.2025.
//

import UIKit
import Foundation
import SwiftUI

// MARK: - Image Cache

class ImageCache {
    static let shared = ImageCache()
    private let cache = NSCache<NSString, UIImage>()
    private let queue = DispatchQueue(label: "com.rpghabitplanner.imagecache", qos: .userInitiated)

    private init() {
        cache.countLimit = 100 // Limit cache to 100 images
        cache.totalCostLimit = 50 * 1024 * 1024 // 50MB limit

        // Register for memory pressure notifications
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleMemoryPressure),
            name: UIApplication.didReceiveMemoryWarningNotification,
            object: nil
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func getImage(for name: String) -> UIImage? {
        return queue.sync {
            return cache.object(forKey: name as NSString)
        }
    }

    func setImage(_ image: UIImage, for name: String) {
        queue.async {
            self.cache.setObject(image, forKey: name as NSString)
        }
    }

    func clearCache() {
        queue.async {
            self.cache.removeAllObjects()
        }
    }

    @objc private func handleMemoryPressure() {
        clearCache()
    }
}

// MARK: - Rarity Badge

public struct RarityBadge: View {
    let rarity: AssetRarity

    public init(rarity: AssetRarity) {
        self.rarity = rarity
    }

    public var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(rarity.color)
                .frame(width: 8, height: 8)

            Text(rarity.rawValue.localized)
                .font(.appFont(size: 12, weight: .medium))
                .foregroundColor(rarity.color)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(rarity.color.opacity(0.2))
                .overlay(
                    Capsule()
                        .stroke(rarity.borderColor, lineWidth: 1)
                )
        )
    }
}

// MARK: - Optimized Image Loader

public struct OptimizedImageLoader: View {
    let imageName: String
    let height: CGFloat
    @State private var image: UIImage?
    @State private var isLoading = true

    public init(imageName: String, height: CGFloat) {
        self.imageName = imageName
        self.height = height
    }

    public var body: some View {
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
        if let cachedImage = ImageCache.shared.getImage(for: imageName) {
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
