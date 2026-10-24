import SwiftUI

/// Frozen stand-ins for every built-in preset, plus the custom ember ring.
/// Live playground owns every `VortexView`.
enum GalleryCard: String, CaseIterable, Identifiable {
    case confetti
    case fire
    case fireflies
    case fireworks
    case magic
    case rain
    case smoke
    case snow
    case spark
    case splash
    case ember

    var id: String { rawValue }

    var title: String {
        switch self {
        case .ember: "Ember ring"
        default:
            ParticlePreset(rawValue: rawValue)?.title ?? rawValue
        }
    }

    var subtitle: String {
        switch self {
        case .ember: "VortexSystem · onDeath"
        default:
            ParticlePreset(rawValue: rawValue)?.api ?? ""
        }
    }

    var chips: [String] {
        switch self {
        case .ember:
            ["ring", "secondary", "burstCount", "circle"]
        default:
            ParticlePreset(rawValue: rawValue)?.chips ?? []
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
        case .confetti:
            FrozenParticles(style: .burst, tint: Color(red: 1, green: 0.45, blue: 0.55))
        case .fire:
            FrozenParticles(style: .rise, tint: Color(red: 1, green: 0.45, blue: 0.12))
        case .fireflies:
            FrozenParticles(style: .drift, tint: Color(red: 1, green: 0.86, blue: 0.35))
        case .fireworks:
            FrozenParticles(style: .burst, tint: Color(red: 0.45, green: 0.75, blue: 1))
        case .magic:
            FrozenParticles(style: .ring, tint: Color(red: 1, green: 0.55, blue: 0.85))
        case .rain:
            FrozenParticles(style: .streaks, tint: Color(red: 0.62, green: 0.72, blue: 1))
        case .smoke:
            FrozenParticles(style: .rise, tint: Color(red: 0.55, green: 0.55, blue: 0.58))
        case .snow:
            FrozenParticles(style: .fall, tint: .white)
        case .spark:
            FrozenParticles(style: .streaks, tint: Color(red: 1, green: 0.82, blue: 0.35))
        case .splash:
            FrozenParticles(style: .splash, tint: Color(red: 0.62, green: 0.72, blue: 1))
        case .ember:
            FrozenParticles(style: .ring, tint: Color(red: 1, green: 0.48, blue: 0.18))
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

private enum FrozenStyle {
    case burst
    case rise
    case fall
    case drift
    case ring
    case streaks
    case splash
}

/// Painted dots. Not a particle system.
private struct FrozenParticles: View {
    var style: FrozenStyle
    var tint: Color

    var body: some View {
        Canvas { context, size in
            let dots = layout(in: size)
            for dot in dots {
                let half: CGFloat = dot.side / 2
                let originX = dot.x - half
                let originY = dot.y - half
                let streakHeight: CGFloat = dot.side * 3.2
                let height: CGFloat = style == .streaks ? streakHeight : dot.side
                let rect = CGRect(x: originX, y: originY, width: dot.side, height: height)
                context.fill(Path(ellipseIn: rect), with: .color(tint.opacity(dot.alpha)))
            }
        }
        .frame(height: 148)
        .background(DemoPalette.canvas)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    /// Coordinates are separate typed statements. A single closure expression that
    /// mixes `Int` modulo, `CGFloat`, and `Double` literals exceeds the type checker.
    private func layout(in size: CGSize) -> [Dot] {
        switch style {
        case .burst:
            return (0 ..< 18).map { index in
                let turns = Double(index) / Double(18)
                let angle = turns * Double.pi * 2
                let radius = Double(18) + Double(index % 4) * Double(16)
                let centerX: CGFloat = size.width / 2
                let centerY: CGFloat = size.height / 2
                let xReach = cos(angle) * radius
                let yReach = sin(angle) * radius * 0.72
                let x = centerX + CGFloat(xReach)
                let y = centerY + CGFloat(yReach)
                let side: CGFloat = index % 3 == 0 ? 9 : 6
                let alpha = 0.95 - Double(index % 4) * 0.15
                return Dot(x: x, y: y, side: side, alpha: alpha)
            }
        case .rise:
            return (0 ..< 14).map { index in
                let column = CGFloat(index % 5)
                let row = CGFloat(index / 5)
                let xFactor: CGFloat = 0.34 + column * 0.08
                let yFactor: CGFloat = 0.82 - row * 0.22
                let x = size.width * xFactor
                let y = size.height * yFactor
                let side: CGFloat = 16 - row * 3
                let alpha = 0.85 - Double(row) * 0.2
                return Dot(x: x, y: y, side: side, alpha: alpha)
            }
        case .fall:
            return (0 ..< 16).map { index in
                let xSlot = (index * 37) % 100
                let ySlot = (index * 19) % 100
                let x = hashSpan(size.width, slot: xSlot)
                let y = hashSpan(size.height, slot: ySlot)
                let side: CGFloat = index % 3 == 0 ? 8 : 5
                return Dot(x: x, y: y, side: side, alpha: 0.75)
            }
        case .drift:
            return (0 ..< 12).map { index in
                let column = CGFloat(index % 4)
                let row = CGFloat(index / 4)
                let xFactor: CGFloat = 0.18 + column * 0.2
                let yFactor: CGFloat = 0.22 + row * 0.26
                let x = size.width * xFactor
                let y = size.height * yFactor
                let alpha = 0.55 + Double(index % 3) * 0.15
                return Dot(x: x, y: y, side: 7, alpha: alpha)
            }
        case .ring:
            return (0 ..< 16).map { index in
                let turns = Double(index) / Double(16)
                let angle = turns * Double.pi * 2
                let centerX: CGFloat = size.width / 2
                let centerY: CGFloat = size.height / 2
                let xReach = cos(angle) * Double(52)
                let yReach = sin(angle) * Double(36)
                let x = centerX + CGFloat(xReach)
                let y = centerY + CGFloat(yReach)
                return Dot(x: x, y: y, side: 7, alpha: 0.9)
            }
        case .streaks:
            return (0 ..< 14).map { index in
                let xSlot = (index * 17) % 100
                let ySlot = (index * 29) % 80
                let x = hashSpan(size.width, slot: xSlot)
                let yBase = hashSpan(size.height, slot: ySlot)
                let y: CGFloat = yBase + 8
                return Dot(x: x, y: y, side: 3.5, alpha: 0.7)
            }
        case .splash:
            return (0 ..< 10).map { index in
                let spread: CGFloat = CGFloat(index) - 4.5
                let xOffset: CGFloat = spread * 14
                let yLift: CGFloat = abs(spread) * 6
                let yBase: CGFloat = size.height * 0.78
                let centerX: CGFloat = size.width / 2
                let x = centerX + xOffset
                let y = yBase - yLift
                return Dot(x: x, y: y, side: 5, alpha: 0.8)
            }
        }
    }

    /// `(span * CGFloat(slot)) / 100`, split so the multiply and divide type-check separately.
    private func hashSpan(_ span: CGFloat, slot: Int) -> CGFloat {
        let scaled: CGFloat = span * CGFloat(slot)
        return scaled / 100
    }
}

private struct Dot {
    var x: CGFloat
    var y: CGFloat
    var side: CGFloat
    var alpha: Double
}
