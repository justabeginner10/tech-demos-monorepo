import SwiftUI

/// Frozen what's-new cards. No `.whatsNewSheet`, no `.sheet(whatsNew:)`, no `WhatsNewView`.
struct GalleryScreen: View {
    private let columns = [GridItem(.adaptive(minimum: 300), spacing: 12)]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    header
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(GalleryFamily.allCases) { family in
                            DemoChrome.chartCard(title: family.title, subtitle: family.subtitle) {
                                family.preview
                            }
                        }
                    }
                }
                .padding()
            }
            .background(DemoPalette.page)
            .navigationTitle("Gallery")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(DemoPalette.page, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .safeAreaInset(edge: .bottom, spacing: 0) {
                Color.clear.frame(height: 56)
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("What's New")
                .font(.system(size: 34, weight: .bold))
                .foregroundStyle(DemoPalette.ink)

            Text(
                "Static snapshots of the sheets Live can present. No WhatsNewKit "
                    + "modifier is attached on this tab. The rows and buttons are painted SwiftUI."
            )
            .font(.subheadline)
            .foregroundStyle(DemoPalette.inkMuted)
        }
    }
}

#Preview("WhatsNewKit Gallery") {
    GalleryScreen()
}
