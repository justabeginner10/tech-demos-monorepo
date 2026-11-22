import SwiftUI

/// Adaptive playground for WhatsNewKit: one live presenter, plus a static gallery.
struct DemoScreen: View {
    @State private var tab: DemoTab = .live
    @State private var appearance: DemoAppearance = .system

    var body: some View {
        TabView(selection: $tab) {
            LivePlaygroundView(isSelected: tab == .live, appearance: $appearance)
                .tabItem { Label("Live", systemImage: "sparkles") }
                .tag(DemoTab.live)

            GalleryScreen()
                .tabItem { Label("Gallery", systemImage: "square.grid.2x2") }
                .tag(DemoTab.gallery)
        }
        .toolbarBackground(DemoPalette.page, for: .tabBar)
        .preferredColorScheme(appearance.colorScheme)
    }
}

#Preview("WhatsNewKit Demo") {
    DemoScreen()
}
