import Aurora
import SwiftUI

/// Adaptive playground for Aurora: one live Metal glow, plus a static gallery.
struct DemoScreen: View {
    @State private var tab: DemoTab = .live
    @State private var appearance: DemoAppearance = .system
    @State private var galleryPreview: GalleryFamily?

    var body: some View {
        TabView(selection: $tab) {
            LivePlaygroundView(isSelected: tab == .live, appearance: $appearance)
                .tabItem { Label("Live", systemImage: "sparkles") }
                .tag(DemoTab.live)

            GalleryScreen(preview: $galleryPreview)
                .tabItem { Label("Gallery", systemImage: "square.grid.2x2") }
                .tag(DemoTab.gallery)
        }
        .toolbarBackground(DemoPalette.page, for: .tabBar)
        .preferredColorScheme(appearance.colorScheme)
        .onChange(of: tab) { _, newTab in
            if newTab != .gallery {
                galleryPreview = nil
            }
        }
        .sheet(item: $galleryPreview) { family in
            GalleryLivePreview(family: family)
        }
    }
}

/// One live `AuroraGlow` at a time. Leaving the tab — or turning the glow off — unmounts it.
struct LivePlaygroundView: View {
    var isSelected: Bool
    @Binding var appearance: DemoAppearance

    @State private var settings = LiveGlowSettings()
    @State private var promptText = ""
    @State private var burster = AuroraGlow.Burster()

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 12) {
                playgroundControls
                if isSelected {
                    LiveGlowSurface(
                        settings: settings,
                        promptText: $promptText,
                        burster: burster
                    )
                    .frame(maxWidth: .infinity)
                    controlPanel
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    parkedCard
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(DemoPalette.page)
            .navigationTitle("Aurora")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(DemoPalette.page, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .safeAreaInset(edge: .bottom, spacing: 0) {
                Color.clear.frame(height: 56)
            }
        }
    }

    private var playgroundControls: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Playground")
                .font(.headline)
                .foregroundStyle(DemoPalette.ink)

            Picker("Target", selection: targetBinding) {
                ForEach(LiveTarget.allCases) { item in
                    Text(item.title).tag(item)
                }
            }
            .pickerStyle(.segmented)

            Picker("Appearance", selection: $appearance) {
                ForEach(DemoAppearance.allCases) { item in
                    Text(item.title).tag(item)
                }
            }
            .pickerStyle(.segmented)

            Toggle("Show glow", isOn: $settings.isGlowOn)
                .foregroundStyle(DemoPalette.ink)
                .tint(DemoPalette.accent)

            Text(
                "Only this host mounts Metal. Prompt and Card never glow at the same time. "
                    + "Gallery tiles are painted — tap one for a single live preview."
            )
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

    private var controlPanel: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                palettePicker
                intensityPicker
                shapePicker

                DemoChrome.sliderRow(
                    "Speed",
                    value: Binding(
                        get: { CGFloat(settings.speed) },
                        set: { settings.speed = Double($0) }
                    ),
                    range: 0.02 ... 0.6,
                    format: "%.2f"
                )

                DemoChrome.sliderRow(
                    "Glow",
                    value: $settings.glowSize,
                    range: 8 ... 80,
                    format: "%.0f"
                )

                DemoChrome.sliderRow(
                    "Corner",
                    value: $settings.cornerRadius,
                    range: 0 ... 120,
                    format: "%.0f"
                )

                Button {
                    burster.fire()
                } label: {
                    Label("Trigger burst", systemImage: "sparkles")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(DemoPalette.accent)
                .disabled(!settings.isGlowOn)
            }
            .padding(14)
            .background(DemoPalette.card, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(DemoPalette.stroke, lineWidth: 1)
            }
            .padding(.bottom, 12)
        }
    }

    private var palettePicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Palette")
                .font(.caption.weight(.semibold))
                .foregroundStyle(DemoPalette.inkMuted)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(GlowPaletteChoice.allCases) { choice in
                        PaletteChip(
                            choice: choice,
                            isSelected: settings.palette == choice
                        )
                        .onTapGesture {
                            settings.palette = choice
                            burster.fire()
                        }
                    }
                }
            }
        }
    }

    private var intensityPicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Intensity")
                .font(.caption.weight(.semibold))
                .foregroundStyle(DemoPalette.inkMuted)

            Picker("Intensity", selection: $settings.intensity) {
                ForEach(GlowIntensity.allCases) { item in
                    Text(item.title).tag(item)
                }
            }
            .pickerStyle(.segmented)
            .onChange(of: settings.intensity) { _, _ in
                burster.fire()
            }
        }
    }

    private var shapePicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Shape")
                .font(.caption.weight(.semibold))
                .foregroundStyle(DemoPalette.inkMuted)

            Picker("Shape", selection: shapeBinding) {
                ForEach(GlowShape.allCases) { item in
                    Text(item.title).tag(item)
                }
            }
            .pickerStyle(.segmented)
        }
    }

    private var targetBinding: Binding<LiveTarget> {
        Binding(
            get: { settings.target },
            set: { settings.applyTarget($0) }
        )
    }

    private var shapeBinding: Binding<GlowShape> {
        Binding(
            get: { settings.shape },
            set: { settings.applyShape($0) }
        )
    }

    private var parkedCard: some View {
        DemoChrome.chartCard(title: settings.target.title, subtitle: "Unmounted") {
            Text("Live Metal glow is unmounted while Gallery is open.")
                .font(.subheadline)
                .foregroundStyle(DemoPalette.inkMuted)
                .frame(maxWidth: .infinity, minHeight: 120, alignment: .center)
        }
    }
}

private struct PaletteChip: View {
    var choice: GlowPaletteChoice
    var isSelected: Bool

    var body: some View {
        VStack(spacing: 6) {
            HStack(spacing: 2) {
                ForEach(Array(choice.swatchColors.enumerated()), id: \.offset) { _, color in
                    color.frame(width: 12, height: 22)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .strokeBorder(isSelected ? DemoPalette.ink : DemoPalette.stroke, lineWidth: isSelected ? 2 : 1)
            }

            Text(choice.title)
                .font(.caption2.weight(.medium))
                .foregroundStyle(isSelected ? DemoPalette.ink : DemoPalette.inkMuted)
        }
        .padding(6)
        .background(
            isSelected ? Color.primary.opacity(0.08) : Color.clear,
            in: RoundedRectangle(cornerRadius: 10, style: .continuous)
        )
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
        .accessibilityLabel(choice.title)
    }
}

#Preview("Aurora Demo") {
    DemoScreen()
}
