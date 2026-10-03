import Minted
import SwiftUI
import UIKit

/// Vector glyphs used by Live Award / Reverse and by Gallery thumbnails.
enum AwardArt: String, CaseIterable, Identifiable, Hashable {
    case heart
    case star
    case mountain
    case trophy

    var id: String { rawValue }

    var title: String {
        switch self {
        case .heart: "Heart"
        case .star: "Star"
        case .mountain: "Alpine"
        case .trophy: "Trophy"
        }
    }

    var topText: String {
        switch self {
        case .heart: "MINTED"
        case .star: "FIRST"
        case .mountain: "SUMMIT"
        case .trophy: "CHAMPION"
        }
    }

    var bottomText: String {
        switch self {
        case .heart: "AWARD"
        case .star: "CLASS"
        case .mountain: "ALPS"
        case .trophy: "SEASON"
        }
    }

    var defaultSilhouette: DemoSilhouette {
        switch self {
        case .heart: .seal
        case .star: .octagon
        case .mountain: .circle
        case .trophy: .diamond
        }
    }

    var defaultEngraving: CoinEngraving {
        switch self {
        case .heart: .petals
        case .star: .rays
        case .mountain: .plain
        case .trophy: .lattice
        }
    }

    var palette: CoinPalette {
        switch self {
        case .heart:
            CoinPalette()
        case .star:
            CoinPalette(
                field: UIColor(red: 0.08, green: 0.14, blue: 0.28, alpha: 1),
                art: UIColor(red: 0.98, green: 0.92, blue: 0.72, alpha: 1)
            )
        case .mountain:
            CoinPalette(
                field: UIColor(red: 0.10, green: 0.18, blue: 0.42, alpha: 1),
                art: .white,
                artLower: UIColor(red: 0.20, green: 0.48, blue: 0.86, alpha: 1),
                artSplit: 0.34
            )
        case .trophy:
            CoinPalette(
                field: UIColor(red: 0.48, green: 0.10, blue: 0.16, alpha: 1),
                art: UIColor(red: 0.98, green: 0.86, blue: 0.52, alpha: 1)
            )
        }
    }

    /// Known-good SVG `d` data. Falls back to a SwiftUI ellipse if parsing fails.
    var svgPathData: String {
        switch self {
        case .heart:
            """
            M12 21s-6.7-4.35-9.33-8.11C0.33 9.74 1.1 5.5 4.5 3.83 \
            A5.48 5.48 0 0 1 12 6.09 A5.48 5.48 0 0 1 19.5 3.83 \
            c3.4 1.67 4.17 5.91 1.83 9.06C18.7 16.65 12 21 12 21z
            """
        case .star:
            "M12 2 L15.09 8.26 L22 9.27 L17 14.14 L18.18 21.02 L12 17.77 L5.82 21.02 L7 14.14 L2 9.27 L8.91 8.26 Z"
        case .mountain:
            "M2 18 L8 8 L12 13 L16 6 L22 18 Z"
        case .trophy:
            "M6 3 L18 3 L18 5 C18 8 15.5 10 12 10 C8.5 10 6 8 6 5 Z M10 10 L14 10 L14 14 L10 14 Z M8 16 L16 16 L16 18 L8 18 Z M10 18 L14 18 L14 21 L10 21 Z"
        }
    }

    func design(
        silhouette: DemoSilhouette? = nil,
        engraving: CoinEngraving? = nil
    ) -> CoinDesign {
        CatalogCoins.mint(
            svgPathData: svgPathData,
            silhouette: (silhouette ?? defaultSilhouette).minted,
            palette: palette,
            engraving: engraving ?? defaultEngraving,
            topText: topText,
            bottomText: bottomText
        )
    }
}

enum CatalogCoins {
    /// Non-failable mint: SVG when it parses, otherwise a SwiftUI `Path` ellipse.
    static func mint(
        svgPathData: String,
        silhouette: CoinSilhouette = .seal,
        palette: CoinPalette = CoinPalette(),
        engraving: CoinEngraving = .petals,
        topText: String = "",
        bottomText: String = ""
    ) -> CoinDesign {
        if let design = CoinDesign(
            svgPathData: svgPathData,
            silhouette: silhouette,
            palette: palette,
            engraving: engraving,
            topText: topText,
            bottomText: bottomText
        ) {
            return design
        }
        return CoinDesign(
            art: Path(ellipseIn: CGRect(x: 0, y: 0, width: 1, height: 1)),
            silhouette: silhouette,
            palette: palette,
            engraving: engraving,
            topText: topText,
            bottomText: bottomText
        )
    }

    /// `CoinDesign(svgFileData:)` — every `<path>` merges, placed by viewBox.
    static let compass: CoinDesign = {
        let svg = """
        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100">
          <path d="M50 8 L58 42 L50 36 L42 42 Z"/>
          <path d="M92 50 L58 58 L64 50 L58 42 Z"/>
          <path d="M50 92 L42 58 L50 64 L58 58 Z"/>
          <path d="M8 50 L42 42 L36 50 L42 58 Z"/>
        </svg>
        """
        return CoinDesign(
            svgFileData: Data(svg.utf8),
            silhouette: .octagon,
            palette: CoinPalette(
                field: UIColor(red: 0.08, green: 0.28, blue: 0.24, alpha: 1),
                art: .white
            ),
            engraving: .rays,
            topText: "COMPASS",
            bottomText: "FILE"
        ) ?? mint(
            svgPathData: "M50 8 L58 42 L50 36 L42 42 Z",
            silhouette: .octagon,
            palette: CoinPalette(
                field: UIColor(red: 0.08, green: 0.28, blue: 0.24, alpha: 1),
                art: .white
            ),
            engraving: .rays,
            topText: "COMPASS",
            bottomText: "FILE"
        )
    }()

    /// `CoinDesign(art: Path)` — skip SVG entirely.
    static let starburst = CoinDesign(
        art: Path(ellipseIn: CGRect(x: 0.18, y: 0.18, width: 0.64, height: 0.64)),
        silhouette: .circle,
        palette: CoinPalette(
            field: UIColor(red: 0.18, green: 0.12, blue: 0.32, alpha: 1),
            art: UIColor(red: 0.94, green: 0.91, blue: 0.84, alpha: 1)
        ),
        engraving: .plain,
        topText: "PATH",
        bottomText: "ELLIPSE"
    )

    static let awardHeart = AwardArt.heart.design()
    static let alpineSplit = AwardArt.mountain.design()
    static let firstClass = AwardArt.star.design()
    static let champion = AwardArt.trophy.design()
}
