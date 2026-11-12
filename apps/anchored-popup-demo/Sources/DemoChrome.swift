import SwiftUI

enum DemoTab: Hashable {
    case live
    case gallery
}

enum LiveFamily: String, CaseIterable, Identifiable, Hashable {
    case corners
    case placement
    case behavior

    var id: String { rawValue }

    var title: String {
        switch self {
        case .corners: "Corners"
        case .placement: "Placement"
        case .behavior: "Behavior"
        }
    }

    var subtitle: String {
        switch self {
        case .corners: "anchorRelative · minimal overload"
        case .placement: "auto · screenRelative · absolute"
        case .behavior: "animation · dismiss · displayMode"
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
    static let accent = Color(red: 0.98, green: 0.78, blue: 0.28)
    static let paper = Color(red: 0.96, green: 0.93, blue: 0.86)
    static let paperInk = Color(red: 0.16, green: 0.14, blue: 0.12)
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

struct DemoSlider: View {
    var title: String
    @Binding var value: Double
    var range: ClosedRange<Double>
    var step: Double
    var format: String = "%.0f"

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
            Slider(value: $value, in: range, step: step)
                .tint(DemoPalette.accent)
        }
    }
}

struct AnchorStage<Content: View>: View {
    @ViewBuilder var content: () -> Content

    var body: some View {
        ZStack {
            DemoPalette.canvas
            content()
                .padding(16)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 300)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(DemoPalette.stroke, lineWidth: 1)
                .allowsHitTesting(false)
        }
    }
}

struct SourceDisc: View {
    var title: String
    var systemImage: String

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: systemImage)
                .font(.body.weight(.semibold))
            Text(title)
                .font(.caption2.weight(.semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .foregroundStyle(DemoPalette.page)
        .frame(width: 72, height: 64)
        .background(DemoPalette.accent, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .accessibilityLabel(title)
    }
}

extension View {
    func demoCard() -> some View {
        padding(14)
            .background(DemoPalette.card, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(DemoPalette.stroke, lineWidth: 1)
            }
    }

    /// Inactive families stay in the tree so their presenters can still close a window.
    func familyVisibility(_ visible: Bool) -> some View {
        opacity(visible ? 1 : 0)
            .allowsHitTesting(visible)
            .accessibilityHidden(!visible)
            .zIndex(visible ? 1 : 0)
    }
}
