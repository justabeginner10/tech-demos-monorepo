import SwiftUI

/// Frozen stand-ins for the Live families. The playground owns every modifier.
enum GalleryCard: String, CaseIterable, Identifiable {
    case topToast
    case bottomToast
    case floater
    case center
    case dragCard
    case scrollSheet
    case displayMode
    case dismiss
    case item
    case scrim

    var id: String { rawValue }

    var title: String {
        switch self {
        case .topToast: "Top toast"
        case .bottomToast: "Bottom toast"
        case .floater: "Floater"
        case .center: "Center"
        case .dragCard: "Drag card"
        case .scrollSheet: "Scroll sheet"
        case .displayMode: "Display mode"
        case .dismiss: "Dismiss"
        case .item: "Item"
        case .scrim: "Background"
        }
    }

    var subtitle: String {
        switch self {
        case .topToast: ".type(.toast)"
        case .bottomToast: ".position(.bottom)"
        case .floater: ".type(.floater())"
        case .center: ".type(.default)"
        case .dragCard: "dragToDismiss"
        case .scrollSheet: ".scrollPopup"
        case .displayMode: "overlay · sheet · window"
        case .dismiss: "Popup.DismissSource"
        case .item: "item: Binding"
        case .scrim: "color · view"
        }
    }

    var chips: [String] {
        switch self {
        case .topToast:
            ["popupSafeAreaInsets", "autohideIn"]
        case .bottomToast:
            [".bottom", "drag down"]
        case .floater:
            ["position", "padding 10"]
        case .center:
            [".centerScale", "popupDismiss"]
        case .dragCard:
            [".toast", "height / 3"]
        case .scrollSheet:
            [".bottom(64)", "header"]
        case .displayMode:
            [".overlay", ".window", ".sheet"]
        case .dismiss:
            ["tapInside", "drag", "autohide"]
        case .item:
            ["Equatable", "nil hides"]
        case .scrim:
            ["backgroundColor", "backgroundView"]
        }
    }

    @ViewBuilder
    var preview: some View {
        VStack(alignment: .leading, spacing: 8) {
            snapshot
            chipRow
        }
    }

    @ViewBuilder
    private var snapshot: some View {
        switch self {
        case .topToast:
            PaintedStage {
                PaintedBar(title: "Couldn't save", pinnedToTop: true)
            }
        case .bottomToast:
            PaintedStage {
                PaintedBar(title: "Saved", pinnedToTop: false)
            }
        case .floater:
            PaintedStage {
                PaintedFloater()
            }
        case .center:
            PaintedStage {
                PaintedCenter()
            }
        case .dragCard:
            PaintedStage {
                PaintedDragCard()
            }
        case .scrollSheet:
            PaintedStage {
                PaintedScroll()
            }
        case .displayMode:
            ModeList()
        case .dismiss:
            DismissList()
        case .item:
            ItemList()
        case .scrim:
            ScrimList()
        }
    }

    private var chipRow: some View {
        HStack(spacing: 6) {
            ForEach(chips, id: \.self) { label in
                DemoChrome.chip(label)
            }
        }
        .padding(.horizontal, 8)
        .padding(.bottom, 8)
    }
}

private struct PaintedStage<Content: View>: View {
    @ViewBuilder var content: () -> Content

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(DemoPalette.page)
            content()
        }
        .frame(height: 148)
        .padding(8)
    }
}

private struct PaintedBar: View {
    var title: String
    var pinnedToTop: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.caption.weight(.semibold))
            Text(pinnedToTop ? "Bleeds to the top edge" : "Bleeds to the bottom edge")
                .font(.caption2)
                .opacity(0.8)
        }
        .foregroundStyle(pinnedToTop ? Color.white : DemoPalette.paperInk)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(pinnedToTop ? DemoPalette.accent : DemoPalette.paper)
        .frame(maxHeight: .infinity, alignment: pinnedToTop ? .top : .bottom)
    }
}

private struct PaintedFloater: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("Session invite")
                .font(.caption.weight(.semibold))
            Text("Padded card · safe area")
                .font(.caption2)
                .foregroundStyle(DemoPalette.inkMuted)
        }
        .foregroundStyle(DemoPalette.ink)
        .padding(10)
        .background(DemoPalette.card, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .strokeBorder(DemoPalette.stroke, lineWidth: 1)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding(10)
    }
}

private struct PaintedCenter: View {
    var body: some View {
        VStack(spacing: 6) {
            Text("Centered")
                .font(.caption.weight(.semibold))
                .foregroundStyle(DemoPalette.paperInk)
            Text("Thanks")
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(DemoPalette.accent, in: Capsule())
        }
        .padding(12)
        .background(DemoPalette.paper, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

private struct PaintedDragCard: View {
    var body: some View {
        VStack(spacing: 8) {
            Capsule()
                .fill(Color.black.opacity(0.2))
                .frame(width: 28, height: 4)
            Text("Drag down")
                .font(.caption.weight(.semibold))
                .foregroundStyle(DemoPalette.paperInk)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 8)
        .padding(.bottom, 16)
        .background(DemoPalette.paper)
        .clipShape(
            UnevenRoundedRectangle(
                topLeadingRadius: 16,
                bottomLeadingRadius: 0,
                bottomTrailingRadius: 0,
                topTrailingRadius: 16,
                style: .continuous
            )
        )
        .frame(maxHeight: .infinity, alignment: .bottom)
    }
}

private struct PaintedScroll: View {
    var body: some View {
        VStack(spacing: 0) {
            Capsule()
                .fill(Color.black.opacity(0.2))
                .frame(width: 28, height: 4)
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity)
                .background(DemoPalette.paper)
            VStack(alignment: .leading, spacing: 4) {
                Text("Header stays put")
                    .font(.caption2.weight(.semibold))
                Text("The lines below scroll.")
                    .font(.caption2)
                    .foregroundStyle(DemoPalette.paperMuted)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 10)
            .padding(.bottom, 10)
            .background(DemoPalette.paper)
        }
        .clipShape(
            UnevenRoundedRectangle(
                topLeadingRadius: 16,
                bottomLeadingRadius: 0,
                bottomTrailingRadius: 0,
                topTrailingRadius: 16,
                style: .continuous
            )
        )
        .frame(maxHeight: .infinity, alignment: .bottom)
        .padding(.top, 28)
    }
}

private struct ModeList: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            modeRow("overlay", "In the view. State updates.")
            modeRow("sheet", "fullScreenCover. One at a time.")
            modeRow("window", "Default. Binding, not @State.")
        }
        .padding(10)
    }

    private func modeRow(_ name: String, _ detail: String) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Text(name)
                .font(.caption2.monospaced())
                .foregroundStyle(DemoPalette.ink)
                .frame(width: 64, alignment: .leading)
            Text(detail)
                .font(.caption2)
                .foregroundStyle(DemoPalette.inkMuted)
        }
    }
}

private struct DismissList: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("binding · tapInside · tapOutside")
            Text("drag · autohide · exitCommand")
            Text("exitCommand is the TV remote and the Mac escape key.")
                .foregroundStyle(DemoPalette.inkMuted)
        }
        .font(.caption2.monospaced())
        .foregroundStyle(DemoPalette.ink)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
    }
}

private struct ItemList: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("nil  →  hidden")
            Text("value  →  shown")
            Text("The library copies the value for the dismiss animation.")
                .foregroundStyle(DemoPalette.inkMuted)
        }
        .font(.caption2.monospaced())
        .foregroundStyle(DemoPalette.ink)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
    }
}

private struct ScrimList: View {
    var body: some View {
        HStack(spacing: 8) {
            swatch(DemoPalette.page, "clear")
            swatch(Color.black.opacity(0.45), "color")
            swatch(DemoPalette.ink.opacity(0.35), "material")
        }
        .padding(10)
    }

    private func swatch(_ color: Color, _ name: String) -> some View {
        VStack(spacing: 4) {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(color)
                .frame(height: 48)
                .overlay {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .strokeBorder(DemoPalette.stroke, lineWidth: 1)
                }
            Text(name)
                .font(.caption2.monospaced())
                .foregroundStyle(DemoPalette.inkMuted)
        }
        .frame(maxWidth: .infinity)
    }
}
