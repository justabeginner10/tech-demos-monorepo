import SwiftUI

/// Dark playground for SDWebImageSwiftUI: one live family, plus a remote gallery.
struct DemoScreen: View {
    @State private var tab: DemoTab = .live

    init() {
        WebPRegistration.register()
    }

    var body: some View {
        TabView(selection: $tab) {
            LivePlaygroundView(isSelected: tab == .live)
                .tabItem { Label("Live", systemImage: "photo") }
                .tag(DemoTab.live)

            GalleryScreen(isSelected: tab == .gallery)
                .tabItem { Label("Gallery", systemImage: "square.grid.2x2") }
                .tag(DemoTab.gallery)
        }
        .toolbarBackground(DemoPalette.page, for: .tabBar)
        .toolbarColorScheme(.dark, for: .tabBar)
    }
}

/// One live family at a time. Leaving the tab unmounts every loader.
struct LivePlaygroundView: View {
    var isSelected: Bool

    @State private var family: LiveFamily = .load

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    playgroundControls
                    if isSelected {
                        activeSurface
                            .frame(maxWidth: .infinity)
                    } else {
                        parkedCard
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
                .padding(.bottom, 16)
                .frame(maxWidth: .infinity, alignment: .top)
            }
            .scrollDismissesKeyboard(.interactively)
            .background(DemoPalette.page)
            .navigationTitle("WebImage")
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

            Text(family.subtitle)
                .font(.caption.monospaced())
                .foregroundStyle(DemoPalette.inkMuted)

            Text(
                "Only the selected surface mounts WebImage or AnimatedImage. "
                    + "Leaving Live removes them. Gallery mounts its own loaders."
            )
            .font(.caption)
            .foregroundStyle(DemoPalette.inkMuted)
        }
        .demoCard()
    }

    @ViewBuilder
    private var activeSurface: some View {
        switch family {
        case .load:
            LoadSurface()
        case .motion:
            MotionSurface()
        case .player:
            PlayerSurface()
        case .cache:
            CacheSurface()
        }
    }

    private var parkedCard: some View {
        DemoChrome.chartCard(title: family.title, subtitle: "Unmounted") {
            Text("Loaders are unmounted while Gallery is open.")
                .font(.subheadline)
                .foregroundStyle(DemoPalette.inkMuted)
                .frame(maxWidth: .infinity, minHeight: 120, alignment: .center)
        }
    }
}

#Preview("WebImage") {
    DemoScreen()
        .preferredColorScheme(.dark)
}
