import ShaderCards
import ShaderKit
import SwiftUI

/// Named live stacks for the single `HolographicCardContainer`.
/// Keep each recipe to two or three passes so the simulator stays smooth.
enum HoloStack: String, CaseIterable, Identifiable, Hashable {
    case codex
    case starburst
    case glass
    case frozen
    case titanium
    case vmax
    case snowfall
    case psychic

    var id: String { rawValue }

    var title: String {
        switch self {
        case .codex: "Codex"
        case .starburst: "Starburst"
        case .glass: "Glass"
        case .frozen: "Frozen"
        case .titanium: "Titanium"
        case .vmax: "VMAX"
        case .snowfall: "Snowfall"
        case .psychic: "Psychic"
        }
    }

    var caption: String {
        switch self {
        case .codex: "foil · glitter · lightSweep"
        case .starburst: "starburst · radialSweep · multiGlitter"
        case .glass: "foil · glitter · glassEnclosure"
        case .frozen: "frozen"
        case .titanium: "brushedTitanium · glassSheen"
        case .vmax: "tradingCardHolo(.vMax)"
        case .snowfall: "snowfall · glitter"
        case .psychic: "foil · glitter · glare"
        }
    }

    var shadow: Color {
        switch self {
        case .codex: Color(red: 0.85, green: 0.55, blue: 0.12)
        case .starburst: Color(red: 1.0, green: 0.82, blue: 0.22)
        case .glass: Color.white.opacity(0.45)
        case .frozen: Color(red: 0.45, green: 0.78, blue: 1.0)
        case .titanium: Color(red: 0.62, green: 0.66, blue: 0.72)
        case .vmax: Color(red: 0.95, green: 0.35, blue: 0.22)
        case .snowfall: Color(red: 0.35, green: 0.72, blue: 0.95)
        case .psychic: Color(red: 0.72, green: 0.32, blue: 0.92)
        }
    }

    var baseColors: [Color] {
        switch self {
        case .codex:
            [
                Color(red: 0.12, green: 0.08, blue: 0.28),
                Color(red: 0.42, green: 0.18, blue: 0.08),
                Color(red: 0.06, green: 0.05, blue: 0.12),
            ]
        case .starburst:
            [
                Color(red: 0.28, green: 0.12, blue: 0.04),
                Color(red: 0.72, green: 0.48, blue: 0.08),
                Color(red: 0.10, green: 0.06, blue: 0.04),
            ]
        case .glass:
            [
                Color(red: 0.10, green: 0.16, blue: 0.28),
                Color(red: 0.06, green: 0.08, blue: 0.16),
            ]
        case .frozen:
            [
                Color(red: 0.12, green: 0.22, blue: 0.38),
                Color(red: 0.62, green: 0.82, blue: 0.95),
                Color(red: 0.08, green: 0.12, blue: 0.22),
            ]
        case .titanium:
            [
                Color(red: 0.20, green: 0.25, blue: 0.32),
                Color(red: 0.52, green: 0.59, blue: 0.68),
                Color(red: 0.16, green: 0.20, blue: 0.27),
            ]
        case .vmax:
            [
                Color(red: 0.28, green: 0.04, blue: 0.08),
                Color(red: 0.08, green: 0.04, blue: 0.06),
            ]
        case .snowfall:
            [
                Color(red: 0.10, green: 0.18, blue: 0.32),
                Color(red: 0.18, green: 0.38, blue: 0.42),
                Color(red: 0.06, green: 0.10, blue: 0.18),
            ]
        case .psychic:
            [
                Color(red: 0.22, green: 0.06, blue: 0.32),
                Color(red: 0.08, green: 0.04, blue: 0.16),
            ]
        }
    }

    var effects: [ShaderEffect] {
        switch self {
        case .codex:
            [.foil(intensity: 0.85), .glitter(density: 55), .lightSweep]
        case .starburst:
            [.starburst(intensity: 0.9), .radialSweep, .multiGlitter(density: 70)]
        case .glass:
            [
                .foil(intensity: 0.7),
                .glitter(density: 45),
                .glassEnclosure(intensity: 0.9, cornerRadius: 0.05, bevelSize: 0.7, glossiness: 0.8),
            ]
        case .frozen:
            [.frozen(intensity: 0.85, starDensity: 0.7, shimmerIntensity: 0.9)]
        case .titanium:
            [
                .brushedTitanium(intensity: 0.88),
                .glassSheen(intensity: 0.16, spread: 0.7),
            ]
        case .vmax:
            [.tradingCardHolo(style: .vMax, intensity: 0.88)]
        case .snowfall:
            [
                .snowfall(
                    intensity: 0.8,
                    snowDensity: 0.5,
                    starDensity: 0.6,
                    primaryColor: SIMD4<Float>(0.3, 0.5, 0.7, 1.0),
                    secondaryColor: SIMD4<Float>(0.2, 0.4, 0.6, 1.0)
                ),
                .glitter(density: 40),
            ]
        case .psychic:
            [.foil(intensity: 0.8), .glitter(density: 55), .glare(intensity: 0.7)]
        }
    }
}

enum LibraryCard: String, CaseIterable, Identifiable, Hashable {
    case emberfox
    case tidecaller
    case mindmoth
    case nightfang
    case glimmerkit

    var id: String { rawValue }

    var title: String {
        switch self {
        case .emberfox: "Emberfox"
        case .tidecaller: "Tidecaller"
        case .mindmoth: "Mindmoth"
        case .nightfang: "Nightfang"
        case .glimmerkit: "Glimmerkit"
        }
    }

    var caption: String {
        switch self {
        case .emberfox: "Holo Rare"
        case .tidecaller: "Ultra Rare"
        case .mindmoth: "Special Illustration"
        case .nightfang: "Hyper Rare"
        case .glimmerkit: "Rainbow Rare"
        }
    }

    var card: Card {
        switch self {
        case .emberfox: .creature(CardLibrary.emberfox)
        case .tidecaller: .creature(CardLibrary.tidecaller)
        case .mindmoth: .creature(CardLibrary.mindmoth)
        case .nightfang: .creature(CardLibrary.nightfang)
        case .glimmerkit: .creature(CardLibrary.glimmerkit)
        }
    }
}

enum JellyControl: String, CaseIterable, Identifiable, Hashable {
    case toggle
    case button

    var id: String { rawValue }

    var title: String {
        switch self {
        case .toggle: "Switch"
        case .button: "Button"
        }
    }
}

/// High-contrast collectible face. Shaders live on the fill only so type stays ink.
struct DemoHoloFace: View {
    var stack: HoloStack

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: stack.baseColors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .modifier(StackedShaders(effects: stack.effects))

            VStack {
                LinearGradient(
                    colors: [.black.opacity(0.62), .clear],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 88)
                Spacer()
                LinearGradient(
                    colors: [.clear, .black.opacity(0.72)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 168)
            }

            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("SHADERKIT")
                        .font(.caption.weight(.semibold).monospaced())
                        .tracking(1.6)
                        .foregroundStyle(DemoPalette.accent)
                    Spacer()
                    Text("HP 200")
                        .font(.caption.weight(.semibold).monospaced())
                        .foregroundStyle(DemoPalette.ink)
                }

                Spacer()

                Text(stack.title)
                    .font(.system(size: 34, weight: .semibold, design: .serif))
                    .foregroundStyle(DemoPalette.ink)

                Text("Drag across the card. Gyroscope is unused — tilt is the pointer.")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(DemoPalette.ink)
                    .fixedSize(horizontal: false, vertical: true)

                HStack(spacing: 8) {
                    DemoChrome.chip(stack.rawValue)
                    DemoChrome.chip("one Metal pass stack")
                }
            }
            .padding(20)

            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.55),
                            stack.shadow.opacity(0.8),
                            Color.white.opacity(0.18),
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 3
                )
                .allowsHitTesting(false)
        }
    }
}
