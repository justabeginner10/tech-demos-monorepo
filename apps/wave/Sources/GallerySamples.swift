import SwiftUI

/// Frozen stand-ins for the Live families, the built-in springs, and the UIKit block API.
/// Live playground owns every `SpringAnimator`.
enum GalleryCard: String, CaseIterable, Identifiable {
    case drag
    case fling
    case scale
    case springs
    case retarget
    case events
    case modes
    case block

    var id: String { rawValue }

    var title: String {
        switch self {
        case .drag: "Drag"
        case .fling: "Fling"
        case .scale: "Scale"
        case .springs: "Springs"
        case .retarget: "Retarget"
        case .events: "Events"
        case .modes: "Modes"
        case .block: "Block API"
        }
    }

    var subtitle: String {
        switch self {
        case .drag: "SpringAnimator<CGPoint>"
        case .fling: "project(point:velocity:)"
        case .scale: "SpringAnimator<CGFloat>"
        case .springs: "dampingRatio · response"
        case .retarget: "target in flight"
        case .events: "SpringAnimator.Event"
        case .modes: "AnimationMode"
        case .block: "Wave.animate · UIView"
        }
    }

    var chips: [String] {
        switch self {
        case .drag:
            ["nonAnimated", "valueChanged", "offset"]
        case .fling:
            ["velocity", "project", "gesture"]
        case .scale:
            ["defaultInteractive", "defaultAnimated", "scaleEffect"]
        case .springs:
            ["dampingRatio", "response", "stiffness"]
        case .retarget:
            ["target", "velocity kept", "start"]
        case .events:
            ["finished(at:)", "retargeted(from:to:)", "completion"]
        case .modes:
            ["animated", "nonAnimated", "response 0"]
        case .block:
            ["withSpring", "gestureVelocity", "not mounted"]
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
        case .drag:
            FrozenDrag()
        case .fling:
            FrozenFling()
        case .scale:
            FrozenScale()
        case .springs:
            FrozenSprings()
        case .retarget:
            FrozenRetarget()
        case .events:
            FrozenEvents()
        case .modes:
            FrozenModes()
        case .block:
            FrozenBlock()
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

private struct FrozenDrag: View {
    var body: some View {
        ZStack {
            Circle()
                .strokeBorder(DemoPalette.inkMuted, lineWidth: 1)
                .frame(width: 14, height: 14)
                .offset(x: 46, y: 18)

            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(DemoPalette.accent)
                .frame(width: 54, height: 54)
                .offset(x: 28, y: 8)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 148)
        .background(DemoPalette.canvas)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

private struct FrozenFling: View {
    var body: some View {
        Canvas { context, size in
            let start = CGPoint(x: size.width * 0.28, y: size.height * 0.62)
            let end = CGPoint(x: size.width * 0.72, y: size.height * 0.34)
            var path = Path()
            path.move(to: start)
            let control = CGPoint(x: size.width * 0.48, y: size.height * 0.18)
            path.addQuadCurve(to: end, control: control)
            context.stroke(path, with: .color(DemoPalette.accent), lineWidth: 2)

            let ring = Path(ellipseIn: CGRect(x: end.x - 7, y: end.y - 7, width: 14, height: 14))
            context.stroke(ring, with: .color(DemoPalette.inkMuted), lineWidth: 1)

            let puck = Path(roundedRect: CGRect(x: start.x - 16, y: start.y - 16, width: 32, height: 32), cornerRadius: 8)
            context.fill(puck, with: .color(DemoPalette.accent))
        }
        .frame(height: 148)
        .background(DemoPalette.canvas)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

private struct FrozenScale: View {
    var body: some View {
        HStack(spacing: 28) {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(DemoPalette.inkMuted)
                .frame(width: 36, height: 36)
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(DemoPalette.accent)
                .frame(width: 64, height: 64)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 148)
        .background(DemoPalette.canvas)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

/// Three painted responses. Not integrated with `Spring.updateValue`.
private struct FrozenSprings: View {
    var body: some View {
        Canvas { context, size in
            stroke(context, size: size, samples: critical, color: DemoPalette.ink)
            stroke(context, size: size, samples: fast, color: DemoPalette.inkMuted)
            stroke(context, size: size, samples: bounce, color: DemoPalette.accent)
        }
        .frame(height: 148)
        .background(DemoPalette.canvas)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private var critical: [CGFloat] {
        [0.0, 0.22, 0.48, 0.70, 0.84, 0.93, 0.97, 1.0]
    }

    private var fast: [CGFloat] {
        [0.0, 0.55, 0.82, 0.94, 0.99, 1.0, 1.0, 1.0]
    }

    private var bounce: [CGFloat] {
        [0.0, 0.35, 0.78, 1.12, 0.92, 1.04, 0.98, 1.0]
    }

    private func stroke(_ context: GraphicsContext, size: CGSize, samples: [CGFloat], color: Color) {
        var path = Path()
        let count = samples.count
        for index in samples.indices {
            let slot = CGFloat(index)
            let last = CGFloat(count - 1)
            let x = 16 + (size.width - 32) * (slot / last)
            let y = (size.height - 24) - samples[index] * (size.height - 40)
            let point = CGPoint(x: x, y: y)
            if index == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }
        context.stroke(path, with: .color(color), lineWidth: 2)
    }
}

private struct FrozenRetarget: View {
    var body: some View {
        Canvas { context, size in
            let left = CGPoint(x: size.width * 0.22, y: size.height * 0.58)
            let middle = CGPoint(x: size.width * 0.5, y: size.height * 0.58)
            let right = CGPoint(x: size.width * 0.78, y: size.height * 0.58)
            var path = Path()
            path.move(to: left)
            path.addQuadCurve(to: right, control: CGPoint(x: size.width * 0.5, y: size.height * 0.22))
            context.stroke(path, with: .color(DemoPalette.accent), lineWidth: 2)
            for point in [left, middle, right] {
                let rect = CGRect(x: point.x - 6, y: point.y - 6, width: 12, height: 12)
                context.stroke(Path(ellipseIn: rect), with: .color(DemoPalette.inkMuted), lineWidth: 1)
            }
            let puck = CGRect(x: size.width * 0.46, y: size.height * 0.30, width: 16, height: 16)
            context.fill(Path(ellipseIn: puck), with: .color(DemoPalette.accent))
        }
        .frame(height: 148)
        .background(DemoPalette.canvas)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

private struct FrozenEvents: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("retargeted 0.18 → 1.00")
                .font(.caption.monospaced())
                .foregroundStyle(DemoPalette.ink)
            Text("finished at 1.00")
                .font(.caption.monospaced())
                .foregroundStyle(DemoPalette.inkMuted)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
        .frame(height: 148)
        .background(DemoPalette.canvas)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

private struct FrozenModes: View {
    var body: some View {
        HStack(spacing: 18) {
            VStack(spacing: 8) {
                Capsule()
                    .fill(DemoPalette.accent)
                    .frame(width: 72, height: 6)
                Text("animated")
                    .font(.caption2.monospaced())
                    .foregroundStyle(DemoPalette.inkMuted)
            }
            VStack(spacing: 8) {
                HStack(spacing: 4) {
                    Circle()
                        .fill(DemoPalette.inkMuted)
                        .frame(width: 8, height: 8)
                    Circle()
                        .fill(DemoPalette.accent)
                        .frame(width: 8, height: 8)
                }
                Text("nonAnimated")
                    .font(.caption2.monospaced())
                    .foregroundStyle(DemoPalette.inkMuted)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 148)
        .background(DemoPalette.canvas)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

private struct FrozenBlock: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("UIView.animator")
                .font(.caption.monospaced())
                .foregroundStyle(DemoPalette.ink)
            Text("center · scale · alpha")
                .font(.caption.monospaced())
                .foregroundStyle(DemoPalette.inkMuted)
            Text("Not mounted in this app.")
                .font(.caption)
                .foregroundStyle(DemoPalette.inkMuted)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
        .frame(height: 148)
        .background(DemoPalette.canvas)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}
