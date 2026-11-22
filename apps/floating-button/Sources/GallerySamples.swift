import SwiftUI

/// Frozen stand-ins for the Live families. The playground owns every menu.
enum GalleryCard: String, CaseIterable, Identifiable {
    case directions
    case alignment
    case circle
    case motion
    case sizes
    case inits

    var id: String { rawValue }

    var title: String {
        switch self {
        case .directions: "Directions"
        case .alignment: "Alignment"
        case .circle: "Circle"
        case .motion: "Motion"
        case .sizes: "Sizes"
        case .inits: "Inits"
        }
    }

    var subtitle: String {
        switch self {
        case .directions: "Direction"
        case .alignment: "Alignment"
        case .circle: "startAngle · endAngle"
        case .motion: "delays · opacity · scale"
        case .sizes: "wholeMenuSize"
        case .inits: "isOpen · AnyView"
        }
    }

    var chips: [String] {
        switch self {
        case .directions:
            [".left", ".right", ".top", ".bottom"]
        case .alignment:
            [".left", ".center", ".right"]
        case .circle:
            ["3/2 π", "radius 70", ".counterClockwise"]
        case .motion:
            ["delayDelta", "initialOpacity", "initialScaling"]
        case .sizes:
            ["wholeMenuSize", "menuButtonsSize"]
        case .inits:
            ["buttons:", "isOpen:", "AnyView"]
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
        case .directions:
            DirectionMark()
        case .alignment:
            AlignmentMark()
        case .circle:
            CircleMark()
        case .motion:
            MotionMark()
        case .sizes:
            SizeMark()
        case .inits:
            InitMark()
        }
    }

    private var chipRow: some View {
        HStack(spacing: 6) {
            ForEach(chips, id: \.self) { chip in
                DemoChrome.chip(chip)
            }
        }
        .padding(.top, 4)
    }
}

private struct DirectionMark: View {
    var body: some View {
        ZStack {
            hub
            arm(dx: -54, dy: 0)
            arm(dx: 54, dy: 0)
            arm(dx: 0, dy: -54)
            arm(dx: 0, dy: 54)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 140)
    }

    private var hub: some View {
        Circle()
            .fill(DemoPalette.accent)
            .frame(width: 28, height: 28)
    }

    private func arm(dx: CGFloat, dy: CGFloat) -> some View {
        Circle()
            .fill(DemoPalette.ink)
            .frame(width: 14, height: 14)
            .offset(x: dx, y: dy)
    }
}

private struct AlignmentMark: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            row(alignment: .leading, title: "left")
            row(alignment: .center, title: "center")
            row(alignment: .trailing, title: "right")
        }
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func row(alignment: Alignment, title: String) -> some View {
        HStack(spacing: 8) {
            Circle()
                .fill(DemoPalette.accent)
                .frame(width: 16, height: 16)
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .fill(DemoPalette.ink.opacity(0.85))
                .frame(width: 72, height: 16)
                .overlay(alignment: alignment) {
                    Text(title)
                        .font(.caption2.monospaced())
                        .foregroundStyle(DemoPalette.page)
                        .padding(.horizontal, 4)
                }
        }
        .frame(maxWidth: .infinity, alignment: alignment)
    }
}

private struct CircleMark: View {
    var body: some View {
        HStack(spacing: 28) {
            arc(clockwise: true, caption: "clockwise")
            arc(clockwise: false, caption: "counter")
        }
        .frame(maxWidth: .infinity)
        .frame(height: 150)
    }

    private func arc(clockwise: Bool, caption: String) -> some View {
        VStack(spacing: 6) {
            ZStack {
                ForEach(0..<4, id: \.self) { index in
                    let start = 1.5 * Double.pi
                    let end = 2 * Double.pi
                    let step = (end - start) / 3 * Double(index)
                    let angle = clockwise ? start + step : start - step
                    Circle()
                        .fill(DemoPalette.accent)
                        .frame(width: 14, height: 14)
                        .offset(x: CGFloat(cos(angle) * 42), y: CGFloat(sin(angle) * 42))
                }
                Circle()
                    .fill(DemoPalette.ink)
                    .frame(width: 18, height: 18)
            }
            .frame(width: 100, height: 100)
            Text(caption)
                .font(.caption2.monospaced())
                .foregroundStyle(DemoPalette.inkMuted)
        }
    }
}

private struct MotionMark: View {
    var body: some View {
        HStack(alignment: .bottom, spacing: 18) {
            column(title: "scale", dots: [0.35, 0.6, 1])
            column(title: "opacity", dots: [0.25, 0.55, 1])
            delayColumn
        }
        .frame(maxWidth: .infinity)
        .frame(height: 120)
    }

    private func column(title: String, dots: [Double]) -> some View {
        VStack(spacing: 8) {
            HStack(spacing: 6) {
                ForEach(Array(dots.enumerated()), id: \.offset) { item in
                    Circle()
                        .fill(DemoPalette.accent)
                        .frame(width: 18, height: 18)
                        .scaleEffect(CGFloat(title == "scale" ? item.element : 1))
                        .opacity(title == "opacity" ? item.element : 1)
                }
            }
            Text(title)
                .font(.caption2.monospaced())
                .foregroundStyle(DemoPalette.inkMuted)
        }
    }

    private var delayColumn: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("0.00")
            Text("0.10")
            Text("0.20")
        }
        .font(.caption2.monospaced())
        .foregroundStyle(DemoPalette.ink)
    }
}

private struct SizeMark: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Straight: menuButtonsSize is the items. wholeMenuSize adds the main button. The axis follows alignment, not direction.")
            Text("Circle: both bindings receive the same finalFrame.size, and that frame includes the main button.")
        }
        .font(.caption)
        .foregroundStyle(DemoPalette.ink)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct InitMark: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("FloatingButton(mainButtonView:buttons:)")
            Text("FloatingButton(mainButtonView:buttons:isOpen:)")
            Text("AnyView is for a mixed button array. One view type does not need it.")
                .foregroundStyle(DemoPalette.inkMuted)
        }
        .font(.caption.monospaced())
        .foregroundStyle(DemoPalette.ink)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
