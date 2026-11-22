import SwiftUI

enum GalleryCard: String, CaseIterable, Identifiable {
    case pages
    case circle
    case button
    case duration
    case callbacks
    case cycle
    case manual

    var id: String { rawValue }

    var title: String {
        switch self {
        case .pages: "Pages"
        case .circle: "Circle"
        case .button: "Button"
        case .duration: "Duration"
        case .callbacks: "Callbacks"
        case .cycle: "Cycle"
        case .manual: "Manual"
        }
    }

    var subtitle: String {
        switch self {
        case .pages: "pageContents"
        case .circle: "next background"
        case .button: "nextIcon"
        case .duration: "duration(_:)"
        case .callbacks: "page · animation"
        case .cycle: "insteadOfCycling…"
        case .manual: "goToNextPage"
        }
    }

    var chips: [String] {
        switch self {
        case .pages:
            ["(view:background:)", "Color", "≥ 2 pages"]
        case .circle:
            ["radius 30", "limit 15", "y + 300"]
        case .button:
            ["chevron.forward", "arrow.right", "checkmark"]
        case .duration:
            ["easeIn", "easeOut", "default 1s"]
        case .callbacks:
            ["animationWillBegin", "animationDidEnd", "didChangeCurrentPage", "didGoToLastPage"]
        case .cycle:
            ["insteadOfCyclingToFirstPage", "insteadOfCyclingToLastPage"]
        case .manual:
            ["goToNextPage(animated:)", "goToPreviousPage(animated:)", "didPressNextButton"]
        }
    }

    @MainActor
    @ViewBuilder
    var preview: some View {
        VStack(alignment: .leading, spacing: 8) {
            snapshot
            chipRow
        }
    }

    @MainActor
    @ViewBuilder
    private var snapshot: some View {
        switch self {
        case .pages:
            HStack(spacing: 8) {
                ForEach(PageLibrary.walk) { spec in
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(spec.background)
                        .frame(height: 72)
                        .overlay {
                            Text(spec.title)
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(spec.ink)
                        }
                }
            }
            .padding(8)
        case .circle:
            CircleSketch()
        case .button:
            HStack(spacing: 16) {
                ForEach(NextIcon.allCases) { icon in
                    VStack(spacing: 6) {
                        ZStack {
                            Circle()
                                .fill(PageLibrary.gold)
                                .frame(width: 44, height: 44)
                            Image(systemName: icon.symbol)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(PageLibrary.coral)
                        }
                        Text(icon.title)
                            .font(.caption2)
                            .foregroundStyle(DemoPalette.inkMuted)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.vertical, 12)
        case .duration:
            Text("One second is split in half: easeIn while the circle grows, easeOut while it shrinks. The page view uses easeInOut for the same full interval.")
                .font(.caption)
                .foregroundStyle(DemoPalette.inkMuted)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, minHeight: 88, alignment: .leading)
                .padding(8)
        case .callbacks:
            Text("didChangeCurrentPage reports the index after it changes. didGoToLastPage runs in that same step when the index is the last page. animationDidEnd runs after both.")
                .font(.caption)
                .foregroundStyle(DemoPalette.inkMuted)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, minHeight: 88, alignment: .leading)
                .padding(8)
        case .cycle:
            Text("The default next action wraps to the first page. insteadOfCyclingToFirstPage replaces that wrap. insteadOfCyclingToLastPage replaces a backward wrap off page 0. Live never calls goToPreviousPage, so the backward hook is not armed.")
                .font(.caption)
                .foregroundStyle(DemoPalette.inkMuted)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, minHeight: 88, alignment: .leading)
                .padding(8)
        case .manual:
            Text("goToNextPage and goToPreviousPage write the view's private @State. The drawn button calls goToNextPage(animated: true) unless didPressNextButton replaces it. A parent-held copy does not share that state, so Live does not add a second pair of buttons.")
                .font(.caption)
                .foregroundStyle(DemoPalette.inkMuted)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, minHeight: 88, alignment: .leading)
                .padding(8)
        }
    }

    private var chipRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                ForEach(chips, id: \.self) { chip in
                    DemoChrome.chip(chip)
                }
            }
        }
    }
}

/// Two circles. The package draws one growing circle, then a shrinking one. This card does not.
private struct CircleSketch: View {
    var body: some View {
        ZStack {
            PageLibrary.coral
            Circle()
                .fill(PageLibrary.gold)
                .frame(width: 120, height: 120)
                .offset(x: 36, y: 28)
            Circle()
                .fill(PageLibrary.gold)
                .frame(width: 36, height: 36)
                .overlay {
                    Image(systemName: "chevron.forward")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(PageLibrary.coral)
                }
                .offset(y: 36)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 140)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}
