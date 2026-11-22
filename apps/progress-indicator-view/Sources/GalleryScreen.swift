import SwiftUI

/// The five presets. Each card mounts one `ProgressIndicatorView` with the package default arguments.
struct GalleryScreen: View {
    var isSelected: Bool
    @Binding var settings: ProgressSettings

    private let columns = [GridItem(.adaptive(minimum: 168), spacing: 12)]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    header
                    controlCard
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(IndicatorKind.allCases) { kind in
                            GalleryPresetCard(
                                kind: kind,
                                settings: settings,
                                progress: progress,
                                isVisible: $settings.isVisible,
                                isSelected: isSelected
                            )
                        }
                    }
                }
                .padding()
            }
            .background(DemoPalette.page)
            .navigationTitle("Gallery")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(DemoPalette.page, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .safeAreaInset(edge: .bottom, spacing: 0) {
                Color.clear.frame(height: 56)
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Five presets.")
                .font(.system(size: 34, weight: .regular, design: .serif))
                .foregroundStyle(DemoPalette.ink)

            Text(
                "Each card is ProgressIndicatorView with that case's default associated values. "
                    + "Progress, Visible, foreground, and frame size are shared with Live. "
                    + "Track color, dash count, line width, and stroke color stay on the package defaults here."
            )
            .font(.subheadline)
            .foregroundStyle(DemoPalette.inkMuted)
        }
    }

    private var controlCard: some View {
        SharedProgressControls(settings: $settings)
            .padding(14)
            .background(DemoPalette.card, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(DemoPalette.stroke, lineWidth: 1)
                    .allowsHitTesting(false)
            }
    }

    private var progress: Binding<CGFloat> {
        Binding(
            get: { CGFloat(settings.progress) },
            set: { settings.progress = Double($0) }
        )
    }
}

#Preview("Progress Gallery") {
    GalleryScreen(isSelected: true, settings: .constant(ProgressSettings()))
        .preferredColorScheme(.dark)
}
