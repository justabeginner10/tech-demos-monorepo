import SwiftUI

/// The five bundled files. Each card mounts one looping `LottieView` while this tab is selected.
struct GalleryScreen: View {
    var isSelected: Bool

    private let columns = [GridItem(.adaptive(minimum: 300), spacing: 12)]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    header
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(AnimationClip.allCases) { clip in
                            GalleryClipCard(clip: clip, isSelected: isSelected)
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
            Text("Five files, looping.")
                .font(.system(size: 34, weight: .regular, design: .serif))
                .foregroundStyle(DemoPalette.ink)

            Text(
                "Each card is LottieAnimation.named, played with LottieView.looping(). "
                    + "Leaving this tab removes the players. Live is the place for transport, speed, and ranges."
            )
            .font(.subheadline)
            .foregroundStyle(DemoPalette.inkMuted)
        }
    }
}

#Preview("Lottie Gallery") {
    GalleryScreen(isSelected: true)
        .preferredColorScheme(.dark)
}
