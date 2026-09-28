import LazyLayoutKit
import SwiftUI

struct MasonryLiveSurface: View {
    let photos: [PhotoItem]
    var columns: Int
    @Binding var position: LazyLayoutPosition<Int>

    var body: some View {
        LazyLayoutView(
            photos,
            layout: DemoLayouts.masonry(columns: columns),
            position: $position
        ) { photo in
            photo.metric
        } content: { photo in
            PhotoTile(photo: photo)
        }
    }
}

struct JustifiedLiveSurface: View {
    let photos: [PhotoItem]
    @Binding var position: LazyLayoutPosition<Int>

    var body: some View {
        LazyLayoutView(
            photos,
            layout: DemoLayouts.justified,
            position: $position
        ) { photo in
            photo.metric
        } content: { photo in
            PhotoTile(photo: photo)
        }
    }
}

struct TimelineLiveSurface: View {
    let events: [TimelineEvent]
    @Binding var position: LazyLayoutPosition<Int>

    var body: some View {
        LazyLayoutView(
            events,
            layout: DemoLayouts.timeline,
            overscan: .items(60),
            position: $position
        ) { event in
            event.interval
        } content: { event in
            TimelineTile(event: event)
        }
    }
}

/// Solid fill + short label. No images, blur, or timers.
struct PhotoTile: View {
    var photo: PhotoItem
    var compact = false

    var body: some View {
        RoundedRectangle(cornerRadius: compact ? 6 : 10, style: .continuous)
            .fill(DemoPalette.fill(hue: photo.hue))
            .overlay(alignment: .bottomLeading) {
                Text("#\(photo.id)")
                    .font(.system(size: compact ? 8 : 11, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .padding(.horizontal, compact ? 5 : 7)
                    .padding(.vertical, compact ? 2 : 3)
                    .background(.black.opacity(0.28), in: Capsule())
                    .padding(compact ? 4 : 6)
            }
            .accessibilityLabel("Photo \(photo.id)")
    }
}

struct TimelineTile: View {
    var event: TimelineEvent
    var compact = false

    var body: some View {
        RoundedRectangle(cornerRadius: compact ? 4 : 8, style: .continuous)
            .fill(DemoPalette.fill(hue: event.hue))
            .overlay(alignment: .leading) {
                Text("#\(event.id)")
                    .font(.system(size: compact ? 8 : 11, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .padding(.horizontal, compact ? 5 : 8)
            }
            .accessibilityLabel("Event \(event.id)")
    }
}
