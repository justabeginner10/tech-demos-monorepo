import SwiftUI

/// Frozen snapshots at fixed model values. Live playground owns the drawers.
enum GalleryFamily: String, CaseIterable, Identifiable {
    case cardGlass
    case cardSolid
    case typeBody
    case typeCaption
    case shadowDeep
    case shadowSoft

    var id: String { rawValue }

    var title: String {
        switch self {
        case .cardGlass: "Card · glass"
        case .cardSolid: "Card · solid"
        case .typeBody: "Type · body"
        case .typeCaption: "Type · caption"
        case .shadowDeep: "Shadow · deep"
        case .shadowSoft: "Shadow · soft"
        }
    }

    var subtitle: String {
        switch self {
        case .cardGlass: "Fixed CardModel · no drawer"
        case .cardSolid: "Disabled solid fill"
        case .typeBody: "17pt regular"
        case .typeCaption: "13pt semibold"
        case .shadowDeep: "Y 14 · 0.55"
        case .shadowSoft: "Y 6 · 0.22"
        }
    }

    var chips: [String] {
        switch self {
        case .cardGlass:
            ["title Card", "radius 24", "glass", "#F97316"]
        case .cardSolid:
            ["title Tile", "radius 8", "solid", "off"]
        case .typeBody:
            ["17pt", "regular", "track 0", "#E5E7EB"]
        case .typeCaption:
            ["13pt", "semibold", "track 0.6", "#93C5FD"]
        case .shadowDeep:
            ["r 22", "y 14", "op 0.55", "inset 16"]
        case .shadowSoft:
            ["r 10", "y 6", "op 0.22", "inset 28"]
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
        case .cardGlass:
            CardPreview(model: CardModel())
        case .cardSolid:
            CardPreview(
                model: CardModel(
                    title: "Tile",
                    cornerRadius: 8,
                    isEnabled: false,
                    fill: "#38BDF8",
                    style: "solid"
                )
            )
        case .typeBody:
            TypePreview(model: TypeModel())
        case .typeCaption:
            TypePreview(
                model: TypeModel(
                    fontSize: 13,
                    weight: "semibold",
                    tracking: 0.6,
                    lineSpacing: 3,
                    textColor: "#93C5FD"
                )
            )
        case .shadowDeep:
            ShadowPreview(
                model: ShadowModel(
                    radius: 22,
                    offsetY: 14,
                    opacity: 0.55,
                    inset: 16
                )
            )
        case .shadowSoft:
            ShadowPreview(
                model: ShadowModel(
                    radius: 10,
                    offsetY: 6,
                    opacity: 0.22,
                    color: "#082F49",
                    inset: 28
                )
            )
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
