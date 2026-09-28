import LazyLayoutKit

/// Synthetic photo-like card: stable id, aspect ratio, and hue. No images.
struct PhotoItem: Identifiable, Equatable, Hashable, Sendable {
    let id: Int
    var aspectRatio: Double
    var hue: Double

    var metric: ItemMetric { .aspectRatio(aspectRatio) }
}

/// Cheap interval for ``TimelineLayout``. Units are abstract; the layout scales them.
struct TimelineEvent: Identifiable, Equatable, Hashable, Sendable {
    let id: Int
    var start: Double
    var duration: Double
    var hue: Double

    var interval: TimelineLayout.Interval {
        TimelineLayout.Interval(start: start, duration: duration)
    }
}

enum DemoCatalog {
    /// Default Live count: enough to feel virtualized, small enough for a snappy sim.
    static let liveCount = 360
    /// Optional stress path. Still far below the package's 1_000_000 masonry demo.
    static let stressCount = 8_000
    static let galleryPhotoCount = 8
    static let galleryEventCount = 8

    static let photos: [PhotoItem] = makePhotos(count: stressCount)
    static let events: [TimelineEvent] = makeEvents(count: stressCount)

    /// Compact overlapping intervals so the Gallery timeline shows lanes without a tall card.
    static let galleryEvents: [TimelineEvent] = [
        TimelineEvent(id: 0, start: 0, duration: 36, hue: 0.08),
        TimelineEvent(id: 1, start: 10, duration: 28, hue: 0.18),
        TimelineEvent(id: 2, start: 22, duration: 20, hue: 0.30),
        TimelineEvent(id: 3, start: 40, duration: 24, hue: 0.42),
        TimelineEvent(id: 4, start: 48, duration: 18, hue: 0.55),
        TimelineEvent(id: 5, start: 62, duration: 26, hue: 0.66),
        TimelineEvent(id: 6, start: 70, duration: 16, hue: 0.78),
        TimelineEvent(id: 7, start: 84, duration: 22, hue: 0.90),
    ]

    static func photos(stress: Bool) -> [PhotoItem] {
        Array(photos.prefix(stress ? stressCount : liveCount))
    }

    static func events(stress: Bool) -> [TimelineEvent] {
        Array(events.prefix(stress ? stressCount : liveCount))
    }

    static func jumpID(inCount count: Int) -> Int {
        max(0, min(count - 1, (count * 2) / 3))
    }

    /// Deterministic xorshift so aspect ratios stay put across launches.
    private static func makePhotos(count: Int) -> [PhotoItem] {
        var state: UInt64 = 0xF00D
        func unit() -> Double {
            state ^= state << 13
            state ^= state >> 7
            state ^= state << 17
            Double(state % 10_000) / 10_000
        }

        return (0 ..< count).map { index in
            PhotoItem(
                id: index,
                aspectRatio: 0.55 + unit() * 1.35,
                hue: (Double(index) * 0.618_033_988_75).truncatingRemainder(dividingBy: 1)
            )
        }
    }

    /// Sparse intervals: tall blocks, modest overlap, so scrolling stays smooth.
    /// Dense packing (~67 items per 1_000 pt) is the hitch case the package README warns about.
    private static func makeEvents(count: Int) -> [TimelineEvent] {
        var state: UInt64 = 0xC0DE
        func unit() -> Double {
            state ^= state << 13
            state ^= state >> 7
            state ^= state << 17
            Double(state % 10_000) / 10_000
        }

        var cursor = 0.0
        return (0 ..< count).map { index in
            let duration = 16 + unit() * 20
            let gap = 12 + unit() * 10
            let event = TimelineEvent(
                id: index,
                start: cursor,
                duration: duration,
                hue: (Double(index) * 0.618_033_988_75).truncatingRemainder(dividingBy: 1)
            )
            cursor += gap
            return event
        }
    }
}

enum DemoLayouts {
    static func masonry(columns: Int) -> MasonryLayout {
        MasonryLayout(columns: columns, spacing: 8)
    }

    static let justified = JustifiedLayout(
        targetRowHeight: 140,
        horizontalSpacing: 8,
        verticalSpacing: 8
    )

    /// ~6 pt per unit with 16–36 unit durations → 96–216 pt blocks.
    /// Gaps of 12–22 units keep roughly one item per ~80–130 pt of scroll.
    static let timeline = TimelineLayout(
        pointsPerUnit: 6,
        laneSpacing: 6,
        minimumHeight: 28
    )

    static let galleryTimeline = TimelineLayout(
        pointsPerUnit: 2.4,
        laneSpacing: 4,
        minimumHeight: 22
    )
}
