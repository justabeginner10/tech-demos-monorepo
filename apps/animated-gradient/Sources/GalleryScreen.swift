import SwiftUI

/// Preset gradients. Each card is one public entry point, with that entry point's arguments written on the card.
struct GalleryScreen: View {
    var isSelected: Bool

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    header
                    MinimalCard(isMounted: isSelected, reducesMotion: reduceMotion)
                    ModifiersCard(isMounted: isSelected, reducesMotion: reduceMotion)
                    PastelCard(isMounted: isSelected, reducesMotion: reduceMotion)
                    BrightCard(isMounted: isSelected, reducesMotion: reduceMotion)
                    ExampleCard(isMounted: isSelected, reducesMotion: reduceMotion)
                    OneStopCard(isMounted: isSelected, reducesMotion: reduceMotion)
                    CycledStopsCard(isMounted: isSelected, reducesMotion: reduceMotion)
                    StartPointCard(isMounted: isSelected, reducesMotion: reduceMotion)
                    EndPointCard(isMounted: isSelected, reducesMotion: reduceMotion)
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
            Text("Presets and modifiers.")
                .font(.system(size: 34, weight: .regular, design: .serif))
                .foregroundStyle(DemoPalette.ink)

            Text(
                "Each card calls AnimatedLinearGradient. Start only and End only use the one-argument gradientPoints overloads. "
                    + "Leaving the tab removes every gradient. Reduce Motion swaps in a SwiftUI LinearGradient of that card's colors and points."
            )
            .font(.subheadline)
            .foregroundStyle(DemoPalette.inkMuted)
        }
    }
}

#Preview("Gradient Gallery") {
    GalleryScreen(isSelected: true)
        .preferredColorScheme(.dark)
}
