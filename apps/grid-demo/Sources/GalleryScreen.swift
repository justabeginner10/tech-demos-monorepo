import SwiftUI

/// Preset grids. Each card is one public entry point, with that entry point's arguments written on the card.
struct GalleryScreen: View {
    var isSelected: Bool

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    header
                    FractionalTracksCard(isMounted: isSelected)
                    PointTracksCard(isMounted: isSelected)
                    FitTracksCard(isMounted: isSelected)
                    SpansCard(isMounted: isSelected)
                    StartsCard(isMounted: isSelected)
                    ContentModeCard(isMounted: isSelected)
                    FlowCard(isMounted: isSelected)
                    PackingCard(isMounted: isSelected)
                    SpacingCard(isMounted: isSelected)
                    GridGroupCard(isMounted: isSelected)
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
            Text("Tracks, spans, placement.")
                .font(.system(size: 34, weight: .regular, design: .serif))
                .foregroundStyle(DemoPalette.ink)

            Text(
                "Each card calls ExyteGrid.Grid. The stage has a fixed height so fill mode gets a real size. "
                    + "Leaving the tab removes every grid."
            )
            .font(.subheadline)
            .foregroundStyle(DemoPalette.inkMuted)
        }
    }
}

#Preview("Grid Gallery") {
    GalleryScreen(isSelected: true)
        .preferredColorScheme(.dark)
}
