import SwiftUI

/// Preset pictures. Each card is one public entry point, with that entry point written on the card.
struct GalleryScreen: View {
    var isSelected: Bool

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    header
                    FileCard(isMounted: isSelected)
                    StringCard(isMounted: isSelected)
                    DataCard(isMounted: isSelected)
                    StreamCard(isMounted: isSelected)
                    XMLCard(isMounted: isSelected)
                    NodesCard(isMounted: isSelected)
                    GradientCard(isMounted: isSelected)
                    StrokeCard(isMounted: isSelected)
                    ReuseCard(isMounted: isSelected)
                    TextCard(isMounted: isSelected)
                    StyleCard(isMounted: isSelected)
                    GroupCard(isMounted: isSelected)
                    ImageCard(isMounted: isSelected)
                    AspectCard(isMounted: isSelected)
                    SettingsCard(isMounted: isSelected)
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
            Text("Parse, then draw.")
                .font(.system(size: 34, weight: .regular, design: .serif))
                .foregroundStyle(DemoPalette.ink)

            Text(
                "Each card calls SVGView or SVGParser. The stage has a fixed height so the viewport gets a real size. "
                    + "Leaving the tab removes every picture."
            )
            .font(.subheadline)
            .foregroundStyle(DemoPalette.inkMuted)
        }
    }
}

#Preview("SVGView Gallery") {
    GalleryScreen(isSelected: true)
        .preferredColorScheme(.dark)
}
