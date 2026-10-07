import ShaderCards
import SwiftUI

/// Frozen marketing stand-ins. Live playground owns every Metal surface.
enum GalleryFamily: String, CaseIterable, Identifiable {
    case codex
    case starburst
    case glass
    case frozen
    case materials
    case library
    case jelly

    var id: String { rawValue }

    var title: String {
        switch self {
        case .codex: "Codex foil"
        case .starburst: "Starburst gold"
        case .glass: "Glass enclosure"
        case .frozen: "Frozen ice"
        case .materials: "Premium materials"
        case .library: "ShaderCards library"
        case .jelly: "Jelly controls"
        }
    }

    var subtitle: String {
        switch self {
        case .codex: "foil · glitter · lightSweep"
        case .starburst: "starburst · radialSweep"
        case .glass: "glassEnclosure · skipped live Metal"
        case .frozen: "frozen · snowfall"
        case .materials: "brushedTitanium · oilSlick"
        case .library: "CardFaceView · no shader passes"
        case .jelly: "JellySwitch · JellyButton · skipped"
        }
    }

    var chips: [String] {
        switch self {
        case .codex:
            ["foil", "glitter", "lightSweep"]
        case .starburst:
            ["starburst", "radialSweep", "multiGlitter"]
        case .glass:
            ["glassEnclosure", "bevel", "sheen"]
        case .frozen:
            ["frozen", "snowfall", "cyan"]
        case .materials:
            ["titanium", "chrome", "rose gold", "oil slick"]
        case .library:
            ["CardFaceView", "emberfox", "static"]
        case .jelly:
            ["JellySwitch", "JellyButton", "not live"]
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
        case .codex:
            FrozenHoloCard(
                colors: [
                    Color(red: 0.12, green: 0.08, blue: 0.28),
                    Color(red: 0.42, green: 0.18, blue: 0.08),
                ],
                title: "CODEX",
                sheen: Color(red: 0.95, green: 0.55, blue: 0.22)
            )
        case .starburst:
            FrozenStarburstCard()
        case .glass:
            FrozenGlassCard()
        case .frozen:
            FrozenIceCard()
        case .materials:
            FrozenMaterialStrip()
        case .library:
            FrozenLibraryStrip()
        case .jelly:
            FrozenJellyCard()
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

/// Painted rainbow wash. Not a Metal foil.
private struct FrozenHoloCard: View {
    var colors: [Color]
    var title: String
    var sheen: Color

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)

            LinearGradient(
                colors: [
                    Color.red.opacity(0.35),
                    Color.yellow.opacity(0.28),
                    Color.green.opacity(0.22),
                    Color.cyan.opacity(0.28),
                    Color.blue.opacity(0.32),
                    Color.purple.opacity(0.35),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .blendMode(.plusLighter)

            LinearGradient(
                colors: [.clear, sheen.opacity(0.55), .clear],
                startPoint: .leading,
                endPoint: .trailing
            )
            .rotationEffect(.degrees(18))

            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.caption.weight(.bold).monospaced())
                    .tracking(1.4)
                    .foregroundStyle(DemoPalette.ink)
                Text("Drag to tilt")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(DemoPalette.ink)
            }
            .padding(14)
        }
        .frame(height: 148)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

private struct FrozenStarburstCard: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.28, green: 0.12, blue: 0.04),
                    Color(red: 0.10, green: 0.06, blue: 0.04),
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            ForEach(0 ..< 12, id: \.self) { index in
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.yellow.opacity(0.55),
                                Color.orange.opacity(0.12),
                                .clear,
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 10, height: 160)
                    .rotationEffect(.degrees(Double(index) * 30))
            }

            VStack(spacing: 4) {
                Text("STARBURST")
                    .font(.caption.weight(.bold).monospaced())
                    .foregroundStyle(DemoPalette.ink)
                Text("radialSweep")
                    .font(.caption2.monospaced())
                    .foregroundStyle(DemoPalette.inkMuted)
            }
        }
        .frame(height: 148)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

private struct FrozenGlassCard: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.10, green: 0.16, blue: 0.28),
                    Color(red: 0.06, green: 0.08, blue: 0.16),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .strokeBorder(Color.white.opacity(0.55), lineWidth: 6)
                .blur(radius: 0.4)
                .padding(8)

            LinearGradient(
                colors: [.white.opacity(0.35), .clear, .white.opacity(0.12)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Text("LAMINATE")
                .font(.caption.weight(.bold).monospaced())
                .foregroundStyle(DemoPalette.ink)
        }
        .frame(height: 148)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

private struct FrozenIceCard: View {
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            LinearGradient(
                colors: [
                    Color(red: 0.12, green: 0.22, blue: 0.38),
                    Color(red: 0.62, green: 0.82, blue: 0.95),
                    Color(red: 0.08, green: 0.12, blue: 0.22),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            ForEach(0 ..< 8, id: \.self) { index in
                Circle()
                    .fill(Color.white.opacity(index.isMultiple(of: 2) ? 0.85 : 0.45))
                    .frame(width: index.isMultiple(of: 3) ? 6 : 3)
                    .offset(x: CGFloat(18 + index * 28), y: CGFloat(-40 - (index * 7) % 50))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("FROZEN")
                    .font(.caption.weight(.bold).monospaced())
                    .foregroundStyle(.white)
                Text("icy silver")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.white)
            }
            .padding(14)
        }
        .frame(height: 148)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

private struct FrozenMaterialStrip: View {
    private let swatches: [(String, Color)] = [
        ("Titan", Color(red: 0.62, green: 0.66, blue: 0.72)),
        ("Chrome", Color(red: 0.12, green: 0.12, blue: 0.14)),
        ("Rose", Color(red: 0.78, green: 0.48, blue: 0.42)),
        ("Oil", Color(red: 0.18, green: 0.08, blue: 0.28)),
    ]

    var body: some View {
        HStack(spacing: 8) {
            ForEach(swatches, id: \.0) { swatch in
                VStack(spacing: 6) {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(swatch.1)
                        .overlay {
                            LinearGradient(
                                colors: [.white.opacity(0.35), .clear, .black.opacity(0.35)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        }
                        .overlay {
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .strokeBorder(Color.white.opacity(0.22), lineWidth: 1)
                        }
                        .frame(height: 72)
                    Text(swatch.0)
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(DemoPalette.ink)
                }
            }
        }
        .padding(8)
        .frame(maxWidth: .infinity)
    }
}

/// ShaderCards faces with Metal passes stripped. Not `TradingCardView`.
private struct FrozenLibraryStrip: View {
    private let cards = LibraryCard.allCases.prefix(4)

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(Array(cards)) { item in
                    CardFaceView(
                        card: item.card,
                        width: 88,
                        finish: item.card.staticThumbnailFinish
                    )
                }
            }
            .padding(8)
        }
        .frame(maxWidth: .infinity)
    }
}

private struct FrozenJellyCard: View {
    var body: some View {
        ZStack {
            Color(red: 0.04, green: 0.04, blue: 0.05)

            HStack(spacing: 28) {
                Capsule()
                    .fill(Color(red: 0.16, green: 0.16, blue: 0.18))
                    .frame(width: 108, height: 48)
                    .overlay(alignment: .leading) {
                        Circle()
                            .fill(DemoPalette.accent)
                            .frame(width: 40, height: 40)
                            .padding(.leading, 4)
                    }

                Circle()
                    .fill(Color(red: 0.95, green: 0.35, blue: 0.55))
                    .frame(width: 56, height: 56)
                    .overlay {
                        Circle()
                            .fill(.white.opacity(0.28))
                            .frame(width: 18, height: 18)
                            .offset(x: -10, y: -10)
                    }
            }
        }
        .frame(height: 148)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}
