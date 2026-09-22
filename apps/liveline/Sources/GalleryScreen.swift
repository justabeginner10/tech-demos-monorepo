import Liveline
import SwiftUI

/// Static samples of Liveline families that are not on the live playground.
struct GalleryScreen: View {
    private let columns = [GridItem(.adaptive(minimum: 300), spacing: 12)]

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(GalleryFamily.allCases) { family in
                        DemoChrome.chartCard(title: family.title, subtitle: family.subtitle) {
                            family.chart
                                .frame(height: 168)
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

#Preview("Liveline Gallery") {
    GalleryScreen()
        .preferredColorScheme(.dark)
}
