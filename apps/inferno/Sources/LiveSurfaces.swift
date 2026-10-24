import Inferno
import SwiftUI

// MARK: - Glow

/// One color shader. Shimmer, sinebow, and light grid take a clock; infrared is the view modifier.
struct GlowSurface: View {
    private enum Kind: String, CaseIterable, Identifiable {
        case shimmer
        case sinebow
        case lights
        case infrared

        var id: String { rawValue }

        var title: String {
            switch self {
            case .shimmer: "Shimmer"
            case .sinebow: "Sinebow"
            case .lights: "Lights"
            case .infrared: "Infrared"
            }
        }

        var api: String {
            switch self {
            case .shimmer: "InfernoShaderLibrary.shimmer"
            case .sinebow: "InfernoShaderLibrary.sinebow"
            case .lights: "InfernoShaderLibrary.lightGrid"
            case .infrared: "View.infrared()"
            }
        }
    }

    @State private var kind: Kind = .shimmer
    @State private var duration = 3.0
    @State private var gradientWidth = 0.3
    @State private var maxLightness = 0.9
    @State private var density = 8.0
    @State private var speed = 3.0
    @State private var groupSize = 1.0
    @State private var brightness = 3.0

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            controls
            stage
        }
    }

    private var controls: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(kind.title)
                    .font(.headline)
                    .foregroundStyle(DemoPalette.ink)
                Spacer()
                Text(kind.api)
                    .font(.caption2.monospaced())
                    .foregroundStyle(DemoPalette.inkMuted)
                    .lineLimit(1)
            }

            Picker("Effect", selection: $kind) {
                ForEach(Kind.allCases) { item in
                    Text(item.title).tag(item)
                }
            }
            .pickerStyle(.menu)
            .tint(DemoPalette.ink)

            switch kind {
            case .shimmer:
                DemoSlider(title: "Duration", value: $duration, range: 0.4 ... 6)
                DemoSlider(title: "Gradient width", value: $gradientWidth, range: 0.05 ... 0.8)
                DemoSlider(title: "Max lightness", value: $maxLightness, range: 0.2 ... 1)
            case .sinebow:
                Text("Sinebow takes size and time. The clock starts when this effect mounts.")
                    .font(.caption)
                    .foregroundStyle(DemoPalette.inkMuted)
            case .lights:
                DemoSlider(title: "Density", value: $density, range: 2 ... 32, step: 1, format: "%.0f")
                DemoSlider(title: "Speed", value: $speed, range: 1 ... 20)
                DemoSlider(title: "Group size", value: $groupSize, range: 1 ... 8, step: 1, format: "%.0f")
                DemoSlider(title: "Brightness", value: $brightness, range: 0.2 ... 8)
            case .infrared:
                Text("View.infrared() has no parameters. Bright pixels go hot; dark pixels go cold.")
                    .font(.caption)
                    .foregroundStyle(DemoPalette.inkMuted)
            }
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
        switch kind {
        case .shimmer:
            ShimmerStage(duration: duration, gradientWidth: gradientWidth, maxLightness: maxLightness)
        case .sinebow:
            SinebowStage()
        case .lights:
            LightGridStage(density: density, speed: speed, groupSize: groupSize, brightness: brightness)
        case .infrared:
            ShaderPoster()
                .infrared()
                .shaderStage()
        }
    }
}

/// README sample: `visualEffect` + `colorEffect(InfernoShaderLibrary.shimmer(...))`.
private struct ShimmerStage: View {
    var duration: Double
    var gradientWidth: Double
    var maxLightness: Double

    @State private var start = Date.now

    var body: some View {
        let duration = duration
        let gradientWidth = gradientWidth
        let maxLightness = maxLightness
        let start = start
        TimelineView(.animation) { timeline in
            let elapsed = start.distance(to: timeline.date)
            ShaderPoster()
                .visualEffect { content, proxy in
                    content.colorEffect(
                        InfernoShaderLibrary.shimmer(
                            .float2(proxy.size),
                            .float(elapsed),
                            .float(duration),
                            .float(gradientWidth),
                            .float(maxLightness)
                        )
                    )
                }
        }
        .shaderStage()
    }
}

/// README sample: `visualEffect` + `colorEffect(InfernoShaderLibrary.sinebow(...))`.
private struct SinebowStage: View {
    @State private var start = Date.now

    var body: some View {
        let start = start
        TimelineView(.animation) { timeline in
            let elapsed = start.distance(to: timeline.date)
            ShaderPoster()
                .visualEffect { content, proxy in
                    content.colorEffect(
                        InfernoShaderLibrary.sinebow(
                            .float2(proxy.size),
                            .float(elapsed)
                        )
                    )
                }
        }
        .shaderStage()
    }
}

/// README sample: `visualEffect` + `colorEffect(InfernoShaderLibrary.lightGrid(...))`.
private struct LightGridStage: View {
    var density: Double
    var speed: Double
    var groupSize: Double
    var brightness: Double

    @State private var start = Date.now

    var body: some View {
        let density = density
        let speed = speed
        let groupSize = groupSize
        let brightness = brightness
        let start = start
        TimelineView(.animation) { timeline in
            let elapsed = start.distance(to: timeline.date)
            ShaderPoster()
                .visualEffect { content, proxy in
                    content.colorEffect(
                        InfernoShaderLibrary.lightGrid(
                            .float2(proxy.size),
                            .float(elapsed),
                            .float(density),
                            .float(speed),
                            .float(groupSize),
                            .float(brightness)
                        )
                    )
                }
        }
        .shaderStage()
    }
}

// MARK: - Distort

/// One distortion or loupe. Water and wave are `distortionEffect`; the loupe is `layerEffect`.
struct DistortSurface: View {
    private enum Kind: String, CaseIterable, Identifiable {
        case water
        case wave
        case loupe

        var id: String { rawValue }

        var title: String {
            switch self {
            case .water: "Water"
            case .wave: "Wave"
            case .loupe: "Loupe"
            }
        }
    }

    private enum LoupeKind: String, CaseIterable, Identifiable {
        case simple
        case warping

        var id: String { rawValue }

        var title: String {
            switch self {
            case .simple: "Simple"
            case .warping: "Warp"
            }
        }
    }

    @State private var kind: Kind = .water
    @State private var loupe: LoupeKind = .simple
    @State private var waterSpeed = 3.0
    @State private var waterStrength = 3.0
    @State private var waterFrequency = 10.0
    @State private var waveSpeed = 5.0
    @State private var waveSmoothing = 10.0
    @State private var waveStrength = 5.0
    @State private var maxDistance = 0.05
    @State private var zoom = 2.0

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            controls
            stage
        }
    }

    private var controls: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(kind.title)
                    .font(.headline)
                    .foregroundStyle(DemoPalette.ink)
                Spacer()
                Text(apiCaption)
                    .font(.caption2.monospaced())
                    .foregroundStyle(DemoPalette.inkMuted)
                    .lineLimit(1)
            }

            Picker("Effect", selection: $kind) {
                ForEach(Kind.allCases) { item in
                    Text(item.title).tag(item)
                }
            }
            .pickerStyle(.segmented)

            switch kind {
            case .water:
                DemoSlider(title: "Speed", value: $waterSpeed, range: 0.5 ... 10)
                DemoSlider(title: "Strength", value: $waterStrength, range: 1 ... 5)
                DemoSlider(title: "Frequency", value: $waterFrequency, range: 5 ... 25)
            case .wave:
                DemoSlider(title: "Speed", value: $waveSpeed, range: 1 ... 12)
                DemoSlider(title: "Smoothing", value: $waveSmoothing, range: 1 ... 30)
                DemoSlider(title: "Strength", value: $waveStrength, range: 1 ... 12)
            case .loupe:
                Picker("Loupe", selection: $loupe) {
                    ForEach(LoupeKind.allCases) { item in
                        Text(item.title).tag(item)
                    }
                }
                .pickerStyle(.segmented)

                DemoSlider(title: "Radius", value: $maxDistance, range: 0.02 ... 0.2)
                DemoSlider(title: "Zoom", value: $zoom, range: 1 ... 4)
                Text("Drag the poster. maxDistance starts at 0.05, zoom at 2, matching the README.")
                    .font(.caption)
                    .foregroundStyle(DemoPalette.inkMuted)
            }
        }
        .padding(14)
        .background(DemoPalette.card, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(DemoPalette.stroke, lineWidth: 1)
        }
    }

    private var apiCaption: String {
        switch kind {
        case .water: "InfernoShaderLibrary.water"
        case .wave: "InfernoShaderLibrary.wave"
        case .loupe:
            loupe == .simple ? "simpleLoupe" : "warpingLoupe"
        }
    }

    @ViewBuilder
    private var stage: some View {
        switch kind {
        case .water:
            WaterStage(speed: waterSpeed, strength: waterStrength, frequency: waterFrequency)
        case .wave:
            WaveStage(speed: waveSpeed, smoothing: waveSmoothing, strength: waveStrength)
        case .loupe:
            LoupeStage(warping: loupe == .warping, maxDistance: maxDistance, zoom: zoom)
        }
    }
}

private struct WaterStage: View {
    var speed: Double
    var strength: Double
    var frequency: Double

    @State private var start = Date.now

    var body: some View {
        let speed = speed
        let strength = strength
        let frequency = frequency
        let start = start
        TimelineView(.animation) { timeline in
            let elapsed = start.distance(to: timeline.date)
            ShaderPoster()
                .drawingGroup()
                .visualEffect { content, proxy in
                    content.distortionEffect(
                        InfernoShaderLibrary.water(
                            .float2(proxy.size),
                            .float(elapsed),
                            .float(speed),
                            .float(strength),
                            .float(frequency)
                        ),
                        maxSampleOffset: .zero
                    )
                }
        }
        .shaderStage()
    }
}

private struct WaveStage: View {
    var speed: Double
    var smoothing: Double
    var strength: Double

    @State private var start = Date.now

    var body: some View {
        let speed = speed
        let smoothing = smoothing
        let strength = strength
        let start = start
        TimelineView(.animation) { timeline in
            let elapsed = start.distance(to: timeline.date)
            ShaderPoster()
                .drawingGroup()
                .distortionEffect(
                    InfernoShaderLibrary.wave(
                        .float(elapsed),
                        .float(speed),
                        .float(smoothing),
                        .float(strength)
                    ),
                    maxSampleOffset: .zero
                )
        }
        .shaderStage()
    }
}

private struct LoupeStage: View {
    var warping: Bool
    var maxDistance: Double
    var zoom: Double

    @State private var touch = CGPoint(x: 180, y: 200)
    @State private var placed = false

    var body: some View {
        let warping = warping
        let touch = touch
        let maxDistance = maxDistance
        let zoom = zoom
        ShaderPoster()
            .drawingGroup()
            .visualEffect { content, proxy in
                content.layerEffect(
                    warping
                        ? InfernoShaderLibrary.warpingLoupe(
                            .float2(proxy.size),
                            .float2(touch),
                            .float(maxDistance),
                            .float(zoom)
                        )
                        : InfernoShaderLibrary.simpleLoupe(
                            .float2(proxy.size),
                            .float2(touch),
                            .float(maxDistance),
                            .float(zoom)
                        ),
                    maxSampleOffset: .zero
                )
            }
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { self.touch = $0.location }
            )
            .background {
                GeometryReader { proxy in
                    Color.clear
                        .onAppear { placeIfNeeded(proxy.size) }
                        .onChange(of: proxy.size) { _, newSize in
                            placeIfNeeded(newSize)
                        }
                }
            }
            .shaderStage()
    }

    private func placeIfNeeded(_ size: CGSize) {
        guard !placed, size.width > 1, size.height > 1 else { return }
        placed = true
        touch = CGPoint(x: size.width / 2, y: size.height / 2)
    }
}

// MARK: - Transition

/// One package `AnyTransition`. The shader runs only while the insertion or removal animates.
struct TransitionSurface: View {
    private enum Kind: String, CaseIterable, Identifiable {
        case circles
        case swirl
        case pixellate
        case wind

        var id: String { rawValue }

        var title: String {
            switch self {
            case .circles: "Circles"
            case .swirl: "Swirl"
            case .pixellate: "Pixels"
            case .wind: "Wind"
            }
        }

        var api: String {
            switch self {
            case .circles: ".circles(size:)"
            case .swirl: ".swirl(radius:)"
            case .pixellate: ".pixellate(squares:steps:)"
            case .wind: ".wind(size:)"
            }
        }
    }

    @State private var kind: Kind = .circles
    @State private var shown = true
    @State private var circleSize = 20.0
    @State private var swirlRadius = 0.5
    @State private var squares = 20.0
    @State private var steps = 60.0
    @State private var windSize = 0.2

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            controls
            ZStack {
                if shown {
                    ShaderPoster()
                        .transition(activeTransition)
                }
            }
            .shaderStage()
        }
    }

    private var controls: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(kind.title)
                    .font(.headline)
                    .foregroundStyle(DemoPalette.ink)
                Spacer()
                Text(kind.api)
                    .font(.caption2.monospaced())
                    .foregroundStyle(DemoPalette.inkMuted)
            }

            Picker("Transition", selection: $kind) {
                ForEach(Kind.allCases) { item in
                    Text(item.title).tag(item)
                }
            }
            .pickerStyle(.segmented)

            switch kind {
            case .circles:
                DemoSlider(title: "Circle size", value: $circleSize, range: 8 ... 48, step: 1, format: "%.0f")
            case .swirl:
                DemoSlider(title: "Radius", value: $swirlRadius, range: 0.1 ... 1)
            case .pixellate:
                DemoSlider(title: "Squares", value: $squares, range: 4 ... 40, step: 1, format: "%.0f")
                DemoSlider(title: "Steps", value: $steps, range: 4 ... 60, step: 1, format: "%.0f")
            case .wind:
                DemoSlider(title: "Streak size", value: $windSize, range: 0.05 ... 0.6)
            }

            Button(shown ? "Hide" : "Reveal") {
                withAnimation(.easeInOut(duration: 1.2)) {
                    shown.toggle()
                }
            }
            .buttonStyle(.borderedProminent)
            .tint(DemoPalette.accent)
            .foregroundStyle(Color.black)

            Text(caption)
                .font(.caption)
                .foregroundStyle(DemoPalette.inkMuted)
        }
        .padding(14)
        .background(DemoPalette.card, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(DemoPalette.stroke, lineWidth: 1)
        }
    }

    private var activeTransition: AnyTransition {
        switch kind {
        case .circles:
            .circles(size: circleSize)
        case .swirl:
            .swirl(radius: swirlRadius)
        case .pixellate:
            .pixellate(squares: squares, steps: steps)
        case .wind:
            .wind(size: windSize)
        }
    }

    private var caption: String {
        switch kind {
        case .circles, .wind:
            "The package animates insertion. Hide, then Reveal, to run the shader again."
        case .swirl, .pixellate:
            "Insertion and removal both run the shader. Hide and Reveal play it each way."
        }
    }
}
