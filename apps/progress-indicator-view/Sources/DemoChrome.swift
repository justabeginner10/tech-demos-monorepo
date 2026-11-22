import ProgressIndicatorView
import SwiftUI

enum DemoTab: Hashable {
    case live
    case gallery
}

enum DemoPalette {
    static let page = Color(red: 8 / 255, green: 8 / 255, blue: 10 / 255)
    static let card = Color(red: 16 / 255, green: 16 / 255, blue: 18 / 255)
    static let canvas = Color(red: 10 / 255, green: 10 / 255, blue: 10 / 255)
    static let stroke = Color.white.opacity(0.12)
    static let ink = Color(red: 245 / 255, green: 245 / 255, blue: 247 / 255)
    static let inkMuted = Color(red: 198 / 255, green: 198 / 255, blue: 204 / 255)
    static let accent = Color(red: 0.42, green: 0.62, blue: 0.98)
    static let wellLight = Color(red: 0.96, green: 0.96, blue: 0.97)
    static let wellDark = Color(red: 0.11, green: 0.11, blue: 0.13)
    static let wellInk = Color(red: 0.22, green: 0.22, blue: 0.25)
}

enum DemoChrome {
    static func chartCard<Content: View>(
        title: String,
        subtitle: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(DemoPalette.ink)
                Text(subtitle)
                    .font(.caption.monospaced())
                    .foregroundStyle(DemoPalette.inkMuted)
                    .fixedSize(horizontal: false, vertical: true)
            }

            content()
                .padding(.horizontal, 4)
                .padding(.bottom, 6)
                .background(DemoPalette.canvas)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .padding(14)
        .background(DemoPalette.card, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(DemoPalette.stroke, lineWidth: 1)
                .allowsHitTesting(false)
        }
    }

    static func chip(_ text: String) -> some View {
        Text(text)
            .font(.caption2.weight(.medium).monospaced())
            .foregroundStyle(DemoPalette.ink)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.white.opacity(0.12), in: Capsule())
    }
}

struct SharedProgressControls: View {
    @Binding var settings: ProgressSettings

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Toggle("Visible", isOn: $settings.isVisible)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(DemoPalette.ink)
                .tint(DemoPalette.accent)

            VStack(alignment: .leading, spacing: 6) {
                Text("Progress \(formatted(settings.progress))")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(DemoPalette.ink)
                Slider(
                    value: $settings.progress,
                    in: 0...ProgressClock.upperBound,
                    step: 0.01
                )
                .tint(DemoPalette.accent)
                .disabled(settings.autoProgress)
                Text("One Binding<CGFloat> for every case. 0...1.5 so Default can rotate. Bars clamp at 1.")
                    .font(.caption)
                    .foregroundStyle(DemoPalette.inkMuted)
            }

            Toggle("Auto progress", isOn: $settings.autoProgress)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(DemoPalette.ink)
                .tint(DemoPalette.accent)

            VStack(alignment: .leading, spacing: 6) {
                Text("Bar height \(Int(settings.barHeight.rounded())) pt")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(DemoPalette.ink)
                Slider(value: $settings.barHeight, in: 4...28, step: 1)
                    .tint(DemoPalette.accent)
                Text("frame(height:) for bar, impulseBar, and dashBar. IndicatorType has no size argument.")
                    .font(.caption)
                    .foregroundStyle(DemoPalette.inkMuted)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("Diameter \(Int(settings.diameter.rounded())) pt")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(DemoPalette.ink)
                Slider(value: $settings.diameter, in: 36...120, step: 2)
                    .tint(DemoPalette.accent)
                Text("frame(width:height:) for default and circle.")
                    .font(.caption)
                    .foregroundStyle(DemoPalette.inkMuted)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("Foreground")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(DemoPalette.ink)
                Picker("Foreground", selection: $settings.foreground) {
                    ForEach(Ink.allCases) { ink in
                        Text(ink.title).tag(ink)
                    }
                }
                .pickerStyle(.menu)
                .tint(DemoPalette.ink)
                Text("foregroundStyle for every preset except Circle. The README writes foregroundColor.")
                    .font(.caption)
                    .foregroundStyle(DemoPalette.inkMuted)
            }
        }
    }

    private func formatted(_ value: Double) -> String {
        String(format: "%.2f", value)
    }
}

/// One `ProgressIndicatorView`. Off-tab state omits it. `isVisible` is the package binding.
struct ProgressWell: View {
    var isMounted: Bool
    var kind: IndicatorKind
    var progress: Binding<CGFloat>
    var isVisible: Binding<Bool>
    var foreground: Ink
    var parameters: IndicatorParameters
    var diameter: CGFloat
    var barHeight: CGFloat
    var prefersDarkWell: Bool
    var identity: String
    var idleText: String

    var body: some View {
        ZStack {
            prefersDarkWell ? DemoPalette.wellDark : DemoPalette.wellLight
            if isMounted {
                mounted
                if !isVisible.wrappedValue {
                    Text("Hidden")
                        .font(.subheadline)
                        .foregroundStyle(prefersDarkWell ? DemoPalette.inkMuted : DemoPalette.wellInk)
                }
            } else {
                Text(idleText)
                    .font(.subheadline)
                    .foregroundStyle(prefersDarkWell ? DemoPalette.inkMuted : DemoPalette.wellInk)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 148)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    @ViewBuilder
    private var mounted: some View {
        let type = kind.makeType(
            progress: progress,
            track: parameters.track,
            dashCount: parameters.dashCount,
            lineWidth: parameters.lineWidth,
            stroke: parameters.stroke
        )
        if kind.usesForegroundStyle {
            shaped(type)
                .foregroundStyle(foreground.color)
                .id(identity)
        } else {
            shaped(type)
                .id(identity)
        }
    }

    @ViewBuilder
    private func shaped(_ type: ProgressIndicatorView.IndicatorType) -> some View {
        if kind.isLinear {
            ProgressIndicatorView(isVisible: isVisible, type: type)
                .frame(maxWidth: .infinity)
                .frame(height: barHeight)
                .padding(.horizontal, 16)
        } else {
            ProgressIndicatorView(isVisible: isVisible, type: type)
                .frame(width: diameter, height: diameter)
        }
    }
}
