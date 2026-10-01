import SwiftUI

/// Density of a `Showbill`. CaseIterable so `param("density", default:)`
/// builds a segmented picker without an `Adjustable` conformance.
enum ShowDensity: String, CaseIterable, Hashable {
    case compact
    case regular
    case expanded
}

/// Deliberately not CaseIterable — Live offers it via
/// `param.picker(_:options:default:)` the way RehearsalExamples does for `Badge`.
enum ShowRibbon: String, Hashable {
    case hidden
    case premiere
    case soldOut
}

/// Concert poster driven by Rehearsal knobs: string, int, double, bool, color,
/// CaseIterable enum, and a non-CaseIterable picker. Inspired by the package
/// `MyCard` example, not a paste of it.
struct Showbill: View {
    var title: String
    var nights: Int
    var energy: Double
    var starred: Bool
    var accent: Color
    var density: ShowDensity
    var ribbon: ShowRibbon

    var body: some View {
        VStack(alignment: .leading, spacing: stackSpacing) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text(title)
                    .font(titleFont)
                    .foregroundStyle(.white)
                    .lineLimit(2)
                Spacer(minLength: 8)
                if starred {
                    Image(systemName: "star.fill")
                        .foregroundStyle(accent)
                        .imageScale(density == .compact ? .small : .medium)
                }
            }

            if ribbon != .hidden {
                Text(ribbon == .premiere ? "PREMIERE" : "SOLD OUT")
                    .font(.caption2.weight(.bold))
                    .tracking(0.8)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(ribbon == .soldOut ? Color.white.opacity(0.16) : accent.opacity(0.28), in: Capsule())
                    .foregroundStyle(.white)
            }

            if density != .compact {
                ProgressView(value: energy)
                    .tint(accent)
                Text("Energy \(Int((energy * 100).rounded()))")
                    .font(.caption2.monospacedDigit())
                    .foregroundStyle(.white.opacity(0.55))
            }

            HStack(spacing: 6) {
                ForEach(0 ..< max(nights, 0), id: \.self) { index in
                    Text("N\(index + 1)")
                        .font(.caption2.weight(.semibold).monospaced())
                        .foregroundStyle(accent)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 4)
                        .background(accent.opacity(0.16), in: Capsule())
                }
            }
        }
        .padding(density == .expanded ? 22 : 16)
        .frame(maxWidth: .infinity, minHeight: density == .expanded ? 220 : 160, alignment: .topLeading)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(accent.opacity(0.14))
        )
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(accent.opacity(0.35), lineWidth: 1)
        }
    }

    private var stackSpacing: CGFloat {
        switch density {
        case .compact: 6
        case .regular: 10
        case .expanded: 14
        }
    }

    private var titleFont: Font {
        switch density {
        case .compact: .headline
        case .regular: .title2.weight(.semibold)
        case .expanded: .largeTitle.weight(.bold)
        }
    }
}

enum TypeWeight: String, CaseIterable, Hashable {
    case regular
    case medium
    case semibold
    case bold

    var fontWeight: Font.Weight {
        switch self {
        case .regular: .regular
        case .medium: .medium
        case .semibold: .semibold
        case .bold: .bold
        }
    }
}

/// Editorial paragraph whose type tokens come from `param(...)`.
struct TypeSample: View {
    var headline: String
    var size: Double
    var tracking: Double
    var leading: Double
    var weight: TypeWeight
    var ink: Color
    var italic: Bool

    static let bodyCopy = """
    Rehearsal builds the control panel from inline param() calls. \
    Tune size, tracking, and ink here — Copy values as code emits \
    a TypeSample(...) initializer for the current knobs.
    """

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(headline)
                .font(headlineFont)
                .tracking(tracking)
                .foregroundStyle(ink)

            Text(Self.bodyCopy)
                .font(.system(size: max(size - 6, 12), weight: .regular))
                .tracking(tracking * 0.4)
                .lineSpacing(leading)
                .foregroundStyle(ink.opacity(0.78))
        }
        .frame(maxWidth: .infinity, minHeight: 180, alignment: .topLeading)
        .padding(20)
    }

    private var headlineFont: Font {
        let base = Font.system(size: size, weight: weight.fontWeight)
        return italic ? base.italic() : base
    }
}

enum StageAlign: String, CaseIterable, Hashable {
    case leading
    case center
    case trailing

    var alignment: Alignment {
        switch self {
        case .leading: .leading
        case .center: .center
        case .trailing: .trailing
        }
    }
}

/// Layout tile whose columns, spacing, and radius are rehearsal knobs.
struct StageGrid: View {
    var columns: Int
    var spacing: Double
    var corner: Double
    var inset: Double
    var stacked: Bool
    var fill: Color
    var align: StageAlign

    var body: some View {
        let count = max(columns, 1)
        let items = count * (stacked ? 2 : 1)
        LazyVGrid(
            columns: Array(repeating: GridItem(.flexible(), spacing: spacing), count: count),
            alignment: horizontalAlignment,
            spacing: spacing
        ) {
            ForEach(0 ..< items, id: \.self) { index in
                RoundedRectangle(cornerRadius: corner, style: .continuous)
                    .fill(fill.opacity(0.28 + Double(index % 3) * 0.14))
                    .frame(height: stacked ? 46 : 72)
                    .overlay {
                        Text("\(index + 1)")
                            .font(.caption.weight(.semibold).monospaced())
                            .foregroundStyle(fill)
                    }
            }
        }
        .padding(inset)
        .frame(maxWidth: .infinity, minHeight: 180, alignment: align.alignment)
    }

    private var horizontalAlignment: HorizontalAlignment {
        switch align {
        case .leading: .leading
        case .center: .center
        case .trailing: .trailing
        }
    }
}

enum DemoDefaults {
    static let showAccent = Color(red: 1, green: 0.45, blue: 0.22)
    static let typeInk = Color(red: 0.90, green: 0.91, blue: 0.93)
    static let stageFill = Color(red: 0.35, green: 0.72, blue: 0.97)
}
