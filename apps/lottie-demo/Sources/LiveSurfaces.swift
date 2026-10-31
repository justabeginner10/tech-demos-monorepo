import Lottie
import SwiftUI

// MARK: - Playback

/// Play, pause, and stop, plus loop mode and speed, for one bundled file.
private enum Transport: Equatable {
    /// `from` nil resumes at the current progress. `0` starts at the beginning.
    case playing(from: AnimationProgressTime?, loop: LoopChoice)
    case paused
    case stopped
}

struct PlaybackSurface: View {
    @State private var clip: AnimationClip = .pulse
    @State private var loop: LoopChoice = .loop
    @State private var speed: Double = 1
    @State private var transport: Transport = .playing(from: 0, loop: .loop)
    @State private var progress: AnimationProgressTime = 0
    @State private var status = "playing"
    @State private var replayToken = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            controls
            BundledLottieStage(
                clip: clip,
                playback: stagePlayback,
                speed: speed,
                instanceID: "\(clip.id)-\(replayToken)",
                progress: trackedProgress,
                onFinish: finish
            )
            Text(readout)
                .font(.caption.monospaced())
                .foregroundStyle(DemoPalette.ink)
                .fixedSize(horizontal: false, vertical: true)
        }
        .onChange(of: loop) { _, newLoop in
            if case .playing = transport {
                transport = .playing(from: nil, loop: newLoop)
                status = "playing"
            }
        }
        .onChange(of: clip) { _, _ in
            replayToken += 1
            progress = 0
            status = "playing"
            transport = .playing(from: 0, loop: loop)
        }
    }

    private var trackedProgress: Binding<AnimationProgressTime>? {
        if status == "playing" {
            return $progress
        }
        return nil
    }

    private var stagePlayback: StagePlayback {
        switch transport {
        case .playing(let from, let loop):
            .playing(.fromProgress(from, toProgress: 1, loopMode: loop.mode))
        case .paused:
            .paused(.currentFrame)
        case .stopped:
            .paused(.progress(0))
        }
    }

    private var readout: String {
        guard let animation = clip.load() else {
            return "Animation missing · \(status)"
        }
        let frame = animation.frameTime(forProgress: progress)
        let end = LottieFormat.whole(animation.endFrame)
        return "progress \(LottieFormat.progress(progress)) · frame \(LottieFormat.frame(frame)) / \(end) · \(status) · \(loop.call)"
    }

    private var controls: some View {
        VStack(alignment: .leading, spacing: 10) {
            ClipMenu(clip: $clip)
            LoopMenu(loop: $loop)
            DemoSlider(title: "Speed", value: $speed, range: 0.25...3, step: 0.25, format: "%.2f")

            HStack(spacing: 8) {
                prominentButton("Play", action: play)
                borderedButton("Pause", action: pause)
                borderedButton("Stop", action: stop)
            }

            Text(
                "Play uses playing(.fromProgress:toProgress:loopMode:). "
                    + "Pause is paused(at: .currentFrame). "
                    + "Stop is paused(at: .progress(0)), which is the SwiftUI stand-in for LottieAnimationView.stop(). "
                    + "Speed is animationSpeed. A finished Once or Twice run reports animationDidFinish(true)."
            )
            .font(.caption)
            .foregroundStyle(DemoPalette.inkMuted)
            .fixedSize(horizontal: false, vertical: true)
        }
        .demoCard()
    }

    private var isPlaying: Bool {
        if case .playing = transport { return true }
        return false
    }

    private func play() {
        let restart = isPlaying || transport == .stopped || status == "finished"
        if isPlaying {
            replayToken += 1
        }
        transport = .playing(from: restart ? 0 : nil, loop: loop)
        status = "playing"
    }

    private func pause() {
        guard isPlaying else { return }
        transport = .paused
        status = "paused"
    }

    private func stop() {
        transport = .stopped
        progress = 0
        status = "stopped"
    }

    private func finish(_ completed: Bool) {
        guard completed else { return }
        status = "finished"
        transport = .paused
    }
}

// MARK: - Range

private enum RangeCommand: Equatable {
    case progressScrub
    case frameScrub
    case progressSpan
    case frameSpan
}

struct RangeSurface: View {
    @State private var clip: AnimationClip = .orbit
    @State private var loop: LoopChoice = .playOnce
    @State private var command: RangeCommand = .progressScrub
    @State private var scrubProgress: Double = 0
    @State private var scrubFrame: Double = 0
    @State private var fromProgress: Double = 0.15
    @State private var toProgress: Double = 0.8
    @State private var fromFrame: Double = 0
    @State private var toFrame: Double = 60
    @State private var readout: AnimationProgressTime = 0
    @State private var status = "scrubbing progress"
    @State private var replayToken = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            controls
            BundledLottieStage(
                clip: clip,
                playback: stagePlayback,
                instanceID: "\(clip.id)-\(replayToken)",
                progress: trackedProgress,
                onFinish: finish
            )
            Text(readoutLine)
                .font(.caption.monospaced())
                .foregroundStyle(DemoPalette.ink)
                .fixedSize(horizontal: false, vertical: true)
        }
        .onAppear(perform: syncFrames)
        .onChange(of: clip) { _, _ in
            syncFrames()
            command = .progressScrub
            scrubProgress = 0
            scrubFrame = 0
            readout = 0
            status = "scrubbing progress"
        }
        .onChange(of: loop) { _, _ in
            resumeIfSpanning()
        }
        .onChange(of: fromProgress) { _, _ in
            resumeIfSpanning()
        }
        .onChange(of: toProgress) { _, _ in
            resumeIfSpanning()
        }
        .onChange(of: fromFrame) { _, _ in
            resumeIfSpanning()
        }
        .onChange(of: toFrame) { _, _ in
            resumeIfSpanning()
        }
    }

    private var tracksReadout: Bool {
        status == "playing" && (command == .progressSpan || command == .frameSpan)
    }

    private var trackedProgress: Binding<AnimationProgressTime>? {
        if tracksReadout {
            return $readout
        }
        return nil
    }

    private var stagePlayback: StagePlayback {
        switch command {
        case .progressScrub:
            .currentProgress(CGFloat(scrubProgress))
        case .frameScrub:
            .currentFrame(CGFloat(scrubFrame))
        case .progressSpan:
            .playing(.fromProgress(
                CGFloat(fromProgress),
                toProgress: CGFloat(toProgress),
                loopMode: loop.mode
            ))
        case .frameSpan:
            .playing(.fromFrame(
                CGFloat(fromFrame),
                toFrame: CGFloat(toFrame),
                loopMode: loop.mode
            ))
        }
    }

    private var frameSpan: ClosedRange<Double> {
        guard let animation = clip.load() else { return 0...60 }
        let start = Double(animation.startFrame)
        let end = Double(animation.endFrame)
        if end <= start {
            return start...(start + 1)
        }
        return start...end
    }

    private var readoutLine: String {
        guard let animation = clip.load() else { return status }
        let progressValue: AnimationProgressTime
        let frameValue: AnimationFrameTime
        if status == "playing" || status == "finished" {
            progressValue = readout
            frameValue = animation.frameTime(forProgress: readout)
        } else if command == .frameScrub {
            progressValue = CGFloat(scrubProgress)
            frameValue = CGFloat(scrubFrame)
        } else {
            progressValue = CGFloat(scrubProgress)
            frameValue = animation.frameTime(forProgress: progressValue)
        }
        let progressText = LottieFormat.progress(progressValue)
        let frameText = LottieFormat.frame(frameValue)
        return "progress \(progressText) · frame \(frameText) · \(status)"
    }

    private var controls: some View {
        VStack(alignment: .leading, spacing: 10) {
            ClipMenu(clip: $clip)

            DemoSlider(
                title: "Progress",
                value: progressBinding,
                range: 0...1,
                format: "%.2f"
            )
            DemoSlider(
                title: "Frame",
                value: frameBinding,
                range: frameSpan,
                format: "%.1f"
            )

            LoopMenu(loop: $loop)

            DemoSlider(title: "From progress", value: $fromProgress, range: 0...1, format: "%.2f")
            DemoSlider(title: "To progress", value: $toProgress, range: 0...1, format: "%.2f")
            prominentButton("Play progress") {
                replayToken += 1
                command = .progressSpan
                status = "playing"
            }

            DemoSlider(title: "From frame", value: $fromFrame, range: frameSpan, format: "%.1f")
            DemoSlider(title: "To frame", value: $toFrame, range: frameSpan, format: "%.1f")
            prominentButton("Play frames") {
                replayToken += 1
                command = .frameSpan
                status = "playing"
            }

            Text(
                "Dragging Progress calls currentProgress, which pauses. "
                    + "Dragging Frame calls currentFrame. "
                    + "Play progress is fromProgress. Play frames is fromFrame. "
                    + "Either end may be lower than the start, which plays backward."
            )
            .font(.caption)
            .foregroundStyle(DemoPalette.inkMuted)
            .fixedSize(horizontal: false, vertical: true)
        }
        .demoCard()
    }

    private var progressBinding: Binding<Double> {
        Binding(
            get: { scrubProgress },
            set: { newValue in
                scrubProgress = newValue
                command = .progressScrub
                status = "scrubbing progress"
                if let animation = clip.load() {
                    scrubFrame = Double(animation.frameTime(forProgress: CGFloat(newValue)))
                }
            }
        )
    }

    private var frameBinding: Binding<Double> {
        Binding(
            get: { scrubFrame },
            set: { newValue in
                scrubFrame = newValue
                command = .frameScrub
                status = "scrubbing frame"
                if let animation = clip.load() {
                    scrubProgress = Double(animation.progressTime(forFrame: CGFloat(newValue)))
                }
            }
        )
    }

    private func syncFrames() {
        guard let animation = clip.load() else { return }
        fromFrame = Double(animation.startFrame)
        toFrame = Double(animation.endFrame)
        scrubFrame = Double(animation.frameTime(forProgress: CGFloat(scrubProgress)))
    }

    private func resumeIfSpanning() {
        if command == .progressSpan || command == .frameSpan {
            status = "playing"
        }
    }

    private func finish(_ completed: Bool) {
        guard completed, status == "playing" else { return }
        status = "finished"
    }
}

// MARK: - Markers

private enum MarkerCommand: Equatable {
    case idle
    case marker(String, LoopChoice)
    case span(from: String, to: String, playEnd: Bool, loop: LoopChoice)
    case sequence([String])
}

struct MarkerSurface: View {
    @State private var clip: AnimationClip = .check
    @State private var loop: LoopChoice = .playOnce
    @State private var fromMarker = "draw"
    @State private var toMarker = "hold"
    @State private var playEnd = true
    @State private var command: MarkerCommand = .idle
    @State private var readout: AnimationProgressTime = 0
    @State private var status = "idle"
    @State private var replayToken = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            controls
            BundledLottieStage(
                clip: clip,
                playback: stagePlayback,
                instanceID: "\(clip.id)-\(replayToken)",
                progress: trackedProgress,
                onFinish: finish
            )
            Text(statusLine)
                .font(.caption.monospaced())
                .foregroundStyle(DemoPalette.ink)
                .fixedSize(horizontal: false, vertical: true)
        }
        .onAppear(perform: syncMarkers)
        .onChange(of: clip) { _, _ in
            syncMarkers()
            command = .idle
            readout = 0
            status = "idle"
        }
    }

    private var trackedProgress: Binding<AnimationProgressTime>? {
        if status == "playing" {
            return $readout
        }
        return nil
    }

    private var names: [String] {
        clip.load()?.markerNames ?? []
    }

    private var sequenceNames: [String] {
        names.filter { !LottieMarkers.isReducedMotion($0) }
    }

    private var fromName: String {
        names.contains(fromMarker) ? fromMarker : (names.first ?? "")
    }

    private var toName: String {
        names.contains(toMarker) ? toMarker : (names.last ?? "")
    }

    private var stagePlayback: StagePlayback {
        switch command {
        case .idle:
            .paused(.progress(0))
        case .marker(let name, let loop):
            .playing(.marker(name, loopMode: loop.mode))
        case .span(let from, let to, let playEndMarker, let loop):
            .playing(.fromMarker(
                from,
                toMarker: to,
                playEndMarkerFrame: playEndMarker,
                loopMode: loop.mode
            ))
        case .sequence(let markers):
            .playing(.markers(markers))
        }
    }

    private var statusLine: String {
        guard let animation = clip.load() else { return status }
        let caption = animation.markerNames.map { name in
            let frame = animation.frameTime(forMarker: name) ?? 0
            let duration = animation.durationFrameTime(forMarker: name) ?? 0
            return "\(name) @ \(LottieFormat.whole(frame)) +\(LottieFormat.whole(duration))"
        }.joined(separator: " · ")
        return "\(status) · \(caption)"
    }

    private var controls: some View {
        VStack(alignment: .leading, spacing: 10) {
            ClipMenu(clip: $clip)
            LoopMenu(loop: $loop)

            if names.isEmpty {
                Text("This file has no markers.")
                    .font(.caption)
                    .foregroundStyle(DemoPalette.inkMuted)
            } else {
                markerPicker("From", selection: fromBinding, names: names)
                markerPicker("To", selection: toBinding, names: names)
                Toggle("Play end marker frame", isOn: $playEnd)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(DemoPalette.ink)
                    .tint(DemoPalette.accent)

                prominentButton("Play marker") {
                    guard !fromName.isEmpty else { return }
                    replayToken += 1
                    command = .marker(fromName, loop)
                    status = "playing"
                }
                prominentButton("Play span") {
                    guard !fromName.isEmpty, !toName.isEmpty else { return }
                    replayToken += 1
                    command = .span(from: fromName, to: toName, playEnd: playEnd, loop: loop)
                    status = "playing"
                }
                prominentButton("Play sequence") {
                    guard !sequenceNames.isEmpty else { return }
                    replayToken += 1
                    command = .sequence(sequenceNames)
                    status = "playing"
                }
            }

            Text(markerNote)
                .font(.caption)
                .foregroundStyle(DemoPalette.inkMuted)
                .fixedSize(horizontal: false, vertical: true)
        }
        .demoCard()
    }

    private var markerNote: String {
        var note = "Play marker is marker(_:loopMode:). Play span is fromMarker(_:toMarker:playEndMarkerFrame:loopMode:). "
        note += "Play sequence is markers(_:), which has no loop mode and skips a missing name. "
        note += "The reduced-motion name is left out of the sequence."
        if names.contains(where: LottieMarkers.isReducedMotion) {
            note += " Pulse's \"reduced motion\" marker replaces every play command on that file while the system Reduce Motion switch is on."
        }
        return note
    }

    private var fromBinding: Binding<String> {
        Binding(get: { fromName }, set: { fromMarker = $0 })
    }

    private var toBinding: Binding<String> {
        Binding(get: { toName }, set: { toMarker = $0 })
    }

    private func markerPicker(_ title: String, selection: Binding<String>, names: [String]) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption.weight(.medium))
                .foregroundStyle(DemoPalette.ink)
            Picker(title, selection: selection) {
                ForEach(names, id: \.self) { name in
                    Text(name).tag(name)
                }
            }
            .pickerStyle(.menu)
            .labelsHidden()
            .tint(DemoPalette.ink)
        }
    }

    private func syncMarkers() {
        let loaded = clip.load()?.markerNames ?? []
        if let first = loaded.first {
            fromMarker = first
        }
        if loaded.count > 1, let last = loaded.last {
            toMarker = last
        } else if let only = loaded.first {
            toMarker = only
        }
    }

    private func finish(_ completed: Bool) {
        guard completed, status == "playing" else { return }
        status = "finished"
    }
}

// MARK: - Buttons

@MainActor
private func prominentButton(_ title: String, action: @escaping () -> Void) -> some View {
    Button(title, action: action)
        .buttonStyle(.borderedProminent)
        .tint(DemoPalette.accent)
        .foregroundStyle(Color.black)
}

@MainActor
private func borderedButton(_ title: String, action: @escaping () -> Void) -> some View {
    Button(title, action: action)
        .buttonStyle(.bordered)
        .tint(DemoPalette.ink)
}
