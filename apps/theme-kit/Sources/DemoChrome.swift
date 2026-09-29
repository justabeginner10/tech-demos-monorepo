import SwiftUI
import ThemeKit

enum DemoTab: Hashable {
    case live
    case gallery
}

enum LiveFamily: String, CaseIterable, Identifiable, Hashable {
    case themes
    case components
    case generator

    var id: String { rawValue }

    var title: String {
        switch self {
        case .themes: "Themes"
        case .components: "Components"
        case .generator: "Generator"
        }
    }

    var subtitle: String {
        switch self {
        case .themes: "ThemePicker · live preview"
        case .components: "Buttons · Badge · Chip · Field · Card"
        case .generator: "applyGenerated(primaryHex:)"
        }
    }
}

enum DemoPalette {
    static let page = Color(red: 8 / 255, green: 8 / 255, blue: 10 / 255)
    static let card = Color(red: 16 / 255, green: 16 / 255, blue: 18 / 255)
    static let canvas = Color(red: 10 / 255, green: 10 / 255, blue: 10 / 255)
    static let stroke = Color.white.opacity(0.08)
    /// Ink for the dark shell. Hardcoded so ThemeKit / system light scheme cannot
    /// paint `Color.primary` as black-on-black.
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
    /// `Color.primary` / `.secondary` stay light-on-dark. ThemeKit's own demo
    /// binds `preferredColorScheme` to `theme.isDark`; we do **not** — a light
    /// `Theme.shared` would make this chrome unreadable.
    func demoChromeScheme() -> some View {
        preferredColorScheme(.dark)
    }

    /// Match SwiftUI's environment scheme to a ThemeKit palette's light/dark
    /// side so token fallbacks (`?? .primary`) and native fields inside
    /// ThemeKit stay contrasted. Uses `environment(\.colorScheme)` rather than
    /// `preferredColorScheme` so it cannot override the dark window.
    func themeKitIslandScheme(_ theme: Theme) -> some View {
        environment(\.colorScheme, theme.isDark ? .dark : .light)
    }
}
