import SwiftUI

/// Dark playground for AlertKit: one live presenter, plus a painted gallery.
struct DemoScreen: View {
    @State private var tab: DemoTab = .live

    var body: some View {
        TabView(selection: $tab) {
            LivePlaygroundView(isSelected: tab == .live)
                .tabItem { Label("Live", systemImage: "bell.badge") }
                .tag(DemoTab.live)

            GalleryScreen()
                .tabItem { Label("Gallery", systemImage: "square.grid.2x2") }
                .tag(DemoTab.gallery)
        }
        .toolbarBackground(DemoPalette.page, for: .tabBar)
        .toolbarColorScheme(.dark, for: .tabBar)
    }
}

/// One presenter at a time. Leaving the tab removes that surface.
/// Alerts are window subviews, so each surface dismisses on disappear.
struct LivePlaygroundView: View {
    var isSelected: Bool

    @State private var family: LiveFamily = .api

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 12) {
                playgroundControls
                if isSelected {
                    activeSurface
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    parkedCard
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(DemoPalette.page)
            .navigationTitle("Alert Kit")
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
                "Only the selected surface is mounted. API, View, and Modifier never present "
                    + "at the same time. Gallery is painted — no alerts."
            )
            .font(.caption)
            .foregroundStyle(DemoPalette.inkMuted)
        }
        .demoCard()
    }

    @ViewBuilder
    private var activeSurface: some View {
        switch family {
        case .api:
            APISurface()
        case .view:
            ViewSurface()
        case .modifier:
            ModifierSurface()
        }
    }

    private var parkedCard: some View {
        DemoChrome.chartCard(title: family.title, subtitle: "Unmounted") {
            Text("This presenter is unmounted while Gallery is open.")
                .font(.subheadline)
                .foregroundStyle(DemoPalette.inkMuted)
                .frame(maxWidth: .infinity, minHeight: 120, alignment: .center)
        }
    }
}

#Preview("Alert Kit") {
    DemoScreen()
        .preferredColorScheme(.dark)
}
