/// Change effects exercised on the Live tab. Names match `AnyChangeEffect` in Pow 1.0.6.
/// Jump is the package's bounce: it rises by `height` and settles through an underdamped spring.
enum ChangeEffectKind: String, CaseIterable, Identifiable, Hashable {
    case shake
    case glow
    case jump
    case spin
    case shine

    var id: String { rawValue }

    var title: String {
        switch self {
        case .shake: "Shake"
        case .glow: "Glow"
        case .jump: "Jump"
        case .spin: "Spin"
        case .shine: "Shine"
        }
    }

    var symbol: String {
        switch self {
        case .shake: "arrow.left.arrow.right"
        case .glow: "sun.max.fill"
        case .jump: "arrow.up"
        case .spin: "arrow.clockwise"
        case .shine: "sparkle"
        }
    }

    /// The call the Live stage actually attaches. Arguments are filled in `LiveSurfaces`.
    var api: String {
        switch self {
        case .shake: ".shake(rate: .fast)"
        case .glow: ".glow(color:radius:)"
        case .jump: ".jump(height:)"
        case .spin: ".spin(axis:rate:)"
        case .shine: ".shine"
        }
    }

    var summary: String {
        switch self {
        case .shake:
            "AnyChangeEffect.shake(rate:) with ShakeRate.fast. The default rate is also available as .shake."
        case .glow:
            "Highlights the card for about a second. Color is this demo's accent and radius is 20."
        case .jump:
            "Rises 40 points, then bounces back. Pow names this jump, not bounce."
        case .spin:
            "Spins about the y axis. rate is SpinRate.fast. .spin alone uses axis (0, 1, 0) and SpinRate.default."
        case .shine:
            "A shine from the top leading edge to the bottom trailing edge. Duration is the default, 1 second."
        }
    }
}

/// Transitions exercised on the Live tab. All live under `AnyTransition.movingParts` in Pow 1.0.6.
enum TransitionKind: String, CaseIterable, Identifiable, Hashable {
    case boing
    case pop
    case flip
    case iris
    case wipe

    var id: String { rawValue }

    var title: String {
        switch self {
        case .boing: "Boing"
        case .pop: "Pop"
        case .flip: "Flip"
        case .iris: "Iris"
        case .wipe: "Wipe"
        }
    }

    var symbol: String {
        switch self {
        case .boing: "arrow.down"
        case .pop: "heart.fill"
        case .flip: "rotate.right"
        case .iris: "camera.aperture"
        case .wipe: "rectangle.lefthalf.filled"
        }
    }

    var api: String {
        switch self {
        case .boing: ".movingParts.boing(edge:)"
        case .pop: ".movingParts.pop(_:)"
        case .flip: ".movingParts.flip"
        case .iris: ".movingParts.iris(origin:blurRadius:)"
        case .wipe: ".movingParts.wipe(angle:blurRadius:)"
        }
    }

    var summary: String {
        switch self {
        case .boing:
            "Drops in from the top edge. Overshoot squishes the card. Removal fades while it boings back out."
        case .pop:
            "Insertion only. A ripple and tint-colored particles. The package bakes in a 1.2 second linear animation. Removal is .identity."
        case .flip:
            "Rotates in toward the viewer and away on the way out. A bouncy spring lets it overshoot past the settled angle."
        case .iris:
            "A circle grows from the center on insertion and shrinks on removal. blurRadius is 10."
        case .wipe:
            "Insertion sweeps at 45 degrees. Removal sweeps at 225 degrees. Both use blurRadius 10."
        }
    }
}
