import SwiftUI

/// One indicator. Leaving the tab, or turning Visible off, removes `ActivityIndicatorView`.
struct LivePlaygroundView: View {
    var isSelected: Bool
    @Binding var settings: IndicatorSettings

    @State private var kind: IndicatorKind = .spinner
    @State private var count = 8.0
    @State private var inset = 2.0
    @State private var lineWidth = 2.0
    @State private var lineCap: LineCapChoice = .butt
    @State private var arcTint: IndicatorTint = .black
    @State private var gradientStart: IndicatorTint = .white
    @State private var gradientEnd: IndicatorTint = .red

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
            .navigationTitle("Indicators")
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
        IndicatorWell(
            isMounted: isSelected && settings.isVisible,
            kind: kind,
            type: parameters.makeType(for: kind),
            size: CGFloat(settings.size),
            foreground: settings.tint,
            prefersDarkWell: kind.prefersDarkWell(foreground: settings.tint, arcTint: arcTint),
            identity: identity,
            idleText: idleText
        )
    }

    private var controls: some View {
        VStack(alignment: .leading, spacing: 12) {
            SharedIndicatorControls(settings: $settings)

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

            if kind.supportsCount {
                sliderRow(
                    title: "Count \(parameters.count)",
                    value: $count,
                    range: kind.countRange,
                    caption: "Associated value count. The slider starts at 1."
                )
            }

            if kind.supportsInset {
                sliderRow(
                    title: "Inset \(parameters.inset)",
                    value: $inset,
                    range: kind.insetRange,
                    caption: "Associated value inset, in points, as Int."
                )
            }

            if kind.supportsLineWidth {
                sliderRow(
                    title: "Line width \(Int(parameters.lineWidth.rounded()))",
                    value: $lineWidth,
                    range: kind.lineWidthRange,
                    caption: "Associated value lineWidth."
                )
            }

            if kind.supportsLineCap {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Line cap")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(DemoPalette.ink)
                    Picker("Line cap", selection: $lineCap) {
                        ForEach(LineCapChoice.allCases) { cap in
                            Text(cap.title).tag(cap)
                        }
                    }
                    .pickerStyle(.segmented)
                    Text("Second associated value of gradient. Default is .butt.")
                        .font(.caption)
                        .foregroundStyle(DemoPalette.inkMuted)
                }
            }

            if kind.supportsArcColor {
                tintMenu(
                    title: "Arc color",
                    selection: $arcTint,
                    caption: "First associated value of growingArc. The stroke uses this color, not foregroundStyle. Default is .black."
                )
            }

            if kind.supportsGradientColors {
                tintMenu(
                    title: "Gradient start",
                    selection: $gradientStart,
                    caption: "First color in the gradient array. The README sample starts at .white, so this well stays dark."
                )
                tintMenu(
                    title: "Gradient end",
                    selection: $gradientEnd,
                    caption: "Second color in the gradient array. The README sample ends at .red."
                )
            }

            Text(parameters.call(for: kind))
                .font(.caption.monospaced())
                .foregroundStyle(DemoPalette.ink)
                .textSelection(.enabled)
                .frame(maxWidth: .infinity, alignment: .leading)

            Button("Package defaults") {
                applyDefaults(for: kind)
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
        .onChange(of: kind) { _, newKind in
            applyDefaults(for: newKind)
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

    private func tintMenu(title: String, selection: Binding<IndicatorTint>, caption: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(DemoPalette.ink)
            Picker(title, selection: selection) {
                ForEach(IndicatorTint.allCases) { tint in
                    Text(tint.title).tag(tint)
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
        let countRange = kind.countRange
        let insetRange = kind.insetRange
        let widthRange = kind.lineWidthRange
        let clampedCount = min(max(Int(count.rounded()), Int(countRange.lowerBound)), Int(countRange.upperBound))
        let clampedInset = min(max(Int(inset.rounded()), Int(insetRange.lowerBound)), Int(insetRange.upperBound))
        let clampedWidth = min(max(lineWidth, widthRange.lowerBound), widthRange.upperBound)
        return IndicatorParameters(
            count: clampedCount,
            inset: clampedInset,
            lineWidth: CGFloat(clampedWidth),
            lineCap: lineCap,
            arcTint: arcTint,
            gradientStart: gradientStart,
            gradientEnd: gradientEnd
        )
    }

    private var identity: String {
        parameters.call(for: kind)
    }

    private var idleText: String {
        if !isSelected {
            return "Unmounted"
        }
        return "Hidden"
    }

    private func applyDefaults(for kind: IndicatorKind) {
        count = Double(kind.defaultCount)
        inset = Double(kind.defaultInset)
        lineWidth = kind.defaultLineWidth
        lineCap = .butt
        arcTint = .black
        gradientStart = .white
        gradientEnd = .red
    }
}
