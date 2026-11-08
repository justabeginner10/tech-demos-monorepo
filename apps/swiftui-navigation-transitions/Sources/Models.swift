import SwiftUI
import SwiftUINavigationTransitions

enum PresetChoice: String, CaseIterable, Identifiable, Hashable {
    case slide
    case rise
    case fadeIn
    case fadeOut
    case cross
    case slideFade
    case system

    var id: String { rawValue }

    var title: String {
        switch self {
        case .slide: "Slide"
        case .rise: "Rise"
        case .fadeIn: "Fade in"
        case .fadeOut: "Fade out"
        case .cross: "Crossfade"
        case .slideFade: "Slide + fade"
        case .system: "System"
        }
    }

    var call: String {
        switch self {
        case .slide: ".slide"
        case .rise: ".slide(axis: .vertical)"
        case .fadeIn: ".fade(.in)"
        case .fadeOut: ".fade(.out)"
        case .cross: ".fade(.cross)"
        case .slideFade: ".slide.combined(with: .fade(.in))"
        case .system: ".default"
        }
    }

    @MainActor
    var transition: CustomNavigationTransition {
        switch self {
        case .slide: .slide
        case .rise: .slide(axis: .vertical)
        case .fadeIn: .fade(.in)
        case .fadeOut: .fade(.out)
        case .cross: .fade(.cross)
        case .slideFade: .slide.combined(with: .fade(.in))
        case .system: .default
        }
    }
}

enum CustomChoice: String, CaseIterable, Identifiable, Hashable {
    case swing
    case zoom
    case flip
    case flipY
    case drift

    var id: String { rawValue }

    var title: String {
        switch self {
        case .swing: "Swing"
        case .zoom: "Zoom"
        case .flip: "Flip"
        case .flipY: "Flip Y"
        case .drift: "Drift"
        }
    }

    var call: String {
        switch self {
        case .swing: "CustomNavigationTransition(Swing())"
        case .zoom: "CustomNavigationTransition(Zoom())"
        case .flip: "CustomNavigationTransition(Flip(axis: .horizontal))"
        case .flipY: "CustomNavigationTransition(Flip(axis: .vertical))"
        case .drift: "CustomNavigationTransition(Drift())"
        }
    }

    var detail: String {
        switch self {
        case .swing:
            "Slide plus MirrorPush. Insertion rotates, offsets, fades, and scales. Removal mirrors that block."
        case .zoom:
            "MirrorPush of Scale(0.5), with ZPosition and Opacity on insertion only."
        case .flip:
            "MirrorPush of Rotate3D 180° around x."
        case .flipY:
            "MirrorPush of Rotate3D 180° around y."
        case .drift:
            "transition(from:to:for:in:) with typealias _Body = Never. Push fades the incoming page in from the right."
        }
    }

    @MainActor
    var transition: CustomNavigationTransition {
        switch self {
        case .swing: .init(Swing())
        case .zoom: .init(Zoom())
        case .flip: .init(Flip(axis: .horizontal))
        case .flipY: .init(Flip(axis: .vertical))
        case .drift: .init(Drift())
        }
    }
}

enum PopGesture: String, CaseIterable, Identifiable, Hashable {
    case edge
    case content
    case off
    case auto

    var id: String { rawValue }

    var title: String {
        switch self {
        case .edge: "Edge"
        case .content: "Content"
        case .off: "Off"
        case .auto: "Auto"
        }
    }

    var call: String {
        switch self {
        case .edge: ".edgePan"
        case .content: ".contentPan"
        case .off: ".disabled"
        case .auto: ".default"
        }
    }

    var detail: String {
        switch self {
        case .edge:
            "Leading-edge pop. A custom transition uses the package edge recognizer (edges: .left). System uses interactivePopGestureRecognizer."
        case .content:
            "Pop from anywhere on the page. A custom transition uses the package pan recognizer. System on iOS 26 uses the system content pop gesture. Earlier systems copy the edge recognizer's targets onto a full-screen pan."
        case .off:
            "Pop gestures are turned off. The toolbar back button and Pop still call popViewController."
        case .auto:
            "Interactivity.default is contentPan on iOS 26 and later, and edgePan on earlier systems."
        }
    }

    var interactivity: CustomNavigationTransition.Interactivity {
        switch self {
        case .edge: .edgePan
        case .content: .contentPan
        case .off: .disabled
        case .auto: .default
        }
    }
}

enum MotionChoice: String, CaseIterable, Identifiable, Hashable {
    case packageDefault
    case ease
    case linear
    case spring

    var id: String { rawValue }

    var title: String {
        switch self {
        case .packageDefault: "Default"
        case .ease: "Ease"
        case .linear: "Linear"
        case .spring: "Spring"
        }
    }

    /// `nil` leaves the animation the initializer stored (`.default`, ease-in-out, 0.35s).
    @MainActor
    func animation(duration: Double, stiffness: Double, damping: Double, faster: Bool) -> CustomNavigationTransition.Animation? {
        let base: CustomNavigationTransition.Animation?
        switch self {
        case .packageDefault:
            base = faster ? .default : nil
        case .ease:
            base = .easeInOut(duration: duration)
        case .linear:
            base = .linear(duration: duration)
        case .spring:
            base = .interpolatingSpring(stiffness: stiffness, damping: damping)
        }
        guard let base else { return nil }
        return faster ? base.speed(1.6) : base
    }

    func call(duration: Double, stiffness: Double, damping: Double, faster: Bool) -> String? {
        let core: String?
        switch self {
        case .packageDefault:
            core = faster ? ".default" : nil
        case .ease:
            core = ".easeInOut(duration: \(Self.format(duration)))"
        case .linear:
            core = ".linear(duration: \(Self.format(duration)))"
        case .spring:
            core = ".interpolatingSpring(stiffness: \(Self.format(stiffness)), damping: \(Self.format(damping)))"
        }
        guard let core else { return nil }
        return faster ? "\(core).speed(1.6)" : core
    }

    private static func format(_ value: Double) -> String {
        String(format: "%g", value)
    }
}

struct TransitionBuild: Equatable {
    var expression: String
    var token: String
    /// `.default` ignores `animation(_:)`. The package note is on `CustomNavigationTransition.default`.
    var locksMotion: Bool
}

enum TransitionFactory {
    /// Fade branch from the package README: `reduceMotion ? .fade(.in).animation(.linear) : …`.
    @MainActor
    static func preset(
        choice: PresetChoice,
        fadeInstead: Bool,
        motion: MotionChoice,
        duration: Double,
        stiffness: Double,
        damping: Double,
        faster: Bool,
        gesture: PopGesture
    ) -> (CustomNavigationTransition, TransitionBuild) {
        if fadeInstead {
            let animation = MotionChoice.linear.animation(
                duration: duration,
                stiffness: stiffness,
                damping: damping,
                faster: faster
            )
            let faded = CustomNavigationTransition.fade(.in)
            let transition = animation.map { faded.animation($0) } ?? faded
            let motionCall = MotionChoice.linear.call(
                duration: duration,
                stiffness: stiffness,
                damping: damping,
                faster: faster
            ) ?? ".linear"
            let expression = ".fade(.in).animation(\(motionCall))"
            return (
                transition,
                TransitionBuild(
                    expression: expression,
                    token: "fade|\(motionCall)|\(gesture.rawValue)",
                    locksMotion: false
                )
            )
        }

        let base = choice.transition
        if choice == .system {
            return (
                base,
                TransitionBuild(
                    expression: ".default",
                    token: "system|\(gesture.rawValue)",
                    locksMotion: true
                )
            )
        }

        let animation = motion.animation(
            duration: duration,
            stiffness: stiffness,
            damping: damping,
            faster: faster
        )
        let transition = animation.map { base.animation($0) } ?? base
        let expression: String
        if let motionCall = motion.call(duration: duration, stiffness: stiffness, damping: damping, faster: faster) {
            expression = "\(choice.call).animation(\(motionCall))"
        } else {
            expression = choice.call
        }
        return (
            transition,
            TransitionBuild(
                expression: expression,
                token: "\(choice.rawValue)|\(expression)|\(gesture.rawValue)",
                locksMotion: false
            )
        )
    }

    @MainActor
    static func custom(
        choice: CustomChoice,
        motion: MotionChoice,
        duration: Double,
        stiffness: Double,
        damping: Double,
        faster: Bool,
        gesture: PopGesture
    ) -> (CustomNavigationTransition, TransitionBuild) {
        let base = choice.transition
        let animation = motion.animation(
            duration: duration,
            stiffness: stiffness,
            damping: damping,
            faster: faster
        )
        let transition = animation.map { base.animation($0) } ?? base
        let expression: String
        if let motionCall = motion.call(duration: duration, stiffness: stiffness, damping: damping, faster: faster) {
            expression = "\(choice.call).animation(\(motionCall))"
        } else {
            expression = choice.call
        }
        return (
            transition,
            TransitionBuild(
                expression: expression,
                token: "\(choice.rawValue)|\(expression)|\(gesture.rawValue)",
                locksMotion: false
            )
        )
    }
}
