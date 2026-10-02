import SwiftUI

/// Frozen marketing stand-ins. Live playground owns every Metal fold.
enum GalleryFamily: String, CaseIterable, Identifiable {
    case swipeReveal
    case pageTurn
    case midnight
    case materials
    case tiltPane
    case pagerAtlas
    case island

    var id: String { rawValue }

    var title: String {
        switch self {
        case .swipeReveal: "Swipe · reveal"
        case .pageTurn: "Page turn"
        case .midnight: "Midnight glass"
        case .materials: "Six materials"
        case .tiltPane: "Tilt pane"
        case .pagerAtlas: "Pager atlas"
        case .island: "Island pull"
        }
    }

    var subtitle: String {
        switch self {
        case .swipeReveal: "FoldTransition · foldSwipe"
        case .pageTurn: "FoldChoreography.pageTurn"
        case .midnight: "FoldStyle(appearance:)"
        case .materials: "FoldAppearance · frozen"
        case .tiltPane: "foldEffect(angle:)"
        case .pagerAtlas: "FoldPager · one page"
        case .island: "FoldCutout · skipped live"
        }
    }

    var chips: [String] {
        switch self {
        case .swipeReveal:
            ["FoldTransition", "foldSwipe", "reveal"]
        case .pageTurn:
            ["pageTurn", "hinge right", "both views"]
        case .midnight:
            ["midnight", "cool diffusion", "midpoint"]
        case .materials:
            ["frosted", "grain", "gloss", "ink"]
        case .tiltPane:
            ["30°", "right hinge", "recapture at 0"]
        case .pagerAtlas:
            ["FoldPager", "5 places", "swipe"]
        case .island:
            ["FoldCutoutPull", "liquid", "not live"]
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
        case .swipeReveal:
            FrozenFoldCard(
                left: Color(red: 0.12, green: 0.10, blue: 0.28),
                right: Color(red: 0.96, green: 0.62, blue: 0.28),
                leftTitle: "COVER",
                rightTitle: "INNER",
                lifted: .right
            )
        case .pageTurn:
            FrozenFoldCard(
                left: Color(red: 0.06, green: 0.28, blue: 0.34),
                right: Color(red: 0.42, green: 0.10, blue: 0.22),
                leftTitle: "FROM",
                rightTitle: "NEXT",
                lifted: .left
            )
        case .midnight:
            FrozenFoldCard(
                left: Color(red: 0.04, green: 0.06, blue: 0.12),
                right: Color(red: 0.10, green: 0.16, blue: 0.28),
                leftTitle: "NIGHT",
                rightTitle: "GLASS",
                lifted: .right,
                frost: Color(red: 0.45, green: 0.62, blue: 0.92).opacity(0.28)
            )
        case .materials:
            FrozenMaterialStrip()
        case .tiltPane:
            FrozenTiltCard()
        case .pagerAtlas:
            FrozenPagerStrip()
        case .island:
            FrozenIslandCard()
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

private enum LiftedHalf {
    case left, right
}

/// Painted crease + frost. Not a Metal fold.
private struct FrozenFoldCard: View {
    var left: Color
    var right: Color
    var leftTitle: String
    var rightTitle: String
    var lifted: LiftedHalf
    var frost: Color = Color.white.opacity(0.22)

    var body: some View {
        ZStack {
            HStack(spacing: 0) {
                pane(left, title: leftTitle, ink: DemoPalette.ink)
                pane(right, title: rightTitle, ink: liftedInk)
            }

            LinearGradient(
                colors: lifted == .right
                    ? [.clear, frost, frost.opacity(0.7)]
                    : [frost.opacity(0.7), frost, .clear],
                startPoint: .leading,
                endPoint: .trailing
            )
            .allowsHitTesting(false)

            Rectangle()
                .fill(Color.white.opacity(0.55))
                .frame(width: 2)
                .shadow(color: .black.opacity(0.45), radius: 6)
        }
        .frame(height: 148)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private var liftedInk: Color {
        lifted == .right ? Color(red: 0.14, green: 0.08, blue: 0.04) : DemoPalette.ink
    }

    private func pane(_ color: Color, title: String, ink: Color) -> some View {
        ZStack(alignment: .bottomLeading) {
            color
            Text(title)
                .font(.caption.weight(.bold).monospaced())
                .tracking(1.2)
                .foregroundStyle(ink)
                .padding(12)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct FrozenMaterialStrip: View {
    private let swatches: [(String, Color)] = [
        ("Frost", Color(red: 0.72, green: 0.76, blue: 0.84)),
        ("Clear", Color(red: 0.88, green: 0.90, blue: 0.94)),
        ("Grain", Color(red: 0.62, green: 0.58, blue: 0.50)),
        ("Gloss", Color(red: 0.78, green: 0.86, blue: 0.96)),
        ("Ink", Color(red: 0.18, green: 0.18, blue: 0.20)),
        ("Mid", Color(red: 0.16, green: 0.22, blue: 0.38)),
    ]

    var body: some View {
        HStack(spacing: 8) {
            ForEach(swatches, id: \.0) { swatch in
                VStack(spacing: 6) {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(swatch.1)
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

private struct FrozenTiltCard: View {
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            LinearGradient(
                colors: [
                    Color(red: 0.95, green: 0.28, blue: 0.32),
                    Color(red: 0.42, green: 0.08, blue: 0.22),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            LinearGradient(
                colors: [.white.opacity(0.28), .clear, .black.opacity(0.25)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            VStack(alignment: .leading, spacing: 6) {
                Text("PANE")
                    .font(.caption2.weight(.bold).monospaced())
                    .foregroundStyle(.white)
                Text("30° hinge")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.white)
            }
            .padding(14)
        }
        .frame(height: 148)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .rotation3DEffect(.degrees(12), axis: (x: 0, y: 1, z: 0), perspective: 0.55)
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
    }
}

private struct FrozenPagerStrip: View {
    var body: some View {
        HStack(spacing: 8) {
            ForEach(PlaceCard.catalog.prefix(4)) { place in
                ZStack(alignment: .bottomLeading) {
                    LinearGradient(
                        colors: [place.top, place.bottom],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    Text(place.title)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(DemoPalette.ink)
                        .padding(8)
                }
                .frame(height: 96)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
        }
        .padding(8)
    }
}

private struct FrozenIslandCard: View {
    var body: some View {
        ZStack(alignment: .top) {
            LinearGradient(
                colors: [
                    Color(red: 0.10, green: 0.10, blue: 0.12),
                    Color(red: 0.06, green: 0.06, blue: 0.07),
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            Capsule()
                .fill(Color.black)
                .overlay {
                    Capsule().strokeBorder(Color.white.opacity(0.22), lineWidth: 1)
                }
                .frame(width: 118, height: 34)
                .padding(.top, 10)

            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(red: 0.22, green: 0.22, blue: 0.26))
                .overlay(alignment: .leading) {
                    Text("Story card")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(DemoPalette.ink)
                        .padding(.leading, 14)
                }
                .frame(height: 64)
                .padding(.horizontal, 28)
                .padding(.top, 58)
                .opacity(0.55)
        }
        .frame(height: 148)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}
