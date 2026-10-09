import Aurora
import SwiftUI

/// Frozen glow tiles. No `AuroraGlow`, no `.glow`, no `AuroraText` in the grid.
struct GalleryScreen: View {
    @Binding var preview: GalleryFamily?

    private let columns = [GridItem(.adaptive(minimum: 300), spacing: 12)]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    header
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(GalleryFamily.allCases) { family in
                            DemoChrome.chartCard(title: family.title, subtitle: family.subtitle) {
                                family.preview
                            }
                            .contentShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .onTapGesture {
                                preview = family
                            }
                            .accessibilityAddTraits(.isButton)
                            .accessibilityHint("Shows one live AuroraGlow preview")
                        }
                    }
                    DemoChrome.tabBarScrollSpacer
                }
                .padding()
            }
            .background(DemoPalette.page)
            .navigationTitle("Gallery")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(DemoPalette.page, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Hold the glow.")
                .font(.system(size: 34, weight: .regular, design: .serif))
                .foregroundStyle(DemoPalette.ink)

            Text(
                "Static snapshots of the hosts Live can mount. No Metal is running "
                    + "on this grid — tap a tile to open one live AuroraGlow."
            )
            .font(.subheadline)
            .foregroundStyle(DemoPalette.inkMuted)
        }
    }
}

/// Exactly one live `AuroraGlow`. Dismissing the sheet unmounts it.
struct GalleryLivePreview: View {
    var family: GalleryFamily
    @Environment(\.dismiss) private var dismiss
    @State private var palette: GlowPaletteChoice
    @State private var promptText = ""

    init(family: GalleryFamily) {
        self.family = family
        _palette = State(initialValue: family.palette)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                DemoPalette.page.ignoresSafeArea()
                liveBody
            }
            .navigationTitle(family.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(DemoPalette.page, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .presentationDetents(family == .fullScreen ? [.large] : [.medium, .large])
        .presentationDragIndicator(.visible)
    }

    @ViewBuilder
    private var liveBody: some View {
        switch family {
        case .button:
            AuroraHalo(
                isOn: true,
                glow: AuroraGlow(.standard)
                    .palette(palette.palette)
                    .speed(0.12),
                shape: .capsule,
                hostCornerRadius: 22,
                glowSize: 14,
                intensity: .standard,
                palette: palette
            ) {
                FrozenContinueButton()
            }
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        case .prompt:
            AuroraHalo(
                isOn: true,
                glow: AuroraGlow(.standard)
                    .palette(palette.palette)
                    .speed(0.12),
                shape: .capsule,
                hostCornerRadius: 80,
                glowSize: 14,
                intensity: .standard,
                palette: palette
            ) {
                PromptHost(
                    text: $promptText,
                    shape: .capsule,
                    cornerRadius: 80,
                    onSubmit: {}
                )
            }
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        case .card:
            AuroraHalo(
                isOn: true,
                glow: AuroraGlow(.standard)
                    .palette(palette.palette)
                    .speed(0.12),
                shape: .rounded,
                hostCornerRadius: 24,
                glowSize: 14,
                intensity: .standard,
                palette: palette
            ) {
                CardHost(shape: .rounded, cornerRadius: 24, palette: palette)
            }
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        case .fullScreen:
            fullScreenGlow
        case .palettes:
            paletteGlow
        }
    }

    private var fullScreenGlow: some View {
        ZStack {
            VStack(spacing: 12) {
                Text("Listen")
                    .font(.caption.weight(.semibold).monospaced())
                    .tracking(2)
                    .foregroundStyle(DemoPalette.inkMuted)
                Text("Ask anything")
                    .font(.system(size: 34, weight: .semibold, design: .rounded))
                    .foregroundStyle(DemoPalette.ink)
                Text("Full-screen overlay.ignoresSafeArea()")
                    .font(.subheadline)
                    .foregroundStyle(DemoPalette.inkMuted)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .overlay {
            AuroraGlow(.dramatic)
                .palette(palette.palette)
                .ignoresSafeArea()
        }
    }

    private var paletteGlow: some View {
        VStack(spacing: 20) {
            Spacer()
            Text(palette.title)
                .font(.system(size: 28, weight: .regular, design: .serif))
                .foregroundStyle(DemoPalette.ink)
            Spacer()
            paletteStrip
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .overlay {
            AuroraGlow(.standard)
                .palette(palette.palette)
                .ignoresSafeArea()
        }
    }

    private var paletteStrip: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(GlowPaletteChoice.allCases) { choice in
                    PaletteChipButton(choice: choice, isSelected: palette == choice) {
                        palette = choice
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .background(.ultraThinMaterial)
    }
}

private struct PaletteChipButton: View {
    var choice: GlowPaletteChoice
    var isSelected: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                HStack(spacing: 2) {
                    ForEach(Array(choice.swatchColors.enumerated()), id: \.offset) { _, color in
                        color.frame(width: 12, height: 22)
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
                Text(choice.title)
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(DemoPalette.ink)
            }
            .padding(8)
            .background(
                isSelected ? Color.primary.opacity(0.10) : Color.clear,
                in: RoundedRectangle(cornerRadius: 10, style: .continuous)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview("Aurora Gallery") {
    GalleryScreen(preview: .constant(nil))
}
