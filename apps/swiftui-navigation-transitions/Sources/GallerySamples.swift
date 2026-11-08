import SwiftUI

enum GalleryCard: String, CaseIterable, Identifiable {
    case slide
    case fade
    case combined
    case custom
    case handler
    case gesture
    case motion

    var id: String { rawValue }

    var title: String {
        switch self {
        case .slide: "Slide"
        case .fade: "Fade"
        case .combined: "Combined"
        case .custom: "Custom"
        case .handler: "Handler"
        case .gesture: "Gesture"
        case .motion: "Motion"
        }
    }

    var subtitle: String {
        switch self {
        case .slide: "slide(axis:)"
        case .fade: "Fade.Style"
        case .combined: "combined(with:)"
        case .custom: "MirrorPush"
        case .handler: "transition(from:to:for:in:)"
        case .gesture: "Interactivity"
        case .motion: "Animation"
        }
    }

    var chips: [String] {
        switch self {
        case .slide:
            [".slide", ".vertical"]
        case .fade:
            [".in", ".out", ".cross"]
        case .combined:
            ["slide", "fade(.in)"]
        case .custom:
            ["Swing", "Zoom", "Flip"]
        case .handler:
            ["_Body = Never", "Drift"]
        case .gesture:
            ["edgePan", "contentPan", "disabled"]
        case .motion:
            ["easeInOut", "linear", "spring"]
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
        case .slide:
            SlideMark()
        case .fade:
            FadeMark()
        case .combined:
            CombinedMark()
        case .custom:
            CustomMark()
        case .handler:
            HandlerMark()
        case .gesture:
            GestureMark()
        case .motion:
            MotionMark()
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

private struct PageCard: View {
    var color: Color
    var title: String
    var opacity: Double = 1
    var rotation: Double = 0
    var scale: CGFloat = 1

    var body: some View {
        RoundedRectangle(cornerRadius: 10, style: .continuous)
            .fill(color)
            .frame(width: 72, height: 96)
            .overlay(alignment: .bottomLeading) {
                Text(title)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(DemoPalette.ink)
                    .padding(8)
            }
            .opacity(opacity)
            .rotationEffect(.degrees(rotation))
            .scaleEffect(scale)
    }
}

private struct SlideMark: View {
    var body: some View {
        HStack(spacing: 16) {
            ZStack(alignment: .leading) {
                PageCard(color: DemoPalette.bay, title: "from")
                    .offset(x: -14)
                PageCard(color: DemoPalette.rust, title: "to")
                    .offset(x: 18)
            }
            .frame(maxWidth: .infinity, minHeight: 120)

            VStack(spacing: 8) {
                PageCard(color: DemoPalette.pine, title: "to")
                    .offset(y: 16)
                Text("vertical")
                    .font(.caption2.monospaced())
                    .foregroundStyle(DemoPalette.inkMuted)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(12)
    }
}

private struct FadeMark: View {
    var body: some View {
        HStack(spacing: 10) {
            fadeColumn("in", incoming: 0.35, outgoing: 1)
            fadeColumn("out", incoming: 1, outgoing: 0.3)
            fadeColumn("cross", incoming: 0.55, outgoing: 0.45)
        }
        .padding(12)
        .frame(maxWidth: .infinity, minHeight: 130)
    }

    private func fadeColumn(_ title: String, incoming: Double, outgoing: Double) -> some View {
        VStack(spacing: 6) {
            ZStack {
                PageCard(color: DemoPalette.bay, title: "from", opacity: outgoing)
                PageCard(color: DemoPalette.rust, title: "to", opacity: incoming)
            }
            Text(title)
                .font(.caption2.monospaced())
                .foregroundStyle(DemoPalette.inkMuted)
        }
        .frame(maxWidth: .infinity)
    }
}

private struct CombinedMark: View {
    var body: some View {
        ZStack {
            PageCard(color: DemoPalette.bay, title: "from")
                .offset(x: -20)
            PageCard(color: DemoPalette.rust, title: "to", opacity: 0.55)
                .offset(x: 22)
        }
        .frame(maxWidth: .infinity, minHeight: 130)
        .padding(12)
    }
}

private struct CustomMark: View {
    var body: some View {
        HStack(spacing: 12) {
            PageCard(color: DemoPalette.rust, title: "swing", rotation: -18, scale: 0.8)
            PageCard(color: DemoPalette.bay, title: "zoom", scale: 0.62)
            PageCard(color: DemoPalette.pine, title: "flip", rotation: 68)
        }
        .frame(maxWidth: .infinity, minHeight: 130)
        .padding(12)
    }
}

private struct HandlerMark: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 0) {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(DemoPalette.bay)
                    .frame(width: 88, height: 64)
                    .overlay {
                        Text("from")
                            .font(.caption2.monospaced())
                            .foregroundStyle(DemoPalette.ink)
                    }
                    .offset(x: -8)
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(DemoPalette.rust.opacity(0.7))
                    .frame(width: 88, height: 64)
                    .overlay {
                        Text("to")
                            .font(.caption2.monospaced())
                            .foregroundStyle(DemoPalette.ink)
                    }
                    .offset(x: 16)
            }
            Text("alpha and translation on TransientView")
                .font(.caption2.monospaced())
                .foregroundStyle(DemoPalette.inkMuted)
        }
        .padding(12)
        .frame(maxWidth: .infinity, minHeight: 120, alignment: .leading)
    }
}

private struct GestureMark: View {
    var body: some View {
        HStack(spacing: 12) {
            gestureColumn(title: "edge", fills: false)
            gestureColumn(title: "content", fills: true)
            VStack(spacing: 6) {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .strokeBorder(DemoPalette.stroke, lineWidth: 1)
                    .frame(width: 72, height: 96)
                    .overlay {
                        Image(systemName: "hand.raised.slash")
                            .foregroundStyle(DemoPalette.inkMuted)
                    }
                Text("off")
                    .font(.caption2.monospaced())
                    .foregroundStyle(DemoPalette.inkMuted)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, minHeight: 140)
    }

    private func gestureColumn(title: String, fills: Bool) -> some View {
        VStack(spacing: 6) {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(DemoPalette.bay)
                .frame(width: 72, height: 96)
                .overlay(alignment: .leading) {
                    Rectangle()
                        .fill(DemoPalette.accent)
                        .frame(width: fills ? 72 : 8)
                }
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                .overlay(alignment: .bottomTrailing) {
                    Image(systemName: "arrow.right")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(DemoPalette.ink)
                        .padding(8)
                }
            Text(title)
                .font(.caption2.monospaced())
                .foregroundStyle(DemoPalette.inkMuted)
        }
    }
}

private struct MotionMark: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            curve(samples: [0.05, 0.2, 0.55, 0.85, 1], title: "ease")
            curve(samples: [0.2, 0.4, 0.6, 0.8, 1], title: "linear")
            curve(samples: [0.15, 0.7, 1.05, 0.92, 1], title: "spring")
        }
        .padding(12)
    }

    private func curve(samples: [CGFloat], title: String) -> some View {
        HStack(spacing: 8) {
            Text(title)
                .font(.caption2.monospaced())
                .foregroundStyle(DemoPalette.inkMuted)
                .frame(width: 44, alignment: .leading)
            GeometryReader { geo in
                Path { path in
                    let step = geo.size.width / CGFloat(samples.count - 1)
                    for (index, sample) in samples.enumerated() {
                        let point = CGPoint(
                            x: CGFloat(index) * step,
                            y: geo.size.height - min(sample, 1) * (geo.size.height - 4) - 2
                        )
                        if index == 0 {
                            path.move(to: point)
                        } else {
                            path.addLine(to: point)
                        }
                    }
                }
                .stroke(DemoPalette.accent, lineWidth: 2)
            }
            .frame(height: 22)
        }
    }
}
