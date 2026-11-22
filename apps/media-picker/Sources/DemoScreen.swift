import SwiftUI

/// Dark playground for MediaPicker: one live picker, plus a painted gallery.
struct DemoScreen: View {
    @State private var tab: DemoTab = .live

    var body: some View {
        TabView(selection: $tab) {
            LivePlaygroundView(isSelected: tab == .live)
                .tabItem { Label("Live", systemImage: "photo.on.rectangle.angled") }
                .tag(DemoTab.live)

            GalleryScreen()
                .tabItem { Label("Gallery", systemImage: "square.grid.2x2") }
                .tag(DemoTab.gallery)
        }
        .toolbarBackground(DemoPalette.page, for: .tabBar)
        .toolbarColorScheme(.dark, for: .tabBar)
    }
}

/// One live picker at a time. Leaving the tab removes `MediaPicker`.
struct LivePlaygroundView: View {
    var isSelected: Bool

    @State private var family: LiveFamily = .photos
    @State private var store = SelectionStore()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    playgroundControls
                    if isSelected {
                        activeSurface
                        SelectedMediaSection(store: store)
                    } else {
                        parkedCard
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
                .padding(.bottom, 12)
            }
            .background(DemoPalette.page)
            .navigationTitle("Media Picker")
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
                "Only the selected surface mounts a MediaPicker. Photos, Albums, Camera, and Theme "
                    + "never run at the same time. Gallery is painted — no picker."
            )
            .font(.caption)
            .foregroundStyle(DemoPalette.inkMuted)
        }
        .demoCard()
    }

    @ViewBuilder
    private var activeSurface: some View {
        switch family {
        case .photos:
            PhotosSurface(store: store)
        case .albums:
            AlbumsSurface(store: store)
        case .camera:
            CameraSurface(store: store)
        case .theme:
            ThemeSurface(store: store)
        }
    }

    private var parkedCard: some View {
        DemoChrome.chartCard(title: family.title, subtitle: "Unmounted") {
            Text("The live MediaPicker is unmounted while Gallery is open.")
                .font(.subheadline)
                .foregroundStyle(DemoPalette.inkMuted)
                .frame(maxWidth: .infinity, minHeight: 120, alignment: .center)
        }
    }
}

#Preview("Media Picker") {
    DemoScreen()
        .preferredColorScheme(.dark)
}
