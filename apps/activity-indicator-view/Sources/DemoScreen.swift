import SwiftUI

/// Dark playground for ActivityIndicatorView: one tuned indicator, plus the ten presets.
struct DemoScreen: View {
    @State private var tab: DemoTab = .gallery
    @State private var settings = IndicatorSettings()

    var body: some View {
        TabView(selection: $tab) {
            LivePlaygroundView(isSelected: tab == .live, settings: $settings)
                .tabItem { Label("Live", systemImage: "slider.horizontal.3") }
                .tag(DemoTab.live)

            GalleryScreen(isSelected: tab == .gallery, settings: $settings)
                .tabItem { Label("Gallery", systemImage: "square.grid.2x2") }
                .tag(DemoTab.gallery)
        }
        .toolbarBackground(DemoPalette.page, for: .tabBar)
        .toolbarColorScheme(.dark, for: .tabBar)
    }
}

#Preview("Indicators") {
    DemoScreen()
        .preferredColorScheme(.dark)
}
