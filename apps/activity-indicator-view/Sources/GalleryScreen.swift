import SwiftUI

/// The ten presets. Each card mounts one `ActivityIndicatorView` with the package default arguments.
struct GalleryScreen: View {
    var isSelected: Bool
    @Binding var settings: IndicatorSettings

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
            Text("Ten presets.")
                .font(.system(size: 34, weight: .regular, design: .serif))
                .foregroundStyle(DemoPalette.ink)

            Text(
                "Each card is ActivityIndicatorView with that case's default associated values. "
                    + "Visible, size, and foreground are shared with Live. "
                    + "Count, inset, line width, line cap, and gradient colors stay on the package defaults here."
            )
            .font(.subheadline)
            .foregroundStyle(DemoPalette.inkMuted)
        }
    }

    private var controlCard: some View {
        SharedIndicatorControls(settings: $settings)
            .padding(14)
            .background(DemoPalette.card, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(DemoPalette.stroke, lineWidth: 1)
                    .allowsHitTesting(false)
            }
    }
}

#Preview("Indicator Gallery") {
    GalleryScreen(isSelected: true, settings: .constant(IndicatorSettings()))
        .preferredColorScheme(.dark)
}
