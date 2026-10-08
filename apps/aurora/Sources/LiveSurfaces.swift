import Aurora
import SwiftUI

/// Single host + optional `View.glow(_:)`. Switching Prompt/Card restyles this
/// overlay — it does not add a second Metal surface.
struct LiveGlowSurface: View {
    var settings: LiveGlowSettings
    @Binding var promptText: String
    var burster: AuroraGlow.Burster

    var body: some View {
        DemoChrome.chartCard(title: settings.target.title, subtitle: settings.target.subtitle) {
            glowingHost
                .frame(maxWidth: .infinity, minHeight: 168)
        }
    }

    private var configuredGlow: AuroraGlow {
        settings.glow.burster(burster)
    }

    @ViewBuilder
    private var glowingHost: some View {
        Group {
            if settings.isGlowOn {
                host.glow(configuredGlow)
            } else {
                host
            }
        }
        .padding(settings.glowSize + 8)
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
        .background(DemoPalette.canvas, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .strokeBorder(DemoPalette.stroke, lineWidth: 1)
                .allowsHitTesting(false)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Siri-style prompt")
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
        .background(DemoPalette.canvas, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .strokeBorder(DemoPalette.stroke, lineWidth: 1)
                .allowsHitTesting(false)
        }
    }
}
