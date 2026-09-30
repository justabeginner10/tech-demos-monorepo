import DesignFoundation
import SwiftUI

/// Frozen themed cards. Isolated `.dfTheme` / `.dfThemePreset` per card.
enum GalleryFamily: String, CaseIterable, Identifiable {
    case slateLight
    case auroraDark
    case copperLight
    case sageDark
    case garnetLight
    case chips
    case atoms
    case popupCard

    var id: String { rawValue }

    var title: String {
        switch self {
        case .slateLight: "Slate"
        case .auroraDark: "Aurora"
        case .copperLight: "Copper"
        case .sageDark: "Sage"
        case .garnetLight: "Garnet"
        case .chips: "Chips"
        case .atoms: "Atoms"
        case .popupCard: "Popup card"
        }
    }

    var subtitle: String {
        switch self {
        case .slateLight: ".dfTheme(.slateLight)"
        case .auroraDark: ".dfThemePreset(.aurora) · dark"
        case .copperLight: ".dfTheme(.copperLight)"
        case .sageDark: ".dfThemePreset(.sage) · dark"
        case .garnetLight: ".dfTheme(.garnetLight)"
        case .chips: "No queue · frozen"
        case .atoms: "Badge · Avatar · ProgressBar"
        case .popupCard: "DFPopupCard · not presented"
        }
    }

    var chips: [String] {
        switch self {
        case .slateLight:
            ["preset slate", ".dfTheme", "light"]
        case .auroraDark:
            ["preset aurora", ".dfThemePreset", "dark"]
        case .copperLight:
            ["preset copper", ".dfTheme", "light"]
        case .sageDark:
            ["preset sage", ".dfThemePreset", "dark"]
        case .garnetLight:
            ["preset garnet", ".dfTheme", "light"]
        case .chips:
            ["Chip", "no binding", "frozen"]
        case .atoms:
            ["Badge", "Avatar", "ProgressBar"]
        case .popupCard:
            ["DFPopupCard", "no .dfPopup", "static"]
        }
    }

    @ViewBuilder
    var preview: some View {
        VStack(alignment: .leading, spacing: 8) {
            snapshot
            chipRow
        }
    }

    @ViewBuilder
    private var snapshot: some View {
        switch self {
        case .slateLight:
            IsolatedThemeHost(theme: .slateLight, colorScheme: .light) {
                FrozenThemedCard(caption: "Slate")
            }
        case .auroraDark:
            IsolatedPresetHost(preset: .aurora, colorScheme: .dark) {
                FrozenThemedCard(caption: "Aurora")
            }
        case .copperLight:
            IsolatedThemeHost(theme: .copperLight, colorScheme: .light) {
                FrozenThemedCard(caption: "Copper")
            }
        case .sageDark:
            IsolatedPresetHost(preset: .sage, colorScheme: .dark) {
                FrozenThemedCard(caption: "Sage")
            }
        case .garnetLight:
            IsolatedThemeHost(theme: .garnetLight, colorScheme: .light) {
                FrozenThemedCard(caption: "Garnet")
            }
        case .chips:
            IsolatedThemeHost(theme: .slateLight, colorScheme: .light) {
                FrozenChipGrid()
            }
        case .atoms:
            IsolatedPresetHost(preset: .copper, colorScheme: .dark) {
                FrozenAtoms()
            }
        case .popupCard:
            IsolatedThemeHost(theme: .garnetDark, colorScheme: .dark) {
                FrozenPopupCard()
            }
        }
    }

    private var chipRow: some View {
        HStack(spacing: 6) {
            ForEach(chips, id: \.self) { label in
                DemoChrome.chip(label)
            }
        }
        .padding(.horizontal, 8)
        .padding(.bottom, 8)
    }
}

private struct FrozenThemedCard: View {
    @Environment(\.dfTheme) private var theme
    let caption: String

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            HStack(spacing: theme.spacing.sm) {
                DFAvatar("DF", size: 32)
                DFBadge(text: "Live off")
                    .dfBadgeStyle(.tinted)
                DFButton("Book") {}
            }
            DFText(caption, scale: .headline)
            DFText("Injected per card. No shared theme singleton.", scale: .caption)
        }
        .padding(theme.spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(theme.colors.background)
    }
}

private struct FrozenChipGrid: View {
    @Environment(\.dfTheme) private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            DFText("Status chips, no selection binding.", scale: .caption)
            HStack(spacing: theme.spacing.sm) {
                DFChip("Filter")
                DFChip(.labelWithIcon("Direct", systemImage: "paperplane"))
                DFChip(.selectable("Wifi"), isSelected: true)
                    .dfChipStyle(.tinted)
            }
            HStack(spacing: theme.spacing.sm) {
                DFChip("Pool")
                    .dfChipStyle(.outlined)
                DFChip("Pets")
            }
        }
        .padding(theme.spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(theme.colors.background)
    }
}

private struct FrozenAtoms: View {
    @Environment(\.dfTheme) private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.md) {
            HStack(spacing: theme.spacing.sm) {
                DFAvatar("NK", size: 40, presence: .online)
                DFBadge(text: "Info")
                DFBadge(text: "OK")
                    .dfBadgeStyle(.outlined)
            }
            DFProgressBar(value: 0.4, label: "Idle")
        }
        .padding(theme.spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(theme.colors.background)
    }
}

/// Composed popup content without mounting `.dfPopup` (no overlay, no timers).
private struct FrozenPopupCard: View {
    @Environment(\.dfTheme) private var theme

    var body: some View {
        DFPopupCard(
            icon: "sparkles",
            title: "Orbit Pro",
            message: "Frozen card. Gallery never presents a popup host.",
            primaryAction: DFPopupAction("Upgrade") {},
            secondaryAction: DFPopupAction("Not now") {}
        )
        .padding(theme.spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(theme.colors.surfaceElevated)
    }
}
