import SwiftUI

/// Frozen marketing stand-ins. Live playground owns every WhatsNewKit presentation.
enum GalleryFamily: String, CaseIterable, Identifiable {
    case automatic
    case harbor
    case atelier
    case signal
    case layout
    case stores

    var id: String { rawValue }

    var title: String {
        switch self {
        case .automatic: "Automatic"
        case .harbor: "Harbor"
        case .atelier: "Atelier"
        case .signal: "Signal"
        case .layout: "Layout"
        case .stores: "Version store"
        }
    }

    var subtitle: String {
        switch self {
        case .automatic: "environment · patch fallback"
        case .harbor: "openURL · 1.1.0"
        case .atelier: "markdown · present"
        case .signal: "attributed title · custom"
        case .layout: "spacing · radius"
        case .stores: "UserDefaults · memory · iCloud"
        }
    }

    var chips: [String] {
        switch self {
        case .automatic:
            ["whatsNewSheet()", "WhatsNewEnvironment", "2.2.1 → 2.2.0"]
        case .harbor:
            ["sheet(whatsNew:)", "openURL", "notification"]
        case .atelier:
            ["AttributedString", "Action.present", "hierarchical"]
        case .signal:
            ["Action.custom", "impact", "AttributedString"]
        case .layout:
            ["featureListSpacing", "footerActionSpacing", "reset()"]
        case .stores:
            ["UserDefaults", "InMemory", "remove(presentedVersion:)"]
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
        case .automatic:
            FrozenWhatsNewCard(
                title: "What's New in Field Notes",
                tint: DemoPalette.accent,
                rows: [
                    FeaturePaint("note.text", "First page", "A sheet for the features in this version."),
                    FeaturePaint("sparkles", "Automatic presentation", "The environment picks the sheet."),
                    FeaturePaint("number", "Patch fallback", "2.2.1 can show the 2.2.0 entry."),
                ],
                primaryTitle: "Continue",
                secondaryTitle: "Learn more"
            )
        case .harbor:
            FrozenWhatsNewCard(
                title: "What's New in Harbor",
                tint: ManualPreset.harbor.tint,
                rows: ManualPreset.harbor.rows,
                primaryTitle: ManualPreset.harbor.primaryTitle,
                secondaryTitle: ManualPreset.harbor.secondaryTitle
            )
        case .atelier:
            FrozenWhatsNewCard(
                title: "What's New in Atelier",
                tint: ManualPreset.atelier.tint,
                rows: ManualPreset.atelier.rows,
                primaryTitle: ManualPreset.atelier.primaryTitle,
                secondaryTitle: ManualPreset.atelier.secondaryTitle
            )
        case .signal:
            FrozenWhatsNewCard(
                title: "What's New in Signal",
                tint: ManualPreset.signal.tint,
                rows: ManualPreset.signal.rows,
                primaryTitle: ManualPreset.signal.primaryTitle,
                secondaryTitle: ManualPreset.signal.secondaryTitle
            )
        case .layout:
            FrozenWhatsNewCard(
                title: "Wider layout",
                tint: DemoPalette.accent,
                rows: [
                    FeaturePaint("square.grid.2x2", "Feature spacing", "featureListSpacing is 48 in this sketch."),
                    FeaturePaint("hand.tap", "Footer", "footerActionSpacing separates the two buttons."),
                ],
                primaryTitle: "Continue",
                secondaryTitle: nil,
                featureSpacing: 22,
                cornerRadius: 8
            )
        case .stores:
            VStack(alignment: .leading, spacing: 8) {
                storeRow("UserDefaults", "WhatsNewKit.<version> in the demo suite")
                storeRow("InMemory", "versions set, gone when the process ends")
                storeRow("iCloud", "NSUbiquitousKeyValueWhatsNewVersionStore")
            }
            .padding(4)
        }
    }

    private func storeRow(_ title: String, _ detail: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(DemoPalette.ink)
            Text(detail)
                .font(.caption)
                .foregroundStyle(DemoPalette.inkMuted)
        }
    }

    private var chipRow: some View {
        HStack(spacing: 6) {
            ForEach(chips, id: \.self) { label in
                DemoChrome.chip(label)
            }
        }
        .padding(.horizontal, 4)
        .padding(.bottom, 4)
    }
}

/// Painted what's-new sheet. Not `WhatsNewView`.
struct FrozenWhatsNewCard: View {
    var title: String
    var tint: Color
    var rows: [FeaturePaint]
    var primaryTitle: String
    var secondaryTitle: String?
    var featureSpacing: CGFloat = 14
    var cornerRadius: CGFloat = 14

    var body: some View {
        VStack(spacing: 16) {
            Text(title)
                .font(.title2.bold())
                .foregroundStyle(DemoPalette.ink)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)

            VStack(alignment: .leading, spacing: featureSpacing) {
                ForEach(rows) { row in
                    HStack(alignment: .center, spacing: 12) {
                        Image(systemName: row.symbol)
                            .font(.system(size: 20, weight: .regular))
                            .foregroundStyle(tint)
                            .frame(width: 32, height: 32)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(row.title)
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(DemoPalette.ink)
                            Text(row.subtitle)
                                .font(.caption)
                                .foregroundStyle(DemoPalette.inkMuted)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
            }

            VStack(spacing: 8) {
                if let secondaryTitle {
                    Text(secondaryTitle)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(tint)
                }
                Text(primaryTitle)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(tint, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(DemoPalette.canvas, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(DemoPalette.stroke, lineWidth: 1)
        }
        .accessibilityElement(children: .combine)
    }
}
