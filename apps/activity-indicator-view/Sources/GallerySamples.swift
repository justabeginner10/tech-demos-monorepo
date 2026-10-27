import SwiftUI

struct GalleryPresetCard: View {
    let kind: IndicatorKind
    let settings: IndicatorSettings
    var isSelected: Bool

    var body: some View {
        DemoChrome.chartCard(title: kind.title, subtitle: kind.signature) {
            VStack(alignment: .leading, spacing: 8) {
                IndicatorWell(
                    isMounted: isSelected && settings.isVisible,
                    kind: kind,
                    type: kind.presetType,
                    size: CGFloat(settings.size),
                    foreground: settings.tint,
                    prefersDarkWell: kind.prefersDarkWell(foreground: settings.tint, arcTint: .black),
                    identity: identity,
                    idleText: isSelected ? "Hidden" : "Unmounted"
                )
                Text(kind.presetCall)
                    .font(.caption2.monospaced())
                    .foregroundStyle(DemoPalette.inkMuted)
                    .padding(.horizontal, 8)
                chipRow
            }
        }
    }

    private var identity: String {
        kind.presetCall
    }

    private var chipRow: some View {
        VStack(alignment: .leading, spacing: 6) {
            ForEach(chips, id: \.self) { label in
                DemoChrome.chip(label)
            }
        }
        .padding(.horizontal, 8)
        .padding(.bottom, 8)
    }

    private var chips: [String] {
        var labels = kind.presetChips
        if kind.usesForegroundStyle {
            labels.append("foreground .\(settings.tint.rawValue)")
        }
        return labels
    }
}
