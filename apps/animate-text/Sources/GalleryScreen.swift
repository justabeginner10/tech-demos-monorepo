import SwiftUI

/// Every built-in effect. The views unmount when Live is selected.
struct GalleryScreen: View {
    var isSelected: Bool

    @State private var replay = 0

    private let columns = [GridItem(.adaptive(minimum: 300), spacing: 12)]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    header
                    if isSelected {
                        LazyVGrid(columns: columns, spacing: 12) {
                            ForEach(BuiltInEffect.allCases) { effect in
                                EffectCard(effect: effect, replayToken: replay)
                            }
                        }
                    } else {
                        parkedCard
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
            Text("Eighteen effects, one word.")
                .font(.system(size: 34, weight: .regular, design: .serif))
                .foregroundStyle(DemoPalette.ink)

            Text(
                "Each card is AnimateText on \"Animate\", split into letters, with userInfo nil. "
                    + "Words, the typo glyph set, and the custom effect stay on Live."
            )
            .font(.subheadline)
            .foregroundStyle(DemoPalette.inkMuted)

            Button("Replay all") { replay += 1 }
                .buttonStyle(.borderedProminent)
                .tint(DemoPalette.accent)
                .disabled(!isSelected)
        }
    }

    private var parkedCard: some View {
        DemoChrome.chartCard(title: "Gallery", subtitle: "Unmounted") {
            Text("The gallery effects are unmounted while Live is open.")
                .font(.subheadline)
                .foregroundStyle(DemoPalette.inkMuted)
                .frame(maxWidth: .infinity, minHeight: 120, alignment: .center)
        }
    }
}

#Preview("Animate Text Gallery") {
    GalleryScreen(isSelected: true)
        .preferredColorScheme(.dark)
}
