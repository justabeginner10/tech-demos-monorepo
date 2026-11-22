import ScalingHeaderScrollView
import SwiftUI

// MARK: - Profile

struct ProfileSurface: View {
    @State private var progress: CGFloat = 0
    @State private var offset: CGFloat = 0
    @State private var snap: SnapHeaderState?
    @State private var resetScroll = false
    @State private var minHeight = 128.0
    @State private var maxHeight = 340.0
    @State private var useInitialSnap = false
    @State private var initialSnap = 0.0
    @State private var allowsGrowth = false
    @State private var allowsCollapse = true
    @State private var clipHeader = true
    @State private var hideIndicator = false
    @State private var anchor: HeaderAnchor = .bottom
    @State private var snapChoice: HeaderSnapChoice = .lift

    private var resolvedMin: CGFloat { CGFloat(min(minHeight, maxHeight - 40)) }
    private var resolvedMax: CGFloat { CGFloat(max(maxHeight, minHeight + 40)) }

    private var scrollIdentity: String {
        "\(resolvedMin.rounded())-\(resolvedMax.rounded())-\(useInitialSnap)-\(initialSnap)"
    }

    var body: some View {
        assembled.id(scrollIdentity)
    }

    /// Modifiers stay on the concrete scroll view. An opaque `some View` would hide `ScalingHeaderViewAPI`.
    private var assembled: some View {
        applyInitial(
            applySnap(
                ScalingHeaderScrollView(minHeight: resolvedMin, maxHeight: resolvedMax) { height, headerProgress in
                    ProfileHeader(height: height, progress: headerProgress)
                } content: {
                    profileContent
                }
                .collapseProgress($progress)
                .scrollOffset($offset)
                .scrollToTop(resetScroll: $resetScroll)
                .snapHeaderToState($snap)
                .allowsHeaderGrowth(allowsGrowth)
                .allowsHeaderCollapse(allowsCollapse)
                .headerIsClipped(clipHeader)
                .headerAlignment(anchor.alignment)
                .hideScrollIndicators(hideIndicator)
            )
        )
    }

    private func applySnap<V: ScalingHeaderViewAPI>(_ view: V) -> V {
        switch snapChoice {
        case .off:
            return view.setHeaderSnapMode(.disabled)
        case .lift:
            return view.setHeaderSnapMode(.immediately)
        case .coast:
            return view.setHeaderSnapMode(.afterFinishAccelerating)
        case .thirds:
            return view
                .headerSnappingPositions(snapPositions: [0, 0.5, 1])
                .setHeaderSnapMode(.immediately)
        }
    }

    private func applyInitial<V: ScalingHeaderViewAPI>(_ view: V) -> V {
        guard useInitialSnap else { return view }
        return view.initialSnapPosition(initialSnapPosition: CGFloat(initialSnap))
    }

    private var profileContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            readout
            controls
            ForEach(SampleLibrary.profileNotes) { note in
                NoteRow(note: note)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, 28)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(DemoPalette.page)
    }

    private var readout: some View {
        InspectorCard {
            Text("collapseProgress \(format(progress))")
                .font(.caption.monospaced())
                .foregroundStyle(DemoPalette.ink)
            Text("scrollOffset \(format(offset))")
                .font(.caption.monospaced())
                .foregroundStyle(DemoPalette.inkMuted)
            Text("The header closure receives the same progress, plus the current height. 0 is expanded. 1 is collapsed.")
                .font(.caption)
                .foregroundStyle(DemoPalette.inkMuted)
        }
    }

    private var controls: some View {
        InspectorCard {
            DemoSlider(title: "Min height", value: $minHeight, range: 96...220, step: 4, format: "%.0f")
            DemoSlider(title: "Max height", value: $maxHeight, range: 240...480, step: 4, format: "%.0f")
            Text("Passed as minHeight \(Int(resolvedMin.rounded())) and maxHeight \(Int(resolvedMax.rounded())). Changing either rebuilds the scroll view. The package keeps at least 40 pt between them here.")
                .font(.caption)
                .foregroundStyle(DemoPalette.inkMuted)

            Text("Snap")
                .font(.caption.weight(.medium))
                .foregroundStyle(DemoPalette.ink)
            Picker("Snap", selection: $snapChoice) {
                ForEach(HeaderSnapChoice.allCases) { choice in
                    Text(choice.title).tag(choice)
                }
            }
            .pickerStyle(.segmented)
            Text(snapCaption)
                .font(.caption)
                .foregroundStyle(DemoPalette.inkMuted)

            Toggle("Initial snap", isOn: $useInitialSnap)
                .font(.caption.weight(.medium))
                .foregroundStyle(DemoPalette.ink)
                .tint(DemoPalette.accent)
            if useInitialSnap {
                DemoSlider(title: "Initial position", value: $initialSnap, range: 0...1, step: 0.05)
                Text("0 is expanded, 1 is collapsed. Applied only when the scroll view is created.")
                    .font(.caption)
                    .foregroundStyle(DemoPalette.inkMuted)
            }

            Text("Alignment")
                .font(.caption.weight(.medium))
                .foregroundStyle(DemoPalette.ink)
            Picker("Alignment", selection: $anchor) {
                ForEach(HeaderAnchor.allCases) { item in
                    Text(item.title).tag(item)
                }
            }
            .pickerStyle(.segmented)
            Text("headerAlignment. The scroll view's own default is center. This surface starts at bottom.")
                .font(.caption)
                .foregroundStyle(DemoPalette.inkMuted)

            Toggle("Allow collapse", isOn: $allowsCollapse)
                .font(.caption.weight(.medium))
                .foregroundStyle(DemoPalette.ink)
                .tint(DemoPalette.accent)
            Toggle("Allow growth", isOn: $allowsGrowth)
                .font(.caption.weight(.medium))
                .foregroundStyle(DemoPalette.ink)
                .tint(DemoPalette.accent)
            Text("Growth past maxHeight is ignored while a pull-to-refresh action is set. This surface does not set one.")
                .font(.caption)
                .foregroundStyle(DemoPalette.inkMuted)

            Toggle("Clip header", isOn: $clipHeader)
                .font(.caption.weight(.medium))
                .foregroundStyle(DemoPalette.ink)
                .tint(DemoPalette.accent)
            Toggle("Hide indicator", isOn: $hideIndicator)
                .font(.caption.weight(.medium))
                .foregroundStyle(DemoPalette.ink)
                .tint(DemoPalette.accent)

            HStack(spacing: 8) {
                snapButton("Expand") { snap = .expanded }
                snapButton("Mid") { snap = .custom((resolvedMin - resolvedMax) / 2) }
                snapButton("Collapse") { snap = .collapsed }
                snapButton("Top") { resetScroll = true }
            }
            Text("Expand, Mid, and Collapse write snapHeaderToState. Mid is custom((min - max) / 2), which the package adds to -minHeight. Top sets scrollToTop.")
                .font(.caption)
                .foregroundStyle(DemoPalette.inkMuted)
        }
    }

    private var snapCaption: String {
        switch snapChoice {
        case .off:
            "setHeaderSnapMode(.disabled). Positions are cleared."
        case .lift:
            "setHeaderSnapMode(.immediately). Default stops are 0 and 1."
        case .coast:
            "setHeaderSnapMode(.afterFinishAccelerating). Snaps when deceleration ends, or sooner if the lift is slow."
        case .thirds:
            "headerSnappingPositions([0, 0.5, 1]), then immediate mode so those stops are kept."
        }
    }

    private func snapButton(_ title: String, action: @escaping () -> Void) -> some View {
        Button(title, action: action)
            .font(.caption.weight(.semibold))
            .buttonStyle(.bordered)
            .tint(DemoPalette.accent)
    }

    private func format(_ value: CGFloat) -> String {
        String(format: "%.2f", value)
    }
}

private struct ProfileHeader: View {
    var height: CGFloat
    var progress: CGFloat

    @Environment(\.scalingHeaderSafeAreaInsets) private var insets

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            HeaderArtwork(progress: progress)

            expandedIdentity
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
                .opacity(1 - progress)
                .allowsHitTesting(progress < 0.5)

            collapsedBar
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .padding(.top, insets.top + 6)
                .padding(.horizontal, 16)
                .opacity(progress)
                .allowsHitTesting(progress > 0.5)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
    }

    private var expandedIdentity: some View {
        HStack(alignment: .bottom, spacing: 12) {
            Image(systemName: "person.crop.circle.fill")
                .font(.system(size: 64))
                .foregroundStyle(.white)
                .scaleEffect(1 - 0.35 * progress, anchor: .bottomLeading)
                .background {
                    Circle().fill(.white.opacity(0.16))
                }

            VStack(alignment: .leading, spacing: 2) {
                Text("Mara Ellison")
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(.white)
                Text("Field notes")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.82))
            }

            Spacer(minLength: 0)
        }
    }

    private var collapsedBar: some View {
        HStack {
            Text("Mara Ellison")
                .font(.headline)
                .foregroundStyle(.white)
            Spacer()
            Text("\(Int(height.rounded())) pt")
                .font(.caption.monospaced())
                .foregroundStyle(.white.opacity(0.85))
        }
    }
}

// MARK: - Refresh

struct RefreshSurface: View {
    @State private var notes: [FieldNote] = SampleLibrary.refreshSeed
    @State private var nextID = 100
    @State private var refreshOn = true
    @State private var loadMoreOn = true
    @State private var refreshCount = 0
    @State private var loadCount = 0
    @State private var bottomHits = 0
    @State private var lastBottom: Date?
    @State private var progress: CGFloat = 0
    @State private var offset: CGFloat = 0

    var body: some View {
        ScalingHeaderScrollView(minHeight: 108, maxHeight: 240) { height, headerProgress in
            RefreshHeader(height: height, progress: headerProgress, count: notes.count)
        } content: {
            refreshContent
        }
        .collapseProgress($progress)
        .scrollOffset($offset)
        .pullToRefresh(isActive: refreshOn) {
            try? await Task.sleep(nanoseconds: 900_000_000)
            notes.insert(SampleLibrary.freshNote(id: nextID), at: 0)
            nextID += 1
            refreshCount += 1
        }
        .pullToLoadMore(isActive: loadMoreOn, contentOffset: 0) {
            try? await Task.sleep(nanoseconds: 900_000_000)
            let batch = SampleLibrary.moreNotes(start: nextID, count: 4)
            notes.append(contentsOf: batch)
            nextID += batch.count
            loadCount += 1
        }
        .scrollViewDidReachBottom {
            let now = Date()
            if let lastBottom, now.timeIntervalSince(lastBottom) < 0.6 { return }
            lastBottom = now
            bottomHits += 1
        }
        .setHeaderSnapMode(.immediately)
        .headerAlignment(.bottom)
    }

    private var refreshContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            InspectorCard {
                Text("progress \(String(format: "%.2f", progress))   offset \(String(format: "%.1f", offset))")
                    .font(.caption.monospaced())
                    .foregroundStyle(DemoPalette.ink)
                Text("Refreshes \(refreshCount) · loaded \(loadCount) · bottom \(bottomHits)")
                    .font(.caption.monospaced())
                    .foregroundStyle(DemoPalette.inkMuted)

                Toggle("Pull to refresh", isOn: $refreshOn)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(DemoPalette.ink)
                    .tint(DemoPalette.accent)
                Toggle("Pull to load more", isOn: $loadMoreOn)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(DemoPalette.ink)
                    .tint(DemoPalette.accent)

                Text("Pull down past the expanded header until the petal spinner fills, then release. Pull up past the last row to load more. The package arms either gesture after 60 pt of overscroll. contentOffset is passed as 0. Tag 3.1.0 stores that value and does not read it.")
                    .font(.caption)
                    .foregroundStyle(DemoPalette.inkMuted)
            }

            ForEach(notes) { note in
                NoteRow(note: note)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, 28)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(DemoPalette.page)
    }
}

private struct RefreshHeader: View {
    var height: CGFloat
    var progress: CGFloat
    var count: Int

    @Environment(\.scalingHeaderSafeAreaInsets) private var insets

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            HeaderArtwork(progress: progress)
            VStack(alignment: .leading, spacing: 4) {
                Text("Pull")
                    .font(.title.weight(.semibold))
                    .foregroundStyle(.white)
                    .opacity(1 - progress)
                Text("\(count) notes")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.85))
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
            .opacity(1 - progress * 0.35)

            Text("\(Int(height.rounded())) pt")
                .font(.caption.monospaced())
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                .padding(.top, insets.top + 8)
                .padding(.trailing, 16)
                .opacity(progress)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Tabs

struct TabsSurface: View {
    @State private var shelf: Shelf = .notes
    @State private var progress: CGFloat = 0
    @State private var offset: CGFloat = 0
    @State private var snap: SnapHeaderState?
    @State private var resetScroll = false

    var body: some View {
        ZStack(alignment: .bottom) {
            ScalingHeaderTabView(selection: $shelf, minHeight: 168, maxHeight: 300) { _, headerProgress in
                ShelfHeader(shelf: $shelf, progress: headerProgress)
            } pageContent: { page in
                ShelfPage(shelf: page)
            }
            .collapseProgress($progress)
            .scrollOffset($offset)
            .snapHeaderToState($snap)
            .scrollToTop(resetScroll: $resetScroll)
            .setHeaderSnapMode(.immediately)
            .headerAlignment(.bottom)

            snapBar
        }
    }

    private var snapBar: some View {
        HStack(spacing: 8) {
            Text(String(format: "%.2f", progress))
                .font(.caption.monospaced())
                .foregroundStyle(DemoPalette.ink)
            snapButton("Expand") { snap = .expanded }
            snapButton("Collapse") { snap = .collapsed }
            snapButton("Top") { resetScroll = true }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial, in: Capsule())
        .padding(.bottom, 10)
    }

    private func snapButton(_ title: String, action: @escaping () -> Void) -> some View {
        Button(title, action: action)
            .font(.caption.weight(.semibold))
            .buttonStyle(.bordered)
            .tint(DemoPalette.accent)
    }
}

private struct ShelfHeader: View {
    @Binding var shelf: Shelf
    var progress: CGFloat

    @Environment(\.scalingHeaderSafeAreaInsets) private var insets

    var body: some View {
        ZStack(alignment: .bottom) {
            HeaderArtwork(progress: progress)

            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .bottom) {
                    Image(systemName: shelf.symbol)
                        .font(.system(size: 44))
                        .foregroundStyle(.white)
                        .opacity(1 - progress)
                    Spacer()
                    Text(shelf.title)
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(.white)
                }

                Picker("Shelf", selection: $shelf) {
                    ForEach(Shelf.allCases) { item in
                        Text(item.title).tag(item)
                    }
                }
                .pickerStyle(.segmented)
            }
            .padding(.horizontal, 16)
            .padding(.top, insets.top + 8)
            .padding(.bottom, 12)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct ShelfPage: View {
    var shelf: Shelf

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(shelf.title)
                .font(.headline)
                .foregroundStyle(DemoPalette.ink)
            Text("This page keeps its own scroll offset. The header height is shared. Notes, Places, and Saved are different lengths so the saved position is easy to see.")
                .font(.caption)
                .foregroundStyle(DemoPalette.inkMuted)
                .padding(.bottom, 4)

            ForEach(SampleLibrary.shelfNotes(shelf)) { note in
                NoteRow(note: note)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, 72)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(DemoPalette.page)
    }
}
