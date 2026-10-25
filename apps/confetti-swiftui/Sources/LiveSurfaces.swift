import ConfettiSwiftUI
import SwiftUI

// MARK: - Cannon

/// Package defaults from `confettiCannon` in ConfettiSwiftUI 3.0.0.
private enum CannonDefaults {
    static let count = 20.0
    static let size = 10.0
    static let radius = 300.0
    static let opening = 60.0
    static let closing = 120.0
    static let rain = 600.0
    static let repetitions = 1.0
    static let interval = 1.0
    static let opacity = 1.0
}

/// Arguments for one `.confettiCannon`. `token` is the view identity.
/// The cannon copies these into an internal config inside its initializer, so a new
/// token replaces the view instead of editing a burst that is already on screen.
private struct CannonRequest {
    var token: String
    var num: Int
    var confettis: [ConfettiType]
    var colors: [Color]
    var confettiSize: CGFloat
    var rainHeight: CGFloat
    var fadesOut: Bool
    var opacity: Double
    var openingAngle: Angle
    var closingAngle: Angle
    var radius: CGFloat
    var repetitions: Int
    var repetitionInterval: Double
    var hapticFeedback: Bool
    var caption: String
}

/// Stage the modifier is attached to. The burst origin is the center of this view.
private struct CannonStage: View {
    @Binding var trigger: Int
    var request: CannonRequest

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(DemoPalette.canvas)

            Circle()
                .fill(DemoPalette.ink.opacity(0.45))
                .frame(width: 8, height: 8)
                .allowsHitTesting(false)

            Text(request.caption)
                .font(.caption)
                .foregroundStyle(DemoPalette.ink)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(DemoPalette.card.opacity(0.88), in: Capsule())
                .padding(.top, 12)
                .frame(maxHeight: .infinity, alignment: .top)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 340)
        .overlay {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(DemoPalette.stroke, lineWidth: 1)
                .allowsHitTesting(false)
        }
        .confettiCannon(
            trigger: $trigger,
            num: max(request.num, 1),
            confettis: request.confettis.isEmpty ? ConfettiType.allCases : request.confettis,
            colors: request.colors.isEmpty ? BurstPalette.spectrum.colors : request.colors,
            confettiSize: request.confettiSize,
            rainHeight: request.rainHeight,
            fadesOut: request.fadesOut,
            opacity: request.opacity,
            openingAngle: request.openingAngle,
            closingAngle: request.closingAngle,
            radius: request.radius,
            repetitions: request.repetitions,
            repetitionInterval: request.repetitionInterval,
            hapticFeedback: request.hapticFeedback
        )
        .id(request.token)
    }
}

private func pieces(for set: PieceSet) -> [ConfettiType] {
    switch set {
    case .shapes:
        ConfettiType.allCases
    case .circles:
        [.shape(.circle)]
    case .triangles:
        [.shape(.triangle)]
    case .squares:
        [.shape(.square)]
    case .ribbons:
        [.shape(.slimRectangle)]
    case .crosses:
        [.shape(.roundedCross)]
    case .emoji:
        [.text("🎉"), .text("✨"), .text("🎊")]
    case .letters:
        [.text("A"), .text("B"), .text("C")]
    case .symbols:
        [
            .sfSymbol(symbolName: "star.fill"),
            .sfSymbol(symbolName: "heart.fill"),
            .sfSymbol(symbolName: "party.popper"),
        ]
    }
}

// MARK: - Burst

/// Full knob set. Starts on the package defaults, including the five shapes.
struct BurstSurface: View {
    @State private var trigger = 0
    @State private var palette: BurstPalette = .spectrum
    @State private var count = CannonDefaults.count
    @State private var size = CannonDefaults.size
    @State private var radius = CannonDefaults.radius
    @State private var opening = CannonDefaults.opening
    @State private var closing = CannonDefaults.closing
    @State private var rain = CannonDefaults.rain
    @State private var repetitions = CannonDefaults.repetitions
    @State private var interval = CannonDefaults.interval
    @State private var opacity = CannonDefaults.opacity
    @State private var fadesOut = true
    @State private var haptics = true

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            header
            VStack(alignment: .leading, spacing: 0) {
                VStack(alignment: .leading, spacing: 10) {
                    DemoSlider(title: "Count", value: $count, range: 1 ... 60, step: 1, format: "%.0f")
                    DemoSlider(title: "Size", value: $size, range: 6 ... 36, step: 1, format: "%.0f")
                    DemoSlider(title: "Radius", value: $radius, range: 40 ... 360, step: 10, format: "%.0f")
                    DemoSlider(title: "Opening °", value: $opening, range: 0 ... 360, step: 5, format: "%.0f")
                    DemoSlider(title: "Closing °", value: $closing, range: 0 ... 360, step: 5, format: "%.0f")
                    DemoSlider(title: "Rain height", value: $rain, range: 0 ... 800, step: 20, format: "%.0f")
                    DemoSlider(title: "Repetitions", value: $repetitions, range: 1 ... 6, step: 1, format: "%.0f")
                    DemoSlider(title: "Interval", value: $interval, range: 0.1 ... 2, step: 0.1, format: "%.1f")
                    DemoSlider(title: "Opacity", value: $opacity, range: 0.15 ... 1, step: 0.05, format: "%.2f")
                    Toggle("Fade out", isOn: $fadesOut)
                        .font(.subheadline)
                        .foregroundStyle(DemoPalette.ink)
                        .tint(DemoPalette.accent)
                    Toggle("Haptics", isOn: $haptics)
                        .font(.subheadline)
                        .foregroundStyle(DemoPalette.ink)
                        .tint(DemoPalette.accent)
                }
            }
            .demoCard()

            CannonStage(trigger: $trigger, request: request)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Defaults")
                    .font(.headline)
                    .foregroundStyle(DemoPalette.ink)
                Spacer()
                Text("trigger \(trigger)")
                    .font(.caption.monospaced())
                    .foregroundStyle(DemoPalette.inkMuted)
            }

            Picker("Palette", selection: $palette) {
                ForEach(BurstPalette.allCases) { item in
                    Text(item.title).tag(item)
                }
            }
            .pickerStyle(.menu)
            .tint(DemoPalette.ink)

            HStack(spacing: 10) {
                Button("Burst") {
                    trigger += 1
                }
                .buttonStyle(.borderedProminent)
                .tint(DemoPalette.accent)
                .foregroundStyle(Color.black)

                Button("Reset") {
                    palette = .spectrum
                    count = CannonDefaults.count
                    size = CannonDefaults.size
                    radius = CannonDefaults.radius
                    opening = CannonDefaults.opening
                    closing = CannonDefaults.closing
                    rain = CannonDefaults.rain
                    repetitions = CannonDefaults.repetitions
                    interval = CannonDefaults.interval
                    opacity = CannonDefaults.opacity
                    fadesOut = true
                    haptics = true
                }
                .buttonStyle(.bordered)
                .tint(DemoPalette.ink)
            }

            Text(
                "Shapes are ConfettiType.allCases. Spectrum is the package color list. "
                    + "Poster is red and white so both colors stay visible on this page. "
                    + "The README color sample uses red and black."
            )
            .font(.caption)
            .foregroundStyle(DemoPalette.inkMuted)
            .fixedSize(horizontal: false, vertical: true)
        }
        .demoCard()
    }

    private var request: CannonRequest {
        let count = Int(count)
        let repetitions = Int(repetitions)
        let token = [
            palette.rawValue,
            "\(count)",
            "\(Int(size))",
            "\(Int(radius))",
            "\(Int(opening))",
            "\(Int(closing))",
            "\(Int(rain))",
            "\(repetitions)",
            String(format: "%.1f", interval),
            String(format: "%.2f", opacity),
            fadesOut ? "fade" : "hold",
            haptics ? "haptic" : "quiet",
        ].joined(separator: "-")

        return CannonRequest(
            token: token,
            num: count,
            confettis: ConfettiType.allCases,
            colors: palette.colors,
            confettiSize: CGFloat(size),
            rainHeight: CGFloat(rain),
            fadesOut: fadesOut,
            opacity: opacity,
            openingAngle: .degrees(opening),
            closingAngle: .degrees(closing),
            radius: CGFloat(radius),
            repetitions: repetitions,
            repetitionInterval: interval,
            hapticFeedback: haptics,
            caption: "Origin is the dot. 0° is right, 90° is up."
        )
    }
}

// MARK: - Pieces

/// One piece set at a time. Angles stay on the default upward wedge.
struct PiecesSurface: View {
    @State private var trigger = 0
    @State private var set: PieceSet = .shapes
    @State private var palette: BurstPalette = .spectrum
    @State private var count = 24.0
    @State private var size = 18.0

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            header
            CannonStage(trigger: $trigger, request: request)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(set.title)
                    .font(.headline)
                    .foregroundStyle(DemoPalette.ink)
                Spacer()
                Text(set.api)
                    .font(.caption2.monospaced())
                    .foregroundStyle(DemoPalette.inkMuted)
                    .lineLimit(1)
            }

            Picker("Pieces", selection: $set) {
                ForEach(PieceSet.allCases) { item in
                    Text(item.title).tag(item)
                }
            }
            .pickerStyle(.menu)
            .tint(DemoPalette.ink)

            Picker("Palette", selection: $palette) {
                ForEach(BurstPalette.allCases) { item in
                    Text(item.title).tag(item)
                }
            }
            .pickerStyle(.segmented)

            DemoSlider(title: "Count", value: $count, range: 1 ... 60, step: 1, format: "%.0f")
            DemoSlider(title: "Size", value: $size, range: 8 ... 36, step: 1, format: "%.0f")

            Text(set.summary)
                .font(.caption)
                .foregroundStyle(DemoPalette.inkMuted)
                .fixedSize(horizontal: false, vertical: true)

            HStack {
                Button("Burst") {
                    trigger += 1
                }
                .buttonStyle(.borderedProminent)
                .tint(DemoPalette.accent)
                .foregroundStyle(Color.black)
                Spacer()
                Text("trigger \(trigger)")
                    .font(.caption.monospaced())
                    .foregroundStyle(DemoPalette.inkMuted)
            }
        }
        .demoCard()
    }

    private var request: CannonRequest {
        let count = Int(count)
        let token = [
            set.rawValue,
            palette.rawValue,
            "\(count)",
            "\(Int(size))",
        ].joined(separator: "-")

        return CannonRequest(
            token: token,
            num: count,
            confettis: pieces(for: set),
            colors: palette.colors,
            confettiSize: CGFloat(size),
            rainHeight: CGFloat(CannonDefaults.rain),
            fadesOut: true,
            opacity: 1,
            openingAngle: .degrees(CannonDefaults.opening),
            closingAngle: .degrees(CannonDefaults.closing),
            radius: CGFloat(CannonDefaults.radius),
            repetitions: 1,
            repetitionInterval: 1,
            hapticFeedback: true,
            caption: "Default wedge, 60° to 120°."
        )
    }
}

// MARK: - Recipes

/// The four README configurations, one cannon at a time.
struct RecipesSurface: View {
    @State private var trigger = 0
    @State private var recipe: CannonRecipe = .firework

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            header
            CannonStage(trigger: $trigger, request: request)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(recipe.title)
                    .font(.headline)
                    .foregroundStyle(DemoPalette.ink)
                Spacer()
                Text("trigger \(trigger)")
                    .font(.caption.monospaced())
                    .foregroundStyle(DemoPalette.inkMuted)
            }

            Picker("Recipe", selection: $recipe) {
                ForEach(CannonRecipe.allCases) { item in
                    Text(item.title).tag(item)
                }
            }
            .pickerStyle(.segmented)

            Text(recipe.summary)
                .font(.caption)
                .foregroundStyle(DemoPalette.inkMuted)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 6) {
                ForEach(recipe.chips, id: \.self) { label in
                    DemoChrome.chip(label)
                }
            }

            Button("Burst") {
                trigger += 1
            }
            .buttonStyle(.borderedProminent)
            .tint(DemoPalette.accent)
            .foregroundStyle(Color.black)
        }
        .demoCard()
    }

    private var request: CannonRequest {
        switch recipe {
        case .firework:
            recipeRequest(
                token: "firework",
                num: 50,
                confettis: ConfettiType.allCases,
                colors: BurstPalette.spectrum.colors,
                confettiSize: 10,
                rainHeight: 600,
                opening: .degrees(0),
                closing: .degrees(360),
                radius: 200,
                repetitions: 1,
                repetitionInterval: 1,
                hapticFeedback: true,
                caption: "Full circle. Radius 200."
            )
        case .hearts:
            recipeRequest(
                token: "hearts",
                num: 20,
                confettis: [.text("❤️"), .text("💙"), .text("💚"), .text("🧡")],
                colors: BurstPalette.spectrum.colors,
                confettiSize: 10,
                rainHeight: 600,
                opening: .degrees(60),
                closing: .degrees(120),
                radius: 300,
                repetitions: 1,
                repetitionInterval: 1,
                hapticFeedback: true,
                caption: "Four .text values. Default wedge."
            )
        case .rain:
            recipeRequest(
                token: "rain",
                num: 1,
                confettis: [.text("💵"), .text("💶"), .text("💷"), .text("💴")],
                colors: BurstPalette.spectrum.colors,
                confettiSize: 30,
                rainHeight: 600,
                opening: .degrees(60),
                closing: .degrees(120),
                radius: 300,
                repetitions: 50,
                repetitionInterval: 0.1,
                hapticFeedback: false,
                caption: "One piece, fifty times. Haptics off."
            )
        case .repeatBurst:
            recipeRequest(
                token: "repeat",
                num: 20,
                confettis: ConfettiType.allCases,
                colors: BurstPalette.spectrum.colors,
                confettiSize: 10,
                rainHeight: 600,
                opening: .degrees(60),
                closing: .degrees(120),
                radius: 300,
                repetitions: 3,
                repetitionInterval: 0.7,
                hapticFeedback: true,
                caption: "Three bursts, 0.7 s apart."
            )
        }
    }

    private func recipeRequest(
        token: String,
        num: Int,
        confettis: [ConfettiType],
        colors: [Color],
        confettiSize: CGFloat,
        rainHeight: CGFloat,
        opening: Angle,
        closing: Angle,
        radius: CGFloat,
        repetitions: Int,
        repetitionInterval: Double,
        hapticFeedback: Bool,
        caption: String
    ) -> CannonRequest {
        CannonRequest(
            token: token,
            num: num,
            confettis: confettis,
            colors: colors,
            confettiSize: confettiSize,
            rainHeight: rainHeight,
            fadesOut: true,
            opacity: 1,
            openingAngle: opening,
            closingAngle: closing,
            radius: radius,
            repetitions: repetitions,
            repetitionInterval: repetitionInterval,
            hapticFeedback: hapticFeedback,
            caption: caption
        )
    }
}
