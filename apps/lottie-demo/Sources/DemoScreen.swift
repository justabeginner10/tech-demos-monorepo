import SwiftUI

/// Dark playground for Lottie: one live player, plus a gallery of the bundled files.
struct DemoScreen: View {
    @State private var tab: DemoTab = .live

    var body: some View {
        TabView(selection: $tab) {
            LivePlaygroundView(isSelected: tab == .live)
                .tabItem { Label("Live", systemImage: "play.circle") }
                .tag(DemoTab.live)

            GalleryScreen(isSelected: tab == .gallery)
                .tabItem { Label("Gallery", systemImage: "square.grid.2x2") }
                .tag(DemoTab.gallery)
        }
        .toolbarBackground(DemoPalette.page, for: .tabBar)
        .toolbarColorScheme(.dark, for: .tabBar)
    }
}

/// One live Lottie surface at a time. Leaving the tab unmounts the player.
struct LivePlaygroundView: View {
    var isSelected: Bool

    @State private var family: LiveFamily = .playback

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    playgroundControls
                    if isSelected {
                        activeSurface
                    } else {
                        parkedCard
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
                .padding(.bottom, 12)
            }
            .background(DemoPalette.page)
            .navigationTitle("Lottie")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(DemoPalette.page, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .safeAreaInset(edge: .bottom, spacing: 0) {
                Color.clear.frame(height: 56)
            }
        }
    }

    private var playgroundControls: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Playground")
                .font(.headline)
                .foregroundStyle(DemoPalette.ink)

            Picker("Family", selection: $family) {
                ForEach(LiveFamily.allCases) { item in
                    Text(item.title).tag(item)
                }
            }
            .pickerStyle(.segmented)

            Text(
                "Only the selected surface keeps a LottieView. Playback, Range, and Markers "
                    + "never play at the same time. Gallery mounts its own players, and only while that tab is open."
            )
            .font(.caption)
            .foregroundStyle(DemoPalette.inkMuted)
        }
        .demoCard()
    }

    @ViewBuilder
    private var activeSurface: some View {
        switch family {
        case .playback:
            PlaybackSurface()
        case .range:
            RangeSurface()
        case .markers:
            MarkerSurface()
        }
    }

    private var parkedCard: some View {
        DemoChrome.chartCard(title: family.title, subtitle: "Unmounted") {
            Text("The live LottieView is unmounted while Gallery is open.")
                .font(.subheadline)
                .foregroundStyle(DemoPalette.inkMuted)
                .frame(maxWidth: .infinity, minHeight: 120, alignment: .center)
        }
    }
}

#Preview("Lottie Demo") {
    DemoScreen()
        .preferredColorScheme(.dark)
}
