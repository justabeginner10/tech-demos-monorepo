import Aurora
import SwiftUI

/// One live `AuroraGlow` used as an animated color field, then masked to
/// the host outline so the ring follows a `Capsule` / `RoundedRectangle`
/// the way the painted Gallery tiles do.
///
/// Aurora's SDF lights a square canvas, so the Metal view is never shown
/// raw. Construction:
/// 1. Crisp ring — one `AuroraGlow` is `.mask`'d to
///    `shape.strokeBorder` (`Capsule` / `RoundedRectangle`).
/// 2. Outer bloom — a non-Metal palette stroke, blurred and shadowed
///    *behind* the host. It does not pad the host (padding stole width
///    and crushed the field). Blur/shadow paint outside the layout
///    box; the section card clips overflow.
/// Glow size and Style scale ring width and bloom, not the host size.
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
            .background {
                if isOn {
                    // Color.clear keeps the layout box equal to the host.
                    // Blur/shadow paint in the overlay and must not pad.
                    Color.clear
                        .overlay { bloom }
                }
            }
            // Fixed gutters so the default bloom has room to fade. Not
            // tied to Glow size / Style, so the host width never changes.
            .padding(.vertical, HaloMetrics.verticalRoom)
    }

    /// Slider 8…80 → stroke 4…11pt, times Style.
    private var ringWidth: CGFloat {
        let t = HaloMetrics.unit(glowSize)
        return (4 + t * 7) * intensity.ringScale
    }

    /// Slider 8…80 → blur 14…22pt, times Style, hard-capped so max Glow
    /// cannot inflate layout. Default is already a wide Apple-like wash.
    private var bloomRadius: CGFloat {
        let t = HaloMetrics.unit(glowSize)
        return min((14 + t * 8) * intensity.bloomScale, 22)
    }

    private var bloomOpacity: CGFloat {
        switch intensity {
        case .subtle: 0.72
        case .standard: 0.95
        case .dramatic: 1.0
        }
    }

    private var bloomLead: Color {
        palette.swatchColors.first ?? palette.baseColor
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

    /// Sized to the host. Blur and shadow draw outside the layout box
    /// and do not change the proposed width/height.
    private var bloom: some View {
        let width = ringWidth + 5
        return ZStack {
            bloomStroke(lineWidth: width)
                .blur(radius: bloomRadius)
                .opacity(0.7)
            bloomStroke(lineWidth: width - 2)
                .blur(radius: max(bloomRadius * 0.4, 4))
                .shadow(color: bloomLead.opacity(0.65), radius: 10)
                .shadow(color: bloomLead.opacity(0.4), radius: 18)
        }
        .opacity(bloomOpacity)
        .blendMode(.plusLighter)
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }

    @ViewBuilder
    private func bloomStroke(lineWidth: CGFloat) -> some View {
        switch shape {
        case .capsule:
            Capsule().strokeBorder(
                AngularGradient(colors: palette.ringColors, center: .center),
                lineWidth: lineWidth
            )
        case .rectangle, .rounded:
            RoundedRectangle(cornerRadius: hostCornerRadius, style: .continuous)
                .strokeBorder(
                    AngularGradient(colors: palette.ringColors, center: .center),
                    lineWidth: lineWidth
                )
        }
    }
}

/// Constants that cannot live on generic `AuroraHalo` (no static stored properties).
private enum HaloMetrics {
    /// Vertical room inside the section card. Horizontal overflow is
    /// clipped by the card; 16pt of card padding is enough to avoid a
    /// hard edge at Standard/Dramatic.
    static let verticalRoom: CGFloat = 28

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
