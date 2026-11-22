import NukeUI
import SwiftUI

struct StatesSurface: View {
    @ObservedObject var session: NukeSession

    @State private var sample: StateSample = .photo

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Picker("Sample", selection: $sample) {
                ForEach(StateSample.allCases) { item in
                    Text(item.title).tag(item)
                }
            }
            .pickerStyle(.segmented)

            LazyImage(
                request: sample.request,
                transaction: Transaction(animation: .easeOut(duration: 0.2))
            ) { state in
                StateBody(
                    progress: state.progress,
                    image: state.image,
                    errorText: state.error.map(nukeErrorText),
                    isLoading: state.isLoading
                )
            }
            .pipeline(session.pipeline)
            .priority(.high)
            .onDisappear(.cancel)
            .onCompletion { result in
                session.record(result)
            }
            .id(session.generation)
            .frame(maxWidth: .infinity)
            .frame(height: 240)

            Text(sample.detail)
                .font(.caption)
                .foregroundStyle(DemoPalette.inkMuted)
                .fixedSize(horizontal: false, vertical: true)

            labeled("Last completion", session.lastSource)
        }
        .demoCard()
    }
}

/// Observes `FetchImage.Progress` directly. `LazyImage` republishes when the image
/// or the loading flag changes, not on every byte.
private struct StateBody: View {
    @ObservedObject var progress: FetchImage.Progress
    var image: Image?
    var errorText: String?
    var isLoading: Bool

    var body: some View {
        ZStack {
            DemoPalette.canvas
            if let image {
                image
                    .resizable()
                    .scaledToFill()
            } else if let errorText {
                failure(errorText)
            } else {
                placeholder
            }

            if isLoading {
                progressBar
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(DemoPalette.stroke, lineWidth: 1)
                .allowsHitTesting(false)
        }
    }

    private var placeholder: some View {
        VStack(spacing: 8) {
            Image(systemName: "photo")
                .font(.title)
                .foregroundStyle(DemoPalette.inkMuted)
            Text("Placeholder")
                .font(.caption)
                .foregroundStyle(DemoPalette.inkMuted)
        }
    }

    private func failure(_ text: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle")
                .font(.title)
                .foregroundStyle(DemoPalette.accent)
            Text(text)
                .font(.caption2)
                .foregroundStyle(DemoPalette.ink)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 12)
        }
    }

    private var progressBar: some View {
        VStack {
            Spacer()
            VStack(alignment: .leading, spacing: 4) {
                ProgressView(value: Double(progress.fraction))
                    .tint(DemoPalette.accent)
                Text(progressLine)
                    .font(.caption2.monospaced())
                    .foregroundStyle(DemoPalette.ink)
            }
            .padding(10)
            .background(DemoPalette.page.opacity(0.88), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
            .padding(10)
        }
    }

    private var progressLine: String {
        if progress.total > 0 {
            return "\(progress.completed) / \(progress.total)  \(String(format: "%.0f%%", Double(progress.fraction) * 100))"
        }
        return "waiting for length"
    }
}

struct GridSurface: View {
    @ObservedObject var session: NukeSession

    @State private var prefetching = true

    private let columns = [GridItem(.adaptive(minimum: 104), spacing: 8)]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Toggle("Prefetch ahead", isOn: $prefetching)
                .font(.subheadline)
                .foregroundStyle(DemoPalette.ink)
                .tint(DemoPalette.accent)

            Text(
                "ImagePrefetcher destination .memoryCache, priority .low, 2 at a time. "
                    + "Each cell's LazyImage uses the same resize, so a finished prefetch is a memory hit."
            )
            .font(.caption)
            .foregroundStyle(DemoPalette.inkMuted)
            .fixedSize(horizontal: false, vertical: true)

            ScrollView {
                LazyVGrid(columns: columns, spacing: 8) {
                    ForEach(Array(PhotoCatalog.grid.enumerated()), id: \.element.id) { index, photo in
                        GridCell(
                            photo: photo,
                            index: index,
                            session: session,
                            prefetching: prefetching
                        )
                    }
                }
            }
            .frame(height: 420)

            labeled("didComplete", "\(session.prefetchWaves)")
        }
        .demoCard()
        .onChange(of: prefetching) { _, isOn in
            session.prefetcher.isPaused = !isOn
            if !isOn {
                session.stopPrefetching()
            }
        }
        .onDisappear {
            session.stopPrefetching()
        }
    }
}

private struct GridCell: View {
    var photo: DemoPhoto
    var index: Int
    @ObservedObject var session: NukeSession
    var prefetching: Bool

    var body: some View {
        LazyImage(request: PhotoCatalog.gridRequest(for: photo)) { state in
            ZStack {
                DemoPalette.canvas
                if let image = state.image {
                    image
                        .resizable()
                        .scaledToFill()
                } else if state.error != nil {
                    Image(systemName: "wifi.exclamationmark")
                        .foregroundStyle(DemoPalette.accent)
                } else {
                    ProgressView()
                        .tint(DemoPalette.accent)
                }
            }
        }
        .pipeline(session.pipeline)
        .onDisappear(.cancel)
        .id(session.generation)
        .frame(height: 104)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .strokeBorder(DemoPalette.stroke, lineWidth: 1)
                .allowsHitTesting(false)
        }
        .onAppear {
            guard prefetching else { return }
            session.prefetch(after: index)
        }
    }
}

struct ProcessorSurface: View {
    @ObservedObject var session: NukeSession

    @State private var recipe: ProcessorRecipe = .resize

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Picker("Processor", selection: $recipe) {
                ForEach(ProcessorRecipe.allCases) { item in
                    Text(item.title).tag(item)
                }
            }
            .pickerStyle(.segmented)

            LazyImage(url: PhotoCatalog.processorPhoto.url(width: 800, height: 600)) { state in
                ZStack {
                    DemoPalette.canvas
                    if let image = state.image {
                        image
                            .resizable()
                            .scaledToFit()
                            .padding(12)
                    } else if let error = state.error {
                        Text(nukeErrorText(error))
                            .font(.caption2)
                            .foregroundStyle(DemoPalette.ink)
                            .padding(12)
                    } else {
                        ProgressView()
                            .tint(DemoPalette.accent)
                    }
                }
            }
            .processors(recipe.processors)
            .pipeline(session.pipeline)
            .onDisappear(.cancel)
            .id("\(session.generation.uuidString)-\(recipe.rawValue)")
            .frame(maxWidth: .infinity)
            .frame(height: 220)
            .background(DemoPalette.canvas, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(DemoPalette.stroke, lineWidth: 1)
                    .allowsHitTesting(false)
            }

            Text(
                "LazyImage.processors fills the request when the request has none. "
                    + "Resize runs first so corners, blur, and the circle match the bitmap."
            )
                .font(.caption)
                .foregroundStyle(DemoPalette.inkMuted)
                .fixedSize(horizontal: false, vertical: true)

            Text(recipe.call)
                .font(.caption2.monospaced())
                .foregroundStyle(DemoPalette.ink)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .demoCard()
    }
}

struct CacheSurface: View {
    @ObservedObject var session: NukeSession

    @State private var ignoreCachedData = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Picker("Pipeline", selection: $session.kind) {
                ForEach(NukeSession.Kind.allCases) { item in
                    Text(item.title).tag(item)
                }
            }
            .pickerStyle(.segmented)

            Toggle("Progressive decoding", isOn: $session.progressive)
                .font(.subheadline)
                .foregroundStyle(DemoPalette.ink)
                .tint(DemoPalette.accent)

            LazyImage(request: PhotoCatalog.cacheRequest(ignoreCachedData: ignoreCachedData)) { state in
                ZStack {
                    DemoPalette.canvas
                    if let image = state.image {
                        image
                            .resizable()
                            .scaledToFill()
                    } else if state.error != nil {
                        Image(systemName: "exclamationmark.triangle")
                            .foregroundStyle(DemoPalette.accent)
                    } else {
                        ProgressView()
                            .tint(DemoPalette.accent)
                    }
                }
            }
            .pipeline(session.pipeline)
            .onDisappear(.cancel)
            .onCompletion { result in
                session.record(result)
            }
            .id("\(session.generation.uuidString)-\(ignoreCachedData)")
            .frame(maxWidth: .infinity)
            .frame(height: 180)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

            Text(ignoreCachedData ? "options .reloadIgnoringCachedData" : "options []")
                .font(.caption.monospaced())
                .foregroundStyle(DemoPalette.inkMuted)

            labeled("Completion", session.lastSource)

            HStack(spacing: 8) {
                cacheButton("Reload") { ignoreCachedData.toggle() }
                cacheButton("Read caches") { session.refresh() }
            }

            HStack(spacing: 8) {
                cacheButton("Clear memory") { session.clearMemory() }
                cacheButton("Clear disk") { session.clearDisk() }
                cacheButton("Clear both") { session.clearAll() }
            }

            if let dataCacheError = session.dataCacheError {
                Text(dataCacheError)
                    .font(.caption)
                    .foregroundStyle(DemoPalette.accent)
            }

            Text(
                "Disk files count the DataCache directory. Probe on disk asks ImagePipeline.Cache, "
                    + "which only sees a data cache attached to this pipeline. URL cache mode leaves that nil."
            )
            .font(.caption)
            .foregroundStyle(DemoPalette.inkMuted)
            .fixedSize(horizontal: false, vertical: true)

            VStack(alignment: .leading, spacing: 4) {
                labeled("Memory images", "\(session.memoryCount)")
                labeled("Memory cost", ByteFormat.string(session.memoryCost))
                labeled("Probe in memory", session.probeInMemory ? "yes" : "no")
                labeled("Disk files", "\(session.diskCount)")
                labeled("Disk size", ByteFormat.string(session.diskBytes))
                labeled("Probe on disk", session.probeOnDisk ? "yes" : "no")
                labeled("dataCache", session.dataCacheAttached ? "attached" : "nil")
            }
        }
        .demoCard()
        .onAppear { session.refresh() }
    }

    private func cacheButton(_ title: String, action: @escaping () -> Void) -> some View {
        Button(title, action: action)
            .font(.caption.weight(.semibold))
            .foregroundStyle(DemoPalette.ink)
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(Color.white.opacity(0.08), in: Capsule())
    }
}

func labeled(_ title: String, _ value: String) -> some View {
    HStack(alignment: .firstTextBaseline) {
        Text(title)
            .font(.caption)
            .foregroundStyle(DemoPalette.inkMuted)
        Spacer()
        Text(value)
            .font(.caption.monospaced())
            .foregroundStyle(DemoPalette.ink)
            .multilineTextAlignment(.trailing)
    }
}
