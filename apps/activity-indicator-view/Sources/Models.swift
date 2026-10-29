import ActivityIndicatorView
import CoreGraphics
import SwiftUI

/// Shared Live / Gallery knobs. Size and foreground are SwiftUI modifiers.
/// `IndicatorType` itself has no size and no visibility flag.
struct IndicatorSettings {
    var isVisible = true
    /// README sample frame is 50×50. The slider stays on even steps so 50 remains reachable.
    var size = 50.0
    var tint = IndicatorTint.red
}

enum IndicatorTint: String, CaseIterable, Identifiable, Hashable {
    case red
    case orange
    case green
    case blue
    case white
    case black

    var id: String { rawValue }

    var title: String {
        switch self {
        case .red: "Red"
        case .orange: "Orange"
        case .green: "Green"
        case .blue: "Blue"
        case .white: "White"
        case .black: "Black"
        }
    }

    var color: Color {
        switch self {
        case .red: .red
        case .orange: .orange
        case .green: .green
        case .blue: .blue
        case .white: .white
        case .black: .black
        }
    }
}

/// Second associated value of `.gradient(_:_:lineWidth:)`. The package default is `.butt`.
enum LineCapChoice: String, CaseIterable, Identifiable, Hashable {
    case butt
    case round
    case square

    var id: String { rawValue }

    var title: String {
        switch self {
        case .butt: "Butt"
        case .round: "Round"
        case .square: "Square"
        }
    }

    var lineCap: CGLineCap {
        switch self {
        case .butt: .butt
        case .round: .round
        case .square: .square
        }
    }
}

/// The ten `ActivityIndicatorView.IndicatorType` cases, in source order.
/// `spinner` is this app's name for the package case `default`.
enum IndicatorKind: String, CaseIterable, Identifiable, Hashable {
    case spinner
    case arcs
    case rotatingDots
    case flickeringDots
    case scalingDots
    case opacityDots
    case equalizer
    case growingArc
    case growingCircle
    case gradient

    var id: String { rawValue }

    var title: String {
        switch self {
        case .spinner: "Default"
        case .arcs: "Arcs"
        case .rotatingDots: "Rotating Dots"
        case .flickeringDots: "Flickering Dots"
        case .scalingDots: "Scaling Dots"
        case .opacityDots: "Opacity Dots"
        case .equalizer: "Equalizer"
        case .growingArc: "Growing Arc"
        case .growingCircle: "Growing Circle"
        case .gradient: "Gradient"
        }
    }

    var signature: String {
        switch self {
        case .spinner: ".default(count:)"
        case .arcs: ".arcs(count:lineWidth:)"
        case .rotatingDots: ".rotatingDots(count:)"
        case .flickeringDots: ".flickeringDots(count:)"
        case .scalingDots: ".scalingDots(count:inset:)"
        case .opacityDots: ".opacityDots(count:inset:)"
        case .equalizer: ".equalizer(count:)"
        case .growingArc: ".growingArc(_:lineWidth:)"
        case .growingCircle: ".growingCircle"
        case .gradient: ".gradient(_:_:lineWidth:)"
        }
    }

    /// Package default for the `count` associated value. Kinds without `count` still report 1.
    var defaultCount: Int {
        switch self {
        case .spinner: 8
        case .arcs: 3
        case .rotatingDots: 5
        case .flickeringDots: 8
        case .scalingDots: 3
        case .opacityDots: 3
        case .equalizer: 5
        case .growingArc, .growingCircle, .gradient: 1
        }
    }

    var defaultInset: Int {
        switch self {
        case .scalingDots: 2
        case .opacityDots: 4
        default: 0
        }
    }

    var defaultLineWidth: Double {
        switch self {
        case .arcs: 2
        case .growingArc, .gradient: 4
        default: 2
        }
    }

    var supportsCount: Bool {
        switch self {
        case .growingArc, .growingCircle, .gradient: false
        default: true
        }
    }

    var supportsInset: Bool {
        switch self {
        case .scalingDots, .opacityDots: true
        default: false
        }
    }

    var supportsLineWidth: Bool {
        switch self {
        case .arcs, .growingArc, .gradient: true
        default: false
        }
    }

    var supportsLineCap: Bool {
        self == .gradient
    }

    var supportsArcColor: Bool {
        self == .growingArc
    }

    var supportsGradientColors: Bool {
        self == .gradient
    }

    /// Shapes that are not stroked with their own `Color` pick up `foregroundStyle`.
    var usesForegroundStyle: Bool {
        switch self {
        case .growingArc, .gradient: false
        default: true
        }
    }

    /// Closed ranges that stay inside what the indicator views divide by.
    ///
    /// Several indicators divide by `count` (`Default`, `FlickeringDots`, `ScalingDots`,
    /// `OpacityDots`, `Equalizer`), so the slider starts at 1.
    /// Arcs uses `radius = width / 2 - index * count`. At the minimum 36 pt frame,
    /// count 5 already makes the inner radius negative, so Arcs stops at 4.
    /// Scaling and opacity dots size each dot as
    /// `(width - inset * (count - 1)) / count`. Count 5 and inset 6 still fit in 36 pt.
    /// Rotating dots hard-code `/ 5` in the scale formula, so counts past 5 flip later dots.
    var countRange: ClosedRange<Double> {
        switch self {
        case .arcs:
            1...4
        case .rotatingDots:
            1...8
        case .scalingDots, .opacityDots:
            1...5
        case .equalizer:
            1...8
        case .spinner, .flickeringDots:
            1...12
        case .growingArc, .growingCircle, .gradient:
            1...1
        }
    }

    var insetRange: ClosedRange<Double> { 0...6 }

    var lineWidthRange: ClosedRange<Double> { 1...12 }

    /// Gallery call, using every associated-value default from `IndicatorType`.
    var presetType: ActivityIndicatorView.IndicatorType {
        switch self {
        case .spinner:
            .`default`(count: 8)
        case .arcs:
            .arcs(count: 3, lineWidth: 2)
        case .rotatingDots:
            .rotatingDots(count: 5)
        case .flickeringDots:
            .flickeringDots(count: 8)
        case .scalingDots:
            .scalingDots(count: 3, inset: 2)
        case .opacityDots:
            .opacityDots(count: 3, inset: 4)
        case .equalizer:
            .equalizer(count: 5)
        case .growingArc:
            .growingArc(Color.black, lineWidth: 4)
        case .growingCircle:
            .growingCircle
        case .gradient:
            .gradient([Color.white, Color.red], CGLineCap.butt, lineWidth: 4)
        }
    }

    var presetCall: String {
        switch self {
        case .spinner: ".default(count: 8)"
        case .arcs: ".arcs(count: 3, lineWidth: 2)"
        case .rotatingDots: ".rotatingDots(count: 5)"
        case .flickeringDots: ".flickeringDots(count: 8)"
        case .scalingDots: ".scalingDots(count: 3, inset: 2)"
        case .opacityDots: ".opacityDots(count: 3, inset: 4)"
        case .equalizer: ".equalizer(count: 5)"
        case .growingArc: ".growingArc(.black, lineWidth: 4)"
        case .growingCircle: ".growingCircle"
        case .gradient: ".gradient([.white, .red], .butt, lineWidth: 4)"
        }
    }

    var presetChips: [String] {
        switch self {
        case .spinner:
            ["count 8"]
        case .arcs:
            ["count 3", "lineWidth 2"]
        case .rotatingDots:
            ["count 5"]
        case .flickeringDots:
            ["count 8"]
        case .scalingDots:
            ["count 3", "inset 2"]
        case .opacityDots:
            ["count 3", "inset 4"]
        case .equalizer:
            ["count 5"]
        case .growingArc:
            ["Color.black", "lineWidth 4"]
        case .growingCircle:
            ["no parameters"]
        case .gradient:
            [".white .red", ".butt", "lineWidth 4"]
        }
    }

    func prefersDarkWell(foreground: IndicatorTint, arcTint: IndicatorTint) -> Bool {
        switch self {
        case .gradient:
            true
        case .growingArc:
            arcTint == .white
        default:
            foreground == .white
        }
    }
}

struct IndicatorParameters {
    var count: Int
    var inset: Int
    var lineWidth: CGFloat
    var lineCap: LineCapChoice
    var arcTint: IndicatorTint
    var gradientStart: IndicatorTint
    var gradientEnd: IndicatorTint

    func makeType(for kind: IndicatorKind) -> ActivityIndicatorView.IndicatorType {
        switch kind {
        case .spinner:
            .`default`(count: count)
        case .arcs:
            .arcs(count: count, lineWidth: lineWidth)
        case .rotatingDots:
            .rotatingDots(count: count)
        case .flickeringDots:
            .flickeringDots(count: count)
        case .scalingDots:
            .scalingDots(count: count, inset: inset)
        case .opacityDots:
            .opacityDots(count: count, inset: inset)
        case .equalizer:
            .equalizer(count: count)
        case .growingArc:
            .growingArc(arcTint.color, lineWidth: lineWidth)
        case .growingCircle:
            .growingCircle
        case .gradient:
            .gradient(
                [gradientStart.color, gradientEnd.color],
                lineCap.lineCap,
                lineWidth: lineWidth
            )
        }
    }

    func call(for kind: IndicatorKind) -> String {
        switch kind {
        case .spinner:
            ".default(count: \(count))"
        case .arcs:
            ".arcs(count: \(count), lineWidth: \(formatted(lineWidth)))"
        case .rotatingDots:
            ".rotatingDots(count: \(count))"
        case .flickeringDots:
            ".flickeringDots(count: \(count))"
        case .scalingDots:
            ".scalingDots(count: \(count), inset: \(inset))"
        case .opacityDots:
            ".opacityDots(count: \(count), inset: \(inset))"
        case .equalizer:
            ".equalizer(count: \(count))"
        case .growingArc:
            ".growingArc(.\(arcTint.rawValue), lineWidth: \(formatted(lineWidth)))"
        case .growingCircle:
            ".growingCircle"
        case .gradient:
            ".gradient([.\(gradientStart.rawValue), .\(gradientEnd.rawValue)], .\(lineCap.rawValue), lineWidth: \(formatted(lineWidth)))"
        }
    }

    private func formatted(_ value: CGFloat) -> String {
        let rounded = Int(value.rounded())
        if CGFloat(rounded) == value {
            return String(rounded)
        }
        return String(format: "%.1f", Double(value))
    }
}
