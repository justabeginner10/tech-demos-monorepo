import Kingfisher
import SwiftUI

/// Kingfisher invokes `onSuccess` and `onFailure` on the main queue
/// (`CallbackQueueMain` in ImageBinder.swift). `onProgress` is the download
/// callback and is not main-isolated, so that hop is a `Task`.
enum CallbackSink {
    nonisolated static func cacheType(
        _ body: @escaping @MainActor (String) -> Void
    ) -> (RetrieveImageResult) -> Void {
        { result in
            let label: String
            switch result.cacheType {
            case .none: label = "none"
            case .memory: label = "memory"
            case .disk: label = "disk"
            }
            MainActor.assumeIsolated {
                body(label)
            }
        }
    }

    nonisolated static func failure(
        _ body: @escaping @MainActor (String) -> Void
    ) -> (KingfisherError) -> Void {
        { error in
            let message = error.isInvalidResponseStatusCode(404)
                ? "HTTP 404. DelayRetryStrategy stops after the retries."
                : (error.errorDescription ?? "Load failed.")
            MainActor.assumeIsolated {
                body(message)
            }
        }
    }

    nonisolated static func progress(
        _ body: @escaping @MainActor (String) -> Void
    ) -> (Int64, Int64) -> Void {
        { received, total in
            let message: String
            if total > 0 {
                let percent = Int((Double(received) / Double(total) * 100).rounded())
                message = "\(received) / \(total) bytes · \(percent)%"
            } else {
                message = "\(received) bytes · length unknown"
            }
            Task { @MainActor in
                body(message)
            }
        }
    }
}

/// Remote `KFImage` with a progress placeholder and one transition at a time.
struct LoadSurface: View {
    @State private var transition: LoadTransition = .fade
    @State private var reloadToken = 0
    @State private var progressLine = "onProgress waits for expectedContentLength."
    @State private var cacheLine = "—"

    var body: some View {
        DemoChrome.chartCard(title: "Load", subtitle: transition.api) {
            VStack(alignment: .leading, spacing: 10) {
                Picker("Transition", selection: $transition) {
                    ForEach(LoadTransition.allCases) { item in
                        Text(item.title).tag(item)
                    }
                }
                .pickerStyle(.segmented)

                configured(KFImage(PhotoLibrary.hero.url))
                    .scaledToFill()
                    .photoFrame()
                    .id(reloadToken)

                Text(PhotoLibrary.hero.caption)
                    .font(.caption.monospaced())
                    .foregroundStyle(DemoPalette.inkMuted)

                labeled("Progress", progressLine)
                labeled("CacheType", cacheLine)

                Button("Reload") {
                    reloadToken += 1
                    progressLine = "forceRefresh skips memory and disk."
                    cacheLine = "—"
                }
                .buttonStyle(.bordered)
                .tint(DemoPalette.accent)

                Text(
                    "First load uses the cache when the photo is already there, and fade stays off for a cache hit. "
                        + "Reload sets forceRefresh and a new view id so the transition runs on a download."
                )
                .font(.caption)
                .foregroundStyle(DemoPalette.inkMuted)
                .fixedSize(horizontal: false, vertical: true)
            }
        }
        .onChange(of: transition) { _, _ in
            reloadToken += 1
            progressLine = "Transition changed. Downloading again."
            cacheLine = "—"
        }
    }

    private func configured(_ image: KFImage) -> KFImage {
        let base = image
            .placeholder { progress in
                DemoChrome.placeholder(progress: progress, caption: "Loading")
            }
            .onProgress(CallbackSink.progress { progressLine = $0 })
            .onSuccess(CallbackSink.cacheType { cacheLine = $0 })
            .onFailure(CallbackSink.failure { progressLine = $0 })
            .onFailureView { failureMark }
            .cancelOnDisappear(true)
            .forceRefresh(reloadToken > 0)
            .resizable()

        switch transition {
        case .fade:
            return base.fade(duration: 0.45)
        case .opacity:
            return base.loadTransition(.opacity, animation: .easeInOut(duration: 0.45))
        case .scale:
            return base.loadTransition(.scale, animation: .spring(duration: 0.5))
        case .blurReplace:
            return base.loadTransition(.blurReplace(.downUp), animation: .bouncy)
        }
    }

    private var failureMark: some View {
        VStack(spacing: 6) {
            Image(systemName: "exclamationmark.triangle")
                .foregroundStyle(DemoPalette.accent)
            Text("Could not load")
                .font(.caption)
                .foregroundStyle(DemoPalette.ink)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

/// One pipeline: downsample, then round the corners, then an optional blur.
struct ProcessSurface: View {
    @State private var blurRadius: Double = 0

    private var processor: any ImageProcessor {
        let downsampled = DownsamplingImageProcessor(size: CGSize(width: 200, height: 200))
            |> RoundCornerImageProcessor(cornerRadius: 36)
        if blurRadius > 0 {
            return downsampled |> BlurImageProcessor(blurRadius: CGFloat(blurRadius))
        }
        return downsampled
    }

    var body: some View {
        DemoChrome.chartCard(title: "Processors", subtitle: "|> pipeline") {
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .top, spacing: 8) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Original")
                            .font(.caption.weight(.medium))
                            .foregroundStyle(DemoPalette.ink)
                        KFImage(PhotoLibrary.process.url)
                            .placeholder { progress in
                                DemoChrome.placeholder(progress: progress, caption: "Loading")
                            }
                            .cacheOriginalImage()
                            .cancelOnDisappear(true)
                            .resizable()
                            .scaledToFill()
                            .photoFrame(height: 160)
                    }
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Pipeline")
                            .font(.caption.weight(.medium))
                            .foregroundStyle(DemoPalette.ink)
                        KFImage(PhotoLibrary.process.url)
                            .placeholder { progress in
                                DemoChrome.placeholder(progress: progress, caption: "Processing")
                            }
                            .setProcessor(processor)
                            .cacheOriginalImage()
                            .cancelOnDisappear(true)
                            .resizable()
                            .scaledToFit()
                            .photoFrame(height: 160)
                    }
                }

                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("BlurImageProcessor")
                            .font(.caption.weight(.medium))
                            .foregroundStyle(DemoPalette.ink)
                        Spacer()
                        Text(blurRadius == 0 ? "off" : String(format: "%.0f pt", blurRadius))
                            .font(.caption.monospaced())
                            .foregroundStyle(DemoPalette.inkMuted)
                    }
                    Slider(value: $blurRadius, in: 0...16, step: 1)
                        .tint(DemoPalette.accent)
                }

                Text(PhotoLibrary.process.caption + " · target 200×200 · corner 36")
                    .font(.caption.monospaced())
                    .foregroundStyle(DemoPalette.inkMuted)
                    .fixedSize(horizontal: false, vertical: true)

                Text(
                    "cacheOriginalImage keeps the unprocessed download, so moving the blur slider reprocesses that original. "
                        + "Blur radius 0 leaves BlurImageProcessor out of the chain."
                )
                .font(.caption)
                .foregroundStyle(DemoPalette.inkMuted)
                .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

/// A URL picsum answers with 404, then a real photo. Retries use `DelayRetryStrategy`.
struct RetrySurface: View {
    @State private var useFailure = true
    @State private var message = "id 999999 is HTTP 404. The strategy retries response errors twice, one second apart."

    private var url: URL {
        useFailure ? PhotoLibrary.failure : PhotoLibrary.recovery.url
    }

    var body: some View {
        DemoChrome.chartCard(title: "Retry", subtitle: "retry(maxCount:interval:)") {
            VStack(alignment: .leading, spacing: 10) {
                KFImage(url)
                    .placeholder { progress in
                        DemoChrome.placeholder(progress: progress, caption: "Requesting")
                    }
                    .retry(maxCount: 2, interval: .seconds(1))
                    .onFailure(CallbackSink.failure { message = $0 })
                    .onSuccess(CallbackSink.cacheType { message = "Loaded. CacheType \($0)." })
                    .onFailureView { failureMark }
                    .cancelOnDisappear(true)
                    .resizable()
                    .scaledToFill()
                    .photoFrame()
                    .id(useFailure)

                Text(message)
                    .font(.caption)
                    .foregroundStyle(DemoPalette.ink)
                    .fixedSize(horizontal: false, vertical: true)

                Button(useFailure ? "Load a real photo" : "Fail again") {
                    message = useFailure
                        ? "Swapped to \(PhotoLibrary.recovery.caption)."
                        : "Back to the 404. Retries start over."
                    useFailure.toggle()
                }
                .buttonStyle(.bordered)
                .tint(DemoPalette.accent)

                Text("DelayRetryStrategy retries KingfisherError.responseError only. A 404 is one. Task cancellation is not.")
                    .font(.caption)
                    .foregroundStyle(DemoPalette.inkMuted)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var failureMark: some View {
        VStack(spacing: 6) {
            Image(systemName: "xmark.octagon")
                .foregroundStyle(DemoPalette.accent)
            Text("onFailureView")
                .font(.caption.monospaced())
                .foregroundStyle(DemoPalette.ink)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

/// `ImageCache.default`: memory cost, disk size, and the two clear methods.
struct CacheSurface: View {
    @State private var memory = "—"
    @State private var memoryLimit = "—"
    @State private var disk = "—"
    @State private var diskLimit = "—"
    @State private var note = "Reading ImageCache.default."

    var body: some View {
        DemoChrome.chartCard(title: "Cache", subtitle: "ImageCache.default") {
            VStack(alignment: .leading, spacing: 10) {
                KFImage(PhotoLibrary.cache.url)
                    .placeholder { progress in
                        DemoChrome.placeholder(progress: progress, caption: "Loading")
                    }
                    .onSuccess(CallbackSink.cacheType { _ in
                        Task { await refresh() }
                    })
                    .cancelOnDisappear(true)
                    .resizable()
                    .scaledToFill()
                    .photoFrame(height: 150)

                labeled("Memory", memory)
                labeled("Memory limit", memoryLimit)
                labeled("Disk", disk)
                labeled("Disk limit", diskLimit)

                Text(note)
                    .font(.caption)
                    .foregroundStyle(DemoPalette.inkMuted)
                    .fixedSize(horizontal: false, vertical: true)

                Button("Refresh sizes") {
                    Task { await refresh() }
                }
                .buttonStyle(.bordered)
                .tint(DemoPalette.accent)

                HStack(spacing: 8) {
                    Button("Clear memory") {
                        ImageCache.default.clearMemoryCache()
                        Task { await refresh() }
                    }
                    .buttonStyle(.bordered)
                    .tint(DemoPalette.accent)

                    Button("Clear disk") {
                        Task {
                            await ImageCache.default.clearDiskCache()
                            await refresh()
                        }
                    }
                    .buttonStyle(.bordered)
                    .tint(DemoPalette.accent)
                }

                Text(PhotoLibrary.cache.caption + " · shared with every other KFImage in this app.")
                    .font(.caption.monospaced())
                    .foregroundStyle(DemoPalette.inkMuted)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .task { await refresh() }
    }

    private func refresh() async {
        let cache = ImageCache.default
        memory = ByteCount.string(cache.memoryStorageCacheCost)
        memoryLimit = ByteCount.string(cache.memoryStorage.config.totalCostLimit)
        let sizeLimit = cache.diskStorage.config.sizeLimit
        diskLimit = sizeLimit == 0 ? "0 · no cap" : ByteCount.string(sizeLimit)
        do {
            let size = try await cache.diskStorageSize
            disk = ByteCount.string(size)
            note = "memoryStorageCacheCost is synchronous. diskStorageSize sums the cache folder."
        } catch {
            disk = "unavailable"
            note = error.localizedDescription
        }
    }
}

private struct LabeledLine: View {
    var title: String
    var value: String

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)
                .font(.caption.weight(.medium))
                .foregroundStyle(DemoPalette.ink)
            Spacer()
            Text(value)
                .font(.caption.monospaced())
                .foregroundStyle(DemoPalette.inkMuted)
                .multilineTextAlignment(.trailing)
        }
    }
}

private func labeled(_ title: String, _ value: String) -> some View {
    LabeledLine(title: title, value: value)
}
