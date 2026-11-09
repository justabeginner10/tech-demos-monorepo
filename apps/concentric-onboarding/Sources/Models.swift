import SwiftUI

struct PageSpec: Identifiable {
    let id: String
    let title: String
    let detail: String
    let symbol: String
    let background: Color
    let ink: Color
}

enum PageInk {
    static let light = Color(red: 0.16, green: 0.12, blue: 0.14)
    static let white = Color.white
}

enum PageLibrary {
    static let coral = Color(red: 0.949, green: 0.361, blue: 0.329)
    static let gold = Color(red: 1.0, green: 0.878, blue: 0.541)
    static let teal = Color(red: 0.180, green: 0.769, blue: 0.714)
    static let indigo = Color(red: 0.239, green: 0.204, blue: 0.545)

    /// Four pages. Each background is the next page's button color.
    static let walk: [PageSpec] = [
        PageSpec(
            id: "mark",
            title: "Mark",
            detail: "Drop a pin before the trail fades.",
            symbol: "mappin.and.ellipse",
            background: coral,
            ink: PageInk.white
        ),
        PageSpec(
            id: "ring",
            title: "Ring",
            detail: "The next color grows out of the button.",
            symbol: "circle.circle",
            background: gold,
            ink: PageInk.light
        ),
        PageSpec(
            id: "note",
            title: "Note",
            detail: "Leave one line for the walk back.",
            symbol: "note.text",
            background: teal,
            ink: PageInk.light
        ),
        PageSpec(
            id: "return",
            title: "Return",
            detail: "The last page can cycle home, or stop.",
            symbol: "arrow.uturn.backward",
            background: indigo,
            ink: PageInk.white
        ),
    ]

    static let finish: [PageSpec] = [
        PageSpec(
            id: "start",
            title: "Start",
            detail: "Three pages, then the button stays.",
            symbol: "flag.fill",
            background: indigo,
            ink: PageInk.white
        ),
        PageSpec(
            id: "middle",
            title: "Middle",
            detail: "The circle is the color of the next page.",
            symbol: "figure.walk",
            background: gold,
            ink: PageInk.light
        ),
        PageSpec(
            id: "last",
            title: "Last",
            detail: "Next does not wrap to Start.",
            symbol: "checkmark.seal.fill",
            background: coral,
            ink: PageInk.white
        ),
    ]

    static let held: [PageSpec] = [
        PageSpec(
            id: "held",
            title: "Held",
            detail: "This press belongs to the closure.",
            symbol: "hand.raised.fill",
            background: teal,
            ink: PageInk.light
        ),
        PageSpec(
            id: "waiting",
            title: "Waiting",
            detail: "The button still shows this page's color.",
            symbol: "paintpalette.fill",
            background: coral,
            ink: PageInk.white
        ),
    ]
}

enum NextIcon: String, CaseIterable, Identifiable {
    case chevron
    case arrow
    case check

    var id: String { rawValue }

    var title: String {
        switch self {
        case .chevron: "Chevron"
        case .arrow: "Arrow"
        case .check: "Check"
        }
    }

    /// SF Symbol name passed to `nextIcon(_:)`.
    var symbol: String {
        switch self {
        case .chevron: "chevron.forward"
        case .arrow: "arrow.right"
        case .check: "checkmark"
        }
    }
}

struct OnboardingPage: View {
    let page: PageSpec

    var body: some View {
        VStack(spacing: 14) {
            Image(systemName: page.symbol)
                .font(.system(size: 52, weight: .semibold))
                .foregroundStyle(page.ink)
            Text(page.title)
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundStyle(page.ink)
                .multilineTextAlignment(.center)
            Text(page.detail)
                .font(.body.weight(.medium))
                .foregroundStyle(page.ink.opacity(0.88))
                .multilineTextAlignment(.center)
                .frame(maxWidth: 280)
        }
        .padding(.horizontal, 28)
        .padding(.bottom, 48)
    }
}
