import SwiftUI

/// Painted stand-ins for the Live families. The prefetch grid above is the only Kingfisher view on this tab.
enum GalleryCard: String, CaseIterable, Identifiable {
    case fade
    case processors
    case retry
    case cache

    var id: String { rawValue }

    var title: String {
        switch self {
        case .fade: "Transitions"
        case .processors: "Processors"
        case .retry: "Retry"
        case .cache: "Cache"
        }
    }

    var subtitle: String {
        switch self {
        case .fade: "fade · loadTransition"
        case .processors: "|> chain"
        case .retry: "onFailureView"
        case .cache: "clearMemoryCache · clearDiskCache"
        }
    }

    var chips: [String] {
        switch self {
        case .fade:
            ["fade(duration:)", "loadTransition", "forceRefresh"]
        case .processors:
            ["Downsampling", "RoundCorner", "Blur"]
        case .retry:
            ["retry(maxCount:)", ".seconds(1)", "404"]
        case .cache:
            ["memory cost", "diskStorageSize", "ImageCache.default"]
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
        case .fade:
            FrozenFade()
        case .processors:
            FrozenProcessors()
        case .retry:
            FrozenRetry()
        case .cache:
            FrozenCache()
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

private struct FrozenFade: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(DemoPalette.accent.opacity(0.35))
                .frame(width: 120, height: 78)
                .offset(x: -18)
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(DemoPalette.accent)
                .frame(width: 120, height: 78)
                .offset(x: 18)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 120)
    }
}

private struct FrozenProcessors: View {
    var body: some View {
        HStack(spacing: 10) {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(DemoPalette.ink.opacity(0.2))
                .frame(width: 72, height: 72)
            Image(systemName: "arrow.right")
                .foregroundStyle(DemoPalette.inkMuted)
            Circle()
                .fill(DemoPalette.accent.opacity(0.85))
                .frame(width: 72, height: 72)
                .blur(radius: 0.4)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 120)
    }
}

private struct FrozenRetry: View {
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "arrow.clockwise")
                .font(.title2)
                .foregroundStyle(DemoPalette.accent)
            Text("404 · retry 2 × 1s")
                .font(.caption.monospaced())
                .foregroundStyle(DemoPalette.inkMuted)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 120)
    }
}

private struct FrozenCache: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            bar(width: 0.72, title: "memory")
            bar(width: 0.38, title: "disk")
        }
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity)
        .frame(height: 120)
    }

    private func bar(width: CGFloat, title: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption2.monospaced())
                .foregroundStyle(DemoPalette.inkMuted)
            GeometryReader { proxy in
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .fill(DemoPalette.accent)
                    .frame(width: proxy.size.width * width)
            }
            .frame(height: 8)
        }
    }
}
