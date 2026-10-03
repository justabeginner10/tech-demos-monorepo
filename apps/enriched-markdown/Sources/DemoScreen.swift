import SwiftUI

/// Dark playground for Enriched Markdown: one live document, plus a static gallery.
struct DemoScreen: View {
    @State private var tab: DemoTab = .live

    var body: some View {
        TabView(selection: $tab) {
            LivePlaygroundView(isSelected: tab == .live)
                .tabItem { Label("Live", systemImage: "text.word.spacing") }
                .tag(DemoTab.live)

            GalleryScreen()
                .tabItem { Label("Gallery", systemImage: "square.grid.2x2") }
                .tag(DemoTab.gallery)
        }
        .toolbarBackground(DemoPalette.page, for: .tabBar)
        .toolbarColorScheme(.dark, for: .tabBar)
    }
}

/// One scrollable EnrichedMarkdownText. Leaving the tab unmounts it.
struct LivePlaygroundView: View {
    var isSelected: Bool

    @State private var theme: DocumentTheme = .ink
    @State private var spoilerOverlay: DemoSpoilerOverlay = .particles

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 12) {
                playgroundControls
                if isSelected {
                    LiveDocumentSurface(theme: theme, spoilerOverlay: spoilerOverlay)
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
            .navigationTitle("Enriched MD")
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

            Picker("Theme", selection: $theme) {
                ForEach(DocumentTheme.allCases) { item in
                    Text(item.title).tag(item)
                }
            }
            .pickerStyle(.segmented)

            Picker("Spoiler", selection: $spoilerOverlay) {
                ForEach(DemoSpoilerOverlay.allCases) { item in
                    Text(item.title).tag(item)
                }
            }
            .pickerStyle(.segmented)

            Text(
                "One scrollable document. Paper and Ink restyle it through `.markdownTheme`. "
                    + "SwiftUI `Text(markdown)` cannot do spoilers, task lists, GFM tables, "
                    + "GitHub alerts, or typeset LaTeX."
            )
            .font(.caption)
            .foregroundStyle(DemoPalette.inkMuted)
        }
        .padding(14)
        .background(DemoPalette.card, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(DemoPalette.stroke, lineWidth: 1)
        }
    }

    private var parkedCard: some View {
        DemoChrome.chartCard(title: theme.title, subtitle: "Unmounted") {
            Text("Live EnrichedMarkdownText is unmounted while Gallery is open.")
                .font(.subheadline)
                .foregroundStyle(DemoPalette.inkMuted)
                .frame(maxWidth: .infinity, minHeight: 120, alignment: .center)
        }
    }
}

#Preview("Enriched Markdown Demo") {
    DemoScreen()
        .preferredColorScheme(.dark)
}
