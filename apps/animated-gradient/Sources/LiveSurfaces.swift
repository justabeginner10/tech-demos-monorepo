import AnimatedGradient
import SwiftUI

/// One `AnimatedLinearGradient`. Leaving the tab removes it. Remount runs `onAppear` again.
struct LivePlaygroundView: View {
    var isSelected: Bool

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var source: PaletteSource = .spectrum
    @State private var colorCount = 3.0
    @State private var simultaneous = Double(GradientDefaults.simultaneousColors)
    @State private var curve: AnimationCurve = .linear
    @State private var duration = GradientDefaults.duration
    @State private var start = GradientDefaults.start
    @State private var end = GradientDefaults.end
    @State private var driverProgress = 0.0
    @State private var mountID = 0

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 12) {
                stage
                callout
                ScrollView {
                    controls
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(DemoPalette.page)
            .navigationTitle("Gradient")
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
        GradientWell(
            isMounted: isSelected,
            reducesMotion: reduceMotion,
            fallbackColors: palette,
            fallbackStart: start.unitPoint,
            fallbackEnd: end.unitPoint,
            height: 240
        ) {
            AnimatedLinearGradient(colors: palette)
                .numberOfSimultaneousColors(simultaneousCount)
                .setAnimation(transition)
                .gradientPoints(start: start.unitPoint, end: end.unitPoint)
                .id(mountID)
        }
    }

    private var callout: some View {
        Text(callText)
            .font(.caption2.monospaced())
            .foregroundStyle(DemoPalette.ink)
            .textSelection(.enabled)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var controls: some View {
        VStack(alignment: .leading, spacing: 14) {
            segmented("Palette", selection: $source) { Text($0.title) }
            PaletteSwatches(colors: palette, labels: source.selectionLabels(count: paletteCount))
            Text(paletteCaption)
                .font(.caption)
                .foregroundStyle(DemoPalette.inkMuted)
                .fixedSize(horizontal: false, vertical: true)

            DemoSlider(
                title: "Colors in the cycle",
                value: $colorCount,
                range: 2...Double(source.colors.count),
                step: 1,
                caption: "prefix of the palette. The init takes that array. Two colors is the smallest blend.",
                valueText: String(paletteCount)
            )
            DemoSlider(
                title: "Simultaneous colors",
                value: $simultaneous,
                range: 1...8,
                step: 1,
                caption: "numberOfSimultaneousColors. The stored default is 2. A count past the palette repeats stops.",
                valueText: String(simultaneousCount)
            )

            curvePicker
            DemoSlider(
                title: "Duration",
                value: $duration,
                range: 0.5...10,
                step: 0.1,
                caption: "setAnimation. The stored default is .linear(duration: 3). The example slider starts at 1.",
                valueText: durationLiteral(duration)
            )

            anchorPicker("Start", selection: $start, caption: "gradientPoints start. The stored default is .topTrailing.")
            anchorPicker("End", selection: $end, caption: "gradientPoints end. The stored default is .bottomLeading.")

            Text(timingCaption)
                .font(.caption)
                .foregroundStyle(DemoPalette.inkMuted)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 12) {
                Button("Remount") {
                    mountID += 1
                }
                .buttonStyle(.bordered)
                .tint(DemoPalette.accent)

                Button("Package defaults") {
                    applyDefaults()
                }
                .buttonStyle(.bordered)
                .tint(DemoPalette.accent)
            }

            driver
        }
        .padding(14)
        .background(DemoPalette.card, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(DemoPalette.stroke, lineWidth: 1)
                .allowsHitTesting(false)
        }
        .padding(.bottom, 8)
    }

    private var driver: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Driver")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(DemoPalette.ink)
            Text("animatableLinearGradient(fromGradient:toGradient:progress:startPoint:endPoint:)")
                .font(.caption.monospaced())
                .foregroundStyle(DemoPalette.inkMuted)
                .fixedSize(horizontal: false, vertical: true)

            GradientWell(
                isMounted: isSelected,
                reducesMotion: false,
                fallbackColors: [.red, .yellow],
                fallbackStart: .leading,
                fallbackEnd: .trailing,
                height: 120
            ) {
                Rectangle()
                    .animatableLinearGradient(
                        fromGradient: Gradient(colors: [.red, .yellow]),
                        toGradient: Gradient(colors: [.blue, .green]),
                        progress: CGFloat(driverProgress),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
            }

            DemoSlider(
                title: "Progress",
                value: $driverProgress,
                range: 0...1,
                step: 0.01,
                caption: "0 is the from gradient. 1 is the to gradient. Both gradients have two stops.",
                valueText: String(format: "%.2f", driverProgress)
            )
        }
    }

    private var curvePicker: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Animation")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(DemoPalette.ink)
            Picker("Animation", selection: $curve) {
                ForEach(AnimationCurve.allCases) { item in
                    Text(item.title).tag(item)
                }
            }
            .pickerStyle(.menu)
            .tint(DemoPalette.ink)
            Text("setAnimation takes a SwiftUI Animation. The package default, and the example, use .linear.")
                .font(.caption)
                .foregroundStyle(DemoPalette.inkMuted)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func anchorPicker(
        _ title: String,
        selection: Binding<GradientAnchor>,
        caption: String
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(DemoPalette.ink)
            Picker(title, selection: selection) {
                ForEach(GradientAnchor.allCases) { anchor in
                    Text(anchor.title).tag(anchor)
                }
            }
            .pickerStyle(.menu)
            .tint(DemoPalette.ink)
            Text(caption)
                .font(.caption)
                .foregroundStyle(DemoPalette.inkMuted)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var paletteCaption: String {
        switch source {
        case .spectrum:
            "README colors are red, green, and blue. The extra three are ordinary SwiftUI colors."
        case .pastel:
            "GradientPreset.pastel. Six hex colors from the package."
        case .bright:
            "GradientPreset.bright. Six hex colors from the package."
        }
    }

    private var timingCaption: String {
        if reduceMotion {
            return "Reduce Motion is on, so the stage is a SwiftUI LinearGradient of the whole palette between these points. That is not a freeze-frame of the animated window. The package has no reduce-motion switch. The driver below stays, because its progress is a slider."
        }
        return "Count, palette, and animation are read in onAppear and when the current transition finishes. Remount runs onAppear now. Points are read from body, so they update without remounting."
    }

    private var paletteCount: Int {
        min(max(Int(colorCount.rounded()), 2), source.colors.count)
    }

    private var palette: [Color] {
        source.selection(count: paletteCount)
    }

    private var simultaneousCount: Int {
        min(max(Int(simultaneous.rounded()), 1), 8)
    }

    private var snappedDuration: Double {
        let snapped = (duration * 10).rounded() / 10
        return min(max(snapped, 0.5), 10)
    }

    private var transition: Animation {
        curve.animation(duration: snappedDuration)
    }

    private var callText: String {
        if reduceMotion {
            return """
            LinearGradient(colors: \(source.colorsCall(count: paletteCount)), startPoint: \(start.call), endPoint: \(end.call))
            """
        }
        return """
        AnimatedLinearGradient(colors: \(source.colorsCall(count: paletteCount)))
            .numberOfSimultaneousColors(\(simultaneousCount))
            .setAnimation(\(curve.call)(duration: \(durationLiteral(snappedDuration))))
            .gradientPoints(start: \(start.call), end: \(end.call))
        """
    }

    private func applyDefaults() {
        source = .spectrum
        colorCount = 3
        simultaneous = Double(GradientDefaults.simultaneousColors)
        curve = .linear
        duration = GradientDefaults.duration
        start = GradientDefaults.start
        end = GradientDefaults.end
        driverProgress = 0
        mountID += 1
    }

    private func segmented<Choice: Hashable, Label: View>(
        _ title: String,
        selection: Binding<Choice>,
        @ViewBuilder label: @escaping (Choice) -> Label
    ) -> some View where Choice: CaseIterable & Identifiable, Choice.AllCases: RandomAccessCollection {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(DemoPalette.ink)
            Picker(title, selection: selection) {
                ForEach(Array(Choice.allCases)) { choice in
                    label(choice).tag(choice)
                }
            }
            .pickerStyle(.segmented)
        }
    }
}
