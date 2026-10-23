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
                let rect = CGRect(
                    x: dot.x - dot.side / 2,
                    y: dot.y - dot.side / 2,
                    width: dot.side,
                    height: style == .streaks ? dot.side * 3.2 : dot.side
                )
                context.fill(
                    Path(ellipseIn: style == .streaks ? rect : CGRect(x: dot.x - dot.side / 2, y: dot.y - dot.side / 2, width: dot.side, height: dot.side)),
                    with: .color(tint.opacity(dot.alpha))
                )
            }
        }
        .frame(height: 148)
        .background(DemoPalette.canvas)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private func layout(in size: CGSize) -> [Dot] {
        switch style {
        case .burst:
            return (0 ..< 18).map { index in
                let angle = Double(index) / 18 * .pi * 2
                let radius = 18 + Double(index % 4) * 16
                return Dot(
                    x: size.width / 2 + CGFloat(cos(angle) * radius),
                    y: size.height / 2 + CGFloat(sin(angle) * radius * 0.72),
                    side: index % 3 == 0 ? 9 : 6,
                    alpha: 0.95 - Double(index % 4) * 0.15
                )
            }
        case .rise:
            return (0 ..< 14).map { index in
                let column = CGFloat(index % 5)
                let row = CGFloat(index / 5)
                return Dot(
                    x: size.width * (0.34 + column * 0.08),
                    y: size.height * (0.82 - row * 0.22),
                    side: 16 - row * 3,
                    alpha: 0.85 - Double(row) * 0.2
                )
            }
        case .fall:
            return (0 ..< 16).map { index in
                Dot(
                    x: size.width * CGFloat((index * 37) % 100) / 100,
                    y: size.height * CGFloat((index * 19) % 100) / 100,
                    side: index % 3 == 0 ? 8 : 5,
                    alpha: 0.75
                )
            }
        case .drift:
            return (0 ..< 12).map { index in
                Dot(
                    x: size.width * (0.18 + CGFloat(index % 4) * 0.2),
                    y: size.height * (0.22 + CGFloat(index / 4) * 0.26),
                    side: 7,
                    alpha: 0.55 + Double(index % 3) * 0.15
                )
            }
        case .ring:
            return (0 ..< 16).map { index in
                let angle = Double(index) / 16 * .pi * 2
                return Dot(
                    x: size.width / 2 + CGFloat(cos(angle) * 52),
                    y: size.height / 2 + CGFloat(sin(angle) * 36),
                    side: 7,
                    alpha: 0.9
                )
            }
        case .streaks:
            return (0 ..< 14).map { index in
                Dot(
                    x: size.width * CGFloat((index * 17) % 100) / 100,
                    y: size.height * CGFloat((index * 29) % 80) / 100 + 8,
                    side: 3.5,
                    alpha: 0.7
                )
            }
        case .splash:
            return (0 ..< 10).map { index in
                let spread = CGFloat(index) - 4.5
                return Dot(
                    x: size.width / 2 + spread * 14,
                    y: size.height * 0.78 - abs(spread) * 6,
                    side: 5,
                    alpha: 0.8
                )
            }
        }
    }
}

private struct Dot {
    var x: CGFloat
    var y: CGFloat
    var side: CGFloat
    var alpha: Double
}
