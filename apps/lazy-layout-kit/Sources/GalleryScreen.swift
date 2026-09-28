import SwiftUI

/// Frozen algorithm snapshots. No `LazyLayoutView`, no scrolling million-item layouts.
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
            .safeAreaInset(edge: .bottom, spacing: 0) {
                Color.clear.frame(height: 56)
            }
        }
    }
}

#Preview("LazyLayoutKit Gallery") {
    GalleryScreen()
        .preferredColorScheme(.dark)
}
