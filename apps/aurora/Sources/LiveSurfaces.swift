import Aurora
import SwiftUI

/// One live `AuroraGlow` used as an animated color field, then masked to
/// the host outline so the ring follows a `Capsule` / `RoundedRectangle`
/// the way the painted Gallery tiles do.
///
/// Aurora's SDF lights a square canvas (and the short prompt fills that
/// canvas), so the Metal view is never shown raw. Construction:
/// 1. Crisp ring — the single `AuroraGlow` is `.mask`'d to
///    `shape.strokeBorder(lineWidth:)` (`Capsule` or `RoundedRectangle`).
/// 2. Outer bloom — a non-Metal copy of that same stroke (palette
///    `AngularGradient`) is `.blur`'d and drawn *behind* the host. The
///    wrapper is padded by ~2.2× the blur radius so the halo fades to
///    zero before any rectangular frame edge.
/// Glow size and Style scale the stroke width and the blur; they are not
/// capped into a 14pt shader band.
struct AuroraHalo<Content: View>: View {
    var isOn: Bool
    var glow: AuroraGlow
    var shape: GlowShape
    var hostCornerRadius: CGFloat
    var glowSize: CGFloat
    var intensity: GlowIntensity
    var palette: GlowPaletteChoice
    var content: Content

    init(
        isOn: Bool,
        glow: AuroraGlow,
        shape: GlowShape,
        hostCornerRadius: CGFloat,
        glowSize: CGFloat,
        intensity: GlowIntensity,
        palette: GlowPaletteChoice,
        @ViewBuilder content: () -> Content
    ) {
        self.isOn = isOn
        self.glow = glow
        self.shape = shape
        self.hostCornerRadius = hostCornerRadius
        self.glowSize = glowSize
        self.intensity = intensity
        self.palette = palette
        self.content = content()
    }

    var body: some View {
        content
            .overlay {
                if isOn { crispRing }
            }
            .padding(haloPad)
            .background {
                if isOn { bloom }
            }
    }

    /// Pad first so the bloom's GeometryReader is larger than the host.
    /// Blur then dies out before that padded frame, not on a square clip.
    private var haloPad: CGFloat {
        isOn ? bloomPad : 16
    }

    /// Slider 8…80 → stroke 3…12pt, times Style. Capped so a 50pt field
    /// still has a hole in the middle.
    private var ringWidth: CGFloat {
        let t = Self.unit(glowSize)
        return (3 + t * 9) * intensity.ringScale
    }

    /// Slider 8…80 → blur 8…32pt, times Style.
    private var bloomRadius: CGFloat {
        let t = Self.unit(glowSize)
        return (8 + t * 24) * intensity.bloomScale
    }

    /// Layout padding so the blur reaches ~0 before the wrapper edge.
    private var bloomPad: CGFloat {
        bloomRadius * 2.2 + 8
    }

    private var bloomOpacity: CGFloat {
        switch intensity {
        case .subtle: 0.55
        case .standard: 0.78
        case .dramatic: 0.92
        }
    }

    private var crispRing: some View {
        GeometryReader { proxy in
            let outline = GlowOutline.make(
                shape: shape,
                radius: hostCornerRadius,
                in: proxy.size
            )
            let width = min(ringWidth, min(proxy.size.width, proxy.size.height) * 0.35)
            glow
                .cornerRadius(outline.shaderRadius(in: proxy.size))
                .glowSize(glowSize)
                .borderWidth(width)
                .mask {
                    outline.strokeMask(lineWidth: width)
                }
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }

    private var bloom: some View {
        GeometryReader { proxy in
            let hostSize = CGSize(
                width: max(proxy.size.width - bloomPad * 2, 0),
                height: max(proxy.size.height - bloomPad * 2, 0)
            )
            let outline = GlowOutline.make(
                shape: shape,
                radius: hostCornerRadius,
                in: hostSize
            )
            let width = min(ringWidth, min(hostSize.width, hostSize.height) * 0.35)
            outline.gradientStroke(lineWidth: width + 2, colors: palette.ringColors)
                .frame(width: hostSize.width, height: hostSize.height)
                .position(x: proxy.size.width / 2, y: proxy.size.height / 2)
                .blur(radius: bloomRadius)
                .opacity(bloomOpacity)
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }

    static func unit(_ glowSize: CGFloat) -> CGFloat {
        min(max((glowSize - 8) / 72, 0), 1)
    }
}

/// Capsule vs continuous rounded rect — same outline for host fill, Metal
/// mask, and bloom stroke.
enum GlowOutline {
    case capsule
    case rounded(CGFloat)

    static func make(shape: GlowShape, radius: CGFloat, in size: CGSize) -> GlowOutline {
        let limit = min(size.width, size.height) / 2
        let clamped = min(max(radius, 0), max(limit, 0))
        if shape == .capsule || (limit > 0 && clamped >= limit - 0.5) {
            return .capsule
        }
        return .rounded(clamped)
    }

    func shaderRadius(in size: CGSize) -> CGFloat {
        switch self {
        case .capsule:
            min(size.width, size.height) / 2
        case .rounded(let radius):
            radius
        }
    }

    @ViewBuilder
    func strokeMask(lineWidth: CGFloat) -> some View {
        switch self {
        case .capsule:
            Capsule().strokeBorder(Color.white, lineWidth: lineWidth)
        case .rounded(let radius):
            RoundedRectangle(cornerRadius: radius, style: .continuous)
                .strokeBorder(Color.white, lineWidth: lineWidth)
        }
    }

    @ViewBuilder
    func gradientStroke(lineWidth: CGFloat, colors: [Color]) -> some View {
        switch self {
        case .capsule:
            Capsule().strokeBorder(
                AngularGradient(colors: colors, center: .center),
                lineWidth: lineWidth
            )
        case .rounded(let radius):
            RoundedRectangle(cornerRadius: radius, style: .continuous)
                .strokeBorder(
                    AngularGradient(colors: colors, center: .center),
                    lineWidth: lineWidth
                )
        }
    }
}

/// Single host + optional masked `AuroraGlow`. Switching Prompt/Card
/// restyles this overlay — it does not add a second Metal surface.
struct LiveGlowSurface: View {
    var settings: LiveGlowSettings
    @Binding var promptText: String
    var burster: AuroraGlow.Burster

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                Text(settings.target.title)
                    .font(.headline)
                    .foregroundStyle(DemoPalette.ink)
                Spacer()
                Text(settings.target.subtitle)
                    .font(.caption)
                    .foregroundStyle(DemoPalette.inkMuted)
            }

            AuroraHalo(
                isOn: settings.isGlowOn,
                glow: configuredGlow,
                shape: settings.shape,
                hostCornerRadius: settings.cornerRadius,
                glowSize: settings.glowSize,
                intensity: settings.intensity,
                palette: settings.palette
            ) {
                host
            }
            .frame(maxWidth: .infinity)
        }
        .padding(14)
        .background(DemoPalette.card, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(DemoPalette.stroke, lineWidth: 1)
                .allowsHitTesting(false)
        }
    }

    private var configuredGlow: AuroraGlow {
        AuroraGlow(settings.intensity.style)
            .palette(settings.palette.palette)
            .speed(settings.speed)
            .burster(burster)
    }

    @ViewBuilder
    private var host: some View {
        switch settings.target {
        case .prompt:
            PromptHost(
                text: $promptText,
                shape: settings.shape,
                cornerRadius: settings.cornerRadius,
                onSubmit: { burster.fire() }
            )
        case .card:
            CardHost(
                shape: settings.shape,
                cornerRadius: settings.cornerRadius,
                palette: settings.palette
            )
        }
    }
}

struct PromptHost: View {
    @Binding var text: String
    var shape: GlowShape
    var cornerRadius: CGFloat
    var onSubmit: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "sparkles")
                .font(.body.weight(.semibold))
                .foregroundStyle(DemoPalette.accent)
                .accessibilityHidden(true)

            TextField("Ask anything", text: $text)
                .textFieldStyle(.plain)
                .foregroundStyle(DemoPalette.ink)
                .submitLabel(.send)
                .onSubmit(onSubmit)

            Image(systemName: "microphone.fill")
                .font(.body)
                .foregroundStyle(DemoPalette.inkMuted)
                .accessibilityHidden(true)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background { HostChrome(shape: shape, cornerRadius: cornerRadius) }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Siri-style prompt")
    }
}

struct CardHost: View {
    var shape: GlowShape
    var cornerRadius: CGFloat
    var palette: GlowPaletteChoice

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("AURORA")
                .font(.caption.weight(.semibold).monospaced())
                .tracking(1.6)
                .foregroundStyle(palette.baseColor)

            Text("Apple Intelligence glow")
                .font(.title3.weight(.semibold))
                .foregroundStyle(DemoPalette.ink)

            Text("One Metal ring. Palette, speed, and style restyle this card — they do not stack another shader.")
                .font(.subheadline)
                .foregroundStyle(DemoPalette.inkMuted)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 8) {
                DemoChrome.chip("AuroraGlow")
                DemoChrome.chip(".glow")
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background { HostChrome(shape: shape, cornerRadius: cornerRadius) }
    }
}

/// Fill + hairline using the same Capsule / rounded rect as the glow mask.
private struct HostChrome: View {
    var shape: GlowShape
    var cornerRadius: CGFloat

    var body: some View {
        Group {
            switch shape {
            case .capsule:
                Capsule()
                    .fill(DemoPalette.canvas)
                    .overlay {
                        Capsule().strokeBorder(DemoPalette.stroke, lineWidth: 1)
                    }
            case .rectangle, .rounded:
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(DemoPalette.canvas)
                    .overlay {
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .strokeBorder(DemoPalette.stroke, lineWidth: 1)
                    }
            }
        }
        .allowsHitTesting(false)
    }
}

extension GlowPaletteChoice {
    var ringColors: [Color] {
        let colors = swatchColors
        guard let first = colors.first else { return [baseColor] }
        return colors + [first]
    }
}
