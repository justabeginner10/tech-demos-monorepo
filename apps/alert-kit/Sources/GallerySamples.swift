import SwiftUI

enum GalleryCard: String, CaseIterable, Identifiable {
    case banner
    case center
    case icons
    case haptics
    case dismiss
    case calls

    var id: String { rawValue }

    var title: String {
        switch self {
        case .banner: "Banner"
        case .center: "Center"
        case .icons: "Icons"
        case .haptics: "Haptics"
        case .dismiss: "Dismiss"
        case .calls: "Calls"
        }
    }

    var subtitle: String {
        switch self {
        case .banner: ".iOS17AppleMusic"
        case .center: ".iOS16AppleMusic"
        case .icons: "AlertIcon"
        case .haptics: "AlertHaptic"
        case .dismiss: "tap · time · all"
        case .calls: "API · modifier"
        }
    }

    var chips: [String] {
        switch self {
        case .banner:
            ["bottom", "radius 14", "line 3"]
        case .center:
            ["center", "radius 8", "line 9"]
        case .icons:
            [".done", ".error", ".heart", ".spinnerSmall", ".spinnerLarge", ".custom", "nil"]
        case .haptics:
            [".success", ".warning", ".error", "AlertHaptic.none", "nil"]
        case .dismiss:
            ["dismissByTap", "dismissInTime", "duration", "dismissAllAlerts"]
        case .calls:
            ["present(title:)", "present(view:)", ".alert(isPresent:)"]
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
        case .banner:
            AlertSketch(
                style: .banner,
                icon: .done,
                title: "Added to Library",
                subtitle: nil
            )
        case .center:
            AlertSketch(
                style: .center,
                icon: .error,
                title: "Couldn't Add",
                subtitle: "Favorites"
            )
        case .icons:
            IconRow()
        case .haptics:
            Text("success, warning, and error are notification haptics. nil skips impact(). AlertHaptic.none calls it and returns.")
                .font(.caption)
                .foregroundStyle(DemoPalette.inkMuted)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, minHeight: 88, alignment: .leading)
                .padding(8)
        case .dismiss:
            Text("Timed dismiss is 1.5s after the 0.2s present animation. Spinners start with both dismiss flags off. dismissAllAlerts only removes AlertAppleMusic17View.")
                .font(.caption)
                .foregroundStyle(DemoPalette.inkMuted)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, minHeight: 88, alignment: .leading)
                .padding(8)
        case .calls:
            Text("Live → API uses present(title:). Live → View uses present(view:). Live → Modifier uses .alert(isPresent:view:).")
                .font(.caption)
                .foregroundStyle(DemoPalette.inkMuted)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, minHeight: 88, alignment: .leading)
                .padding(8)
        }
    }

    private var chipRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                ForEach(chips, id: \.self) { chip in
                    DemoChrome.chip(chip)
                }
            }
        }
    }
}

private struct IconRow: View {
    var body: some View {
        HStack(spacing: 10) {
            mark("checkmark", "done")
            mark("xmark", "error")
            mark("heart.fill", "heart")
            VStack(spacing: 4) {
                ProgressView()
                    .controlSize(.small)
                    .tint(DemoPalette.packageInk)
                Text("spin")
                    .font(.caption2.monospaced())
                    .foregroundStyle(DemoPalette.inkMuted)
            }
            mark("star.fill", "custom")
            VStack(spacing: 4) {
                Text("Aa")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(DemoPalette.packageInk)
                Text("nil")
                    .font(.caption2.monospaced())
                    .foregroundStyle(DemoPalette.inkMuted)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 88)
        .padding(8)
    }

    private func mark(_ symbol: String, _ caption: String) -> some View {
        VStack(spacing: 4) {
            Image(systemName: symbol)
                .font(.body.weight(.semibold))
                .foregroundStyle(DemoPalette.packageInk)
            Text(caption)
                .font(.caption2.monospaced())
                .foregroundStyle(DemoPalette.inkMuted)
        }
    }
}
