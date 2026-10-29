import SwiftUI

enum DemoTab: Hashable {
    case live
    case gallery
}

enum LiveFamily: String, CaseIterable, Identifiable, Hashable {
    case toasts
    case floaters
    case sheets

    var id: String { rawValue }

    var title: String {
        switch self {
        case .toasts: "Toasts"
        case .floaters: "Floaters"
        case .sheets: "Sheets"
        }
    }

    var subtitle: String {
        switch self {
        case .toasts: ".type(.toast) · top / bottom · autohide"
        case .floaters: ".type(.floater()) · position · padding"
        case .sheets: ".default · drag toast · scrollPopup"
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
    /// Sample purple from the PopupView example (`9265F8`).
    static let accent = Color(red: 146 / 255, green: 101 / 255, blue: 248 / 255)
    static let paper = Color(red: 0.96, green: 0.96, blue: 0.97)
    static let paperInk = Color(red: 0.10, green: 0.10, blue: 0.12)
    static let paperMuted = Color(red: 0.32, green: 0.32, blue: 0.38)
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

extension View {
    func demoCard() -> some View {
        padding(14)
            .background(DemoPalette.card, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(DemoPalette.stroke, lineWidth: 1)
            }
    }
}
