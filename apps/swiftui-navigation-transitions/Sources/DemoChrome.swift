import SwiftUI

enum DemoTab: Hashable {
    case live
    case gallery
}

enum LiveFamily: String, CaseIterable, Identifiable, Hashable {
    case presets
    case custom
    case gesture

    var id: String { rawValue }

    var title: String {
        switch self {
        case .presets: "Presets"
        case .custom: "Custom"
        case .gesture: "Gesture"
        }
    }

    var subtitle: String {
        switch self {
        case .presets: "slide · fade · combined"
        case .custom: "NavigationTransitionProtocol"
        case .gesture: "edgePan · contentPan"
        }
    }
}

enum DemoPalette {
    static let page = Color(red: 8 / 255, green: 8 / 255, blue: 10 / 255)
    static let card = Color(red: 16 / 255, green: 16 / 255, blue: 18 / 255)
    static let canvas = Color(red: 10 / 255, green: 10 / 255, blue: 10 / 255)
    static let stroke = Color.white.opacity(0.12)
    /// Hardcoded so the system scheme cannot paint black-on-black chrome.
    static let ink = Color(red: 245 / 255, green: 245 / 255, blue: 247 / 255)
    static let inkMuted = Color(red: 198 / 255, green: 198 / 255, blue: 204 / 255)
    static let accent = Color(red: 1, green: 0.55, blue: 0.22)
    static let bay = Color(red: 0.13, green: 0.22, blue: 0.40)
    static let rust = Color(red: 0.42, green: 0.18, blue: 0.14)
    static let pine = Color(red: 0.12, green: 0.30, blue: 0.24)
}

enum DemoChrome {
    static func chartCard<Content: View>(
        title: String,
        subtitle: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(DemoPalette.ink)
                Spacer()
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(DemoPalette.inkMuted)
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

struct InspectorCard<Content: View>: View {
    @ViewBuilder var content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            content()
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(DemoPalette.card, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(DemoPalette.stroke, lineWidth: 1)
                .allowsHitTesting(false)
        }
    }
}

struct DemoSlider: View {
    var title: String
    @Binding var value: Double
    var range: ClosedRange<Double>
    var step: Double?
    var format: String = "%.2f"

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(title)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(DemoPalette.ink)
                Spacer()
                Text(String(format: format, value))
                    .font(.caption.monospaced())
                    .foregroundStyle(DemoPalette.inkMuted)
            }
            slider
        }
    }

    @ViewBuilder
    private var slider: some View {
        if let step {
            Slider(value: $value, in: range, step: step)
                .tint(DemoPalette.accent)
        } else {
            Slider(value: $value, in: range)
                .tint(DemoPalette.accent)
        }
    }
}

func trailColor(_ depth: Int) -> Color {
    switch depth {
    case 0: DemoPalette.page
    case 1: DemoPalette.bay
    case 2: DemoPalette.rust
    default: DemoPalette.pine
    }
}

func trailTitle(_ depth: Int) -> String {
    switch depth {
    case 0: "Root"
    case 1: "One"
    case 2: "Two"
    default: "Three"
    }
}
