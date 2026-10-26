import CoreGraphics
import Wave

/// Wave's `Spring` class shares its name with `SwiftUI.Spring`.
/// This file imports Wave and not SwiftUI, so `Spring` is unambiguous.
/// The package's own `WaveSpring` typealias is internal (`Spring.swift`), and inside
/// that module `Wave.Spring` does not resolve because the `Wave` class shadows the module.
typealias WaveSpring = Spring

/// Springs the Live tab can assign to a `SpringAnimator`.
/// Numbers are the package defaults or the Picture-in-Picture sample, except Underdamped and Stiff.
enum SpringPreset: String, CaseIterable, Identifiable, Hashable {
    case interactive
    case animated
    case bouncy
    case underdamped
    case stiff
    case snap

    var id: String { rawValue }

    var title: String {
        switch self {
        case .interactive: "Interactive"
        case .animated: "Animated"
        case .bouncy: "Bouncy"
        case .underdamped: "Underdamped"
        case .stiff: "Stiff"
        case .snap: "Snap"
        }
    }

    var api: String {
        switch self {
        case .interactive: "Spring.defaultInteractive"
        case .animated: "Spring.defaultAnimated"
        case .bouncy: "Spring(dampingRatio:response:)"
        case .underdamped: "Spring(dampingRatio:response:)"
        case .stiff: "Spring(dampingRatio:stiffness:)"
        case .snap: "Spring.defaultNonAnimated"
        }
    }

    var detail: String {
        switch self {
        case .interactive:
            "Package default for dragging. dampingRatio 0.8, response 0.20."
        case .animated:
            "Package default for non-interactive motion. dampingRatio 1.0, response 0.82. Critically damped."
        case .bouncy:
            "The Picture-in-Picture sample's animated spring. dampingRatio 0.68, response 0.80."
        case .underdamped:
            "Demo spring. dampingRatio 0.45, response 0.62. Overshoots, then settles."
        case .stiff:
            "Demo spring built with stiffness 280 and dampingRatio 0.86. Response is derived."
        case .snap:
            "Spring.defaultNonAnimated (response 0) and AnimationMode.nonAnimated. The value jumps on the first update."
        }
    }

    var chips: [String] {
        switch self {
        case .interactive:
            ["damping 0.8", "response 0.20", "animated"]
        case .animated:
            ["damping 1.0", "response 0.82", "critical"]
        case .bouncy:
            ["damping 0.68", "response 0.80", "sample"]
        case .underdamped:
            ["damping 0.45", "response 0.62", "overshoot"]
        case .stiff:
            ["damping 0.86", "stiffness 280", "derived response"]
        case .snap:
            ["response 0", "nonAnimated", "immediate"]
        }
    }

    var spring: WaveSpring {
        switch self {
        case .interactive:
            .defaultInteractive
        case .animated:
            .defaultAnimated
        case .bouncy:
            WaveSpring(dampingRatio: 0.68, response: 0.80)
        case .underdamped:
            WaveSpring(dampingRatio: 0.45, response: 0.62)
        case .stiff:
            WaveSpring(dampingRatio: 0.86, stiffness: 280)
        case .snap:
            .defaultNonAnimated
        }
    }

    var mode: AnimationMode {
        switch self {
        case .snap:
            .nonAnimated
        default:
            .animated
        }
    }
}

enum WaveFormat {
    static func decimal(_ value: CGFloat) -> String {
        if value.isInfinite {
            return "inf"
        }
        if value.isNaN {
            return "nan"
        }
        return String(format: "%.2f", Double(value))
    }

    static func point(_ value: CGPoint) -> String {
        "\(decimal(value.x)), \(decimal(value.y))"
    }

    static func state(_ state: AnimatorState) -> String {
        switch state {
        case .inactive: "inactive"
        case .running: "running"
        case .ended: "ended"
        }
    }

    static func mode(_ mode: AnimationMode) -> String {
        switch mode {
        case .animated: "animated"
        case .nonAnimated: "nonAnimated"
        }
    }
}
