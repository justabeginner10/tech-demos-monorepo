import Aurora
import SwiftUI

/// One live `AuroraGlow` used as an animated color field, then masked to
/// the host outline so the ring follows a `Capsule` / `RoundedRectangle`.
///
/// Construction (e899411 bloom, layout-stable):
/// 1. Crisp ring — one `AuroraGlow` masked to a thin `strokeBorder`
///    (`Capsule` / `RoundedRectangle`). Width is 3–5pt from Style only.
/// 2. Outer bloom — the same outline stroked with the palette
///    `AngularGradient`, blurred, normal blend, drawn behind the host
///    in a GeometryReader the size of the *padded* wrapper so the blur
///    has room. Padding is a fixed gutter (not Glow size), so the host
///    never shrinks. No `plusLighter` (that washed to white on a light card).
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
            .padding(.horizontal, HaloMetrics.sideInset)
            .padding(.vertical, HaloMetrics.verticalRoom)
            .background {
                if isOn { bloom }
            }
    }

    /// Thin outline. Glow size must not thicken this inward over the text.
    private var ringWidth: CGFloat {
        intensity.ringWidth
    }

    /// Slider 8…80 and Style scale the *outward* blur only. Capped so the
    /// wash dies inside the fixed gutter instead of clipping hard.
    private var bloomRadius: CGFloat {
        let t = HaloMetrics.unit(glowSize)
        let raw = (10 + t * 12) * intensity.bloomScale
        return min(max(raw, 8), HaloMetrics.maxBloomRadius)
    }

    private var bloomOpacity: CGFloat {
        switch intensity {
        case .subtle: 0.55
        case .standard: 0.82
        case .dramatic: 0.95
        }
    }

    private var crispRing: some View {
        GeometryReader { proxy in
            let outline = GlowOutline.make(
                shape: shape,
                radius: hostCornerRadius,
                in: proxy.size
            )
            glow
                .cornerRadius(outline.shaderRadius(in: proxy.size))
                .glowSize(18)
                .borderWidth(ringWidth)
                .mask {
                    outline.strokeMask(lineWidth: ringWidth)
                }
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }

    /// Palette stroke of the *host* size, centered in the padded canvas,
    /// then blurred. Normal blend so colour reads on a white card.
    private var bloom: some View {
        GeometryReader { proxy in
            let hostSize = CGSize(
                width: max(proxy.size.width - HaloMetrics.sideInset * 2, 0),
                height: max(proxy.size.height - HaloMetrics.verticalRoom * 2, 0)
            )
            let outline = GlowOutline.make(
                shape: shape,
                radius: hostCornerRadius,
                in: hostSize
            )
            outline.gradientStroke(
                lineWidth: ringWidth + 2,
                colors: palette.ringColors
            )
            .frame(width: hostSize.width, height: hostSize.height)
            .position(x: proxy.size.width / 2, y: proxy.size.height / 2)
            .blur(radius: bloomRadius)
            .opacity(bloomOpacity)
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

/// Constants that cannot live on generic `AuroraHalo` (no static stored properties).
private enum HaloMetrics {
    /// Fixed side gutter: field stays ~280pt, bloom can fade. Not tied
    /// to Glow size, so the host width never changes.
    static let sideInset: CGFloat = 32
    /// Fixed vertical gutter so the blur dies before the section clip.
    static let verticalRoom: CGFloat = 36
    static let maxBloomRadius: CGFloat = 16

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
        VStack(alignment: .leading, spacing: 8) {
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
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
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
        .frame(maxWidth: .infinity)
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
        VStack(alignment: .leading, spacing: 8) {
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
        .padding(14)
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
