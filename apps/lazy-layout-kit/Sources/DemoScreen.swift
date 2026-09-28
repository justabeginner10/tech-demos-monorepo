import LazyLayoutKit
import SwiftUI

/// Dark playground for LazyLayoutKit: one live virtualized layout, plus a static gallery.
struct DemoScreen: View {
    @State private var tab: DemoTab = .live

    var body: some View {
        TabView(selection: $tab) {
            LivePlaygroundView(isSelected: tab == .live)
                .tabItem { Label("Live", systemImage: "square.grid.3x3") }
                .tag(DemoTab.live)

            GalleryScreen()
                .tabItem { Label("Gallery", systemImage: "square.grid.2x2") }
                .tag(DemoTab.gallery)
        }
    }
}

/// One live `LazyLayoutView` at a time. Leaving the tab or switching the picker unmounts it.
struct LivePlaygroundView: View {
    var isSelected: Bool

    @State private var family: LiveFamily = .masonry
    @State private var masonryColumns = 2
    @State private var stress = false
    @State private var position = LazyLayoutPosition<Int>()

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
            .navigationTitle("LazyLayoutKit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Jump") {
                        position.scrollTo(id: DemoCatalog.jumpID(inCount: itemCount), anchor: .center)
                    }
                    .disabled(!isSelected)
                }
            }
            .safeAreaInset(edge: .bottom, spacing: 0) {
                Color.clear.frame(height: 56)
            }
        }
        .onChange(of: family) { _, _ in
            position = LazyLayoutPosition()
        }
        .onChange(of: stress) { _, _ in
            position = LazyLayoutPosition()
        }
        .onChange(of: isSelected) { _, selected in
            if !selected {
                position = LazyLayoutPosition()
            }
        }
    }

    private var itemCount: Int {
        stress ? DemoCatalog.stressCount : DemoCatalog.liveCount
    }

    private var playgroundControls: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Playground")
                .font(.headline)

            Picker("Family", selection: $family) {
                ForEach(LiveFamily.allCases) { item in
                    Text(item.title).tag(item)
                }
            }
            .pickerStyle(.segmented)

            if family == .masonry {
                Picker("Columns", selection: $masonryColumns) {
                    Text("2 columns").tag(2)
                    Text("3 columns").tag(3)
                }
                .pickerStyle(.segmented)
            }

            Toggle("Stress (\(DemoCatalog.stressCount.formatted()) items)", isOn: $stress)

            Text(
                "Only the selected algorithm mounts a `LazyLayoutView`. Default Live uses "
                    + "\(DemoCatalog.liveCount) cheap cells — not a million. **Jump** scrolls by id."
            )
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding(14)
        .background(DemoPalette.card, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(DemoPalette.stroke, lineWidth: 1)
        }
    }

    @ViewBuilder
    private var activeSurface: some View {
        switch family {
        case .masonry:
            MasonryLiveSurface(
                photos: DemoCatalog.photos(stress: stress),
                columns: masonryColumns,
                position: $position
            )
            .id("masonry-\(stress)")
        case .justified:
            JustifiedLiveSurface(
                photos: DemoCatalog.photos(stress: stress),
                position: $position
            )
            .id("justified-\(stress)")
        case .timeline:
            TimelineLiveSurface(
                events: DemoCatalog.events(stress: stress),
                position: $position
            )
            .id("timeline-\(stress)")
        }
    }

    private var parkedCard: some View {
        DemoChrome.chartCard(title: family.title, subtitle: "Unmounted") {
            Text("Live LazyLayoutView is unmounted while Gallery is open.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, minHeight: 120, alignment: .center)
        }
    }
}

#Preview("LazyLayoutKit Demo") {
    DemoScreen()
        .preferredColorScheme(.dark)
}
