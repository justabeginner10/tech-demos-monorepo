import SwiftUI

/// Remote stills in a grid, plus one GIF player and one animated WebP player.
struct GalleryScreen: View {
    var isSelected: Bool

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    header
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(RemoteStill.gallery) { still in
                            GalleryTile(still: still, isMounted: isSelected)
                        }
                    }
                    AnimatedClipCard(clip: .gif, isMounted: isSelected)
                    AnimatedClipCard(clip: .webp, isMounted: isSelected)
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
            Text("Remote images.")
                .font(.system(size: 34, weight: .regular, design: .serif))
                .foregroundStyle(DemoPalette.ink)

            Text(
                "Each tile is a WebImage. The two cards are AnimatedImage, one GIF and one animated WebP. "
                    + "Leaving the tab removes every loader."
            )
            .font(.subheadline)
            .foregroundStyle(DemoPalette.inkMuted)
        }
    }
}

#Preview("WebImage Gallery") {
    GalleryScreen(isSelected: true)
        .preferredColorScheme(.dark)
}
