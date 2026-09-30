import DesignFoundation
import SwiftUI

enum DemoTab: Hashable {
    case live
    case gallery
}

enum LiveFamily: String, CaseIterable, Identifiable, Hashable {
    case themes
    case components
    case toast

    var id: String { rawValue }

    var title: String {
        switch self {
        case .themes: "Themes"
        case .components: "Components"
        case .toast: "Toast"
        }
    }

    var subtitle: String {
        switch self {
        case .themes: "Presets · light/dark · tokens"
        case .components: "Button · Field · Chip · Toggle · Card"
        case .toast: "DFToastQueue · .dfPopup"
        }
    }
}

/// Dark playground shell. Hardcoded so a light `.dfTheme` / `.dfThemePreset`
/// island cannot paint `Color.primary` as dark-on-black chrome.
enum DemoPalette {
    static let page = Color(red: 8 / 255, green: 8 / 255, blue: 10 / 255)
    static let card = Color(red: 16 / 255, green: 16 / 255, blue: 18 / 255)
    static let canvas = Color(red: 10 / 255, green: 10 / 255, blue: 10 / 255)
    static let stroke = Color.white.opacity(0.08)
    static let ink = Color.white
    static let inkMuted = Color.white.opacity(0.58)
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
            .foregroundStyle(DemoPalette.inkMuted)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.white.opacity(0.08), in: Capsule())
    }
}

extension View {
    /// Dark playground window: nav titles, tab pill, segmented picker, and
    /// `Color.primary` stay light-on-dark. Themed islands set
    /// `environment(\.colorScheme)` so light presets cannot override this.
    func demoChromeScheme() -> some View {
        preferredColorScheme(.dark)
    }

    /// Match SwiftUI's environment scheme to a DesignFoundation island so
    /// `.dfThemePreset` and token fallbacks stay contrasted. Uses
    /// `environment(\.colorScheme)` rather than `preferredColorScheme` so it
    /// cannot override the dark window.
    func dfIslandScheme(_ scheme: ColorScheme) -> some View {
        environment(\.colorScheme, scheme)
    }
}
