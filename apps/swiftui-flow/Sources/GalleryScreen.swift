import SwiftUI

/// Preset flows. Each card is one public entry point, with that entry point's arguments written on the card.
struct GalleryScreen: View {
    var isSelected: Bool

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    header
                    TagCloudCard(isMounted: isSelected)
                    VerticalFlowCard(isMounted: isSelected)
                    RowAlignmentCard(isMounted: isSelected)
                    SpacingCard(isMounted: isSelected)
                    JustifiedCard(isMounted: isSelected)
                    DistributedCard(isMounted: isSelected)
                    FlexibilityCard(isMounted: isSelected)
                    MaxLinesCard(isMounted: isSelected)
                    SeparatorsCard(isMounted: isSelected)
                    BreaksCard(isMounted: isSelected)
                    LayoutTypeCard(isMounted: isSelected)
                    DirectionCard(isMounted: isSelected)
                    LazyFlowCard(isMounted: isSelected)
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
            Text("Rows, columns, wraps.")
                .font(.system(size: 34, weight: .regular, design: .serif))
                .foregroundStyle(DemoPalette.ink)

            Text(
                "Each card calls HFlow, VFlow, HFlowLayout, VFlowLayout, LazyHFlow, or LazyVFlow. "
                    + "A fixed width or height is what makes the stack wrap. Leaving the tab removes every flow."
            )
            .font(.subheadline)
            .foregroundStyle(DemoPalette.inkMuted)
        }
    }
}

#Preview("Flow Gallery") {
    GalleryScreen(isSelected: true)
        .preferredColorScheme(.dark)
}
