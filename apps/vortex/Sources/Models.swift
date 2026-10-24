/// Built-in `VortexSystem` presets shipped in Vortex 1.0.4, in sandbox order.
/// Confetti emits nothing until `VortexProxy.burst()` — it lives on the Burst family.
enum ParticlePreset: String, CaseIterable, Identifiable, Hashable {
    case confetti
    case fire
    case fireflies
    case fireworks
    case magic
    case rain
    case smoke
    case snow
    case spark
    case splash

    var id: String { rawValue }

    var title: String {
        switch self {
        case .confetti: "Confetti"
        case .fire: "Fire"
        case .fireflies: "Fireflies"
        case .fireworks: "Fireworks"
        case .magic: "Magic"
        case .rain: "Rain"
        case .smoke: "Smoke"
        case .snow: "Snow"
        case .spark: "Spark"
        case .splash: "Splash"
        }
    }

    var api: String {
        switch self {
        case .confetti: "VortexSystem.confetti"
        case .fire: "VortexSystem.fire"
        case .fireflies: "VortexSystem.fireflies"
        case .fireworks: "VortexSystem.fireworks"
        case .magic: "VortexSystem.magic"
        case .rain: "VortexSystem.rain"
        case .smoke: "VortexSystem.smoke"
        case .snow: "VortexSystem.snow"
        case .spark: "VortexSystem.spark"
        case .splash: "VortexSystem.splash"
        }
    }

    /// Tags the preset looks up. Symbols in `VortexView` must use these names.
    var tags: String {
        switch self {
        case .confetti: "square · circle"
        case .magic: "sparkle"
        default: "circle"
        }
    }

    var chips: [String] {
        switch self {
        case .confetti:
            ["birthRate 0", "proxy.burst", "square", "circle"]
        case .fire:
            ["plusLighter", "attractTo", "circle"]
        case .fireflies:
            ["ellipse", "repel", "circle"]
        case .fireworks:
            ["onUpdate", "onDeath", "circle"]
        case .magic:
            ["ring", "Image.sparkle", "sparkle"]
        case .rain:
            ["stretchFactor", "circle"]
        case .smoke:
            ["color ramp", "circle"]
        case .snow:
            ["box emitter", "circle"]
        case .spark:
            ["idleDuration", "circle"]
        case .splash:
            ["secondary", "with rain", "circle"]
        }
    }

    var summary: String {
        switch self {
        case .confetti:
            "Bursts only. Tap moves the emitter, then burst() fires square and circle particles."
        case .fire:
            "A tight box of flame. Drag calls attractTo(_:) and sets attractionStrength."
        case .fireflies:
            "Dots born inside an ellipse. Drag sets a negative attractionStrength so they flee."
        case .fireworks:
            "Three stages: a launch, onUpdate sparkles, and an onDeath colored explosion."
        case .magic:
            "A ring of sparkle-tagged particles. Uses the package Image.sparkle asset."
        case .rain:
            "Fast streaks from the top edge. Stretch follows speed."
        case .smoke:
            "Soft circles that grow and fade through a gray ramp."
        case .snow:
            "Slow flakes from a wide box along the top."
        case .spark:
            "Short emission bursts separated by idleDuration."
        case .splash:
            "The rain preset stacked with the splash preset, as in the package sample."
        }
    }

    /// Presets that emit on their own. Confetti stays on the Burst family.
    var isContinuous: Bool { self != .confetti }
}
