import SwiftUI

/// Frozen marketing stand-ins. Live playground and the gallery sheet own Metal.
enum GalleryFamily: String, CaseIterable, Identifiable {
    case button
    case prompt
    case card
    case fullScreen
    case palettes

    var id: String { rawValue }

    var title: String {
        switch self {
        case .button: "Button"
        case .prompt: "Prompt"
        case .card: "Card"
        case .fullScreen: "Full-screen edge"
        case .palettes: "Palettes"
        }
    }

    var subtitle: String {
        switch self {
        case .button: "Capsule continue · painted halo"
        case .prompt: "Siri-style field · painted halo"
        case .card: "Inset card · painted halo"
        case .fullScreen: "ignoresSafeArea · painted edge"
        case .palettes: "Six built-in AuroraGlow.Palette"
        }
    }

    var chips: [String] {
        switch self {
        case .button:
            [".glow", "capsule", "standard"]
        case .prompt:
            ["Ask anything", "cornerRadius 80", ".glow"]
        case .card:
            ["AuroraGlow", "rounded 24", "sunset"]
        case .fullScreen:
            ["overlay", "ignoresSafeArea", "dramatic"]
        case .palettes:
            ["appleIntelligence", "sunset", "ocean"]
        }
    }

    var palette: GlowPaletteChoice {
        switch self {
        case .button: .ocean
        case .prompt: .appleIntelligence
        case .card: .sunset
        case .fullScreen: .cyberpunk
        case .palettes: .appleIntelligence
        }
    }

    @ViewBuilder
    var preview: some View {
        VStack(alignment: .leading, spacing: 8) {
            snapshot
            chipRow
        }
    }

    @ViewBuilder
    private var snapshot: some View {
        switch self {
        case .button:
            FrozenButtonTile(palette: palette)
        case .prompt:
            FrozenPromptTile(palette: palette)
        case .card:
            FrozenCardTile(palette: palette)
        case .fullScreen:
            FrozenFullScreenTile(palette: palette)
        case .palettes:
            FrozenPaletteStrip()
        }
    }

    private var chipRow: some View {
        HStack(spacing: 6) {
            ForEach(chips, id: \.self) { label in
                DemoChrome.chip(label)
            }
        }
        .padding(.horizontal, 4)
        .padding(.bottom, 4)
    }
}

/// Angular gradient ring. Not `AuroraGlow`.
struct FrozenGlowHalo: View {
    var palette: GlowPaletteChoice
    var cornerRadius: CGFloat
    var lineWidth: CGFloat = 5

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .strokeBorder(
                AngularGradient(colors: ringColors, center: .center),
                lineWidth: lineWidth
            )
            .shadow(color: ringLead.opacity(0.55), radius: 8)
            .shadow(color: palette.baseColor.opacity(0.35), radius: 16)
            .allowsHitTesting(false)
    }

    private var ringLead: Color {
        palette.swatchColors.first ?? palette.baseColor
    }

    private var ringColors: [Color] {
        let colors = palette.swatchColors
        return colors.isEmpty ? [ringLead] : colors + [ringLead]
    }
}

struct FrozenContinueButton: View {
    var body: some View {
        Text("Continue")
            .font(.headline)
            .foregroundStyle(Color.white)
            .padding(.horizontal, 28)
            .padding(.vertical, 12)
            .background(DemoPalette.accent, in: Capsule())
    }
}

private struct FrozenButtonTile: View {
    var palette: GlowPaletteChoice

    var body: some View {
        ZStack {
            DemoPalette.canvas
            FrozenContinueButton()
                .overlay {
                    FrozenGlowHalo(palette: palette, cornerRadius: 80, lineWidth: 4)
                        .padding(-6)
                }
        }
        .frame(height: 132)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

private struct FrozenPromptTile: View {
    var palette: GlowPaletteChoice

    var body: some View {
        ZStack {
            DemoPalette.canvas
            HStack(spacing: 10) {
                Image(systemName: "sparkles")
                    .foregroundStyle(DemoPalette.accent)
                Text("Ask anything")
                    .font(.subheadline)
                    .foregroundStyle(DemoPalette.inkMuted)
                Spacer()
                Image(systemName: "microphone.fill")
                    .foregroundStyle(DemoPalette.inkMuted)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(DemoPalette.card, in: Capsule())
            .overlay {
                FrozenGlowHalo(palette: palette, cornerRadius: 80, lineWidth: 4)
            }
            .padding(.horizontal, 18)
        }
        .frame(height: 132)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

private struct FrozenCardTile: View {
    var palette: GlowPaletteChoice

    var body: some View {
        ZStack {
            DemoPalette.canvas
            VStack(alignment: .leading, spacing: 6) {
                Text("CARD")
                    .font(.caption2.weight(.bold).monospaced())
                    .foregroundStyle(palette.baseColor)
                Text("Sunset inset")
                    .font(.headline)
                    .foregroundStyle(DemoPalette.ink)
                Text("Painted halo, no TimelineView.")
                    .font(.caption)
                    .foregroundStyle(DemoPalette.inkMuted)
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(DemoPalette.card, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay {
                FrozenGlowHalo(palette: palette, cornerRadius: 18, lineWidth: 4)
            }
            .padding(16)
        }
        .frame(height: 148)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

private struct FrozenFullScreenTile: View {
    var palette: GlowPaletteChoice

    var body: some View {
        ZStack {
            Color(light: Color(red: 0.92, green: 0.93, blue: 0.96),
                  dark: Color(red: 0.06, green: 0.06, blue: 0.08))

            VStack(spacing: 6) {
                Text("LISTEN")
                    .font(.caption2.weight(.bold).monospaced())
                    .tracking(1.4)
                    .foregroundStyle(DemoPalette.inkMuted)
                Text("Edge glow")
                    .font(.headline)
                    .foregroundStyle(DemoPalette.ink)
            }

            FrozenGlowHalo(palette: palette, cornerRadius: 18, lineWidth: 7)
                .padding(8)
        }
        .frame(height: 148)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

private struct FrozenPaletteStrip: View {
    var body: some View {
        HStack(spacing: 8) {
            ForEach(GlowPaletteChoice.allCases) { choice in
                VStack(spacing: 6) {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: choice.swatchColors,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(height: 56)
                    Text(choice.title)
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(DemoPalette.ink)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }
            }
        }
        .padding(8)
        .frame(maxWidth: .infinity)
    }
}
