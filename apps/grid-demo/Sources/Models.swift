import ExyteGrid
import SwiftUI

/// Every live recipe uses three fixed tracks so Wide can span that axis and leave a hole.
enum LiveGridMetrics {
    static let trackCount = 3
}

enum DemoTab: Hashable {
    case live
    case gallery
}

enum TrackRecipe: String, CaseIterable, Identifiable, Hashable {
    case fractions
    case points
    case fit

    var id: String { rawValue }

    var title: String {
        switch self {
        case .fractions: "Fractions"
        case .points: "Points"
        case .fit: "Fit"
        }
    }

    /// `3` is `[GridTrack](integerLiteral:)`, which repeats `.fr(Constants.defaultFractionSize)`.
    /// `defaultFractionSize` is 1.
    var tracks: [GridTrack] {
        switch self {
        case .fractions:
            [GridTrack](integerLiteral: LiveGridMetrics.trackCount)
        case .points:
            [.pt(76), .pt(40), .pt(96)]
        case .fit:
            [.fit, .fr(1), .fit]
        }
    }

    var call: String {
        switch self {
        case .fractions: "3"
        case .points: "[.pt(76), .pt(40), .pt(96)]"
        case .fit: "[.fit, .fr(1), .fit]"
        }
    }
}

enum ContentModeChoice: String, CaseIterable, Identifiable, Hashable {
    case fill
    case scroll

    var id: String { rawValue }

    var title: String {
        switch self {
        case .fill: "Fill"
        case .scroll: "Scroll"
        }
    }

    var mode: GridContentMode {
        switch self {
        case .fill: .fill
        case .scroll: .scroll
        }
    }

    var call: String {
        switch self {
        case .fill: ".fill"
        case .scroll: ".scroll"
        }
    }
}

enum FlowChoice: String, CaseIterable, Identifiable, Hashable {
    case rows
    case columns

    var id: String { rawValue }

    var title: String {
        switch self {
        case .rows: "Rows"
        case .columns: "Columns"
        }
    }

    var flow: GridFlow {
        switch self {
        case .rows: .rows
        case .columns: .columns
        }
    }

    var call: String {
        switch self {
        case .rows: ".rows"
        case .columns: ".columns"
        }
    }
}

enum PackingChoice: String, CaseIterable, Identifiable, Hashable {
    case sparse
    case dense

    var id: String { rawValue }

    var title: String {
        switch self {
        case .sparse: "Sparse"
        case .dense: "Dense"
        }
    }

    var packing: GridPacking {
        switch self {
        case .sparse: .sparse
        case .dense: .dense
        }
    }

    var call: String {
        switch self {
        case .sparse: ".sparse"
        case .dense: ".dense"
        }
    }
}

struct GridTile: Identifiable, Hashable {
    var index: Int

    var id: Int { index }

    var title: String {
        switch index {
        case 0: "A"
        case 1: "Wide"
        case 2: "F"
        default: String(index)
        }
    }
}

struct TilePlacement {
    var column: Int
    var row: Int
}

/// Live knobs. Defaults match `Constants` at tag 1.5.4: fill, rows, sparse, spacing 5, center.
struct LiveLayout {
    var recipe: TrackRecipe = .fractions
    var contentMode: ContentModeChoice = .fill
    var flow: FlowChoice = .rows
    var packing: PackingChoice = .sparse
    var horizontalSpacing: Double = 5
    var verticalSpacing: Double = 5
    var count: Int = 12
    var focusColumnSpan: Int = 1
    var focusRowSpan: Int = 1
    var itemAlignment: GridAlignment = .center

    var tiles: [GridTile] {
        (0..<count).map { GridTile(index: $0) }
    }

    var spacing: GridSpacing {
        GridSpacing(
            horizontal: CGFloat(horizontalSpacing),
            vertical: CGFloat(verticalSpacing)
        )
    }

    /// A is 1×1. Wide spans the fixed axis (columns in rows-flow, rows in columns-flow),
    /// which leaves a hole beside A. F uses the span sliders. Later cells are 1×1.
    /// Dense can move a cell that fits back into that hole. Sparse only moves forward.
    func placement(for index: Int) -> TilePlacement {
        let tracks = LiveGridMetrics.trackCount
        switch index {
        case 0:
            TilePlacement(column: 1, row: 1)
        case 1:
            flow == .rows
                ? TilePlacement(column: tracks, row: 1)
                : TilePlacement(column: 1, row: tracks)
        case 2:
            TilePlacement(column: focusColumnSpan, row: focusRowSpan)
        default:
            TilePlacement(column: 1, row: 1)
        }
    }

    func call(animationEnabled: Bool) -> String {
        let focus = placement(for: 2)
        let wide = placement(for: 1)
        let animation = animationEnabled ? "Animation.default" : "nil"
        return """
        ExyteGrid.Grid(tiles, tracks: \(recipe.call), contentMode: \(contentMode.call), flow: \(flow.call), packing: \(packing.call), spacing: GridSpacing(horizontal: \(Int(horizontalSpacing)), vertical: \(Int(verticalSpacing))), commonItemsAlignment: .\(itemAlignment))
        A gridSpan(column: 1, row: 1) · Wide gridSpan(column: \(wide.column), row: \(wide.row)) · F gridSpan(column: \(focus.column), row: \(focus.row))
        .gridAnimation(\(animation))
        """
    }
}

enum TilePalette {
    static func color(index: Int) -> Color {
        let palette: [Color] = [
            Color(red: 0.36, green: 0.62, blue: 0.98),
            Color(red: 0.93, green: 0.42, blue: 0.34),
            Color(red: 0.32, green: 0.74, blue: 0.56),
            Color(red: 0.95, green: 0.72, blue: 0.28),
            Color(red: 0.68, green: 0.48, blue: 0.95),
            Color(red: 0.28, green: 0.74, blue: 0.80),
            Color(red: 0.95, green: 0.52, blue: 0.68),
            Color(red: 0.55, green: 0.58, blue: 0.66),
        ]
        let wrapped = ((index % palette.count) + palette.count) % palette.count
        return palette[wrapped]
    }
}
