import DesignFoundation
import SwiftUI

/// Curated DesignFoundation presets for Live + Gallery. Not a singleton.
enum DemoPreset: String, CaseIterable, Identifiable, Hashable {
    case slate
    case aurora
    case copper
    case sage
    case garnet

    var id: String { rawValue }

    var title: String {
        rawValue.capitalized
    }

    var blurb: String {
        switch self {
        case .slate: "Navy · default radius"
        case .aurora: "Violet · rounded"
        case .copper: "Amber · sharp"
        case .sage: "Sage · airy"
        case .garnet: "Garnet · editorial"
        }
    }

    var preset: DFThemePreset {
        switch self {
        case .slate: .slate
        case .aurora: .aurora
        case .copper: .copper
        case .sage: .sage
        case .garnet: .garnet
        }
    }

    func theme(isDark: Bool) -> DFTheme {
        isDark ? preset.dark : preset.light
    }

    func swatch(isDark: Bool) -> Color {
        theme(isDark: isDark).colors.primary
    }
}

/// Host that applies `.dfTheme(_:)` from `body` and pins island `colorScheme`.
struct IsolatedThemeHost<Content: View>: View {
    let theme: DFTheme
    let colorScheme: ColorScheme
    @ViewBuilder let content: () -> Content

    var body: some View {
        content()
            .dfTheme(theme)
            .dfIslandScheme(colorScheme)
    }
}

/// Host that applies `.dfThemePreset(_:)` from `body`. The preset reads
/// `@Environment(\.colorScheme)` from this wrapper.
struct IsolatedPresetHost<Content: View>: View {
    let preset: DFThemePreset
    let colorScheme: ColorScheme
    @ViewBuilder let content: () -> Content

    var body: some View {
        content()
            .dfThemePreset(preset)
            .dfIslandScheme(colorScheme)
    }
}
