import ShadcnUI
import SwiftUI

/// Static snapshots of ShadKit surfaces. No live streams, no CanvasView.
struct GalleryScreen: View {
    private let columns = [GridItem(.adaptive(minimum: 300), spacing: 12)]

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(GalleryFamily.allCases) { family in
                        DemoChrome.chartCard(title: family.title, subtitle: family.subtitle) {
                            family.preview
                        }
                    }
                }
                .padding()
            }
            .background(DemoPalette.page)
            .navigationTitle("Gallery")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview("ShadKit Gallery") {
    GalleryScreen()
        .preferredColorScheme(.dark)
        .shadcnSurface()
}
