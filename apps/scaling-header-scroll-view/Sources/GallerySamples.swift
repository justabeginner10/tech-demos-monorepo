import SwiftUI

enum GalleryCard: String, CaseIterable, Identifiable {
    case heights
    case progress
    case snap
    case pull
    case tabs
    case api

    var id: String { rawValue }

    var title: String {
        switch self {
        case .heights: "Heights"
        case .progress: "Progress"
        case .snap: "Snap"
        case .pull: "Pull"
        case .tabs: "Tabs"
        case .api: "Modifiers"
        }
    }

    var subtitle: String {
        switch self {
        case .heights: "minHeight · maxHeight"
        case .progress: "0 expanded · 1 collapsed"
        case .snap: "SnapHeaderMode"
        case .pull: "60 pt overscroll"
        case .tabs: "ScalingHeaderTabView"
        case .api: "ScalingHeaderViewAPI"
        }
    }

    var chips: [String] {
        switch self {
        case .heights:
            ["min", "max", "growth"]
        case .progress:
            ["height", "progress", "opacity"]
        case .snap:
            ["0", "0.5", "1"]
        case .pull:
            ["refresh", "load more"]
        case .tabs:
            ["selection", "pageContent"]
        case .api:
            ["collapseProgress", "scrollOffset"]
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
        case .heights:
            HeightsMark()
        case .progress:
            ProgressMark()
        case .snap:
            SnapMark()
        case .pull:
            PullMark()
        case .tabs:
            TabsMark()
        case .api:
            APIMark()
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

private struct HeightsMark: View {
    var body: some View {
        HStack(spacing: 10) {
            headerColumn(title: "max", fraction: 0.92)
            headerColumn(title: "min", fraction: 0.38)
        }
        .padding(12)
        .frame(maxWidth: .infinity, minHeight: 140)
    }

    private func headerColumn(title: String, fraction: CGFloat) -> some View {
        VStack(spacing: 6) {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [DemoPalette.duskTop, DemoPalette.duskMid],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(height: 96 * fraction)
                .overlay(alignment: .bottomLeading) {
                    Image(systemName: "mountain.2.fill")
                        .foregroundStyle(.white.opacity(0.8))
                        .padding(8)
                }
            Text(title)
                .font(.caption2.monospaced())
                .foregroundStyle(DemoPalette.inkMuted)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
    }
}

private struct ProgressMark: View {
    var body: some View {
        HStack(spacing: 8) {
            ForEach(Array([0.0, 0.35, 0.7, 1.0].enumerated()), id: \.offset) { _, value in
                VStack(spacing: 6) {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(DemoPalette.duskMid)
                        .frame(height: 72)
                        .overlay {
                            Image(systemName: "person.crop.circle.fill")
                                .font(.title2)
                                .foregroundStyle(.white)
                                .opacity(1 - value)
                        }
                    Text(String(format: "%.2f", value))
                        .font(.caption2.monospaced())
                        .foregroundStyle(DemoPalette.inkMuted)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(12)
    }
}

private struct SnapMark: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            GeometryReader { geo in
                let width = geo.size.width
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.white.opacity(0.12))
                        .frame(height: 4)
                    ForEach(Array([0.0, 0.5, 1.0].enumerated()), id: \.offset) { _, stop in
                        Circle()
                            .fill(stop == 0.5 ? DemoPalette.accent : DemoPalette.ink)
                            .frame(width: 12, height: 12)
                            .offset(x: (width - 12) * stop)
                    }
                }
            }
            .frame(height: 16)

            HStack {
                Text("expanded")
                Spacer()
                Text("mid")
                Spacer()
                Text("collapsed")
            }
            .font(.caption2.monospaced())
            .foregroundStyle(DemoPalette.inkMuted)
        }
        .padding(12)
        .frame(minHeight: 88)
    }
}

private struct PullMark: View {
    var body: some View {
        HStack(spacing: 18) {
            VStack(spacing: 6) {
                Image(systemName: "arrow.down")
                    .foregroundStyle(DemoPalette.accent)
                petal
                Text("refresh")
                    .font(.caption2.monospaced())
                    .foregroundStyle(DemoPalette.inkMuted)
            }
            .frame(maxWidth: .infinity)

            VStack(spacing: 6) {
                petal
                Image(systemName: "arrow.up")
                    .foregroundStyle(DemoPalette.accent)
                Text("load more")
                    .font(.caption2.monospaced())
                    .foregroundStyle(DemoPalette.inkMuted)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(12)
        .frame(minHeight: 120)
    }

    private var petal: some View {
        ZStack {
            ForEach(0..<8, id: \.self) { index in
                Capsule()
                    .fill(DemoPalette.ink.opacity(index < 5 ? 0.9 : 0.25))
                    .frame(width: 3, height: 8)
                    .offset(y: -8)
                    .rotationEffect(.degrees(Double(index) * 45))
            }
        }
        .frame(width: 28, height: 28)
    }
}

private struct TabsMark: View {
    var body: some View {
        VStack(spacing: 8) {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [DemoPalette.duskTop, DemoPalette.duskMid],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(height: 54)
                .overlay(alignment: .bottom) {
                    HStack(spacing: 6) {
                        ForEach(Shelf.allCases) { shelf in
                            Text(shelf.title)
                                .font(.caption2.weight(.semibold))
                                .foregroundStyle(shelf == .notes ? DemoPalette.page : DemoPalette.ink)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    shelf == .notes ? DemoPalette.ink : Color.white.opacity(0.14),
                                    in: Capsule()
                                )
                        }
                    }
                    .padding(.bottom, 8)
                }

            HStack(spacing: 6) {
                pageStrip(count: 4)
                pageStrip(count: 2)
                pageStrip(count: 6)
            }
        }
        .padding(12)
    }

    private func pageStrip(count: Int) -> some View {
        VStack(spacing: 4) {
            ForEach(0..<count, id: \.self) { _ in
                RoundedRectangle(cornerRadius: 2, style: .continuous)
                    .fill(Color.white.opacity(0.16))
                    .frame(height: 6)
            }
        }
        .frame(maxWidth: .infinity, alignment: .top)
    }
}

private struct APIMark: View {
    private let names = [
        "collapseProgress",
        "scrollOffset",
        "scrollToTop",
        "allowsHeaderGrowth",
        "allowsHeaderCollapse",
        "headerIsClipped",
        "headerAlignment",
        "snapHeaderToState",
        "pullToRefresh",
        "pullToLoadMore",
    ]

    var body: some View {
        FlowChips(names: names)
            .padding(12)
    }
}

private struct FlowChips: View {
    var names: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            ForEach(rows, id: \.self) { row in
                HStack(spacing: 6) {
                    ForEach(row, id: \.self) { name in
                        DemoChrome.chip(name)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var rows: [[String]] {
        stride(from: 0, to: names.count, by: 2).map { start in
            Array(names[start..<min(start + 2, names.count)])
        }
    }
}
