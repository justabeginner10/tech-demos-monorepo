import Aurora
import SwiftUI

/// Inner-edge `AuroraGlow` on the host itself — the package's wrap-a-view
/// recipe (`View.glow(_:)`, same as `GlowCard` in Aurora's sources).
///
/// The Metal SDF is the host's bounds. The ring sits on that outline and
/// falls inward; the shader never draws outside the canvas. Padding the
/// host first would only move the ring onto the padded rectangle and
/// slice it there. Radius is `min(requested, half the short side)` so a
/// capsule is `height/2`. Glow size is capped so the band cannot fill
/// the interior.
struct AuroraHalo<Content: View>: View {
    var isOn: Bool
    var glow: AuroraGlow
    var hostCornerRadius: CGFloat
    var glowSize: CGFloat
    var content: Content

    init(
        isOn: Bool,
        glow: AuroraGlow,
        hostCornerRadius: CGFloat,
        glowSize: CGFloat,
        @ViewBuilder content: () -> Content
    ) {
        self.isOn = isOn
        self.glow = glow
        self.hostCornerRadius = hostCornerRadius
        self.glowSize = glowSize
        self.content = content()
    }

    var body: some View {
        content
            .overlay {
                if isOn {
                    GeometryReader { proxy in
                        glow
                            .cornerRadius(Self.cornerRadius(hostCornerRadius, in: proxy.size))
                            .glowSize(Self.cappedGlowSize(glowSize, in: proxy.size))
                    }
                }
            }
    }

    /// Capsule when the slider is large: never exceed half the short side.
    static func cornerRadius(_ requested: CGFloat, in size: CGSize) -> CGFloat {
        let limit = min(size.width, size.height) / 2
        guard limit > 0 else { return 0 }
        return min(max(requested, 0), limit)
    }

    /// Keep an interior so labels stay readable. Falloff in the shader is
    /// about `glowSize * 1.4` from each edge.
    static func cappedGlowSize(_ requested: CGFloat, in size: CGSize) -> CGFloat {
        let minSide = min(size.width, size.height)
        guard minSide > 0 else { return 4 }
        return min(max(requested, 4), minSide * 0.28)
    }
}

/// Single host + optional inner-edge `AuroraGlow`. Switching Prompt/Card
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
                hostCornerRadius: settings.cornerRadius,
                glowSize: settings.glowSize
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
            PromptHost(text: $promptText, cornerRadius: settings.cornerRadius) {
                burster.fire()
            }
        case .card:
            CardHost(cornerRadius: settings.cornerRadius, palette: settings.palette)
        }
    }
}

struct PromptHost: View {
    @Binding var text: String
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
        .background(DemoPalette.canvas, in: hostShape)
        .overlay {
            hostShape
                .strokeBorder(DemoPalette.stroke, lineWidth: 1)
                .allowsHitTesting(false)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Siri-style prompt")
    }

    private var hostShape: RoundedRectangle {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
    }
}

struct CardHost: View {
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
        .background(DemoPalette.canvas, in: hostShape)
        .overlay {
            hostShape
                .strokeBorder(DemoPalette.stroke, lineWidth: 1)
                .allowsHitTesting(false)
        }
    }

    private var hostShape: RoundedRectangle {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
    }
}
