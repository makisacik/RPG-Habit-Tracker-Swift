import SwiftUI
import Combine

struct SpriteStripView: View {
    let imageName: String
    let columns: Int
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
        .onAppear {
            prepareFramesIfNeeded()
        }
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

    private var timer: Publishers.Autoconnect<Timer.TimerPublisher> {
        Timer.publish(every: max(1.0 / fps, 0.016), on: .main, in: .common).autoconnect()
    }

    private func prepareFramesIfNeeded() {
        guard frames.isEmpty,
              let uiImage = UIImage(named: imageName),
              let sheet = uiImage.cgImage else { return }

        let frameW = sheet.width / columns
        let frameH = sheet.height / rows

        var extractedFrames: [CGImage] = []
        extractedFrames.reserveCapacity(columns * rows)

        for row in 0..<rows {
            for col in 0..<columns {
                let rect = CGRect(x: col * frameW, y: row * frameH, width: frameW, height: frameH)
                if let subImage = sheet.cropping(to: rect) {
                    extractedFrames.append(subImage)
                }
            }
        }
        frames = extractedFrames
    }
}
