import DrafterCharts
import SwiftUI

/// Static samples of DrafterCharts public families. No timer.
struct GalleryScreen: View {
    private let columns = [GridItem(.adaptive(minimum: 300), spacing: 12)]

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(GalleryFamily.allCases) { family in
                        DemoChrome.chartCard(title: family.title, subtitle: family.subtitle) {
                            family.chart
                                .frame(height: family.cardHeight)
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

#Preview("DrafterCharts Gallery") {
    GalleryScreen()
        .preferredColorScheme(.dark)
        .drafterTheme(.dark)
}
