import SwiftUI

/// Frozen stand-ins for the Live families. The playground owns every bar.
enum GalleryCard: String, CaseIterable, Identifiable {
    case parabolic
    case teleport
    case straight
    case droplet
    case wiggle
    case colors
    case notch
    case inits

    var id: String { rawValue }

    var title: String {
        switch self {
        case .parabolic: "Parabolic"
        case .teleport: "Teleport"
        case .straight: "Straight"
        case .droplet: "Droplet"
        case .wiggle: "Wiggle"
        case .colors: "Colors"
        case .notch: "Indent"
        case .inits: "Inits"
        }
    }

    var subtitle: String {
        switch self {
        case .parabolic: "BallTrajectory.parabolic"
        case .teleport: "BallTrajectory.teleport"
        case .straight: "BallTrajectory.straight"
        case .droplet: "DropletButton"
        case .wiggle: "WiggleButton"
        case .colors: "bar / selected / ball"
        case .notch: "indentAnimation"
        case .inits: "builder · views"
        }
    }

    var chips: [String] {
        switch self {
        case .parabolic:
            ["quad curve", "control −100", "default"]
        case .teleport:
            ["teleportEffect", "fraction 0.2"]
        case .straight:
            ["offset y 15", "sliding indent"]
        case .droplet:
            ["imageName", "dropletColor"]
        case .wiggle:
            ["image", "maskImage", "imageSize 20"]
        case .colors:
            ["barColor", "selectedColor", "ballColor"]
        case .notch:
            ["delay 0.7", "width 60"]
        case .inits:
            ["TupleView", "views: []"]
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
        case .parabolic:
            ParabolicMark()
        case .teleport:
            TeleportMark()
        case .straight:
            StraightMark()
        case .droplet:
            DropletMark()
        case .wiggle:
            WiggleMark()
        case .colors:
            ColorLegend()
        case .notch:
            NotchMark()
        case .inits:
            InitMark()
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

// MARK: - Paint

private struct ParabolicMark: View {
    var body: some View {
        Canvas { context, size in
            let bar = barRect(in: size)
            let from = CGPoint(x: size.width * 0.22, y: bar.minY - 8)
            let to = CGPoint(x: size.width * 0.62, y: bar.minY - 8)
            let control = CGPoint(x: (from.x + to.x) / 2, y: from.y - 70)
            var arc = Path()
            arc.move(to: from)
            arc.addQuadCurve(to: to, control: control)
            context.stroke(arc, with: .color(DemoPalette.inkMuted), lineWidth: 1.5)
            let peak = CGPoint(x: control.x, y: from.y - 35)
            fillDot(in: &context, center: peak, color: .red)
            fillBar(in: &context, rect: bar, notchAt: to.x)
        }
        .frame(height: 148)
    }
}

private struct TeleportMark: View {
    var body: some View {
        Canvas { context, size in
            let bar = barRect(in: size)
            fillBar(in: &context, rect: bar, notchAt: size.width * 0.78)
            fillDot(in: &context, center: CGPoint(x: size.width * 0.22, y: bar.minY - 8), color: .white.opacity(0.28))
            fillDot(in: &context, center: CGPoint(x: size.width * 0.78, y: bar.minY - 8), color: .white)
        }
        .frame(height: 148)
    }
}

private struct StraightMark: View {
    var body: some View {
        Canvas { context, size in
            let bar = barRect(in: size)
            var guide = Path()
            guide.move(to: CGPoint(x: size.width * 0.22, y: bar.minY - 8))
            guide.addLine(to: CGPoint(x: size.width * 0.7, y: bar.minY - 8))
            context.stroke(guide, with: .color(DemoPalette.inkMuted), lineWidth: 1.5)
            fillDot(in: &context, center: CGPoint(x: size.width * 0.7, y: bar.minY - 8), color: .white)
            fillBar(in: &context, rect: bar, notchAt: size.width * 0.7)
        }
        .frame(height: 148)
    }
}

private struct DropletMark: View {
    var body: some View {
        HStack(spacing: 18) {
            droplet("dropletHouse", active: false)
            droplet("dropletSearch", active: true)
            droplet("dropletBell", active: false)
            droplet("dropletPerson", active: false)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 148)
    }

    private func droplet(_ name: String, active: Bool) -> some View {
        ZStack {
            Circle()
                .fill(Color(red: 125 / 255, green: 38 / 255, blue: 254 / 255))
                .frame(width: active ? 36 : 8, height: active ? 36 : 8)
                .offset(y: active ? 0 : 10)
            Image(name)
                .resizable()
                .scaledToFit()
                .frame(width: 28, height: 28)
                .foregroundStyle(Color(red: 12 / 255, green: 12 / 255, blue: 12 / 255).opacity(0.45))
        }
        .frame(width: 44, height: 56)
        .padding(.horizontal, 6)
        .padding(.vertical, 16)
        .background(Color.white, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

private struct WiggleMark: View {
    var body: some View {
        HStack(spacing: 22) {
            wiggle("heart", active: false)
            wiggle("leaf", active: true)
            wiggle("drop", active: false)
            wiggle("book", active: false)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 148)
        .background {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white)
                .frame(height: 64)
        }
    }

    private func wiggle(_ name: String, active: Bool) -> some View {
        let purple = Color(red: 125 / 255, green: 38 / 255, blue: 254 / 255)
        return ZStack {
            Circle()
                .trim(from: 0.5, to: 1)
                .fill(purple.opacity(active ? 0.45 : 0))
                .frame(width: 34, height: 34)
                .offset(y: 12)
            Image(systemName: active ? "\(name).fill" : name)
                .font(.system(size: 22, weight: .medium))
                .foregroundStyle(active ? purple : purple.opacity(0.35))
                .scaleEffect(active ? 1.2 : 1)
        }
        .frame(width: 44, height: 56)
    }
}

private struct ColorLegend: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            swatch("barColor", note: "default white", color: .white)
            swatch("selectedColor", note: "default red", color: .red)
            swatch("unselectedColor", note: "default black", color: .black)
            swatch("ballColor", note: "default red", color: .red)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(minHeight: 148)
    }

    private func swatch(_ name: String, note: String, color: Color) -> some View {
        HStack(spacing: 8) {
            RoundedRectangle(cornerRadius: 4, style: .continuous)
                .fill(color)
                .frame(width: 18, height: 18)
                .overlay {
                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                        .strokeBorder(DemoPalette.stroke, lineWidth: 1)
                }
            Text(name)
                .font(.caption.monospaced())
                .foregroundStyle(DemoPalette.ink)
            Spacer()
            Text(note)
                .font(.caption2)
                .foregroundStyle(DemoPalette.inkMuted)
        }
    }
}

private struct NotchMark: View {
    var body: some View {
        Canvas { context, size in
            let bar = barRect(in: size, height: 48)
            fillBar(in: &context, rect: bar, notchAt: size.width * 0.5)
            var idle = Path(roundedRect: CGRect(x: 28, y: 28, width: size.width * 0.28, height: 22), cornerRadius: 6)
            context.stroke(idle, with: .color(DemoPalette.inkMuted), lineWidth: 1)
        }
        .frame(height: 148)
    }
}

private struct InitMark: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Builder takes any views. The array initializer needs one type, or AnyView.")
                .font(.caption)
                .foregroundStyle(DemoPalette.ink)
            Text("selectedIndex: Binding<Int>")
                .font(.caption.monospaced())
                .foregroundStyle(DemoPalette.inkMuted)
            Text("prevSelectedIndex is optional. Omitted, the package stores .constant(0).")
                .font(.caption)
                .foregroundStyle(DemoPalette.inkMuted)
        }
        .padding(12)
        .frame(maxWidth: .infinity, minHeight: 148, alignment: .leading)
    }
}

// MARK: - Canvas helpers

private func barRect(in size: CGSize, height: CGFloat = 36) -> CGRect {
    CGRect(x: 20, y: size.height - height - 22, width: size.width - 40, height: height)
}

private func fillDot(in context: inout GraphicsContext, center: CGPoint, color: Color) {
    let rect = CGRect(x: center.x - 5, y: center.y - 5, width: 10, height: 10)
    context.fill(Path(ellipseIn: rect), with: .color(color))
}

private func fillBar(in context: inout GraphicsContext, rect: CGRect, notchAt x: CGFloat) {
    var path = Path(roundedRect: rect, cornerRadius: 12)
    let bite = CGRect(x: x - 22, y: rect.minY - 14, width: 44, height: 28)
    path.addEllipse(in: bite)
    context.fill(path, with: .color(.white), style: FillStyle(eoFill: true))
}
