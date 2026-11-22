import SwiftUI

/// Dark playground for ExyteChat: one live thread, plus a gallery of chat type, bubbles, input, and theme.
struct DemoScreen: View {
    @State private var tab: DemoTab = .live

    var body: some View {
        TabView(selection: $tab) {
            LivePlaygroundView(isSelected: tab == .live)
                .tabItem { Label("Live", systemImage: "slider.horizontal.3") }
                .tag(DemoTab.live)

            GalleryScreen(isSelected: tab == .gallery)
                .tabItem { Label("Gallery", systemImage: "square.grid.2x2") }
                .tag(DemoTab.gallery)
        }
        .toolbarBackground(DemoPalette.page, for: .tabBar)
        .toolbarColorScheme(.dark, for: .tabBar)
    }
}

#Preview("Chat") {
    DemoScreen()
        .preferredColorScheme(.dark)
}
