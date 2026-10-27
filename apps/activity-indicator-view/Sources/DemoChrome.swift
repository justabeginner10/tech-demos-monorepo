import ActivityIndicatorView
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

struct SharedIndicatorControls: View {
    @Binding var settings: IndicatorSettings

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Toggle("Visible", isOn: $settings.isVisible)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(DemoPalette.ink)
                .tint(DemoPalette.accent)

            VStack(alignment: .leading, spacing: 6) {
                Text("Size \(Int(settings.size.rounded())) pt")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(DemoPalette.ink)
                Slider(value: $settings.size, in: 36...120, step: 2)
                    .tint(DemoPalette.accent)
                Text("frame(width:height:). IndicatorType has no size argument.")
                    .font(.caption)
                    .foregroundStyle(DemoPalette.inkMuted)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("Foreground")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(DemoPalette.ink)
                Picker("Foreground", selection: $settings.tint) {
                    ForEach(IndicatorTint.allCases) { tint in
                        Text(tint.title).tag(tint)
                    }
                }
                .pickerStyle(.menu)
                .tint(DemoPalette.ink)
                Text("foregroundStyle for every preset except Growing Arc and Gradient.")
                    .font(.caption)
                    .foregroundStyle(DemoPalette.inkMuted)
            }
        }
    }
}

/// One `ActivityIndicatorView`. Hidden and off-tab states omit it so its `.task` animation stops.
struct IndicatorWell: View {
    var isMounted: Bool
    var kind: IndicatorKind
    var type: ActivityIndicatorView.IndicatorType
    var size: CGFloat
    var foreground: IndicatorTint
    var prefersDarkWell: Bool
    var identity: String
    var idleText: String

    var body: some View {
        ZStack {
            prefersDarkWell ? DemoPalette.wellDark : DemoPalette.wellLight
            if isMounted {
                mounted
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
        if kind.usesForegroundStyle {
            ActivityIndicatorView(type: type)
                .foregroundStyle(foreground.color)
                .frame(width: size, height: size)
                .id(identity)
        } else {
            ActivityIndicatorView(type: type)
                .frame(width: size, height: size)
                .id(identity)
        }
    }
}
