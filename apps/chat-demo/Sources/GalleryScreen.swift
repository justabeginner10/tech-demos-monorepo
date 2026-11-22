import SwiftUI

/// Preset chats. Each card is one public entry point, with that call written on the card.
struct GalleryScreen: View {
    var isSelected: Bool

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    header
                    ConversationCard(isMounted: isSelected)
                    CommentsCard(isMounted: isSelected)
                    CustomBubblesCard(isMounted: isSelected)
                    CustomInputCard(isMounted: isSelected)
                    PaperThemeCard(isMounted: isSelected)
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
            Text("List, input, theme.")
                .font(.system(size: 34, weight: .regular, design: .serif))
                .foregroundStyle(DemoPalette.ink)

            Text(
                "Each card mounts a ChatView. Leaving the tab removes every one. "
                    + "Sends stay in that card's store."
            )
            .font(.subheadline)
            .foregroundStyle(DemoPalette.inkMuted)
        }
    }
}

#Preview("Chat Gallery") {
    GalleryScreen(isSelected: true)
        .preferredColorScheme(.dark)
}
