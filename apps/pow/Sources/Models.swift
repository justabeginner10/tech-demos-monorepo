import Pow
import SwiftUI
import UIKit

enum LiveFamily: String, CaseIterable, Identifiable, Hashable {
    case effects
    case transitions

    var id: String { rawValue }

    var title: String {
        switch self {
        case .effects: "Effects"
        case .transitions: "Transitions"
        }
    }

    var subtitle: String {
        switch self {
        case .effects: "changeEffect"
        case .transitions: ".movingParts"
        }
    }
}

enum ChangeEffectKind: String, CaseIterable, Identifiable, Hashable {
    case spray
    case jump
    case pulse
    case shine
    case spin
    case shake
    case wiggle
    case glow
    case rise
    case haptic

    var id: String { rawValue }

    var title: String {
        switch self {
        case .spray: "Spray"
        case .jump: "Jump"
        case .pulse: "Pulse"
        case .shine: "Shine"
        case .spin: "Spin"
        case .shake: "Shake"
        case .wiggle: "Wiggle"
        case .glow: "Glow"
        case .rise: "Rise"
        case .haptic: "Haptic"
        }
    }

    var systemImage: String {
        switch self {
        case .spray: "heart.fill"
        case .jump: "arrow.up.circle.fill"
        case .pulse: "dot.radiowaves.left.and.right"
        case .shine: "sparkle"
        case .spin: "arrow.triangle.2.circlepath"
        case .shake: "arrow.left.and.right"
        case .wiggle: "waveform.path"
        case .glow: "sun.max.fill"
        case .rise: "arrow.up.to.line"
        case .haptic: "iphone.radiowaves.left.and.right"
        }
    }

    var apiName: String {
        switch self {
        case .spray: ".spray(origin:layer:)"
        case .jump: ".jump(height:)"
        case .pulse: ".pulse(shape:style:drawingMode:count:)"
        case .shine: ".shine(angle:duration:)"
        case .spin: ".spin(axis:rate:)"
        case .shake: ".shake(rate:)"
        case .wiggle: ".wiggle(rate:)"
        case .glow: ".glow(color:radius:)"
        case .rise: ".rise(origin:layer:)"
        case .haptic: ".feedback(hapticNotification:)"
        }
    }

    var summary: String {
        switch self {
        case .spray: "Emits shaded particles that burst upward from an origin."
        case .jump: "The view leaps, then settles with a few bounces."
        case .pulse: "Growing, fading shapes behind the view. Replaces deprecated ping."
        case .shine: "A highlight sweeps across the view."
        case .spin: "Spins the view around an axis, then coasts to rest."
        case .shake: "Horizontal shake, as if telling the user no."
        case .wiggle: "Rotates the view back and forth around z."
        case .glow: "A colored halo blooms, then fades."
        case .rise: "Particles float up and drift side to side."
        case .haptic: "Notification, impact, or selection feedback. No bundled audio."
        }
    }
}

enum TransitionKind: String, CaseIterable, Identifiable, Hashable {
    case pop
    case flip
    case anvil
    case blinds
    case boing
    case swoosh
    case vanish
    case glare
    case iris
    case clock
    case poof
    case wipe
    case snapshot
    case flicker
    case skid
    case blur

    var id: String { rawValue }

    static let liveCases: [TransitionKind] = [
        .pop, .flip, .anvil, .blinds, .boing, .swoosh, .vanish,
    ]

    var title: String {
        switch self {
        case .pop: "Pop"
        case .flip: "Flip"
        case .anvil: "Anvil"
        case .blinds: "Blinds"
        case .boing: "Boing"
        case .swoosh: "Swoosh"
        case .vanish: "Vanish"
        case .glare: "Glare"
        case .iris: "Iris"
        case .clock: "Clock"
        case .poof: "Poof"
        case .wipe: "Wipe"
        case .snapshot: "Snapshot"
        case .flicker: "Flicker"
        case .skid: "Skid"
        case .blur: "Blur"
        }
    }

    var systemImage: String {
        switch self {
        case .pop: "rays"
        case .flip: "rectangle.portrait.rotate"
        case .anvil: "scalemass.fill"
        case .blinds: "square.split.1x2"
        case .boing: "arrow.down.circle"
        case .swoosh: "square.3.layers.3d"
        case .vanish: "sparkles"
        case .glare: "sun.horizon.fill"
        case .iris: "circle.circle"
        case .clock: "clock"
        case .poof: "cloud.fill"
        case .wipe: "rectangle.split.2x1"
        case .snapshot: "camera.fill"
        case .flicker: "lightbulb.fill"
        case .skid: "arrow.forward.to.line"
        case .blur: "drop.halffull"
        }
    }

    var apiName: String {
        switch self {
        case .pop: ".movingParts.pop(_)"
        case .flip: ".movingParts.flip"
        case .anvil: ".movingParts.anvil"
        case .blinds: ".movingParts.blinds(slatWidth:style:isStaggered:)"
        case .boing: ".movingParts.boing(edge:)"
        case .swoosh: ".movingParts.swoosh"
        case .vanish: ".movingParts.vanish(_:increasedBrightness:)"
        case .glare: ".movingParts.glare(angle:)"
        case .iris: ".movingParts.iris(origin:)"
        case .clock: ".movingParts.clock"
        case .poof: ".movingParts.poof"
        case .wipe: ".movingParts.wipe(edge:)"
        case .snapshot: ".movingParts.snapshot"
        case .flicker: ".movingParts.flicker(count:)"
        case .skid: ".movingParts.skid(direction:)"
        case .blur: ".movingParts.blur(radius:)"
        }
    }

    var summary: String {
        switch self {
        case .pop: "Insertion-only ripple and tinted particles. Removal is identity."
        case .flip: "Rotates toward the viewer on insert, away on remove."
        case .anvil: "Drops in from the top with impact haptics. Insertion-only."
        case .blinds: "Reveals the view as window blinds. Venetian or vertical slats."
        case .boing: "Moves in from an edge; overshoot squashes the view."
        case .swoosh: "Three-dimensional move from back to front."
        case .vanish: "Dissolves into particles. Removal-only."
        case .glare: "Diagonal wipe with a bright streak."
        case .iris: "A circle grows from an origin, or shrinks on removal."
        case .clock: "A clockwise sweep uncovers the view."
        case .poof: "Cartoon cloud dissolve. Removal-only."
        case .wipe: "A sweep from an edge."
        case .snapshot: "Blows out to white, then settles."
        case .flicker: "Toggles visibility several times before settling."
        case .skid: "Slides in with elastic overshoot."
        case .blur: "Blurry to sharp on insert, sharp to blurry on remove."
        }
    }

    func powTransition(_ params: TransitionParams) -> AnyTransition {
        switch self {
        case .pop:
            .movingParts.pop(params.ink.color)
        case .flip:
            .movingParts.flip
        case .anvil:
            .movingParts.anvil
        case .blinds:
            .movingParts.blinds(
                slatWidth: params.blindsWidth,
                style: params.blindsKind.powStyle,
                isStaggered: params.blindsStaggered
            )
        case .boing:
            .movingParts.boing(edge: params.edge.edge)
        case .swoosh:
            .movingParts.swoosh
        case .vanish:
            .movingParts.vanish(params.ink.color, increasedBrightness: params.vanishBright)
        case .glare:
            .movingParts.glare(angle: .degrees(params.glareAngle), color: .white)
        case .iris:
            .movingParts.iris(origin: params.origin.unitPoint)
        case .clock:
            .movingParts.clock
        case .poof:
            .movingParts.poof
        case .wipe:
            .movingParts.wipe(edge: params.edge.edge)
        case .snapshot:
            .movingParts.snapshot
        case .flicker:
            .movingParts.flicker(count: params.flickerCount)
        case .skid:
            .movingParts.skid(direction: params.skidKind.powDirection)
        case .blur:
            .movingParts.blur(radius: params.blurRadius)
        }
    }
}

enum ParticleOrigin: String, CaseIterable, Identifiable, Hashable {
    case center
    case top
    case bottom
    case leading
    case trailing

    var id: String { rawValue }

    var title: String {
        rawValue.capitalized
    }

    var unitPoint: UnitPoint {
        switch self {
        case .center: .center
        case .top: .top
        case .bottom: .bottom
        case .leading: .leading
        case .trailing: .trailing
        }
    }
}

enum ShakePace: String, CaseIterable, Identifiable, Hashable {
    case `default`
    case fast

    var id: String { rawValue }

    var title: String {
        switch self {
        case .default: "Default"
        case .fast: "Fast"
        }
    }

    var rate: AnyChangeEffect.ShakeRate {
        switch self {
        case .default: AnyChangeEffect.ShakeRate.`default`
        case .fast: AnyChangeEffect.ShakeRate.fast
        }
    }
}

enum WigglePace: String, CaseIterable, Identifiable, Hashable {
    case `default`
    case fast

    var id: String { rawValue }

    var title: String {
        switch self {
        case .default: "Default"
        case .fast: "Fast"
        }
    }

    var rate: AnyChangeEffect.WiggleRate {
        switch self {
        case .default: AnyChangeEffect.WiggleRate.`default`
        case .fast: AnyChangeEffect.WiggleRate.fast
        }
    }
}

enum SpinPace: String, CaseIterable, Identifiable, Hashable {
    case `default`
    case fast

    var id: String { rawValue }

    var title: String {
        switch self {
        case .default: "Default"
        case .fast: "Fast"
        }
    }

    var rate: AnyChangeEffect.SpinRate {
        switch self {
        case .default: AnyChangeEffect.SpinRate.`default`
        case .fast: AnyChangeEffect.SpinRate.fast
        }
    }
}

enum SpinAxis: String, CaseIterable, Identifiable, Hashable {
    case x
    case y
    case z

    var id: String { rawValue }

    var title: String { rawValue.uppercased() }

    var vector: (x: CGFloat, y: CGFloat, z: CGFloat) {
        switch self {
        case .x: (1, 0, 0)
        case .y: (0, 1, 0)
        case .z: (0, 0, 1)
        }
    }
}

enum PulseInk: String, CaseIterable, Identifiable, Hashable {
    case fill
    case stroke

    var id: String { rawValue }

    var title: String { rawValue.capitalized }

    var mode: AnyChangeEffect.PulseDrawingMode {
        switch self {
        case .fill: .fill
        case .stroke: .stroke
        }
    }
}

enum PulseShapeKind: String, CaseIterable, Identifiable, Hashable {
    case roundedRect
    case capsule

    var id: String { rawValue }

    var title: String {
        switch self {
        case .roundedRect: "Rounded"
        case .capsule: "Capsule"
        }
    }
}

enum AccentInk: String, CaseIterable, Identifiable, Hashable {
    case rose
    case orange
    case blue

    var id: String { rawValue }

    var title: String { rawValue.capitalized }

    var color: Color {
        switch self {
        case .rose: DemoPalette.accent
        case .orange: Color(red: 0.92, green: 0.45, blue: 0.12)
        case .blue: Color(red: 0.12, green: 0.42, blue: 0.88)
        }
    }
}

enum HapticKind: String, CaseIterable, Identifiable, Hashable {
    case success
    case warning
    case error
    case impact
    case selection

    var id: String { rawValue }

    var title: String { rawValue.capitalized }

    var effect: AnyChangeEffect {
        switch self {
        case .success:
            .feedback(hapticNotification: .success)
        case .warning:
            .feedback(hapticNotification: .warning)
        case .error:
            .feedback(hapticNotification: .error)
        case .impact:
            .feedback(hapticImpact: .medium)
        case .selection:
            .feedbackHapticSelection
        }
    }
}

enum BlindsKind: String, CaseIterable, Identifiable, Hashable {
    case venetian
    case vertical

    var id: String { rawValue }

    var title: String { rawValue.capitalized }

    var powStyle: AnyTransition.MovingParts.BlindsStyle {
        switch self {
        case .venetian: .venetian
        case .vertical: .vertical
        }
    }
}

enum EdgeKind: String, CaseIterable, Identifiable, Hashable {
    case top
    case bottom
    case leading
    case trailing

    var id: String { rawValue }

    var title: String { rawValue.capitalized }

    var edge: Edge {
        switch self {
        case .top: .top
        case .bottom: .bottom
        case .leading: .leading
        case .trailing: .trailing
        }
    }
}

enum SkidKind: String, CaseIterable, Identifiable, Hashable {
    case leading
    case trailing

    var id: String { rawValue }

    var title: String { rawValue.capitalized }

    var powDirection: AnyTransition.MovingParts.SkidDirection {
        switch self {
        case .leading: .leading
        case .trailing: .trailing
        }
    }
}

struct ChangeEffectParams: Equatable {
    var origin: ParticleOrigin = .center
    var jumpHeight: CGFloat = 48
    var shineDuration: Double = 1.0
    var shineAngle: Double = 45
    var shakePace: ShakePace = .default
    var wigglePace: WigglePace = .default
    var spinAxis: SpinAxis = .y
    var spinPace: SpinPace = .default
    var spinBoost: CGFloat = 0
    var pulseInk: PulseInk = .fill
    var pulseCount: Int = 2
    var pulseShape: PulseShapeKind = .roundedRect
    var glowRadius: CGFloat = 24
    var glowInk: AccentInk = .rose
    var hapticKind: HapticKind = .success
}

struct TransitionParams: Equatable {
    var ink: AccentInk = .rose
    var blindsWidth: CGFloat = 10
    var blindsKind: BlindsKind = .venetian
    var blindsStaggered: Bool = false
    var edge: EdgeKind = .top
    var vanishBright: Bool = true
    var glareAngle: Double = 0
    var origin: ParticleOrigin = .center
    var flickerCount: Int = 3
    var skidKind: SkidKind = .leading
    var blurRadius: CGFloat = 8
}

enum GallerySelection: Identifiable, Hashable {
    case change(ChangeEffectKind)
    case transition(TransitionKind)

    var id: String {
        switch self {
        case .change(let kind): "change.\(kind.rawValue)"
        case .transition(let kind): "transition.\(kind.rawValue)"
        }
    }

    var title: String {
        switch self {
        case .change(let kind): kind.title
        case .transition(let kind): kind.title
        }
    }

    var subtitle: String {
        switch self {
        case .change(let kind): kind.apiName
        case .transition(let kind): kind.apiName
        }
    }

    var summary: String {
        switch self {
        case .change(let kind): kind.summary
        case .transition(let kind): kind.summary
        }
    }

    var systemImage: String {
        switch self {
        case .change(let kind): kind.systemImage
        case .transition(let kind): kind.systemImage
        }
    }
}
