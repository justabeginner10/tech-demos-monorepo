import SwiftUI

/// Dark playground for AnchoredPopup: live anchors, plus a painted gallery.
/// Both pages stay mounted. A system tab that drops Live would also drop the
/// presenter that has to close an open window.
struct DemoScreen: View {
    @State private var tab: DemoTab = .live

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                LivePlaygroundView()
                    .familyVisibility(tab == .live)
                GalleryScreen()
                    .familyVisibility(tab == .gallery)
            }
            tabBar
        }
        .background(DemoPalette.page)
    }

    private var tabBar: some View {
        HStack(spacing: 0) {
            tabButton("Live", systemImage: "rectangle.portrait.on.rectangle.portrait", value: .live)
            tabButton("Gallery", systemImage: "square.grid.2x2", value: .gallery)
        }
        .padding(.top, 8)
        .padding(.bottom, 4)
        .background(DemoPalette.page)
        .overlay(alignment: .top) {
            Rectangle()
                .fill(DemoPalette.stroke)
                .frame(height: 1)
                .allowsHitTesting(false)
        }
    }

    private func tabButton(_ title: String, systemImage: String, value: DemoTab) -> some View {
        Button {
            tab = value
        } label: {
            VStack(spacing: 4) {
                Image(systemName: systemImage)
                    .font(.body.weight(.semibold))
                Text(title)
                    .font(.caption2.weight(.medium))
            }
            .frame(maxWidth: .infinity)
            .foregroundStyle(tab == value ? DemoPalette.accent : DemoPalette.inkMuted)
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(tab == value ? AccessibilityTraits.isSelected : AccessibilityTraits())
    }
}

/// Every family stays mounted. A popup's presenter has to remain in the tree
/// to close its window after `launchShrinkingAnimation` reaches `.hidden`.
struct LivePlaygroundView: View {
    @State private var family: LiveFamily = .corners

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 12) {
                playgroundControls
                ZStack {
                    CornersSurface()
                        .familyVisibility(family == .corners)
                    PlacementSurface()
                        .familyVisibility(family == .placement)
                    BehaviorSurface()
                        .familyVisibility(family == .behavior)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .padding(.horizontal)
            .padding(.top, 8)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(DemoPalette.page)
            .navigationTitle("Anchored Popup")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(DemoPalette.page, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
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
                "Corners, Placement, and Behavior stay mounted together so an open window "
                    + "can still close. Gallery never calls useAsPopupAnchor."
            )
            .font(.caption)
            .foregroundStyle(DemoPalette.inkMuted)
        }
        .demoCard()
    }
}

#Preview("Anchored Popup") {
    DemoScreen()
        .preferredColorScheme(.dark)
}
