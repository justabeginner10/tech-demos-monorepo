import Aurora
import simd
import SwiftUI

/// Host that receives the single live `AuroraGlow` overlay.
enum LiveTarget: String, CaseIterable, Identifiable, Hashable {
    case prompt
    case card

    var id: String { rawValue }

    var title: String {
        switch self {
        case .prompt: "Prompt"
        case .card: "Card"
        }
    }

    var subtitle: String {
        switch self {
        case .prompt: "Siri-style field · .glow"
        case .card: "Inset card · .glow"
        }
    }

    var defaultShape: GlowShape {
        switch self {
        case .prompt: .capsule
        case .card: .rounded
        }
    }
}

/// Maps onto `AuroraGlow.Style` — the package's intensity / energy profile.
enum GlowIntensity: String, CaseIterable, Identifiable, Hashable {
    case subtle
    case standard
    case dramatic

    var id: String { rawValue }

    var title: String {
        switch self {
        case .subtle: "Subtle"
        case .standard: "Standard"
        case .dramatic: "Dramatic"
        }
    }

    var style: AuroraGlow.Style {
        switch self {
        case .subtle: .subtle
        case .standard: .standard
        case .dramatic: .dramatic
        }
    }

    /// Crisp outline only. Glow size must not drive this.
    var ringWidth: CGFloat {
        switch self {
        case .subtle: 3
        case .standard: 4
        case .dramatic: 5
        }
    }

    /// Outward bloom vs Standard. Capped in AuroraHalo so this cannot resize the host.
    var bloomScale: CGFloat {
        switch self {
        case .subtle: 0.75
        case .standard: 1.0
        case .dramatic: 1.35
        }
    }
}

/// Built-in `AuroraGlow.Palette` cases. Custom `Palette(base:anchors:)` is unused.
enum GlowPaletteChoice: String, CaseIterable, Identifiable, Hashable {
    case appleIntelligence
    case sunset
    case ocean
    case forest
    case monochrome
    case cyberpunk

    var id: String { rawValue }

    var title: String {
        switch self {
        case .appleIntelligence: "Intelligence"
        case .sunset: "Sunset"
        case .ocean: "Ocean"
        case .forest: "Forest"
        case .monochrome: "Mono"
        case .cyberpunk: "Cyber"
        }
    }

    var palette: AuroraGlow.Palette {
        switch self {
        case .appleIntelligence: .appleIntelligence
        case .sunset: .sunset
        case .ocean: .ocean
        case .forest: .forest
        case .monochrome: .monochrome
        case .cyberpunk: .cyberpunk
        }
    }

    var swatchColors: [Color] {
        palette.anchors.map { Color(aurora: $0) }
    }

    var baseColor: Color {
        Color(aurora: palette.base)
    }
}

/// Convenience presets that write `AuroraGlow.cornerRadius`. The shader is always a rounded rect.
enum GlowShape: String, CaseIterable, Identifiable, Hashable {
    case rectangle
    case rounded
    case capsule

    var id: String { rawValue }

    var title: String {
        switch self {
        case .rectangle: "Rect"
        case .rounded: "Round"
        case .capsule: "Capsule"
        }
    }

    /// Values that read as rectangle / continuous round / pill on both hosts.
    var cornerRadius: CGFloat {
        switch self {
        case .rectangle: 8
        case .rounded: 24
        case .capsule: 80
        }
    }
}

struct LiveGlowSettings {
    var target: LiveTarget = .prompt
    var intensity: GlowIntensity = .standard
    var palette: GlowPaletteChoice = .appleIntelligence
    var shape: GlowShape = .capsule
    var speed: Double = 0.12
    var glowSize: CGFloat = 14
    var cornerRadius: CGFloat = 80
    var isGlowOn: Bool = true

    mutating func applyShape(_ shape: GlowShape) {
        self.shape = shape
        cornerRadius = shape.cornerRadius
    }

    mutating func applyTarget(_ target: LiveTarget) {
        self.target = target
        applyShape(target.defaultShape)
    }
}

extension Color {
    init(aurora channel: SIMD3<Float>) {
        self.init(
            red: Double(channel.x),
            green: Double(channel.y),
            blue: Double(channel.z)
        )
    }
}
