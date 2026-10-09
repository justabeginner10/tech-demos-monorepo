import SwiftUI

extension GallerySelection {
    @ViewBuilder
    var frozenPreview: some View {
        switch self {
        case .change(let kind):
            kind.frozenPreview
        case .transition(let kind):
            kind.frozenPreview
        }
    }
}

extension ChangeEffectKind {
    @ViewBuilder
    var frozenPreview: some View {
        switch self {
        case .spray:
            FrozenSpray()
        case .jump:
            FrozenOffsetCard(offset: -18, symbol: "arrow.up")
        case .pulse:
            FrozenRings()
        case .shine:
            FrozenShine()
        case .spin:
            FrozenSpin()
        case .shake:
            FrozenShake()
        case .wiggle:
            FrozenWiggle()
        case .glow:
            FrozenGlow()
        case .rise:
            FrozenBurst(symbol: "plus", count: 5, upward: true)
        case .haptic:
            FrozenHaptic()
        }
    }
}

extension TransitionKind {
    @ViewBuilder
    var frozenPreview: some View {
        switch self {
        case .pop:
            FrozenPop()
        case .flip:
            FrozenFlip()
        case .anvil:
            FrozenAnvil()
        case .blinds:
            FrozenBlinds()
        case .boing:
            FrozenOffsetCard(offset: 16, symbol: "arrow.down", squash: true)
        case .swoosh:
            FrozenSwoosh()
        case .vanish:
            FrozenVanish()
        case .glare:
            FrozenGlare()
        case .iris:
            FrozenIris()
        case .clock:
            FrozenClock()
        case .poof:
            FrozenPoof()
        case .wipe:
            FrozenWipe()
        case .snapshot:
            FrozenSnapshot()
        case .flicker:
            FrozenFlicker()
        case .skid:
            FrozenOffsetCard(offsetX: 22, symbol: "arrow.right")
        case .blur:
            FrozenBlur()
        }
    }
}

private struct FrozenCanvas<Content: View>: View {
    @ViewBuilder var content: () -> Content

    var body: some View {
        ZStack {
            DemoPalette.canvas
            content()
        }
        .frame(height: 112)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(DemoPalette.stroke, lineWidth: 1)
        }
        .allowsHitTesting(false)
    }
}

/// Mini live badge: white hearts sit on rose, not on the light gallery canvas.
private struct FrozenSpray: View {
    var body: some View {
        FrozenCanvas {
            ZStack {
                DemoPalette.badge

                ForEach(0 ..< 7, id: \.self) { index in
                    Image(systemName: index.isMultiple(of: 2) ? "heart.fill" : "sparkles")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(DemoPalette.particle)
                        .offset(
                            x: CGFloat(index - 3) * 16,
                            y: CGFloat(-22 - (index % 3) * 8)
                        )
                        .opacity(0.75 + Double(index % 3) * 0.08)
                }

                VStack(spacing: 6) {
                    Image(systemName: "heart.fill")
                        .font(.title2.weight(.semibold))
                    Text("Spray")
                        .font(.caption.weight(.semibold))
                }
                .foregroundStyle(DemoPalette.badgeInk)
                .offset(y: 14)
            }
        }
    }
}

private struct FrozenBurst: View {
    var symbol: String
    var count: Int
    var upward: Bool

    var body: some View {
        FrozenCanvas {
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(DemoPalette.badge)
                    .frame(width: 44, height: 44)
                ForEach(0 ..< count, id: \.self) { index in
                    Image(systemName: symbol)
                        .font(.caption.weight(.bold))
                        .foregroundStyle(DemoPalette.accent)
                        .offset(
                            x: CGFloat(index - count / 2) * 18,
                            y: upward ? CGFloat(-28 - (index % 3) * 10) : 0
                        )
                        .opacity(0.35 + Double(index % 3) * 0.2)
                }
            }
        }
    }
}

private struct FrozenOffsetCard: View {
    var offset: CGFloat = 0
    var offsetX: CGFloat = 0
    var symbol: String
    var squash: Bool = false

    var body: some View {
        FrozenCanvas {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(DemoPalette.badge)
                .frame(width: squash ? 88 : 72, height: squash ? 36 : 48)
                .overlay {
                    Image(systemName: symbol)
                        .font(.headline)
                        .foregroundStyle(DemoPalette.badgeInk)
                }
                .scaleEffect(x: squash ? 1.15 : 1, y: squash ? 0.75 : 1)
                .offset(x: offsetX, y: offset)
                .shadow(color: Color.primary.opacity(0.2), radius: 6, y: 4)
        }
    }
}

private struct FrozenRings: View {
    var body: some View {
        FrozenCanvas {
            ZStack {
                ForEach([56, 40, 24], id: \.self) { size in
                    Circle()
                        .strokeBorder(DemoPalette.accent.opacity(size == 24 ? 0.95 : 0.35), lineWidth: 3)
                        .frame(width: CGFloat(size), height: CGFloat(size))
                }
                Circle()
                    .fill(DemoPalette.badge)
                    .frame(width: 18, height: 18)
            }
        }
    }
}

private struct FrozenShine: View {
    var body: some View {
        FrozenCanvas {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(DemoPalette.badge)
                .frame(width: 160, height: 56)
                .overlay {
                    LinearGradient(
                        colors: [.clear, Color.white.opacity(0.85), .clear],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .rotationEffect(.degrees(18))
                }
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        }
    }
}

private struct FrozenSpin: View {
    var body: some View {
        FrozenCanvas {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(DemoPalette.badge)
                .frame(width: 88, height: 48)
                .rotation3DEffect(.degrees(48), axis: (x: 0, y: 1, z: 0), perspective: 0.6)
                .overlay {
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .foregroundStyle(DemoPalette.badgeInk)
                        .rotation3DEffect(.degrees(48), axis: (x: 0, y: 1, z: 0), perspective: 0.6)
                }
        }
    }
}

private struct FrozenShake: View {
    var body: some View {
        FrozenCanvas {
            HStack(spacing: 10) {
                ForEach([-1, 0, 1], id: \.self) { index in
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(DemoPalette.badge.opacity(index == 0 ? 1 : 0.35))
                        .frame(width: 40, height: 48)
                        .offset(x: CGFloat(index) * 6)
                }
            }
        }
    }
}

private struct FrozenWiggle: View {
    var body: some View {
        FrozenCanvas {
            HStack(spacing: 14) {
                ForEach([-12.0, 0.0, 12.0], id: \.self) { angle in
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(DemoPalette.badge.opacity(angle == 0 ? 1 : 0.4))
                        .frame(width: 36, height: 48)
                        .rotationEffect(.degrees(angle))
                }
            }
        }
    }
}

private struct FrozenGlow: View {
    var body: some View {
        FrozenCanvas {
            Circle()
                .fill(DemoPalette.accent.opacity(0.35))
                .frame(width: 88, height: 88)
                .blur(radius: 10)
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(DemoPalette.badge)
                .frame(width: 72, height: 40)
        }
    }
}

private struct FrozenHaptic: View {
    var body: some View {
        FrozenCanvas {
            HStack(alignment: .center, spacing: 5) {
                ForEach([18, 32, 48, 28, 38, 16], id: \.self) { height in
                    Capsule()
                        .fill(DemoPalette.accent)
                        .frame(width: 8, height: CGFloat(height))
                }
            }
        }
    }
}

private struct FrozenPop: View {
    var body: some View {
        FrozenCanvas {
            ZStack {
                ForEach(0 ..< 10, id: \.self) { index in
                    Capsule()
                        .fill(DemoPalette.accent)
                        .frame(width: 6, height: 22)
                        .offset(y: -28)
                        .rotationEffect(.degrees(Double(index) * 36))
                }
                Circle()
                    .fill(DemoPalette.badge)
                    .frame(width: 28, height: 28)
            }
        }
    }
}

private struct FrozenFlip: View {
    var body: some View {
        FrozenCanvas {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(DemoPalette.badge)
                .frame(width: 100, height: 48)
                .rotation3DEffect(.degrees(62), axis: (x: 1, y: 0, z: 0), perspective: 0.55)
        }
    }
}

private struct FrozenAnvil: View {
    var body: some View {
        FrozenCanvas {
            VStack(spacing: 6) {
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(DemoPalette.badge)
                    .frame(width: 72, height: 28)
                HStack(spacing: 8) {
                    ForEach(0 ..< 5, id: \.self) { index in
                        Capsule()
                            .fill(Color.primary.opacity(0.25))
                            .frame(width: 10 + CGFloat(index % 2) * 6, height: 6)
                    }
                }
            }
        }
    }
}

private struct FrozenBlinds: View {
    var body: some View {
        FrozenCanvas {
            VStack(spacing: 4) {
                ForEach(0 ..< 6, id: \.self) { index in
                    Rectangle()
                        .fill(index.isMultiple(of: 2) ? DemoPalette.badge : DemoPalette.ink.opacity(0.55))
                        .frame(height: 10)
                }
            }
            .padding(.horizontal, 24)
        }
    }
}

private struct FrozenSwoosh: View {
    var body: some View {
        FrozenCanvas {
            HStack(spacing: -18) {
                ForEach([0.55, 0.75, 1.0], id: \.self) { scale in
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(DemoPalette.badge.opacity(scale))
                        .frame(width: 70, height: 44)
                        .scaleEffect(scale)
                }
            }
        }
    }
}

private struct FrozenVanish: View {
    var body: some View {
        FrozenCanvas {
            ZStack {
                ForEach(0 ..< 18, id: \.self) { index in
                    Circle()
                        .fill(DemoPalette.accent.opacity(index.isMultiple(of: 3) ? 0.9 : 0.4))
                        .frame(width: index.isMultiple(of: 2) ? 7 : 4)
                        .offset(
                            x: CGFloat((index % 6) * 16 - 40),
                            y: CGFloat((index / 6) * 16 - 16)
                        )
                }
            }
        }
    }
}

private struct FrozenGlare: View {
    var body: some View {
        FrozenCanvas {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(DemoPalette.badge)
                .frame(width: 160, height: 56)
                .overlay(alignment: .leading) {
                    LinearGradient(
                        colors: [.white, .white.opacity(0.2), .clear],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: 54)
                    .rotationEffect(.degrees(18))
                }
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        }
    }
}

private struct FrozenIris: View {
    var body: some View {
        FrozenCanvas {
            Circle()
                .strokeBorder(DemoPalette.ink, lineWidth: 6)
                .frame(width: 72, height: 72)
            Circle()
                .fill(DemoPalette.badge)
                .frame(width: 28, height: 28)
        }
    }
}

private struct FrozenClock: View {
    var body: some View {
        FrozenCanvas {
            Circle()
                .fill(DemoPalette.badge)
                .frame(width: 72, height: 72)
                .mask(alignment: .top) {
                    Rectangle()
                        .frame(height: 36)
                }
            Circle()
                .strokeBorder(DemoPalette.ink, lineWidth: 3)
                .frame(width: 72, height: 72)
        }
    }
}

private struct FrozenPoof: View {
    var body: some View {
        FrozenCanvas {
            HStack(spacing: -8) {
                ForEach(0 ..< 5, id: \.self) { index in
                    Circle()
                        .fill(Color.primary.opacity(index == 2 ? 0.18 : 0.12))
                        .frame(width: index == 2 ? 48 : 32)
                }
            }
        }
    }
}

private struct FrozenWipe: View {
    var body: some View {
        FrozenCanvas {
            HStack(spacing: 0) {
                DemoPalette.badge
                DemoPalette.ink.opacity(0.12)
            }
            .overlay(alignment: .center) {
                Rectangle()
                    .fill(Color.primary)
                    .frame(width: 4)
            }
        }
    }
}

private struct FrozenSnapshot: View {
    var body: some View {
        FrozenCanvas {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color.primary.opacity(0.92))
                .frame(width: 160, height: 56)
                .overlay {
                    Text("FLASH")
                        .font(.caption.weight(.bold).monospaced())
                        .foregroundStyle(Color(.systemBackground))
                }
        }
    }
}

private struct FrozenFlicker: View {
    var body: some View {
        FrozenCanvas {
            HStack(spacing: 12) {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(DemoPalette.badge)
                    .frame(width: 48, height: 40)
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .strokeBorder(DemoPalette.stroke, lineWidth: 2)
                    .frame(width: 48, height: 40)
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(DemoPalette.badge.opacity(0.45))
                    .frame(width: 48, height: 40)
            }
        }
    }
}

private struct FrozenBlur: View {
    var body: some View {
        FrozenCanvas {
            Text("POW")
                .font(.title.weight(.bold))
                .foregroundStyle(DemoPalette.ink)
                .blur(radius: 3)
        }
    }
}
