import Lottie
import SwiftUI

/// How one `LottieView` should be configured. Each case is one public modifier.
enum StagePlayback {
    /// `.looping()` — from progress 0 to 1, `LottieLoopMode.loop`.
    case looping
    /// `.currentProgress(_:)` pauses at a 0...1 progress.
    case currentProgress(AnimationProgressTime)
    /// `.currentFrame(_:)` pauses at a frame time.
    case currentFrame(AnimationFrameTime)
    /// `.playing(_:)` with a `LottiePlaybackMode.PlaybackMode`.
    case playing(LottiePlaybackMode.PlaybackMode)
    /// `.paused(at:)`.
    case paused(LottiePlaybackMode.PausedState)
}

/// One bundled JSON file in a `LottieView`. The caller owns playback.
struct BundledLottieStage: View {
    var clip: AnimationClip
    var playback: StagePlayback
    var speed: Double = 1
    var instanceID: String
    var height: CGFloat = 220
    var progress: Binding<AnimationProgressTime>? = nil
    var onFinish: (@MainActor (Bool) -> Void)? = nil

    var body: some View {
        Group {
            if let animation = clip.load() {
                player(animation)
            } else {
                Text("\(clip.fileName).json is not in the app bundle.")
                    .font(.caption)
                    .foregroundStyle(DemoPalette.inkMuted)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .frame(height: height)
        .motionStage()
    }

    private func player(_ animation: LottieAnimation) -> some View {
        let base = LottieView(animation: animation)
            .resizable()
            .animationSpeed(speed)
        let configured = apply(playback, to: base)
        return configured
            .animationDidFinish(finishHandler)
            .getRealtimeAnimationProgress(progress)
            .id(instanceID)
            .accessibilityLabel(clip.title)
    }

    private var finishHandler: LottieCompletionBlock? {
        guard let onFinish else { return nil }
        return PlaybackSink.finished(onFinish)
    }

    private func apply(
        _ playback: StagePlayback,
        to view: LottieView<EmptyView>
    ) -> LottieView<EmptyView> {
        switch playback {
        case .looping:
            view.looping()
        case .currentProgress(let value):
            view.currentProgress(value)
        case .currentFrame(let value):
            view.currentFrame(value)
        case .playing(let mode):
            view.playing(mode)
        case .paused(let state):
            view.paused(at: state)
        }
    }
}
