import SwiftUI

/// Painted cards. No ConcentricOnboardingView is created on this tab.
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
            Text("Circles, held still.")
                .font(.system(size: 34, weight: .regular, design: .serif))
                .foregroundStyle(DemoPalette.ink)

            Text(
                "Painted stand-ins for the four pages, the button, and the public hooks. "
                    + "No ConcentricOnboardingView is mounted on this tab."
            )
            .font(.subheadline)
            .foregroundStyle(DemoPalette.inkMuted)
        }
    }
}

#Preview("Onboarding Gallery") {
    GalleryScreen()
        .preferredColorScheme(.dark)
}
