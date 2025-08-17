import SwiftUI
import Combine

struct SpriteStripView: View {
    let imageName: String
    var columns: Int?
    var rows: Int = 1
    var fps: Double = 10
    var isPlaying: Bool = true

    @State private var frames: [CGImage] = []
    @State private var index: Int = 0

    var body: some View {
        Group {
            if let currentFrame = frames.indices.contains(index) ? frames[index] : nil {
                Image(uiImage: UIImage(cgImage: currentFrame))
                    .resizable()
                    .scaledToFit()
            } else {
                Color.clear
            }
        }
        .onAppear { prepareFramesIfNeeded() }
        .onChange(of: imageName) { _ in
            frames.removeAll()
            index = 0
            prepareFramesIfNeeded()
        }
        .onReceive(timer) { _ in
            guard isPlaying, !frames.isEmpty else { return }
            index = (index + 1) % frames.count
        }
        .animation(nil, value: index) // no implicit crossfade
    }

    // MARK: - Timer

    private var timer: Publishers.Autoconnect<Timer.TimerPublisher> {
        Timer.publish(every: max(1.0 / fps, 0.016), on: .main, in: .common).autoconnect()
    }

    // MARK: - Frame Prep

    private func prepareFramesIfNeeded() {
        guard frames.isEmpty,
              let uiImage = UIImage(named: imageName),
              let sheet = uiImage.cgImage else { return }

        let grid = computeGrid(for: sheet, manualColumns: columns, manualRows: rows)
        let frameWidth = max(sheet.width / max(grid.columns, 1), 1)
        let frameHeight = max(sheet.height / max(grid.rows, 1), 1)

        var extractedFrames: [CGImage] = []
        extractedFrames.reserveCapacity(grid.columns * grid.rows)

        for rowIndex in 0..<grid.rows {
            for columnIndex in 0..<grid.columns {
                let rect = CGRect(
                    x: columnIndex * frameWidth,
                    y: rowIndex * frameHeight,
                    width: frameWidth,
                    height: frameHeight
                )
                if let subImage = sheet.cropping(to: rect) {
                    extractedFrames.append(subImage)
                }
            }
        }
        frames = extractedFrames
    }

    // MARK: - Grid Detection

    private func computeGrid(for image: CGImage, manualColumns: Int?, manualRows: Int) -> (rows: Int, columns: Int) {
        // 0) Manual override
        if let manual = manualColumns, manual > 0 {
            return (rows: max(manualRows, 1), columns: manual)
        }

        // 1) Common case: single row with square frames
        //    columns = imageWidth / imageHeight if divisible.
        if image.height > 0, image.width % image.height == 0 {
            let inferred = image.width / image.height
            if inferred >= 1 {
                return (rows: 1, columns: inferred)
            }
        }

        // 2) Detect transparent gutters between frames (single row)
        if let inferredByGutters = inferColumnsByTransparentGutters(image: image), inferredByGutters >= 1 {
            return (rows: 1, columns: inferredByGutters)
        }

        // 3) Fallback: one frame
        return (rows: max(manualRows, 1), columns: 1)
    }

    /// Scans the image for fully transparent columns used as gutters between frames.
    /// Returns the number of non-transparent runs (frames) if >= 1, else nil.
    private func inferColumnsByTransparentGutters(image: CGImage) -> Int? {
        // Render to RGBA8 premultipliedLast
        guard let context = CGContext(
            data: nil,
            width: image.width,
            height: image.height,
            bitsPerComponent: 8,
            bytesPerRow: image.width * 4,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else { return nil }

        context.draw(image, in: CGRect(x: 0, y: 0, width: image.width, height: image.height))
        guard let data = context.data else { return nil }

        let width = image.width
        let height = image.height
        let bytesPerRow = context.bytesPerRow
        let alphaIndex = 3 // RGBA8 premultipliedLast

        var transparentColumns = [Bool](repeating: false, count: width)

        for x in 0..<width {
            var allTransparent = true
            let columnBase = x * 4
            for y in 0..<height {
                let rowPtr = data.advanced(by: y * bytesPerRow)
                let alpha = rowPtr.load(fromByteOffset: columnBase + alphaIndex, as: UInt8.self)
                if alpha != 0 {
                    allTransparent = false
                    break
                }
            }
            transparentColumns[x] = allTransparent
        }

        // Count contiguous non-transparent runs (frames)
        var framesFound = 0
        var inRun = false
        for isTransparent in transparentColumns {
            if isTransparent {
                inRun = false
            } else {
                if !inRun {
                    framesFound += 1
                    inRun = true
                }
            }
        }

        return framesFound >= 1 ? framesFound : nil
    }
}
