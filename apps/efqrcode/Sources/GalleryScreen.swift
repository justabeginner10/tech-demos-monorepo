import SwiftUI

/// Frozen cards. No `EFQRCode.Generator` and no `EFQRCode.Recognizer`.
struct GalleryScreen: View {
    private let columns = [GridItem(.adaptive(minimum: 300), spacing: 12)]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    header
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(GalleryCard.allCases) { card in
                            DemoChrome.chartCard(title: card.title, subtitle: card.subtitle) {
                                card.preview
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
            .toolbarColorScheme(.dark, for: .navigationBar)
            .safeAreaInset(edge: .bottom, spacing: 0) {
                Color.clear.frame(height: 56)
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Ten styles, held still.")
                .font(.system(size: 34, weight: .regular, design: .serif))
                .foregroundStyle(DemoPalette.ink)

            Text(
                "Painted stand-ins for the EFQRCodeStyle cases Live can mount. "
                    + "No Generator, no Recognizer, no SVG."
            )
            .font(.subheadline)
            .foregroundStyle(DemoPalette.inkMuted)
        }
    }
}

#Preview("EFQRCode Gallery") {
    GalleryScreen()
        .preferredColorScheme(.dark)
}
