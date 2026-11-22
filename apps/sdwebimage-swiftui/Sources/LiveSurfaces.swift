import SDWebImageSwiftUI
import SwiftUI

// MARK: - Load

/// Placeholder, activity or progress indicator, SwiftUI transition, and cache options on `WebImage`.
struct LoadSurface: View {
    @State private var still: RemoteStill = .river
    @State private var indicator: IndicatorChoice = .activity
    @State private var transition: LoadTransition = .fade
    @State private var policy: LoadPolicy = .standard
    @State private var reload = 0
    @State private var status = "Loading"
    @State private var progressText = "—"

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            stage
                .id(stageID)
            Text(callout)
                .font(.caption2.monospaced())
                .foregroundStyle(DemoPalette.ink)
                .textSelection(.enabled)
                .fixedSize(horizontal: false, vertical: true)
            Text(status)
                .font(.caption.monospaced())
                .foregroundStyle(DemoPalette.inkMuted)
                .fixedSize(horizontal: false, vertical: true)
            Text(progressText)
                .font(.caption.monospaced())
                .foregroundStyle(DemoPalette.inkMuted)
            controls
        }
        .onChange(of: stageID) { _, _ in
            status = "Loading"
            progressText = "—"
        }
    }

    private var stageID: String {
        "\(still.id)|\(policy.rawValue)|\(transition.rawValue)|\(indicator.rawValue)|\(reload)"
    }

    private var callout: String {
        """
        WebImage(url: options: \(policy.call)) { phase in … }
        .indicator(\(indicator.call))
        .transition(\(transition.call))
        .retryOnAppear(true) · .cancelOnDisappear(true)
        """
    }

    @ViewBuilder
    private var stage: some View {
        let image = WebImage(url: still.url, options: policy.options) { phase in
            phaseFace(phase)
        }
        .onSuccess(perform: ImageLoadSink.success { image, data, cacheType in
            status = CacheKind.line(image: image, data: data, cacheType: cacheType)
        })
        .onFailure(perform: ImageLoadSink.failure { error in
            status = error.localizedDescription
        })
        .onProgress(perform: ImageLoadSink.progress { received, expected in
            if expected > 0 {
                progressText = "\(received) / \(expected) bytes"
            } else {
                progressText = "\(received) bytes"
            }
        })
        .retryOnAppear(true)
        .cancelOnDisappear(true)

        switch indicator {
        case .activity:
            image
                .indicator(.activity)
                .transition(transition.transition)
                .imageStage()
        case .progress:
            image
                .indicator(.progress)
                .transition(transition.transition)
                .imageStage()
        }
    }

    @ViewBuilder
    private func phaseFace(_ phase: WebImagePhase) -> some View {
        switch phase {
        case .success(let image):
            image
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        case .failure:
            FailureMark()
        case .empty:
            PhotoPlaceholder()
        }
    }

    private var controls: some View {
        VStack(alignment: .leading, spacing: 12) {
            menu("Image", choices: RemoteStill.loadChoices, selection: $still) { Text($0.title) }
            segmented("Indicator", selection: $indicator) { Text($0.title) }
            segmented("Transition", selection: $transition) { Text($0.title) }
            menu("Options", choices: Array(LoadPolicy.allCases), selection: $policy) { Text($0.title) }
            Text(policyCaption)
                .font(.caption)
                .foregroundStyle(DemoPalette.inkMuted)
                .fixedSize(horizontal: false, vertical: true)
            Button("Reload") {
                reload += 1
            }
            .buttonStyle(.bordered)
            .tint(DemoPalette.accent)
            Text("Reload gives the view a new id, so the SwiftUI transition runs again. Cache only fails until something else has stored this URL.")
                .font(.caption)
                .foregroundStyle(DemoPalette.inkMuted)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var policyCaption: String {
        switch policy {
        case .standard:
            "Empty options. Memory and disk are both used."
        case .progressive:
            ".progressiveLoad draws partial JPEG scans while bytes arrive."
        case .refresh:
            ".refreshCached still shows the cached image, then checks the network."
        case .scaleDown:
            ".scaleDownLargeImages decodes a smaller bitmap when the file is larger than the screen."
        case .cacheOnly:
            ".fromCacheOnly never hits the network. A miss calls onFailure."
        }
    }
}

// MARK: - Motion

/// `WebImage` animated playback. The binding starts at true, which is what the package expects.
struct MotionSurface: View {
    @State private var clip: AnimatedClip = .gif
    @State private var playing = true
    @State private var pausable = true
    @State private var rate = 1.0
    @State private var playback: PlaybackChoice = .normal
    @State private var loop: LoopChoice = .file
    @State private var status = "Loading"

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            stage
                .id(stageID)
            Text(callout)
                .font(.caption2.monospaced())
                .foregroundStyle(DemoPalette.ink)
                .textSelection(.enabled)
                .fixedSize(horizontal: false, vertical: true)
            Text(status)
                .font(.caption.monospaced())
                .foregroundStyle(DemoPalette.inkMuted)
                .fixedSize(horizontal: false, vertical: true)
            controls
        }
    }

    /// Rate, mode, and loop are copied when the player is created. A new id builds that player again.
    private var stageID: String {
        "\(clip.id)|\(playback.rawValue)|\(loop.rawValue)|\(rate)"
    }

    private var callout: String {
        """
        WebImage(url: isAnimating: $playing)
        .customLoopCount(\(loop.call))
        .playbackRate(\(String(format: "%.2f", rate)))
        .playbackMode(\(playback.call))
        .pausable(\(pausable))
        """
    }

    private var stage: some View {
        WebImage(url: clip.url, isAnimating: $playing) { image in
            image
                .resizable()
                .scaledToFit()
        } placeholder: {
            PhotoPlaceholder()
        }
        .customLoopCount(loop.count)
        .playbackRate(rate)
        .playbackMode(playback.mode)
        .pausable(pausable)
        .onSuccess(perform: ImageLoadSink.success { image, data, cacheType in
            status = CacheKind.line(image: image, data: data, cacheType: cacheType)
        })
        .onFailure(perform: ImageLoadSink.failure { error in
            status = error.localizedDescription
        })
        .indicator(.activity)
        .imageStage()
    }

    private var controls: some View {
        VStack(alignment: .leading, spacing: 12) {
            segmented("Clip", selection: $clip) { Text($0.title) }
            Text("\(clip.host). WebP plays here because SDImageAWebPCoder is registered.")
                .font(.caption)
                .foregroundStyle(DemoPalette.inkMuted)
                .fixedSize(horizontal: false, vertical: true)

            Button(playing ? "Pause" : "Play") {
                playing.toggle()
            }
            .buttonStyle(.borderedProminent)
            .tint(DemoPalette.accent)

            Toggle("Pausable", isOn: $pausable)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(DemoPalette.ink)
                .tint(DemoPalette.accent)
            Text(pausable
                ? "pausable(true) keeps the current frame when isAnimating becomes false."
                : "pausable(false) stops at frame 0 when isAnimating becomes false.")
                .font(.caption)
                .foregroundStyle(DemoPalette.inkMuted)
                .fixedSize(horizontal: false, vertical: true)

            menu("Playback", choices: Array(PlaybackChoice.allCases), selection: $playback) { Text($0.title) }
            segmented("Loop", selection: $loop) { Text($0.title) }
            DemoSlider(
                title: "Rate",
                value: $rate,
                range: 0.25...2,
                step: 0.25
            )
            Text("1 is the file speed. The stage id includes rate, mode, and loop, because WebImage copies them when the player is set up.")
                .font(.caption)
                .foregroundStyle(DemoPalette.inkMuted)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

// MARK: - Player

/// `AnimatedImage` for GIF and animated WebP, with play/pause on the same binding.
struct PlayerSurface: View {
    @State private var clip: AnimatedClip = .gif
    @State private var playing = true
    @State private var pausable = true
    @State private var rate = 1.0
    @State private var playback: PlaybackChoice = .normal
    @State private var loop: LoopChoice = .file
    @State private var buffer: BufferChoice = .automatic
    @State private var incremental = true
    @State private var indicator: IndicatorChoice = .activity
    @State private var transition: PlayerTransition = .fade
    @State private var forceTransition = false
    @State private var reload = 0
    @State private var status = "Loading"

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            stage
                .id(stageID)
            Text(callout)
                .font(.caption2.monospaced())
                .foregroundStyle(DemoPalette.ink)
                .textSelection(.enabled)
                .fixedSize(horizontal: false, vertical: true)
            Text(status)
                .font(.caption.monospaced())
                .foregroundStyle(DemoPalette.inkMuted)
                .fixedSize(horizontal: false, vertical: true)
            controls
        }
        .onChange(of: stageID) { _, _ in
            status = "Loading"
        }
    }

    private var stageID: String {
        "\(clip.id)|\(transition.rawValue)|\(forceTransition)|\(incremental)|\(reload)"
    }

    private var options: SDWebImageOptions {
        var set: SDWebImageOptions = incremental ? .progressiveLoad : []
        if forceTransition {
            set.insert(.forceTransition)
        }
        return set
    }

    private var optionsCall: String {
        var parts: [String] = []
        if incremental {
            parts.append(".progressiveLoad")
        }
        if forceTransition {
            parts.append(".forceTransition")
        }
        if parts.isEmpty {
            return "[]"
        }
        return "[" + parts.joined(separator: ", ") + "]"
    }

    private var callout: String {
        """
        AnimatedImage(url: options: \(optionsCall), isAnimating: $playing) { placeholder }
        .indicator(\(indicator.call))
        .transition(\(transition.call))
        .playbackRate(\(String(format: "%.2f", rate))) · .playbackMode(\(playback.call))
        .customLoopCount(\(loop.call)) · .maxBufferSize(\(buffer.call)) · .incrementalLoad(\(incremental))
        """
    }

    private var stage: some View {
        let image = AnimatedImage(url: clip.url, options: options, isAnimating: $playing) {
            PhotoPlaceholder()
        }
        .customLoopCount(loop.count)
        .playbackRate(rate)
        .playbackMode(playback.mode)
        .pausable(pausable)
        .incrementalLoad(incremental)
        .maxBufferSize(buffer.size)
        .onSuccess(perform: ImageLoadSink.success { image, data, cacheType in
            status = CacheKind.line(image: image, data: data, cacheType: cacheType)
        })
        .onFailure(perform: ImageLoadSink.failure { error in
            status = error.localizedDescription
        })

        return presented(image)
    }

    @ViewBuilder
    private func presented(_ image: AnimatedImage) -> some View {
        switch indicator {
        case .activity:
            image
                .indicator(.activity)
                .transition(transition.transition)
                .resizable()
                .scaledToFit()
                .imageStage()
        case .progress:
            image
                .indicator(.progress)
                .transition(transition.transition)
                .resizable()
                .scaledToFit()
                .imageStage()
        }
    }

    private var controls: some View {
        VStack(alignment: .leading, spacing: 12) {
            segmented("Clip", selection: $clip) { Text($0.title) }
            Text("\(clip.host). AnimatedImage is the UIKit player. WebImage on Motion is the SwiftUI one.")
                .font(.caption)
                .foregroundStyle(DemoPalette.inkMuted)
                .fixedSize(horizontal: false, vertical: true)

            Button(playing ? "Pause" : "Play") {
                playing.toggle()
            }
            .buttonStyle(.borderedProminent)
            .tint(DemoPalette.accent)

            Toggle("Pausable", isOn: $pausable)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(DemoPalette.ink)
                .tint(DemoPalette.accent)
            Text("pausable(true) sets resetFrameIndexWhenStopped to false. Pause keeps the frame. False sends it back to 0.")
                .font(.caption)
                .foregroundStyle(DemoPalette.inkMuted)
                .fixedSize(horizontal: false, vertical: true)

            menu("Playback", choices: Array(PlaybackChoice.allCases), selection: $playback) { Text($0.title) }
            segmented("Loop", selection: $loop) { Text($0.title) }
            segmented("Buffer", selection: $buffer) { Text($0.title) }
            DemoSlider(
                title: "Rate",
                value: $rate,
                range: 0.25...2,
                step: 0.25
            )
            Toggle("Incremental load", isOn: $incremental)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(DemoPalette.ink)
                .tint(DemoPalette.accent)
            Text("incrementalLoad(true) plus .progressiveLoad draws frames as the file arrives. False waits for a poster.")
                .font(.caption)
                .foregroundStyle(DemoPalette.inkMuted)
                .fixedSize(horizontal: false, vertical: true)

            segmented("Indicator", selection: $indicator) { Text($0.title) }
            segmented("Transition", selection: $transition) { Text($0.title) }
            Toggle("Force transition", isOn: $forceTransition)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(DemoPalette.ink)
                .tint(DemoPalette.accent)
            Text(".forceTransition runs the UIKit transition even when the frame comes from cache. Reload remounts the view.")
                .font(.caption)
                .foregroundStyle(DemoPalette.inkMuted)
                .fixedSize(horizontal: false, vertical: true)
            Button("Reload") {
                reload += 1
            }
            .buttonStyle(.bordered)
            .tint(DemoPalette.accent)
        }
    }
}

// MARK: - Cache

/// Memory and disk counts, then `clearMemory` and `clearDisk(onCompletion:)`.
struct CacheSurface: View {
    @State private var reload = 0
    @State private var status = "Loading"
    @State private var diskSummary = "Counting disk…"

    private var sample: RemoteStill { .shore }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            stage
                .id(reload)
            Text(callout)
                .font(.caption2.monospaced())
                .foregroundStyle(DemoPalette.ink)
                .textSelection(.enabled)
                .fixedSize(horizontal: false, vertical: true)
            Text(status)
                .font(.caption.monospaced())
                .foregroundStyle(DemoPalette.inkMuted)
                .fixedSize(horizontal: false, vertical: true)
            Text(diskSummary)
                .font(.caption.monospaced())
                .foregroundStyle(DemoPalette.inkMuted)
            Text(SDImageCache.shared.diskCachePath)
                .font(.caption2.monospaced())
                .foregroundStyle(DemoPalette.inkMuted)
                .textSelection(.enabled)
                .fixedSize(horizontal: false, vertical: true)
            controls
        }
        .onAppear(perform: refreshSize)
        .onChange(of: reload) { _, _ in
            status = "Loading"
        }
    }

    private var callout: String {
        """
        SDImageCache.shared.clearMemory()
        SDImageCache.shared.clearDisk(onCompletion:)
        SDImageCache.shared.calculateSize { fileCount, totalSize in }
        """
    }

    private var stage: some View {
        WebImage(url: sample.url) { image in
            image
                .resizable()
                .scaledToFit()
        } placeholder: {
            PhotoPlaceholder()
        }
        .onSuccess(perform: ImageLoadSink.success { image, data, cacheType in
            status = CacheKind.line(image: image, data: data, cacheType: cacheType)
            refreshSize()
        })
        .onFailure(perform: ImageLoadSink.failure { error in
            status = error.localizedDescription
        })
        .indicator(.activity)
        .transition(.fade(duration: 0.5))
        .imageStage(height: 180)
    }

    private var controls: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Clear memory drops decoded images. Disk files stay. Clear disk removes the files, then this image loads again.")
                .font(.caption)
                .foregroundStyle(DemoPalette.inkMuted)
                .fixedSize(horizontal: false, vertical: true)
            Button("Clear memory") {
                SDImageCache.shared.clearMemory()
                reload += 1
                refreshSize()
            }
            .buttonStyle(.bordered)
            .tint(DemoPalette.accent)

            Button("Clear disk") {
                SDImageCache.shared.clearDisk(onCompletion: CacheSink.done {
                    reload += 1
                    refreshSize()
                })
            }
            .buttonStyle(.bordered)
            .tint(DemoPalette.accent)

            Button("Clear both") {
                SDImageCache.shared.clearMemory()
                SDImageCache.shared.clearDisk(onCompletion: CacheSink.done {
                    reload += 1
                    refreshSize()
                })
            }
            .buttonStyle(.borderedProminent)
            .tint(DemoPalette.accent)
            Text("A memory hit reports no data unless .queryMemoryData is set. Disk and network include the byte count.")
                .font(.caption)
                .foregroundStyle(DemoPalette.inkMuted)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func refreshSize() {
        CacheSink.refresh { count, bytes in
            diskSummary = "\(count) files · \(ByteFormat.string(bytes))"
        }
    }
}

// MARK: - Pickers

extension View {
    func segmented<Choice: Hashable, Label: View>(
        _ title: String,
        selection: Binding<Choice>,
        @ViewBuilder label: @escaping (Choice) -> Label
    ) -> some View where Choice: CaseIterable & Identifiable, Choice.AllCases: RandomAccessCollection {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(DemoPalette.ink)
            Picker(title, selection: selection) {
                ForEach(Array(Choice.allCases)) { choice in
                    label(choice).tag(choice)
                }
            }
            .pickerStyle(.segmented)
        }
    }

    func menu<Choice: Hashable, Label: View>(
        _ title: String,
        choices: [Choice],
        selection: Binding<Choice>,
        @ViewBuilder label: @escaping (Choice) -> Label
    ) -> some View where Choice: Identifiable {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(DemoPalette.ink)
            Picker(title, selection: selection) {
                ForEach(choices) { choice in
                    label(choice).tag(choice)
                }
            }
            .pickerStyle(.menu)
            .tint(DemoPalette.ink)
        }
    }
}
