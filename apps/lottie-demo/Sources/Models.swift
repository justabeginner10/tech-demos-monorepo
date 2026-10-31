import Lottie

/// `LottieCompletionBlock` is a nonisolated `(Bool) -> Void`.
/// A closure born in a `@MainActor` view would be main-actor isolated and would not match.
/// `CAAnimationDelegate.animationDidStop` runs on the main thread, so `MainActor.assumeIsolated`
/// is the synchronous hop back to SwiftUI state.
enum PlaybackSink {
    nonisolated static func finished(
        _ body: @escaping @MainActor (Bool) -> Void
    ) -> LottieCompletionBlock {
        { completed in
            MainActor.assumeIsolated {
                body(completed)
            }
        }
    }
}

/// Names `LottieAnimation.reducedMotionMarker` treats as the reduced-motion stand-in.
/// The property is internal. The comparison is case insensitive. The four strings are the set in
/// `LottieAnimation.swift` at lottie-ios `4.6.1`.
enum LottieMarkers {
    static let reducedMotionNames: Set<String> = [
        "reduced motion",
        "reduced_motion",
        "reduced-motion",
        "reducedmotion",
    ]

    static func isReducedMotion(_ name: String) -> Bool {
        reducedMotionNames.contains(name.lowercased())
    }
}

/// JSON files in `Sources/Animations`, copied to the bundle root.
/// `LottieAnimation.named` appends `.json` and does not take a subdirectory.
enum AnimationClip: String, CaseIterable, Identifiable, Hashable {
    case pulse
    case orbit
    case check
    case bars
    case bounce

    var id: String { rawValue }

    var fileName: String { rawValue }

    var title: String {
        switch self {
        case .pulse: "Pulse"
        case .orbit: "Orbit"
        case .check: "Check"
        case .bars: "Bars"
        case .bounce: "Bounce"
        }
    }

    var detail: String {
        switch self {
        case .pulse:
            "Filled ellipse. Scale and opacity ease out and back. Markers in, out, and reduced motion."
        case .orbit:
            "Stroked ellipse. Trim end stays at 28. Offset runs 0 to 360. Marker spin covers the whole file."
        case .check:
            "Open polyline, round cap. Trim end draws the mark, then holds. Markers draw and hold."
        case .bars:
            "Three rounded rectangles. Scale Y is staggered. Markers rise and fall."
        case .bounce:
            "Ellipse position and squash, plus a static ground bar. Markers up and down."
        }
    }

    var chips: [String] {
        switch self {
        case .pulse: ["scale", "opacity", "reduced motion"]
        case .orbit: ["trim", "offset", "stroke"]
        case .check: ["trim end", "shape", "markers"]
        case .bars: ["rectangle", "scale", "stagger"]
        case .bounce: ["position", "squash", "markers"]
        }
    }

    /// `named` looks for `fileName.json`. The Xcode project copies the files to the bundle root.
    /// A regenerated project that keeps the `Animations` folder is checked second, so a missing
    /// root file does not make `named` log a decode warning before the fallback.
    func load() -> LottieAnimation? {
        if Bundle.main.url(forResource: fileName, withExtension: "json") != nil {
            return LottieAnimation.named(fileName)
        }
        let folder = "Animations"
        if Bundle.main.url(forResource: fileName, withExtension: "json", subdirectory: folder) != nil {
            return LottieAnimation.named(fileName, subdirectory: folder)
        }
        return nil
    }
}

/// Loop values the Live pickers can assign. `repeatBackwards` is not in this list.
enum LoopChoice: String, CaseIterable, Identifiable, Hashable {
    case playOnce
    case loop
    case autoReverse
    case twice

    var id: String { rawValue }

    var title: String {
        switch self {
        case .playOnce: "Once"
        case .loop: "Loop"
        case .autoReverse: "Reverse"
        case .twice: "Twice"
        }
    }

    var call: String {
        switch self {
        case .playOnce: ".playOnce"
        case .loop: ".loop"
        case .autoReverse: ".autoReverse"
        case .twice: ".repeat(2)"
        }
    }

    var mode: LottieLoopMode {
        switch self {
        case .playOnce: .playOnce
        case .loop: .loop
        case .autoReverse: .autoReverse
        case .twice: .repeat(2)
        }
    }
}

enum LottieFormat {
    static func progress(_ value: AnimationProgressTime) -> String {
        String(format: "%.2f", Double(value))
    }

    static func frame(_ value: AnimationFrameTime) -> String {
        String(format: "%.1f", Double(value))
    }

    static func whole(_ value: some BinaryFloatingPoint) -> String {
        String(format: "%.0f", Double(value))
    }
}
