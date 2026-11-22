import ProgressIndicatorView
import SwiftUI

/// Shared Live / Gallery knobs.
///
/// `progress` is one `CGFloat` binding passed into every `IndicatorType` case.
/// The package example keeps a second binding for `.default` that runs to 1.5.
/// This demo uses the single binding and lets it reach 1.5 so that case can rotate.
struct ProgressSettings {
    var isVisible = true
    /// Example timer walks this value. `1.5` is where `DefaultSectorView` resets in the example.
    var progress = 0.0
    var autoProgress = false
    var foreground = Ink.red
    /// README sample frame for the linear indicators is height 8. The example draws `.dashBar` at 12.
    var barHeight = 8.0
    /// Square frame for `.default` and `.circle`. The example uses one fifth of the screen width.
    var diameter = 72.0
}

enum Ink: String, CaseIterable, Identifiable, Hashable {
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

/// `backgroundColor` on bar, impulseBar, dashBar, and circle. The enum default is `.clear`.
/// `.gray` is the example's `.gray.opacity(0.25)`, not a second package default.
enum TrackTint: String, CaseIterable, Identifiable, Hashable {
    case clear
    case gray
    case white
    case black

    var id: String { rawValue }

    var title: String {
        switch self {
        case .clear: "Clear"
        case .gray: "Gray 25%"
        case .white: "White"
        case .black: "Black"
        }
    }

    var color: Color {
        switch self {
        case .clear: .clear
        case .gray: Color.gray.opacity(0.25)
        case .white: .white
        case .black: .black
        }
    }

    var call: String {
        switch self {
        case .clear: ".clear"
        case .gray: ".gray.opacity(0.25)"
        case .white: ".white"
        case .black: ".black"
        }
    }
}

/// The five `ProgressIndicatorView.IndicatorType` cases, in source order.
/// `sector` is this app's name for the package case `default`.
enum IndicatorKind: String, CaseIterable, Identifiable, Hashable {
    case sector
    case bar
    case impulseBar
    case dashBar
    case circle

    var id: String { rawValue }

    var title: String {
        switch self {
        case .sector: "Default"
        case .bar: "Bar"
        case .impulseBar: "Impulse Bar"
        case .dashBar: "Dash Bar"
        case .circle: "Circle"
        }
    }

    var signature: String {
        switch self {
        case .sector: ".default(progress:)"
        case .bar: ".bar(progress:backgroundColor:)"
        case .impulseBar: ".impulseBar(progress:backgroundColor:)"
        case .dashBar: ".dashBar(progress:numberOfItems:backgroundColor:)"
        case .circle: ".circle(progress:lineWidth:strokeColor:backgroundColor:)"
        }
    }

    var supportsTrack: Bool {
        self != .sector
    }

    var supportsDashCount: Bool {
        self == .dashBar
    }

    var supportsLineWidth: Bool {
        self == .circle
    }

    var supportsStroke: Bool {
        self == .circle
    }

    var isLinear: Bool {
        switch self {
        case .bar, .impulseBar, .dashBar: true
        case .sector, .circle: false
        }
    }

    /// Shapes that are not stroked with their own `Color` pick up `foregroundStyle`.
    /// `CircleView` strokes `strokeColor` and `backgroundColor` and ignores foreground.
    var usesForegroundStyle: Bool {
        self != .circle
    }

    /// `DashBarView.widthForItem` divides by `numberOfItems`. Zero is a division by zero.
    /// Spacing is a private 4 pt constant, so `(width - (count - 1) * 4) / count` goes
    /// negative once the count outgrows a gallery well. Sixteen still fits a ~140 pt well.
    var dashCountRange: ClosedRange<Double> { 1...16 }

    /// Example uses 8. The arc radius is `rect.width / 2`, so the stroke is clipped by the frame.
    var lineWidthRange: ClosedRange<Double> { 1...24 }

    var presetCall: String {
        switch self {
        case .sector:
            ".default(progress: $progress)"
        case .bar:
            ".bar(progress: $progress, backgroundColor: .clear)"
        case .impulseBar:
            ".impulseBar(progress: $progress, backgroundColor: .clear)"
        case .dashBar:
            ".dashBar(progress: $progress, numberOfItems: 8, backgroundColor: .clear)"
        case .circle:
            ".circle(progress: $progress, lineWidth: 8, strokeColor: .red, backgroundColor: .clear)"
        }
    }

    var presetChips: [String] {
        switch self {
        case .sector:
            ["progress binding"]
        case .bar, .impulseBar:
            ["background .clear"]
        case .dashBar:
            ["numberOfItems 8", "background .clear"]
        case .circle:
            ["lineWidth 8", "stroke .red", "background .clear"]
        }
    }

    func prefersDarkWell(foreground: Ink, track: TrackTint, stroke: Ink) -> Bool {
        if self == .circle {
            return stroke == .white || track == .white
        }
        if foreground == .white {
            return true
        }
        return supportsTrack && track == .white
    }

    @MainActor
    func makeType(
        progress: Binding<CGFloat>,
        track: TrackTint,
        dashCount: Int,
        lineWidth: CGFloat,
        stroke: Ink
    ) -> ProgressIndicatorView.IndicatorType {
        switch self {
        case .sector:
            .`default`(progress: progress)
        case .bar:
            .bar(progress: progress, backgroundColor: track.color)
        case .impulseBar:
            .impulseBar(progress: progress, backgroundColor: track.color)
        case .dashBar:
            .dashBar(
                progress: progress,
                numberOfItems: dashCount,
                backgroundColor: track.color
            )
        case .circle:
            .circle(
                progress: progress,
                lineWidth: lineWidth,
                strokeColor: stroke.color,
                backgroundColor: track.color
            )
        }
    }

    func call(track: TrackTint, dashCount: Int, lineWidth: CGFloat, stroke: Ink) -> String {
        switch self {
        case .sector:
            ".default(progress: $progress)"
        case .bar:
            ".bar(progress: $progress, backgroundColor: \(track.call))"
        case .impulseBar:
            ".impulseBar(progress: $progress, backgroundColor: \(track.call))"
        case .dashBar:
            ".dashBar(progress: $progress, numberOfItems: \(dashCount), backgroundColor: \(track.call))"
        case .circle:
            ".circle(progress: $progress, lineWidth: \(formatted(lineWidth)), strokeColor: .\(stroke.rawValue), backgroundColor: \(track.call))"
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

struct IndicatorParameters {
    var track: TrackTint
    var dashCount: Int
    var lineWidth: CGFloat
    var stroke: Ink

    static let packageDefault = IndicatorParameters(
        track: .clear,
        dashCount: 8,
        lineWidth: 8,
        stroke: .red
    )
}

/// Same thresholds as the example's 0.2s timer, extended past 1 so `.default` can rotate.
/// The example resets its shared `progress` at 1 and runs `progressForDefaultSector` to 1.5 on its own.
enum ProgressClock {
    static let upperBound = 1.5
    static let timerMilliseconds = 200

    static func step(_ progress: Double) -> Double {
        switch progress {
        case ...0.3, 0.4...0.6:
            return progress + 1.0 / 30.0
        case 0.3...0.4, 0.6...0.9:
            return progress + 1.0 / 120.0
        case 0.9..<1:
            return 1
        case 1..<upperBound:
            return progress + 1.0 / 10.0
        default:
            return 0
        }
    }
}
