import Minted
import SwiftUI

/// Frozen marketing stand-ins. Live playground owns every SceneKit coin.
enum GalleryFamily: String, CaseIterable, Identifiable {
    case awardSeal
    case alpineSplit
    case firstClass
    case championLattice
    case compassFile
    case pathEllipse
    case lockedLine
    case pinStills

    var id: String { rawValue }

    var title: String {
        switch self {
        case .awardSeal: "Award · seal"
        case .alpineSplit: "Alpine · split"
        case .firstClass: "First class"
        case .championLattice: "Champion"
        case .compassFile: "Compass · SVG file"
        case .pathEllipse: "Path ellipse"
        case .lockedLine: "Locked line art"
        case .pinStills: "Sample pins"
        }
    }

    var subtitle: String {
        switch self {
        case .awardSeal: "CoinThumbnailView · petals"
        case .alpineSplit: "artSplit 0.34 · two-tone"
        case .firstClass: "octagon · rays"
        case .championLattice: "diamond · lattice"
        case .compassFile: "CoinDesign(svgFileData:)"
        case .pathEllipse: "CoinDesign(art: Path)"
        case .lockedLine: "CoinLineArt · unearned"
        case .pinStills: "ArtworkCoin.Sample · 2D"
        }
    }

    var chips: [String] {
        switch self {
        case .awardSeal:
            ["svgPathData", "seal", "petals", "MINTED"]
        case .alpineSplit:
            ["artLower", "artSplit", "plain", "circle"]
        case .firstClass:
            ["octagon", "rays", "FIRST", "CLASS"]
        case .championLattice:
            ["diamond", "lattice", "CHAMPION"]
        case .compassFile:
            ["svgFileData", "viewBox", "4 paths"]
        case .pathEllipse:
            ["SwiftUI Path", "circle", "plain"]
        case .lockedLine:
            ["CoinLineArt", "no SceneKit", "locked"]
        case .pinStills:
            ["sample JPG", "not live", "source art"]
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
        case .awardSeal:
            thumbnail(CatalogCoins.awardHeart)
        case .alpineSplit:
            thumbnail(CatalogCoins.alpineSplit)
        case .firstClass:
            thumbnail(CatalogCoins.firstClass)
        case .championLattice:
            thumbnail(CatalogCoins.champion)
        case .compassFile:
            thumbnail(CatalogCoins.compass)
        case .pathEllipse:
            thumbnail(CatalogCoins.starburst)
        case .lockedLine:
            CoinLineArt(design: CatalogCoins.awardHeart, size: 140, lineColor: DemoPalette.inkMuted)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
        case .pinStills:
            FrozenPinStrip()
        }
    }

    private func thumbnail(_ design: CoinDesign) -> some View {
        CoinThumbnailView(design: design, size: 148)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
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

/// Bundled pin artwork as stills. Not `SpinningArtworkCoinView`.
private struct FrozenPinStrip: View {
    private let samples: [ArtworkCoin.Sample] = [
        .alhambra, .eiffelTower, .santorini, .mountFuji,
    ]

    var body: some View {
        HStack(spacing: 8) {
            ForEach(samples, id: \.self) { sample in
                VStack(spacing: 6) {
                    if let image = sample.image {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 88)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    } else {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color.white.opacity(0.08))
                            .frame(height: 88)
                    }
                    Text(sample.title)
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(DemoPalette.ink)
                }
            }
        }
        .padding(8)
        .frame(maxWidth: .infinity)
    }
}
