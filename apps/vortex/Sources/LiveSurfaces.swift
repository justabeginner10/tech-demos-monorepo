import SwiftUI
import Vortex

private typealias VortexColor = VortexSystem.Color

/// One built-in preset at a time. Each `VortexView` receives `makeUniqueCopy()` so the
/// shared static preset is not mutated (fire and fireflies write `attractionStrength`).
struct PresetSurface: View {
    @State private var preset: ParticlePreset = .fire

    private var choices: [ParticlePreset] {
        ParticlePreset.allCases.filter(\.isContinuous)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            controls
            stage
        }
    }

    private var controls: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(preset.title)
                    .font(.headline)
                    .foregroundStyle(DemoPalette.ink)
                Spacer()
                Text(preset.tags)
                    .font(.caption.monospaced())
                    .foregroundStyle(DemoPalette.inkMuted)
            }

            Picker("Preset", selection: $preset) {
                ForEach(choices) { item in
                    Text(item.title).tag(item)
                }
            }
            .pickerStyle(.menu)
            .labelsHidden()
            .tint(DemoPalette.ink)

            Text(preset.summary)
                .font(.caption)
                .foregroundStyle(DemoPalette.inkMuted)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(14)
        .background(DemoPalette.card, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(DemoPalette.stroke, lineWidth: 1)
        }
    }

    @ViewBuilder
    private var stage: some View {
        switch preset {
        case .fire:
            FireSurface()
        case .fireflies:
            FirefliesSurface()
        case .fireworks:
            FireworksSurface()
        case .magic:
            MagicSurface()
        case .rain:
            RainSurface()
        case .smoke:
            SmokeSurface()
        case .snow:
            SnowSurface()
        case .spark:
            SparkSurface()
        case .splash:
            SplashSurface()
        case .confetti:
            EmptyView()
        }
    }
}

/// Tap-triggered `.confetti`, plus the iOS 17 color factory.
/// `VortexViewReader` publishes the first system it finds; burst and move use that proxy.
struct BurstSurface: View {
    @State private var palette: ConfettiPalette = .classic
    @Environment(\.self) private var environment

    var body: some View {
        VortexViewReader { proxy in
            VStack(alignment: .leading, spacing: 12) {
                controls(proxy: proxy)
                stage(proxy: proxy)
                    .id(palette)
            }
        }
    }

    private func controls(proxy: VortexProxy) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Confetti")
                    .font(.headline)
                    .foregroundStyle(DemoPalette.ink)
                Spacer()
                Text(palette.tags)
                    .font(.caption.monospaced())
                    .foregroundStyle(DemoPalette.inkMuted)
            }

            Picker("Palette", selection: $palette) {
                ForEach(ConfettiPalette.allCases) { item in
                    Text(item.title).tag(item)
                }
            }
            .pickerStyle(.segmented)

            HStack(spacing: 10) {
                Button("Burst") {
                    proxy.burst()
                }
                .buttonStyle(.borderedProminent)
                .tint(DemoPalette.accent)
                .foregroundStyle(Color.black)
            }

            Text(palette.detail)
                .font(.caption)
                .foregroundStyle(DemoPalette.inkMuted)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(14)
        .background(DemoPalette.card, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(DemoPalette.stroke, lineWidth: 1)
        }
    }

    private func stage(proxy: VortexProxy) -> some View {
        let system = confettiSystem
        return ZStack {
            VortexView(system) {
                Rectangle()
                    .fill(.white)
                    .frame(width: 16, height: 16)
                    .tag("square")

                Circle()
                    .fill(.white)
                    .frame(width: 16)
                    .tag("circle")

                Rectangle()
                    .fill(.white)
                    .frame(width: 16, height: 16)
                    .tag("confetti")
            }

            Text("Tap to move the emitter, then burst.")
                .font(.caption)
                .foregroundStyle(DemoPalette.ink)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(DemoPalette.card.opacity(0.88), in: Capsule())
                .allowsHitTesting(false)
                .frame(maxHeight: .infinity, alignment: .top)
                .padding(.top, 12)
        }
        .particleStage()
        .onTapGesture { location in
            // Local view points. move(to:) divides by the canvas draw size.
            proxy.move(to: location)
            proxy.burst()
        }
    }

    private var confettiSystem: VortexSystem {
        switch palette {
        case .classic:
            VortexSystem.confetti.makeUniqueCopy()
        case .sunset:
            VortexSystem.confetti(
                colors: [
                    SwiftUI.Color.orange,
                    SwiftUI.Color.pink,
                    SwiftUI.Color.yellow,
                    SwiftUI.Color.white,
                ],
                in: environment
            )
        case .ice:
            VortexSystem.confetti(
                colors: [
                    SwiftUI.Color.cyan,
                    SwiftUI.Color.white,
                    SwiftUI.Color.blue,
                    SwiftUI.Color.mint,
                ],
                in: environment
            )
        }
    }
}

/// Hand-built emitter: a ring of embers plus an `onDeath` secondary spark system.
/// Birth rate is written onto the live class instance the `VortexView` is already drawing.
struct CustomEmberSurface: View {
    @State private var system = EmberRing.make()
    @State private var birthRate = 36.0

    var body: some View {
        VortexViewReader { proxy in
            VStack(alignment: .leading, spacing: 12) {
                controls(proxy: proxy)
                VortexView(system) {
                    Circle()
                        .fill(.white)
                        .frame(width: 18)
                        .blur(radius: 1.5)
                        .blendMode(.plusLighter)
                        .tag("circle")
                }
                .particleStage()
            }
        }
    }

    private func controls(proxy: VortexProxy) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Ember ring")
                    .font(.headline)
                    .foregroundStyle(DemoPalette.ink)
                Spacer()
                Text("circle · onDeath")
                    .font(.caption.monospaced())
                    .foregroundStyle(DemoPalette.inkMuted)
            }

            LabeledContent("Birth rate") {
                Text("\(Int(birthRate))/s")
                    .font(.caption.monospaced())
                    .foregroundStyle(DemoPalette.inkMuted)
            }
            .font(.subheadline)
            .foregroundStyle(DemoPalette.ink)

            Slider(value: $birthRate, in: 8 ... 120, step: 1)
                .tint(DemoPalette.accent)
                .onChange(of: birthRate) { _, newValue in
                    system.birthRate = newValue
                }

            Button("Burst") {
                proxy.burst()
            }
            .buttonStyle(.borderedProminent)
            .tint(DemoPalette.accent)
            .foregroundStyle(Color.black)

            Text(
                "A VortexSystem on a ring, with a secondary system spawned onDeath. "
                    + "Both systems use the circle tag, so one symbol covers the pair. "
                    + "Burst uses the primary system's burstCount."
            )
            .font(.caption)
            .foregroundStyle(DemoPalette.inkMuted)
            .fixedSize(horizontal: false, vertical: true)
        }
        .padding(14)
        .background(DemoPalette.card, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(DemoPalette.stroke, lineWidth: 1)
        }
    }
}

private enum ConfettiPalette: String, CaseIterable, Identifiable {
    case classic
    case sunset
    case ice

    var id: String { rawValue }

    var title: String {
        switch self {
        case .classic: "Classic"
        case .sunset: "Sunset"
        case .ice: "Ice"
        }
    }

    var tags: String {
        switch self {
        case .classic: "square · circle"
        case .sunset, .ice: "confetti"
        }
    }

    var detail: String {
        switch self {
        case .classic:
            "Static .confetti. Birth rate is 0, so nothing appears until burst(). Tap calls move(to:) then burst()."
        case .sunset, .ice:
            "VortexSystem.confetti(colors:in:) resolves SwiftUI colors and emits the confetti tag."
        }
    }
}

private enum EmberRing {
    static func make() -> VortexSystem {
        let pop = VortexSystem(
            tags: ["circle"],
            spawnOccasion: .onDeath,
            birthRate: 80,
            emissionLimit: 12,
            lifespan: 0.45,
            speed: 0.35,
            speedVariation: 0.2,
            angleRange: .degrees(360),
            dampingFactor: 3,
            colors: .ramp(
                VortexColor.white,
                VortexColor.orange,
                VortexColor.clear
            ),
            size: 0.2,
            sizeMultiplierAtDeath: 0
        )

        return VortexSystem(
            tags: ["circle"],
            secondarySystems: [pop],
            position: [0.5, 0.42],
            shape: .ring(radius: 0.22),
            birthRate: 36,
            burstCount: 80,
            lifespan: 1.8,
            lifespanVariation: 0.4,
            speed: 0.12,
            speedVariation: 0.08,
            angleRange: .degrees(360),
            dampingFactor: 0.4,
            angularSpeedVariation: [0, 0, 8],
            colors: .randomRamp(
                [VortexColor.white, VortexColor.orange, VortexColor.clear],
                [VortexColor.yellow, VortexColor.red, VortexColor.clear],
                [VortexColor.white, VortexColor.pink, VortexColor.clear]
            ),
            size: 0.45,
            sizeVariation: 0.25,
            sizeMultiplierAtDeath: 0.15
        )
    }
}

private struct FireSurface: View {
    @State private var isDragging = false

    var body: some View {
        VortexViewReader { proxy in
            ZStack(alignment: .top) {
                VortexView(.fire.makeUniqueCopy()) {
                    Circle()
                        .fill(.white)
                        .frame(width: 32)
                        .blur(radius: 3)
                        .blendMode(.plusLighter)
                        .tag("circle")
                }
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            proxy.attractTo(value.location)
                            proxy.particleSystem?.attractionStrength = 2
                            isDragging = true
                        }
                        .onEnded { _ in
                            proxy.particleSystem?.attractionStrength = 0
                            isDragging = false
                        }
                )

                stageHint(isDragging ? "Release to clear attraction." : "Drag to attract the flame.")
            }
        }
        .particleStage()
    }
}

private struct FirefliesSurface: View {
    @State private var isDragging = false

    var body: some View {
        VortexViewReader { proxy in
            ZStack(alignment: .top) {
                VortexView(.fireflies.makeUniqueCopy()) {
                    Circle()
                        .fill(.white)
                        .frame(width: 32)
                        .blur(radius: 3)
                        .blendMode(.plusLighter)
                        .tag("circle")
                }
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            proxy.attractTo(value.location)
                            proxy.particleSystem?.attractionStrength = -2
                            isDragging = true
                        }
                        .onEnded { _ in
                            proxy.particleSystem?.attractionStrength = 0
                            isDragging = false
                        }
                )

                stageHint(isDragging ? "Release to clear repulsion." : "Drag to push the fireflies away.")
            }
        }
        .particleStage()
    }
}

private struct FireworksSurface: View {
    var body: some View {
        VortexView(.fireworks.makeUniqueCopy()) {
            Circle()
                .fill(.white)
                .frame(width: 32)
                .blur(radius: 5)
                .blendMode(.plusLighter)
                .tag("circle")
        }
        .particleStage()
    }
}

private struct MagicSurface: View {
    var body: some View {
        VortexView(.magic.makeUniqueCopy()) {
            Image.sparkle
                .blendMode(.plusLighter)
                .tag("sparkle")
        }
        .particleStage()
    }
}

private struct RainSurface: View {
    var body: some View {
        VortexView(.rain.makeUniqueCopy()) {
            Circle()
                .fill(.white)
                .frame(width: 32)
                .tag("circle")
        }
        .particleStage()
    }
}

private struct SmokeSurface: View {
    var body: some View {
        VortexView(.smoke.makeUniqueCopy()) {
            Circle()
                .fill(.white)
                .frame(width: 64)
                .blur(radius: 10)
                .tag("circle")
        }
        .particleStage()
    }
}

private struct SnowSurface: View {
    var body: some View {
        VortexView(.snow.makeUniqueCopy()) {
            Circle()
                .fill(.white)
                .frame(width: 24)
                .blur(radius: 5)
                .tag("circle")
        }
        .particleStage()
    }
}

private struct SparkSurface: View {
    var body: some View {
        VortexView(.spark.makeUniqueCopy()) {
            Circle()
                .fill(.white)
                .frame(width: 16)
                .tag("circle")
        }
        .particleStage()
    }
}

private struct SplashSurface: View {
    var body: some View {
        ZStack {
            VortexView(.rain.makeUniqueCopy()) {
                Circle()
                    .fill(.white)
                    .frame(width: 32)
                    .tag("circle")
            }

            VortexView(.splash.makeUniqueCopy()) {
                Circle()
                    .fill(.white)
                    .frame(width: 16, height: 16)
                    .tag("circle")
            }
        }
        .particleStage()
    }
}

private func stageHint(_ text: String) -> some View {
    Text(text)
        .font(.caption)
        .foregroundStyle(DemoPalette.ink)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(DemoPalette.card.opacity(0.88), in: Capsule())
        .allowsHitTesting(false)
        .padding(.top, 12)
}

extension View {
    fileprivate func particleStage() -> some View {
        frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(DemoPalette.canvas)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .strokeBorder(DemoPalette.stroke, lineWidth: 1)
                    .allowsHitTesting(false)
            }
    }
}
