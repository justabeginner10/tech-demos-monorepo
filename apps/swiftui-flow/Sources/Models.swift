import SwiftUI

enum DemoTab: Hashable {
    case live
    case gallery
}

enum FlowAxisChoice: String, CaseIterable, Identifiable, Hashable {
    case horizontal
    case vertical

    var id: String { rawValue }

    var title: String {
        switch self {
        case .horizontal: "HFlow"
        case .vertical: "VFlow"
        }
    }
}

enum HorizontalChoice: String, CaseIterable, Identifiable, Hashable {
    case leading
    case center
    case trailing

    var id: String { rawValue }

    var title: String {
        switch self {
        case .leading: "Leading"
        case .center: "Center"
        case .trailing: "Trailing"
        }
    }

    var alignment: HorizontalAlignment {
        switch self {
        case .leading: .leading
        case .center: .center
        case .trailing: .trailing
        }
    }

    var call: String {
        switch self {
        case .leading: ".leading"
        case .center: ".center"
        case .trailing: ".trailing"
        }
    }
}

enum VerticalChoice: String, CaseIterable, Identifiable, Hashable {
    case top
    case center
    case bottom

    var id: String { rawValue }

    var title: String {
        switch self {
        case .top: "Top"
        case .center: "Center"
        case .bottom: "Bottom"
        }
    }

    var alignment: VerticalAlignment {
        switch self {
        case .top: .top
        case .center: .center
        case .bottom: .bottom
        }
    }

    var call: String {
        switch self {
        case .top: ".top"
        case .center: ".center"
        case .bottom: ".bottom"
        }
    }
}

struct FlowChip: Identifiable, Hashable {
    var id: Int
    var title: String
    var fillIndex: Int

    static let seed: [FlowChip] = [
        FlowChip(id: 0, title: "Flow", fillIndex: 0),
        FlowChip(id: 1, title: "HFlow", fillIndex: 1),
        FlowChip(id: 2, title: "alignment", fillIndex: 2),
        FlowChip(id: 3, title: "wrap", fillIndex: 3),
        FlowChip(id: 4, title: "VFlow", fillIndex: 4),
        FlowChip(id: 5, title: "spacing", fillIndex: 5),
        FlowChip(id: 6, title: "justified", fillIndex: 6),
        FlowChip(id: 7, title: "rows", fillIndex: 7),
        FlowChip(id: 8, title: "tags", fillIndex: 0),
        FlowChip(id: 9, title: "distribute", fillIndex: 1),
        FlowChip(id: 10, title: "line", fillIndex: 2),
        FlowChip(id: 11, title: "chips", fillIndex: 3),
    ]
}

enum FlowWordBank {
    static let additions = [
        "separator",
        "flexible",
        "leading",
        "baseline",
        "column",
        "overflow",
        "break",
        "natural",
    ]
}

enum ChipPalette {
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

struct LiveAnimationKey: Equatable {
    var axis: FlowAxisChoice
    var horizontal: HorizontalChoice
    var vertical: VerticalChoice
    var itemSpacing: Double?
    var lineSpacing: Double?
    var justified: Bool
    var distributed: Bool
    var chipIDs: [Int]
}

/// Live knobs. The two-axis initializers are the ones this screen calls.
///
/// `HFlowLayout.init(alignment:)` stores that value as the vertical alignment and uses
/// `.leading` on the horizontal axis. `nil` spacing asks the layout to use `ViewSpacing`.
struct LiveFlowSettings {
    var axis: FlowAxisChoice = .horizontal
    var horizontal: HorizontalChoice = .leading
    var vertical: VerticalChoice = .center
    var itemSpacingExplicit = true
    var itemSpacing = 8.0
    var lineSpacingExplicit = true
    var lineSpacing = 18.0
    var justified = false
    var distributed = false
    var chips: [FlowChip] = FlowChip.seed

    var itemSpacingValue: CGFloat? {
        itemSpacingExplicit ? CGFloat(itemSpacing) : nil
    }

    var lineSpacingValue: CGFloat? {
        lineSpacingExplicit ? CGFloat(lineSpacing) : nil
    }

    /// Along the flow, item spacing is horizontal for `HFlow` and vertical for `VFlow`.
    /// Line spacing is the other axis: rows, or columns.
    var horizontalSpacing: CGFloat? {
        axis == .horizontal ? itemSpacingValue : lineSpacingValue
    }

    var verticalSpacing: CGFloat? {
        axis == .horizontal ? lineSpacingValue : itemSpacingValue
    }

    var animationKey: LiveAnimationKey {
        LiveAnimationKey(
            axis: axis,
            horizontal: horizontal,
            vertical: vertical,
            itemSpacing: itemSpacingExplicit ? itemSpacing : nil,
            lineSpacing: lineSpacingExplicit ? lineSpacing : nil,
            justified: justified,
            distributed: distributed,
            chipIDs: chips.map(\.id)
        )
    }

    func call() -> String {
        let name = axis == .horizontal ? "HFlow" : "VFlow"
        return """
        \(name)(horizontalAlignment: \(horizontal.call), verticalAlignment: \(vertical.call), horizontalSpacing: \(Self.literal(horizontalSpacing)), verticalSpacing: \(Self.literal(verticalSpacing)), justified: \(justified), distributeItemsEvenly: \(distributed))
        """
    }

    private static func literal(_ value: CGFloat?) -> String {
        guard let value else { return "nil" }
        return String(Int(value.rounded()))
    }
}
