import SwiftUI

/// One indicator. Leaving the tab removes `ProgressIndicatorView`. Visible passes `isVisible`.
struct LivePlaygroundView: View {
    var isSelected: Bool
    @Binding var settings: ProgressSettings

    @State private var kind: IndicatorKind = .bar
    @State private var track: TrackTint = .clear
    @State private var dashCount = 8.0
    @State private var lineWidth = 8.0
    @State private var stroke: Ink = .red

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 12) {
                stage
                ScrollView {
                    controls
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(DemoPalette.page)
            .navigationTitle("Progress")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(DemoPalette.page, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .safeAreaInset(edge: .bottom, spacing: 0) {
                Color.clear.frame(height: 56)
            }
        }
    }

    private var stage: some View {
        ProgressWell(
            isMounted: isSelected,
            kind: kind,
            progress: progress,
            isVisible: $settings.isVisible,
            foreground: settings.foreground,
            parameters: parameters,
            diameter: CGFloat(settings.diameter),
            barHeight: CGFloat(settings.barHeight),
            prefersDarkWell: kind.prefersDarkWell(
                foreground: settings.foreground,
                track: track,
                stroke: stroke
            ),
            identity: identity,
            idleText: "Unmounted"
        )
    }

    private var controls: some View {
        VStack(alignment: .leading, spacing: 12) {
            SharedProgressControls(settings: $settings)

            VStack(alignment: .leading, spacing: 6) {
                Text("Type")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(DemoPalette.ink)
                Picker("Type", selection: $kind) {
                    ForEach(IndicatorKind.allCases) { item in
                        Text(item.title).tag(item)
                    }
                }
                .pickerStyle(.menu)
                .tint(DemoPalette.ink)
                Text(kind.signature)
                    .font(.caption.monospaced())
                    .foregroundStyle(DemoPalette.inkMuted)
            }

            if kind.supportsTrack {
                tintMenu
            }

            if kind.supportsDashCount {
                sliderRow(
                    title: "Dash count \(parameters.dashCount)",
                    value: $dashCount,
                    range: kind.dashCountRange,
                    caption: "numberOfItems. The default is 8. The slider starts at 1 because the view divides by this count."
                )
            }

            if kind.supportsLineWidth {
                sliderRow(
                    title: "Line width \(Int(parameters.lineWidth.rounded()))",
                    value: $lineWidth,
                    range: kind.lineWidthRange,
                    caption: "lineWidth has no default. The example uses 8. The stroke is centered on a radius of width / 2, so the frame clips it."
                )
            }

            if kind.supportsStroke {
                colorMenu(
                    title: "Stroke color",
                    selection: $stroke,
                    caption: "strokeColor. Circle does not read foregroundStyle. The example uses .red."
                )
            }

            Text(kind.call(
                track: parameters.track,
                dashCount: parameters.dashCount,
                lineWidth: parameters.lineWidth,
                stroke: parameters.stroke
            ))
            .font(.caption.monospaced())
            .foregroundStyle(DemoPalette.ink)
            .textSelection(.enabled)
            .frame(maxWidth: .infinity, alignment: .leading)

            Button("Package defaults") {
                applyDefaults()
            }
            .buttonStyle(.bordered)
            .tint(DemoPalette.accent)
        }
        .padding(14)
        .background(DemoPalette.card, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(DemoPalette.stroke, lineWidth: 1)
                .allowsHitTesting(false)
        }
        .padding(.bottom, 8)
        .onChange(of: kind) { _, _ in
            applyDefaults()
        }
    }

    private var tintMenu: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Track color")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(DemoPalette.ink)
            Picker("Track color", selection: $track) {
                ForEach(TrackTint.allCases) { tint in
                    Text(tint.title).tag(tint)
                }
            }
            .pickerStyle(.menu)
            .tint(DemoPalette.ink)
            Text("backgroundColor. The package default is .clear. Gray 25% is the example track.")
                .font(.caption)
                .foregroundStyle(DemoPalette.inkMuted)
        }
    }

    private func sliderRow(
        title: String,
        value: Binding<Double>,
        range: ClosedRange<Double>,
        caption: String
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(DemoPalette.ink)
            Slider(value: value, in: range, step: 1)
                .tint(DemoPalette.accent)
            Text(caption)
                .font(.caption)
                .foregroundStyle(DemoPalette.inkMuted)
        }
    }

    private func colorMenu(title: String, selection: Binding<Ink>, caption: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(DemoPalette.ink)
            Picker(title, selection: selection) {
                ForEach(Ink.allCases) { ink in
                    Text(ink.title).tag(ink)
                }
            }
            .pickerStyle(.menu)
            .tint(DemoPalette.ink)
            Text(caption)
                .font(.caption)
                .foregroundStyle(DemoPalette.inkMuted)
        }
    }

    private var parameters: IndicatorParameters {
        let countRange = kind.dashCountRange
        let widthRange = kind.lineWidthRange
        let clampedCount = min(max(Int(dashCount.rounded()), Int(countRange.lowerBound)), Int(countRange.upperBound))
        let clampedWidth = min(max(lineWidth, widthRange.lowerBound), widthRange.upperBound)
        return IndicatorParameters(
            track: track,
            dashCount: clampedCount,
            lineWidth: CGFloat(clampedWidth),
            stroke: stroke
        )
    }

    private var progress: Binding<CGFloat> {
        Binding(
            get: { CGFloat(settings.progress) },
            set: { settings.progress = Double($0) }
        )
    }

    private var identity: String {
        kind.call(
            track: parameters.track,
            dashCount: parameters.dashCount,
            lineWidth: parameters.lineWidth,
            stroke: parameters.stroke
        )
    }

    private func applyDefaults() {
        track = .clear
        dashCount = 8
        lineWidth = 8
        stroke = .red
    }
}
