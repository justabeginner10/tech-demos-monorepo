import SwiftUI

/// Read-only RichTextViewer cards. The editor is not mounted on this tab.
struct GalleryScreen: View {
    var isSelected: Bool

    private let columns = [GridItem(.adaptive(minimum: 300), spacing: 12)]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    header
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(GalleryFamily.allCases) { family in
                            DemoChrome.chartCard(title: family.title, subtitle: family.subtitle) {
                                GalleryCard(family: family, isSelected: isSelected)
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
            Text("Rich text")
                .font(.system(size: 34, weight: .bold))
                .foregroundStyle(DemoPalette.ink)

            Text(
                "Each card is a RichTextViewer. Nothing on this tab creates an editable "
                    + "RichTextEditor. Leaving the tab removes the viewers."
            )
            .font(.subheadline)
            .foregroundStyle(DemoPalette.inkMuted)
        }
    }
}

#Preview("RichTextKit Gallery") {
    GalleryScreen(isSelected: true)
}
