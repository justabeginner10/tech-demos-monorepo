import SwiftUI

/// Dark playground for ScalingHeaderScrollView: one live header, plus a static gallery.
struct DemoScreen: View {
    @State private var tab: DemoTab = .live

    var body: some View {
        TabView(selection: $tab) {
            LivePlaygroundView(isSelected: tab == .live)
                .tabItem { Label("Live", systemImage: "rectangle.compress.vertical") }
                .tag(DemoTab.live)

            GalleryScreen()
                .tabItem { Label("Gallery", systemImage: "square.grid.2x2") }
                .tag(DemoTab.gallery)
        }
        .toolbarBackground(DemoPalette.page, for: .tabBar)
        .toolbarColorScheme(.dark, for: .tabBar)
    }
}

/// One live package view at a time. Leaving the tab unmounts it.
struct LivePlaygroundView: View {
    var isSelected: Bool

    @State private var family: LiveFamily = .profile

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                familyBar
                ZStack {
                    if isSelected {
                        activeSurface
                    } else {
                        parkedCard
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipped()
            }
            .background(DemoPalette.page)
            .toolbar(.hidden, for: .navigationBar)
        }
    }

    private var familyBar: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .firstTextBaseline) {
                Text("Header")
                    .font(.headline)
                    .foregroundStyle(DemoPalette.ink)
                Spacer()
                Text(family.subtitle)
                    .font(.caption)
                    .foregroundStyle(DemoPalette.inkMuted)
                    .lineLimit(1)
            }

            Picker("Family", selection: $family) {
                ForEach(LiveFamily.allCases) { item in
                    Text(item.title).tag(item)
                }
            }
            .pickerStyle(.segmented)
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 8)
        .background(DemoPalette.page)
    }

    @ViewBuilder
    private var activeSurface: some View {
        switch family {
        case .profile:
            ProfileSurface()
        case .refresh:
            RefreshSurface()
        case .tabs:
            TabsSurface()
        }
    }

    private var parkedCard: some View {
        VStack {
            Spacer()
            DemoChrome.chartCard(title: family.title, subtitle: "Unmounted") {
                Text("The live header is unmounted while Gallery is open.")
                    .font(.subheadline)
                    .foregroundStyle(DemoPalette.inkMuted)
                    .frame(maxWidth: .infinity, minHeight: 120, alignment: .center)
            }
            .padding(.horizontal, 16)
            Spacer()
        }
    }
}

#Preview("Header Demo") {
    DemoScreen()
        .preferredColorScheme(.dark)
}
