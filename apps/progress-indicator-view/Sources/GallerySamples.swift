import SwiftUI

struct GalleryPresetCard: View {
    let kind: IndicatorKind
    let settings: ProgressSettings
    var progress: Binding<CGFloat>
    var isVisible: Binding<Bool>
    var isSelected: Bool

    var body: some View {
        DemoChrome.chartCard(title: kind.title, subtitle: kind.signature) {
            VStack(alignment: .leading, spacing: 8) {
                ProgressWell(
                    isMounted: isSelected,
                    kind: kind,
                    progress: progress,
                    isVisible: isVisible,
                    foreground: settings.foreground,
                    parameters: .packageDefault,
                    diameter: CGFloat(settings.diameter),
                    barHeight: CGFloat(settings.barHeight),
                    prefersDarkWell: kind.prefersDarkWell(
                        foreground: settings.foreground,
                        track: .clear,
                        stroke: .red
                    ),
                    identity: kind.presetCall,
                    idleText: "Unmounted"
                )
                Text(kind.presetCall)
                    .font(.caption2.monospaced())
                    .foregroundStyle(DemoPalette.inkMuted)
                    .padding(.horizontal, 8)
                chipRow
            }
        }
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
            labels.append("foreground .\(settings.foreground.rawValue)")
        }
        return labels
    }
}
