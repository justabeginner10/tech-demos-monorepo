import Lottie
import SwiftUI

struct GalleryClipCard: View {
    var clip: AnimationClip
    var isSelected: Bool

    var body: some View {
        DemoChrome.chartCard(title: clip.title, subtitle: metrics) {
            VStack(alignment: .leading, spacing: 8) {
                if isSelected {
                    BundledLottieStage(
                        clip: clip,
                        playback: .looping,
                        instanceID: clip.id,
                        height: 180
                    )
                } else {
                    Text("Unmounted")
                        .font(.subheadline)
                        .foregroundStyle(DemoPalette.inkMuted)
                        .frame(maxWidth: .infinity)
                        .frame(height: 180)
                }

                Text("LottieAnimation.named(\"\(clip.fileName)\")")
                    .font(.caption2.monospaced())
                    .foregroundStyle(DemoPalette.inkMuted)
                    .padding(.horizontal, 8)

                chipRow
            }
        }
    }

    private var metrics: String {
        guard let animation = clip.load() else { return "missing" }
        let fps = LottieFormat.whole(animation.framerate)
        let end = LottieFormat.whole(animation.endFrame)
        let width = LottieFormat.whole(animation.size.width)
        let height = LottieFormat.whole(animation.size.height)
        return "\(fps) fps · 0–\(end) · \(width)×\(height)"
    }

    private var chipRow: some View {
        HStack(spacing: 6) {
            ForEach(clip.chips, id: \.self) { label in
                DemoChrome.chip(label)
            }
        }
        .padding(.horizontal, 8)
        .padding(.bottom, 8)
    }
}
