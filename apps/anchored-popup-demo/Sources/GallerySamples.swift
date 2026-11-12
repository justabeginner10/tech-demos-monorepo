import SwiftUI

enum GalleryCard: String, CaseIterable, Identifiable {
    case corners
    case placement
    case bounds
    case background
    case dismissal
    case display

    var id: String { rawValue }

    var title: String {
        switch self {
        case .corners: "Corners"
        case .placement: "Placement"
        case .bounds: "Bounds"
        case .background: "Background"
        case .dismissal: "Dismissal"
        case .display: "Display"
        }
    }

    var subtitle: String {
        switch self {
        case .corners: "anchorRelative"
        case .placement: "auto · screen · absolute"
        case .bounds: "AnchoredPopupBoundsMode"
        case .background: "AnchoredPopupBackground"
        case .dismissal: "tap · outside · dismiss"
        case .display: "window · sheet"
        }
    }

    var chips: [String] {
        switch self {
        case .corners:
            [".topLeading", ".bottomTrailing", "minimal overload"]
        case .placement:
            [".auto", ".screenRelative", ".absolute"]
        case .bounds:
            [".free", ".safeArea", ".screen"]
        case .background:
            [".blur", ".color", ".none", "viewBuilder"]
        case .dismissal:
            ["closeOnTap", "closeOnTapOutside", "anchoredPopupDismiss"]
        case .display:
            [".window", ".sheet", "launchGrowingAnimation"]
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
        case .corners:
            CornerMark()
        case .placement:
            PlacementMark()
        case .bounds:
            BoundsMark()
        case .background:
            BackgroundMark()
        case .dismissal:
            DismissalMark()
        case .display:
            DisplayMark()
        }
    }

    private var chipRow: some View {
        VStack(alignment: .leading, spacing: 6) {
            ForEach(chips, id: \.self) { chip in
                DemoChrome.chip(chip)
            }
        }
    }
}

private struct CornerMark: View {
    var body: some View {
        ZStack {
            markDisc("TL", alignment: .topLeading)
            markDisc("TR", alignment: .topTrailing)
            markDisc("BL", alignment: .bottomLeading)
            markDisc("BR", alignment: .bottomTrailing)
            Text("Defaults")
                .font(.caption2.weight(.semibold))
                .foregroundStyle(DemoPalette.page)
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
                .background(DemoPalette.accent, in: Capsule())
        }
        .frame(height: 140)
    }

    private func markDisc(_ title: String, alignment: Alignment) -> some View {
        Text(title)
            .font(.caption2.weight(.bold).monospaced())
            .foregroundStyle(DemoPalette.page)
            .frame(width: 36, height: 28)
            .background(DemoPalette.accent, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: alignment)
    }
}

private struct PlacementMark: View {
    var body: some View {
        HStack(spacing: 8) {
            placementTile("Auto", detail: "safe corner")
            placementTile("Screen", detail: "unit point")
            placementTile("Absolute", detail: "CGPoint")
        }
        .frame(maxWidth: .infinity, minHeight: 88, alignment: .leading)
    }

    private func placementTile(_ title: String, detail: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption.weight(.semibold))
            Text(detail)
                .font(.caption2.monospaced())
        }
        .foregroundStyle(DemoPalette.paperInk)
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(DemoPalette.paper, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

private struct BoundsMark: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            boundsRow("Free", note: "no clamp")
            boundsRow("Safe area", note: "inset window")
            boundsRow("Screen", note: "full window")
        }
        .padding(.vertical, 8)
    }

    private func boundsRow(_ title: String, note: String) -> some View {
        HStack {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(DemoPalette.ink)
            Spacer()
            Text(note)
                .font(.caption2.monospaced())
                .foregroundStyle(DemoPalette.inkMuted)
        }
    }
}

private struct BackgroundMark: View {
    var body: some View {
        HStack(spacing: 8) {
            swatch(DemoPalette.ink.opacity(0.35), title: "Blur")
            swatch(Color(red: 0.10, green: 0.08, blue: 0.16), title: "Color")
            swatch(DemoPalette.canvas, title: "None")
            swatch(Color.black.opacity(0.55), title: "View")
        }
        .frame(maxWidth: .infinity, minHeight: 72, alignment: .leading)
    }

    private func swatch(_ color: Color, title: String) -> some View {
        VStack(spacing: 6) {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(color)
                .frame(height: 36)
                .overlay {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .strokeBorder(DemoPalette.stroke, lineWidth: 1)
                }
            Text(title)
                .font(.caption2)
                .foregroundStyle(DemoPalette.inkMuted)
        }
        .frame(maxWidth: .infinity)
    }
}

private struct DismissalMark: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Tap the card")
            Text("Tap outside")
            Text("launchShrinkingAnimation")
            Text("anchoredPopupDismiss")
        }
        .font(.caption.monospaced())
        .foregroundStyle(DemoPalette.ink)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 8)
    }
}

private struct DisplayMark: View {
    var body: some View {
        HStack(spacing: 8) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Window")
                    .font(.caption.weight(.semibold))
                Text("Many popups. Passthrough.")
                    .font(.caption2)
            }
            .foregroundStyle(DemoPalette.paperInk)
            .padding(10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(DemoPalette.paper, in: RoundedRectangle(cornerRadius: 12, style: .continuous))

            VStack(alignment: .leading, spacing: 4) {
                Text("Sheet")
                    .font(.caption.weight(.semibold))
                Text("One popup. SwiftUI state.")
                    .font(.caption2)
            }
            .foregroundStyle(DemoPalette.ink)
            .padding(10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .frame(minHeight: 88)
    }
}
