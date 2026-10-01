import SwiftUI

/// Frozen param combinations. Live playground owns the `Rehearse` sheets.
enum GalleryFamily: String, CaseIterable, Identifiable {
    case showbillPremiere
    case showbillSoldOut
    case typeDisplay
    case typeCaption
    case stageStacked
    case stageWide

    var id: String { rawValue }

    var title: String {
        switch self {
        case .showbillPremiere: "Showbill · premiere"
        case .showbillSoldOut: "Showbill · sold out"
        case .typeDisplay: "Type · display"
        case .typeCaption: "Type · caption"
        case .stageStacked: "Stage · stacked"
        case .stageWide: "Stage · wide"
        }
    }

    var subtitle: String {
        switch self {
        case .showbillPremiere: "Fixed Showbill · no panel"
        case .showbillSoldOut: "Compact · unstarred"
        case .typeDisplay: "32pt bold italic"
        case .typeCaption: "15pt regular"
        case .stageStacked: "3 columns · 2 rows"
        case .stageWide: "1 column · leading"
        }
    }

    var chips: [String] {
        switch self {
        case .showbillPremiere:
            ["Night Shift", "nights 3", "regular", "premiere"]
        case .showbillSoldOut:
            ["Last Call", "nights 1", "compact", "soldOut"]
        case .typeDisplay:
            ["32pt", "bold", "italic", "track 0.8"]
        case .typeCaption:
            ["15pt", "regular", "lead 3", "#93C5FD"]
        case .stageStacked:
            ["cols 3", "space 8", "corner 12", "stacked"]
        case .stageWide:
            ["cols 1", "space 16", "corner 22", "leading"]
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
        case .showbillPremiere:
            Showbill(
                title: "Night Shift",
                nights: 3,
                energy: 0.65,
                starred: true,
                accent: DemoDefaults.showAccent,
                density: .regular,
                ribbon: .premiere
            )
        case .showbillSoldOut:
            Showbill(
                title: "Last Call",
                nights: 1,
                energy: 0.2,
                starred: false,
                accent: Color(red: 0.95, green: 0.35, blue: 0.38),
                density: .compact,
                ribbon: .soldOut
            )
        case .typeDisplay:
            TypeSample(
                headline: "Open rehearsal",
                size: 32,
                tracking: 0.8,
                leading: 8,
                weight: .bold,
                ink: Color(red: 0.99, green: 0.84, blue: 0.40),
                italic: true
            )
        case .typeCaption:
            TypeSample(
                headline: "Quiet caption",
                size: 15,
                tracking: 0.1,
                leading: 3,
                weight: .regular,
                ink: Color(red: 0.58, green: 0.77, blue: 0.99),
                italic: false
            )
        case .stageStacked:
            StageGrid(
                columns: 3,
                spacing: 8,
                corner: 12,
                inset: 12,
                stacked: true,
                fill: DemoDefaults.stageFill,
                align: .center
            )
        case .stageWide:
            StageGrid(
                columns: 1,
                spacing: 16,
                corner: 22,
                inset: 20,
                stacked: false,
                fill: Color(red: 0.65, green: 0.55, blue: 0.98),
                align: .leading
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
