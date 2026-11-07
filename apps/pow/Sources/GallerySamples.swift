import SwiftUI

/// Painted stand-ins for the Live families. The Live playground owns every Pow call.
enum GalleryCard: String, CaseIterable, Identifiable {
    case shake
    case glow
    case jump
    case spin
    case shine
    case boing
    case pop
    case flip
    case iris
    case wipe

    var id: String { rawValue }

    var title: String {
        switch self {
        case .shake: "Shake"
        case .glow: "Glow"
        case .jump: "Jump"
        case .spin: "Spin"
        case .shine: "Shine"
        case .boing: "Boing"
        case .pop: "Pop"
        case .flip: "Flip"
        case .iris: "Iris"
        case .wipe: "Wipe"
        }
    }

    var subtitle: String {
        switch self {
        case .shake: "AnyChangeEffect.shake"
        case .glow: "AnyChangeEffect.glow"
        case .jump: "AnyChangeEffect.jump"
        case .spin: "AnyChangeEffect.spin"
        case .shine: "AnyChangeEffect.shine"
        case .boing: "movingParts.boing"
        case .pop: "movingParts.pop"
        case .flip: "movingParts.flip"
        case .iris: "movingParts.iris"
        case .wipe: "movingParts.wipe"
        }
    }

    var chips: [String] {
        switch self {
        case .shake:
            ["ShakeRate.fast", "changeEffect", "value"]
        case .glow:
            ["color", "radius 20", "changeEffect"]
        case .jump:
            ["height 40", "underdamped", "changeEffect"]
        case .spin:
            ["axis y", "SpinRate.fast", "changeEffect"]
        case .shine:
            ["duration 1", "changeEffect", "value"]
        case .boing:
            ["edge .top", "spring", "opacity"]
        case .pop:
            ["insertion", "1.2s", "ShapeStyle"]
        case .flip:
            ["rotate in", "overshoot", "spring"]
        case .iris:
            ["origin center", "blurRadius 10", "mask"]
        case .wipe:
            ["45°", "225°", "blurRadius 10"]
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
        case .shake:
            FrozenShake()
        case .glow:
            FrozenGlow()
        case .jump:
            FrozenJump()
        case .spin:
            FrozenSpin()
        case .shine:
            FrozenShine()
        case .boing:
            FrozenBoing()
        case .pop:
            FrozenPop()
        case .flip:
            FrozenFlip()
        case .iris:
            FrozenIris()
        case .wipe:
            FrozenWipe()
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

private struct Tile: View {
    var width: CGFloat = 64
    var height: CGFloat = 64
    var radius: CGFloat = 16

    var body: some View {
        RoundedRectangle(cornerRadius: radius, style: .continuous)
            .fill(DemoPalette.accent)
            .frame(width: width, height: height)
    }
}

private struct FrozenShake: View {
    var body: some View {
        ZStack {
            Tile().opacity(0.35).offset(x: -18)
            Tile().opacity(0.55).offset(x: 14)
            Tile()
        }
        .frame(maxWidth: .infinity)
        .frame(height: 148)
    }
}

private struct FrozenGlow: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(DemoPalette.accent.opacity(0.45))
                .frame(width: 120, height: 120)
                .blur(radius: 18)
            Tile(width: 72, height: 72, radius: 20)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 148)
    }
}

private struct FrozenJump: View {
    var body: some View {
        VStack(spacing: 18) {
            Tile(width: 64, height: 64, radius: 18)
            Capsule()
                .fill(DemoPalette.inkMuted.opacity(0.35))
                .frame(width: 36, height: 6)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 148)
    }
}

private struct FrozenSpin: View {
    var body: some View {
        Tile(width: 72, height: 72, radius: 18)
            .rotation3DEffect(.degrees(58), axis: (x: 0, y: 1, z: 0), perspective: 0.5)
            .frame(maxWidth: .infinity)
            .frame(height: 148)
    }
}

private struct FrozenShine: View {
    var body: some View {
        Tile(width: 120, height: 72, radius: 18)
            .overlay {
                LinearGradient(
                    colors: [.clear, .white.opacity(0.85), .clear],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .frame(width: 28)
                .rotationEffect(.degrees(24))
                .allowsHitTesting(false)
            }
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .frame(maxWidth: .infinity)
            .frame(height: 148)
    }
}

private struct FrozenBoing: View {
    var body: some View {
        Tile(width: 88, height: 48, radius: 20)
            .frame(maxWidth: .infinity)
            .frame(height: 148)
    }
}

private struct FrozenPop: View {
    var body: some View {
        ZStack {
            ForEach(Array(dots.enumerated()), id: \.offset) { _, dot in
                Circle()
                    .fill(DemoPalette.accent.opacity(0.8))
                    .frame(width: 8, height: 8)
                    .offset(dot)
            }
            Tile(width: 56, height: 56, radius: 16)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 148)
    }

    private var dots: [CGSize] {
        [
            CGSize(width: 48, height: 0),
            CGSize(width: 24, height: 32),
            CGSize(width: -24, height: 32),
            CGSize(width: -48, height: 0),
            CGSize(width: -24, height: -32),
            CGSize(width: 24, height: -32),
        ]
    }
}

private struct FrozenFlip: View {
    var body: some View {
        Tile(width: 88, height: 56, radius: 16)
            .rotation3DEffect(.degrees(68), axis: (x: 1, y: 0, z: 0), perspective: 0.6)
            .frame(maxWidth: .infinity)
            .frame(height: 148)
    }
}

private struct FrozenIris: View {
    var body: some View {
        Tile(width: 120, height: 72, radius: 16)
            .mask(Circle().frame(width: 64, height: 64))
            .frame(maxWidth: .infinity)
            .frame(height: 148)
    }
}

private struct FrozenWipe: View {
    var body: some View {
        Tile(width: 120, height: 72, radius: 16)
            .mask(alignment: .leading) {
                Rectangle().frame(width: 68)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 148)
    }
}
