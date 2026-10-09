import Pow
import SwiftUI

/// One change-effect target. Switching kinds remounts the badge so only one effect runs.
struct ChangeEffectSurface: View {
    @Binding var kind: ChangeEffectKind
    @Binding var params: ChangeEffectParams

    @State private var fireCount = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            controls
            Spacer(minLength: 8)
            target
            fireButton
            Spacer(minLength: 0)
        }
        .onChange(of: kind) { _, _ in
            fireCount = 0
        }
    }

    private var controls: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline) {
                Text(kind.title)
                    .font(.headline)
                    .foregroundStyle(DemoPalette.ink)
                Spacer()
                Text(kind.apiName)
                    .font(.caption.monospaced())
                    .foregroundStyle(DemoPalette.inkMuted)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }

            LabeledContent("Effect") {
                Picker("Effect", selection: $kind) {
                    ForEach(ChangeEffectKind.allCases) { item in
                        Text(item.title).tag(item)
                    }
                }
                .pickerStyle(.menu)
                .labelsHidden()
                .tint(DemoPalette.ink)
            }
            .foregroundStyle(DemoPalette.ink)

            parameterControls

            Text(kind.summary)
                .font(.caption)
                .foregroundStyle(DemoPalette.inkMuted)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(14)
        .background(DemoPalette.card, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(DemoPalette.stroke, lineWidth: 1)
        }
    }

    @ViewBuilder
    private var parameterControls: some View {
        switch kind {
        case .spray, .rise:
            picker("Origin", selection: $params.origin) {
                ForEach(ParticleOrigin.allCases) { item in
                    Text(item.title).tag(item)
                }
            }
        case .jump:
            slider("Height", value: $params.jumpHeight, range: 16 ... 80, format: "\(Int(params.jumpHeight)) pt")
        case .pulse:
            picker("Shape", selection: $params.pulseShape) {
                ForEach(PulseShapeKind.allCases) { item in
                    Text(item.title).tag(item)
                }
            }
            picker("Draw", selection: $params.pulseInk) {
                ForEach(PulseInk.allCases) { item in
                    Text(item.title).tag(item)
                }
            }
            stepper("Count", value: $params.pulseCount, range: 1 ... 5)
        case .shine:
            slider("Duration", value: $params.shineDuration, range: 0.35 ... 2.0, format: String(format: "%.2fs", params.shineDuration))
            slider("Angle", value: $params.shineAngle, range: 0 ... 90, format: "\(Int(params.shineAngle))°")
        case .spin:
            picker("Axis", selection: $params.spinAxis) {
                ForEach(SpinAxis.allCases) { item in
                    Text(item.title).tag(item)
                }
            }
            picker("Rate", selection: $params.spinPace) {
                ForEach(SpinPace.allCases) { item in
                    Text(item.title).tag(item)
                }
            }
            slider("Boost", value: $params.spinBoost, range: 0 ... 2, format: String(format: "%.1f", params.spinBoost))
        case .shake:
            picker("Rate", selection: $params.shakePace) {
                ForEach(ShakePace.allCases) { item in
                    Text(item.title).tag(item)
                }
            }
        case .wiggle:
            picker("Rate", selection: $params.wigglePace) {
                ForEach(WigglePace.allCases) { item in
                    Text(item.title).tag(item)
                }
            }
        case .glow:
            picker("Color", selection: $params.glowInk) {
                ForEach(AccentInk.allCases) { item in
                    Text(item.title).tag(item)
                }
            }
            slider("Radius", value: $params.glowRadius, range: 8 ... 64, format: "\(Int(params.glowRadius)) pt")
        case .haptic:
            picker("Feedback", selection: $params.hapticKind) {
                ForEach(HapticKind.allCases) { item in
                    Text(item.title).tag(item)
                }
            }
        }
    }

    private var target: some View {
        Button {
            fireCount += 1
        } label: {
            DemoChrome.badge(title: kind.title, systemImage: kind.systemImage)
        }
        .buttonStyle(.plain)
        .powChangeEffect(kind, params: params, value: fireCount)
        .id(kind)
        .accessibilityLabel("Fire \(kind.title)")
        .accessibilityIdentifier("live-badge")
    }

    private var fireButton: some View {
        Button {
            fireCount += 1
        } label: {
            Label("Fire effect", systemImage: "hand.tap")
                .font(.headline)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .tint(DemoPalette.accent)
        .accessibilityIdentifier("fire-effect")
    }

    private func picker<Value: Hashable, Content: View>(
        _ title: String,
        selection: Binding<Value>,
        @ViewBuilder content: () -> Content
    ) -> some View {
        LabeledContent(title) {
            Picker(title, selection: selection, content: content)
                .pickerStyle(.menu)
                .labelsHidden()
                .tint(DemoPalette.ink)
        }
        .foregroundStyle(DemoPalette.ink)
    }

    private func slider(_ title: String, value: Binding<CGFloat>, range: ClosedRange<CGFloat>, format: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            LabeledContent(title) {
                Text(format)
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(DemoPalette.inkMuted)
            }
            .foregroundStyle(DemoPalette.ink)
            Slider(value: value, in: range)
                .tint(DemoPalette.accent)
        }
    }

    private func slider(_ title: String, value: Binding<Double>, range: ClosedRange<Double>, format: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            LabeledContent(title) {
                Text(format)
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(DemoPalette.inkMuted)
            }
            .foregroundStyle(DemoPalette.ink)
            Slider(value: value, in: range)
                .tint(DemoPalette.accent)
        }
    }

    private func stepper(_ title: String, value: Binding<Int>, range: ClosedRange<Int>) -> some View {
        Stepper(value: value, in: range) {
            LabeledContent(title) {
                Text("\(value.wrappedValue)")
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(DemoPalette.inkMuted)
            }
            .foregroundStyle(DemoPalette.ink)
        }
    }
}

/// One transition target. The toggle inserts or removes the same badge.
struct TransitionSurface: View {
    @Binding var kind: TransitionKind
    @Binding var params: TransitionParams

    @State private var isVisible = true

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            controls
            Spacer(minLength: 8)
            stage
            toggleButton
            Spacer(minLength: 0)
        }
        .onChange(of: kind) { _, _ in
            isVisible = true
        }
    }

    private var controls: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline) {
                Text(kind.title)
                    .font(.headline)
                    .foregroundStyle(DemoPalette.ink)
                Spacer()
                Text(kind.apiName)
                    .font(.caption.monospaced())
                    .foregroundStyle(DemoPalette.inkMuted)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }

            LabeledContent("Transition") {
                Picker("Transition", selection: $kind) {
                    ForEach(TransitionKind.liveCases) { item in
                        Text(item.title).tag(item)
                    }
                }
                .pickerStyle(.menu)
                .labelsHidden()
                .tint(DemoPalette.ink)
            }
            .foregroundStyle(DemoPalette.ink)

            parameterControls

            Text(kind.summary)
                .font(.caption)
                .foregroundStyle(DemoPalette.inkMuted)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(14)
        .background(DemoPalette.card, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(DemoPalette.stroke, lineWidth: 1)
        }
    }

    @ViewBuilder
    private var parameterControls: some View {
        switch kind {
        case .pop:
            picker("Style", selection: $params.ink) {
                ForEach(AccentInk.allCases) { item in
                    Text(item.title).tag(item)
                }
            }
        case .blinds:
            slider("Slat", value: $params.blindsWidth, range: 6 ... 28, format: "\(Int(params.blindsWidth)) pt")
            picker("Style", selection: $params.blindsKind) {
                ForEach(BlindsKind.allCases) { item in
                    Text(item.title).tag(item)
                }
            }
            Toggle("Staggered", isOn: $params.blindsStaggered)
                .foregroundStyle(DemoPalette.ink)
                .tint(DemoPalette.accent)
        case .boing:
            picker("Edge", selection: $params.edge) {
                ForEach(EdgeKind.allCases) { item in
                    Text(item.title).tag(item)
                }
            }
        case .vanish:
            picker("Style", selection: $params.ink) {
                ForEach(AccentInk.allCases) { item in
                    Text(item.title).tag(item)
                }
            }
            Toggle("Increased brightness", isOn: $params.vanishBright)
                .foregroundStyle(DemoPalette.ink)
                .tint(DemoPalette.accent)
        case .flip, .anvil, .swoosh:
            EmptyView()
        default:
            EmptyView()
        }
    }

    private var stage: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(DemoPalette.canvas)
                .overlay {
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .strokeBorder(DemoPalette.stroke, lineWidth: 1)
                }

            if isVisible {
                DemoChrome.badge(title: kind.title, systemImage: kind.systemImage)
                    .padding(16)
                    .transition(kind.powTransition(params))
            } else {
                Text("View removed")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(DemoPalette.inkMuted)
                    .transition(.opacity)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(minHeight: 220)
        .id(kind)
    }

    private var toggleButton: some View {
        Button {
            withAnimation(.default) {
                isVisible.toggle()
            }
        } label: {
            Label(isVisible ? "Remove view" : "Insert view", systemImage: isVisible ? "eye.slash" : "eye")
                .font(.headline)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .tint(DemoPalette.accent)
        .accessibilityIdentifier("toggle-transition")
    }

    private func picker<Value: Hashable, Content: View>(
        _ title: String,
        selection: Binding<Value>,
        @ViewBuilder content: () -> Content
    ) -> some View {
        LabeledContent(title) {
            Picker(title, selection: selection, content: content)
                .pickerStyle(.menu)
                .labelsHidden()
                .tint(DemoPalette.ink)
        }
        .foregroundStyle(DemoPalette.ink)
    }

    private func slider(_ title: String, value: Binding<CGFloat>, range: ClosedRange<CGFloat>, format: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            LabeledContent(title) {
                Text(format)
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(DemoPalette.inkMuted)
            }
            .foregroundStyle(DemoPalette.ink)
            Slider(value: value, in: range)
                .tint(DemoPalette.accent)
        }
    }
}

extension View {
    /// Applies the selected Pow change effect. Branches erase to `AnyView` so
    /// the Swift 6 type checker is not asked to unify ten modifier types.
    func powChangeEffect(_ kind: ChangeEffectKind, params: ChangeEffectParams, value: Int) -> some View {
        let layer = ParticleLayer.named(DemoParticleLayer.name)
        switch kind {
        case .spray:
            return AnyView(
                changeEffect(
                    .spray(origin: params.origin.unitPoint, layer: layer) {
                        Group {
                            Image(systemName: "heart.fill")
                            Image(systemName: "sparkles")
                        }
                        .font(.title2.weight(.bold))
                        .foregroundStyle(DemoPalette.accent)
                    },
                    value: value
                )
            )
        case .jump:
            return AnyView(changeEffect(.jump(height: params.jumpHeight), value: value))
        case .pulse:
            switch params.pulseShape {
            case .roundedRect:
                return AnyView(
                    changeEffect(
                        .pulse(
                            shape: RoundedRectangle(cornerRadius: 24, style: .continuous),
                            style: DemoPalette.accent,
                            drawingMode: params.pulseInk.mode,
                            count: params.pulseCount,
                            layer: layer
                        ),
                        value: value
                    )
                )
            case .capsule:
                return AnyView(
                    changeEffect(
                        .pulse(
                            shape: Capsule(),
                            style: DemoPalette.accent,
                            drawingMode: params.pulseInk.mode,
                            count: params.pulseCount,
                            layer: layer
                        ),
                        value: value
                    )
                )
            }
        case .shine:
            return AnyView(
                changeEffect(
                    .shine(angle: .degrees(params.shineAngle), duration: params.shineDuration),
                    value: value
                )
            )
        case .spin:
            return AnyView(
                changeEffect(
                    .spin(
                        axis: params.spinAxis.vector,
                        multiplier: params.spinBoost,
                        rate: params.spinPace.rate
                    ),
                    value: value
                )
            )
        case .shake:
            return AnyView(changeEffect(.shake(rate: params.shakePace.rate), value: value))
        case .wiggle:
            return AnyView(changeEffect(.wiggle(rate: params.wigglePace.rate), value: value))
        case .glow:
            return AnyView(
                changeEffect(
                    .glow(color: params.glowInk.color, radius: params.glowRadius),
                    value: value
                )
            )
        case .rise:
            return AnyView(
                changeEffect(
                    .rise(origin: params.origin.unitPoint, layer: layer) {
                        Group {
                            Image(systemName: "plus")
                            Image(systemName: "star.fill")
                        }
                        .font(.title3.weight(.bold))
                        .foregroundStyle(DemoPalette.accent)
                    },
                    value: value
                )
            )
        case .haptic:
            return AnyView(changeEffect(params.hapticKind.effect, value: value))
        }
    }
}

#Preview("Change effect") {
    ChangeEffectSurface(kind: .constant(.spray), params: .constant(ChangeEffectParams()))
        .padding()
        .background(DemoPalette.page)
}

#Preview("Transition") {
    TransitionSurface(kind: .constant(.pop), params: .constant(TransitionParams()))
        .padding()
        .background(DemoPalette.page)
}
