import AnimatedGradient
import SwiftUI

enum DemoTab: Hashable {
    case live
    case gallery
}

/// Stored defaults on `AnimatedLinearGradient` at tag 1.0.1.
enum GradientDefaults {
    static let simultaneousColors = 2
    static let duration = 3.0
    static let start = GradientAnchor.topTrailing
    static let end = GradientAnchor.bottomLeading
}

enum PaletteSource: String, CaseIterable, Identifiable, Hashable {
    case spectrum
    case pastel
    case bright

    var id: String { rawValue }

    var title: String {
        switch self {
        case .spectrum: "Spectrum"
        case .pastel: "Pastel"
        case .bright: "Bright"
        }
    }

    /// Spectrum is the README trio, then three more `Color` values. Pastel and bright are the package arrays.
    var colors: [Color] {
        switch self {
        case .spectrum:
            [.red, .green, .blue, .orange, .yellow, .purple]
        case .pastel:
            GradientPreset.pastel
        case .bright:
            GradientPreset.bright
        }
    }

    /// Labels for the swatches. Pastel and bright hex strings are the literals in `GradientPreset.swift`.
    var labels: [String] {
        switch self {
        case .spectrum:
            ["Red", "Green", "Blue", "Orange", "Yellow", "Purple"]
        case .pastel:
            ["D2C7F6", "EFC6B7", "F4F2C1", "A2EFE9", "DCF4C4", "F5B8CE"]
        case .bright:
            ["FFE53B", "00FFA9", "6094EA", "0D4DFF", "F02FC2", "FF2525"]
        }
    }

    private var callNames: [String] {
        switch self {
        case .spectrum:
            ["red", "green", "blue", "orange", "yellow", "purple"]
        case .pastel, .bright:
            []
        }
    }

    func selection(count: Int) -> [Color] {
        let capped = min(max(count, 2), colors.count)
        return Array(colors.prefix(capped))
    }

    func selectionLabels(count: Int) -> [String] {
        let capped = min(max(count, 2), labels.count)
        return Array(labels.prefix(capped))
    }

    func colorsCall(count: Int) -> String {
        let capped = min(max(count, 2), colors.count)
        switch self {
        case .spectrum:
            let names = callNames.prefix(capped).map { ".\($0)" }
            return "[" + names.joined(separator: ", ") + "]"
        case .pastel:
            return capped == colors.count
                ? "GradientPreset.pastel"
                : "Array(GradientPreset.pastel.prefix(\(capped)))"
        case .bright:
            return capped == colors.count
                ? "GradientPreset.bright"
                : "Array(GradientPreset.bright.prefix(\(capped)))"
        }
    }
}

enum AnimationCurve: String, CaseIterable, Identifiable, Hashable {
    case linear
    case easeIn
    case easeOut
    case easeInOut

    var id: String { rawValue }

    var title: String {
        switch self {
        case .linear: "Linear"
        case .easeIn: "Ease in"
        case .easeOut: "Ease out"
        case .easeInOut: "Ease in out"
        }
    }

    var call: String {
        switch self {
        case .linear: ".linear"
        case .easeIn: ".easeIn"
        case .easeOut: ".easeOut"
        case .easeInOut: ".easeInOut"
        }
    }

    func animation(duration: Double) -> Animation {
        switch self {
        case .linear: .linear(duration: duration)
        case .easeIn: .easeIn(duration: duration)
        case .easeOut: .easeOut(duration: duration)
        case .easeInOut: .easeInOut(duration: duration)
        }
    }
}

enum GradientAnchor: String, CaseIterable, Identifiable, Hashable {
    case topLeading
    case top
    case topTrailing
    case leading
    case center
    case trailing
    case bottomLeading
    case bottom
    case bottomTrailing

    var id: String { rawValue }

    var title: String {
        switch self {
        case .topLeading: "Top leading"
        case .top: "Top"
        case .topTrailing: "Top trailing"
        case .leading: "Leading"
        case .center: "Center"
        case .trailing: "Trailing"
        case .bottomLeading: "Bottom leading"
        case .bottom: "Bottom"
        case .bottomTrailing: "Bottom trailing"
        }
    }

    var unitPoint: UnitPoint {
        switch self {
        case .topLeading: .topLeading
        case .top: .top
        case .topTrailing: .topTrailing
        case .leading: .leading
        case .center: .center
        case .trailing: .trailing
        case .bottomLeading: .bottomLeading
        case .bottom: .bottom
        case .bottomTrailing: .bottomTrailing
        }
    }

    var call: String { ".\(rawValue)" }
}

func durationLiteral(_ value: Double) -> String {
    let snapped = (value * 10).rounded() / 10
    if abs(snapped - snapped.rounded()) < 0.001 {
        return String(Int(snapped.rounded()))
    }
    return String(format: "%.1f", snapped)
}
