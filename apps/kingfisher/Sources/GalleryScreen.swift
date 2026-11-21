import Kingfisher
import SwiftUI

/// Owns one `ImagePrefetcher`. The class cannot be restarted, so each pass allocates a new one.
@MainActor
final class GalleryPrefetchModel: ObservableObject {
    enum Phase: Equatable {
        case idle
        case running
        case finished
    }

    @Published private(set) var skipped = 0
    @Published private(set) var failed = 0
    @Published private(set) var completed = 0
    @Published private(set) var phase: Phase = .idle

    private var generation = 0
    private var prefetcher: ImagePrefetcher?

    var total: Int { PhotoLibrary.gallery.count }

    func start() {
        generation += 1
        let token = generation
        prefetcher?.stop()
        prefetcher = nil
        skipped = 0
        failed = 0
        completed = 0
        phase = .running

        let urls = PhotoLibrary.gallery.map(\.url)
        let next = ImagePrefetcher(
            urls: urls,
            progressBlock: { [weak self] skipped, failed, completed in
                let snapshot = (skipped.count, failed.count, completed.count)
                Task { @MainActor in
                    self?.apply(snapshot, token: token, finished: false)
                }
            },
            completionHandler: { [weak self] skipped, failed, completed in
                let snapshot = (skipped.count, failed.count, completed.count)
                Task { @MainActor in
                    self?.apply(snapshot, token: token, finished: true)
                }
            }
        )
        next.maxConcurrentDownloads = 4
        prefetcher = next
        next.start()
    }

    func stop() {
        generation += 1
        prefetcher?.stop()
        prefetcher = nil
        phase = .idle
    }

    private func apply(_ snapshot: (Int, Int, Int), token: Int, finished: Bool) {
        guard generation == token else { return }
        skipped = snapshot.0
        failed = snapshot.1
        completed = snapshot.2
        if finished {
            phase = .finished
            prefetcher = nil
        }
    }
}

/// Prefetch grid plus frozen cards. `KFImage` mounts only after prefetch finishes, and only while this tab is selected.
struct GalleryScreen: View {
    var isSelected: Bool

    @StateObject private var prefetch = GalleryPrefetchModel()

    private let columns = [GridItem(.flexible(), spacing: 8), GridItem(.flexible(), spacing: 8)]
    private let cardColumns = [GridItem(.adaptive(minimum: 300), spacing: 12)]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    header
                    if isSelected {
                        prefetchCard
                        if prefetch.phase == .finished {
                            grid
                        }
                    } else {
                        parked
                    }
                    LazyVGrid(columns: cardColumns, spacing: 12) {
                        ForEach(GalleryCard.allCases) { card in
                            DemoChrome.chartCard(title: card.title, subtitle: card.subtitle) {
                                card.preview
                            }
                        }
                    }
                }
                .padding()
            }
            .background(DemoPalette.page)
            .navigationTitle("Gallery")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(DemoPalette.page, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .safeAreaInset(edge: .bottom, spacing: 0) {
                Color.clear.frame(height: 56)
            }
        }
        .onAppear(perform: syncPrefetch)
        .onChange(of: isSelected) { _, _ in
            syncPrefetch()
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Eight photos, fetched first.")
                .font(.system(size: 34, weight: .regular, design: .serif))
                .foregroundStyle(DemoPalette.ink)

            Text(
                "ImagePrefetcher downloads the grid before any KFImage is mounted. "
                    + "A second pass should report those URLs as skipped."
            )
            .font(.subheadline)
            .foregroundStyle(DemoPalette.inkMuted)
            .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var prefetchCard: some View {
        DemoChrome.chartCard(title: "ImagePrefetcher", subtitle: "maxConcurrentDownloads 4") {
            VStack(alignment: .leading, spacing: 8) {
                Text(statusLine)
                    .font(.caption.monospaced())
                    .foregroundStyle(DemoPalette.ink)
                    .fixedSize(horizontal: false, vertical: true)

                ProgressView(
                    value: Double(prefetch.skipped + prefetch.failed + prefetch.completed),
                    total: Double(prefetch.total)
                )
                .tint(DemoPalette.accent)

                if prefetch.phase == .finished {
                    Button("Prefetch again") {
                        prefetch.start()
                    }
                    .buttonStyle(.bordered)
                    .tint(DemoPalette.accent)
                } else {
                    Text("The grid stays unmounted until the completion handler runs.")
                        .font(.caption)
                        .foregroundStyle(DemoPalette.inkMuted)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }

    private var statusLine: String {
        let done = prefetch.skipped + prefetch.failed + prefetch.completed
        switch prefetch.phase {
        case .idle:
            return "Idle."
        case .running:
            return "Running \(done)/\(prefetch.total) · skipped \(prefetch.skipped) · failed \(prefetch.failed) · completed \(prefetch.completed)"
        case .finished:
            return "Finished \(done)/\(prefetch.total) · skipped \(prefetch.skipped) · failed \(prefetch.failed) · completed \(prefetch.completed)"
        }
    }

    private var grid: some View {
        LazyVGrid(columns: columns, spacing: 8) {
            ForEach(PhotoLibrary.gallery) { photo in
                KFImage(photo.url)
                    .placeholder { _ in
                        DemoPalette.canvas
                            .overlay { ProgressView().tint(DemoPalette.accent) }
                    }
                    .cancelOnDisappear(true)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 128)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .overlay(alignment: .bottomLeading) {
                        Text("\(photo.id)")
                            .font(.caption2.monospaced().weight(.medium))
                            .foregroundStyle(DemoPalette.ink)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(Color.black.opacity(0.45), in: Capsule())
                            .padding(6)
                    }
                    .accessibilityLabel(photo.caption)
            }
        }
    }

    private var parked: some View {
        DemoChrome.chartCard(title: "Prefetch", subtitle: "Unmounted") {
            Text("ImagePrefetcher is stopped while Live is open.")
                .font(.subheadline)
                .foregroundStyle(DemoPalette.inkMuted)
                .frame(maxWidth: .infinity, minHeight: 80, alignment: .center)
        }
    }

    private func syncPrefetch() {
        if isSelected {
            if prefetch.phase == .idle {
                prefetch.start()
            }
        } else {
            prefetch.stop()
        }
    }
}

#Preview("Kingfisher Gallery") {
    GalleryScreen(isSelected: true)
        .preferredColorScheme(.dark)
}
