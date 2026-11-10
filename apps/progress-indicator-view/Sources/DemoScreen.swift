import SwiftUI

/// Dark playground for ProgressIndicatorView: one tuned indicator, plus the five presets.
struct DemoScreen: View {
    @State private var tab: DemoTab = .gallery
    @State private var settings = ProgressSettings()

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
        .task(id: settings.autoProgress) {
            await runAutoProgress()
        }
    }

    private func runAutoProgress() async {
        guard settings.autoProgress else { return }
        while !Task.isCancelled {
            do {
                try await Task.sleep(for: .milliseconds(ProgressClock.timerMilliseconds))
            } catch {
                return
            }
            guard !Task.isCancelled, settings.autoProgress else { return }
            settings.progress = ProgressClock.step(settings.progress)
        }
    }
}

#Preview("Progress") {
    DemoScreen()
        .preferredColorScheme(.dark)
}
