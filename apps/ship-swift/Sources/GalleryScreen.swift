import SwiftUI

/// Static snapshots of a curated ShipSwift slice. No live loops, no Metal.
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

#Preview("ShipSwift Gallery") {
    GalleryScreen()
        .preferredColorScheme(.dark)
}
