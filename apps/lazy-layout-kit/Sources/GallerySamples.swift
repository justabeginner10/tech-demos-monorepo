import LazyLayoutKit
import SwiftUI

/// Paused stand-ins. Live playground owns the virtualized scroll.
enum GalleryFamily: String, CaseIterable, Identifiable {
    case masonry
    case justified
    case timeline
    case textFeed

    var id: String { rawValue }

    var title: String {
        switch self {
        case .masonry: "Masonry"
        case .justified: "Justified"
        case .timeline: "Timeline"
        case .textFeed: "Text feed"
        }
    }

    var subtitle: String {
        switch self {
        case .masonry: "Frozen 2-col · no LazyLayoutView"
        case .justified: "Frozen rows · target 88pt"
        case .timeline: "Frozen lanes · 8 events"
        case .textFeed: "Skipped as a Live default"
        }
    }

    var chips: [String] {
        switch self {
        case .masonry:
            ["MasonryLayout", "columns 2", "N \(DemoCatalog.galleryPhotoCount)", "aspectRatio"]
        case .justified:
            ["JustifiedLayout", "row 88pt", "N \(DemoCatalog.galleryPhotoCount)", "fill width"]
        case .timeline:
            ["TimelineLayout", "start+duration", "N \(DemoCatalog.galleryEventCount)", "lanes"]
        case .textFeed:
            ["TextMeasurer", "TextStyle", "not Live", "Gallery note"]
        }
    }

    @ViewBuilder
    var preview: some View {
        VStack(alignment: .leading, spacing: 8) {
            snapshot
            chipRow
        }
    }

    @ViewBuilder
    private var snapshot: some View {
        switch self {
        case .masonry:
            FrozenMasonrySnapshot()
        case .justified:
            FrozenJustifiedSnapshot()
        case .timeline:
            FrozenTimelineSnapshot()
        case .textFeed:
            FrozenTextFeedNote()
        }
    }

    private var chipRow: some View {
        HStack(spacing: 6) {
            ForEach(chips, id: \.self) { label in
                DemoChrome.chip(label)
            }
        }
        .padding(.horizontal, 8)
        .padding(.bottom, 8)
    }
}

/// Places a small N with the real algorithm, then draws every frame (not virtualized).
private struct FrozenAlgorithmCanvas<Item: Identifiable, Cell: View>: View {
    let items: [Item]
    let result: LazyLayoutResult
    let cell: (Item) -> Cell

    init(
        items: [Item],
        result: LazyLayoutResult,
        @ViewBuilder cell: @escaping (Item) -> Cell
    ) {
        self.items = items
        self.result = result
        self.cell = cell
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            Color.clear.frame(width: 1, height: result.contentHeight)
            ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                let frame = result.frames[index]
                cell(item)
                    .frame(width: frame.width, height: frame.height)
                    .offset(x: frame.x, y: frame.y)
            }
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .frame(height: result.contentHeight)
        .clipped()
    }
}

private struct FrozenMasonrySnapshot: View {
    private let photos = Array(DemoCatalog.photos.prefix(DemoCatalog.galleryPhotoCount))
    @State private var width: Double = 0
    @State private var result: LazyLayoutResult?

    var body: some View {
        canvas
            .onGeometryChange(for: Double.self) { $0.size.width } action: { newWidth in
                relayout(width: newWidth)
            }
    }

    @ViewBuilder
    private var canvas: some View {
        if let result {
            FrozenAlgorithmCanvas(items: photos, result: result) { photo in
                PhotoTile(photo: photo, compact: true)
            }
        } else {
            Color.clear.frame(height: 220)
        }
    }

    private func relayout(width newWidth: Double) {
        guard newWidth > 0, abs(newWidth - width) > 0.5 else { return }
        width = newWidth
        result = DemoLayouts.masonry(columns: 2).layout(
            items: photos.map(\.metric),
            containerWidth: newWidth
        )
    }
}

private struct FrozenJustifiedSnapshot: View {
    private let photos = Array(DemoCatalog.photos.prefix(DemoCatalog.galleryPhotoCount))
    private let layout = JustifiedLayout(
        targetRowHeight: 88,
        horizontalSpacing: 6,
        verticalSpacing: 6
    )
    @State private var width: Double = 0
    @State private var result: LazyLayoutResult?

    var body: some View {
        canvas
            .onGeometryChange(for: Double.self) { $0.size.width } action: { newWidth in
                relayout(width: newWidth)
            }
    }

    @ViewBuilder
    private var canvas: some View {
        if let result {
            FrozenAlgorithmCanvas(items: photos, result: result) { photo in
                PhotoTile(photo: photo, compact: true)
            }
        } else {
            Color.clear.frame(height: 180)
        }
    }

    private func relayout(width newWidth: Double) {
        guard newWidth > 0, abs(newWidth - width) > 0.5 else { return }
        width = newWidth
        result = layout.layout(items: photos.map(\.metric), containerWidth: newWidth)
    }
}

private struct FrozenTimelineSnapshot: View {
    private let events = DemoCatalog.galleryEvents
    @State private var width: Double = 0
    @State private var result: LazyLayoutResult?

    var body: some View {
        canvas
            .onGeometryChange(for: Double.self) { $0.size.width } action: { newWidth in
                relayout(width: newWidth)
            }
    }

    @ViewBuilder
    private var canvas: some View {
        if let result {
            FrozenAlgorithmCanvas(items: events, result: result) { event in
                TimelineTile(event: event, compact: true)
            }
        } else {
            Color.clear.frame(height: 200)
        }
    }

    private func relayout(width newWidth: Double) {
        guard newWidth > 0, abs(newWidth - width) > 0.5 else { return }
        width = newWidth
        result = DemoLayouts.galleryTimeline.layout(
            items: events.map(\.interval),
            containerWidth: newWidth
        )
    }
}

private struct FrozenTextFeedNote: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Self-sizing CoreText")
                .font(.subheadline.weight(.semibold))
            Text(
                "`TextMeasurer` / `TextStyle` can size a feed before any view exists. "
                    + "This playground skips that as a Live default — measuring thousands of "
                    + "strings on first layout is a different cost model than aspect-ratio arithmetic."
            )
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
    }
}
