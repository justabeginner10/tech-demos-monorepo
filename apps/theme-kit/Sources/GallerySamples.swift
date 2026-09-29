import SwiftUI
import ThemeKit

/// Frozen themed cards and a chip grid. Isolated `Theme` instances; no timers.
enum GalleryFamily: String, CaseIterable, Identifiable {
    case defaultTheme
    case ocean
    case dracula
    case chips
    case atoms

    var id: String { rawValue }

    var title: String {
        switch self {
        case .defaultTheme: "Default"
        case .ocean: "Ocean"
        case .dracula: "Dracula"
        case .chips: "Chips"
        case .atoms: "Atoms"
        }
    }

    var subtitle: String {
        switch self {
        case .defaultTheme: "ThemePreset.default · isolated"
        case .ocean: "oceanTheme JSON · isolated"
        case .dracula: "ThemePreset.dracula · isolated"
        case .chips: "No Theme.shared mutation"
        case .atoms: "Badge · Avatar · ProgressBar"
        }
    }

    var chips: [String] {
        switch self {
        case .defaultTheme:
            ["preset default", ".theme(_:)", "no shared"]
        case .ocean:
            ["oceanTheme", "bundled JSON", "isolated"]
        case .dracula:
            ["preset dracula", "dark", "isolated"]
        case .chips:
            ["Chip", "no binding", "frozen"]
        case .atoms:
            ["Badge", "Avatar", "ProgressBar"]
        }
    }

    @ViewBuilder
    var preview: some View {
        VStack(alignment: .leading, spacing: 8) {
            snapshot
            chipRow
        }
    }

    /// Apply `.theme(_:)` inside a `View.body` (MainActor) so Swift 6
    /// region-isolation accepts ThemeKit's MainActor-bound modifier.
    @ViewBuilder
    private var snapshot: some View {
        switch self {
        case .defaultTheme:
            IsolatedThemeHost(theme: IsolatedThemes.default) {
                FrozenThemedCard(caption: "Default")
            }
        case .ocean:
            IsolatedThemeHost(theme: IsolatedThemes.ocean) {
                FrozenThemedCard(caption: "Ocean")
            }
        case .dracula:
            IsolatedThemeHost(theme: IsolatedThemes.dracula) {
                FrozenThemedCard(caption: "Dracula")
            }
        case .chips:
            IsolatedThemeHost(theme: IsolatedThemes.default) {
                FrozenChipGrid()
            }
        case .atoms:
            IsolatedThemeHost(theme: IsolatedThemes.nord) {
                FrozenAtoms()
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

/// Host that applies ThemeKit's `.theme(_:)` from `body` (MainActor).
private struct IsolatedThemeHost<Content: View>: View {
    let theme: Theme
    @ViewBuilder let content: () -> Content

    var body: some View {
        content()
            .theme(theme)
            .themeKitIslandScheme(theme)
    }
}

private struct FrozenThemedCard: View {
    @ThemeContext private var theme
    let caption: String

    var body: some View {
        Card(caption) {
            VStack(alignment: .leading, spacing: theme.spacing(.sm)) {
                HStack(spacing: theme.spacing(.sm)) {
                    Avatar(.initials("TK"))
                        .size(.sm)
                    Badge("Live off")
                        .badgeStyle(.neutral)
                    PrimaryButton("Book") {}
                        .controlSize(.small)
                }
                Text("Injected with `.theme(_:)`. Theme.shared is untouched.")
                    .textStyle(.bodySm400)
                    .foregroundStyle(theme.text(.textSecondary))
            }
        }
        .subtitle("Isolated Theme")
        .elevation(.soft)
        .padding(8)
        .background(theme.background(.bgBase))
    }
}

private struct FrozenChipGrid: View {
    @ThemeContext private var theme

    private let labels = ["Filter", "Direct", "Wifi", "Pool", "Pets"]

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing(.sm)) {
            Text("Status chips, no selection binding.")
                .textStyle(.bodySm400)
                .foregroundStyle(theme.text(.textSecondary))
            FlowWrap(labels) { label in
                Chip(label)
                    .size(.small)
            }
        }
        .padding(theme.spacing(.md))
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(theme.background(.bgWhite))
    }
}

private struct FrozenAtoms: View {
    @ThemeContext private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing(.md)) {
            HStack(spacing: theme.spacing(.sm)) {
                Avatar(.initials("NK"))
                    .size(.md)
                Badge("Info")
                    .badgeStyle(.info)
                Badge("OK")
                    .badgeStyle(.success)
                    .variant(.solid)
            }
            ProgressBar(value: 0.4)
                .showsPercentage()
                .status(.success)
        }
        .padding(theme.spacing(.md))
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(theme.background(.bgWhite))
    }
}

/// Tiny wrapping row so Gallery chips stay a grid without a live layout kit.
private struct FlowWrap<Item: Hashable, Content: View>: View {
    let items: [Item]
    let content: (Item) -> Content

    init(_ items: [Item], @ViewBuilder content: @escaping (Item) -> Content) {
        self.items = items
        self.content = content
    }

    var body: some View {
        FlexibleChipRow(items: items, content: content)
    }
}

private struct FlexibleChipRow<Item: Hashable, Content: View>: View {
    let items: [Item]
    let content: (Item) -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                ForEach(items.prefix(3), id: \.self, content: content)
            }
            HStack(spacing: 8) {
                ForEach(items.dropFirst(3), id: \.self, content: content)
            }
        }
    }
}
