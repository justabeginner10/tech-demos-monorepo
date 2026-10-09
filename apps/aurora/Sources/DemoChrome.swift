import SwiftUI
import UIKit

enum DemoTab: Hashable {
    case live
    case gallery
}

enum DemoAppearance: String, CaseIterable, Identifiable {
    case system
    case light
    case dark

    var id: String { rawValue }

    var title: String {
        switch self {
        case .system: "System"
        case .light: "Light"
        case .dark: "Dark"
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: nil
        case .light: .light
        case .dark: .dark
        }
    }
}

/// Semantic colors so chrome stays readable in light and dark.
enum DemoPalette {
    static let page = Color(.systemGroupedBackground)
    static let card = Color(.secondarySystemGroupedBackground)
    static let canvas = Color(.tertiarySystemGroupedBackground)
    static let stroke = Color.primary.opacity(0.14)
    static let ink = Color.primary
    static let inkMuted = Color.secondary
    static let accent = Color(red: 0.62, green: 0.28, blue: 0.96)
}

enum DemoChrome {
    /// Floating iOS tab pill sits above the home indicator and does not
    /// always enlarge the safe area enough for Live's bottom controls.
    static let floatingTabClearance: CGFloat = 108

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
            .background(Color.primary.opacity(0.08), in: Capsule())
    }

    static func sliderRow(
        _ label: String,
        value: Binding<CGFloat>,
        range: ClosedRange<CGFloat>,
        format: String
    ) -> some View {
        HStack(spacing: 12) {
            Text(label)
                .font(.caption.weight(.medium).monospaced())
                .foregroundStyle(DemoPalette.inkMuted)
                .frame(width: 64, alignment: .leading)
            Slider(value: value, in: range)
            Text(String(format: format, value.wrappedValue))
                .font(.caption.weight(.semibold).monospaced())
                .foregroundStyle(DemoPalette.ink)
                .frame(width: 44, alignment: .trailing)
        }
        .accessibilityElement(children: .combine)
    }
}

extension Color {
    init(light: Color, dark: Color) {
        self.init(uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark ? UIColor(dark) : UIColor(light)
        })
    }
}
