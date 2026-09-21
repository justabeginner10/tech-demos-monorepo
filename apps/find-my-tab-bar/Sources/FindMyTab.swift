import SwiftUI

/// Tabs shown in the floating Find My–style bar.
///
/// Icons follow the iOS 26 Find My chrome (People / Devices / Items / Me)
/// using SF Symbols only — no Apple artwork.
enum FindMyTab: String, CaseIterable, Identifiable, Hashable {
    case people
    case devices
    case items
    case me

    var id: String { rawValue }

    var title: String {
        switch self {
        case .people: "People"
        case .devices: "Devices"
        case .items: "Items"
        case .me: "Me"
        }
    }

    var systemImage: String {
        switch self {
        case .people: "person.2.fill"
        case .devices: "laptopcomputer"
        case .items: "circle.grid.2x2.fill"
        case .me: "paperplane.fill"
        }
    }

    static let accent = Color(red: 0.39, green: 0.68, blue: 1.00)
}

/// How tall the floating chrome sits over the map.
enum ChromeDetent: String, CaseIterable, Identifiable {
    case bar
    case peek
    case half

    var id: String { rawValue }

    func height(in maxHeight: CGFloat) -> CGFloat {
        switch self {
        case .bar:
            92
        case .peek:
            min(280, max(248, maxHeight * 0.34))
        case .half:
            min(560, max(400, maxHeight * 0.58))
        }
    }

    var cornerRadius: CGFloat {
        self == .bar ? 42 : 28
    }
}
