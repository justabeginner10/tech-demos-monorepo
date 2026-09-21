import SwiftUI

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

enum ChromeDetent: String, CaseIterable, Identifiable {
    case bar
    case peek
    case half

    var id: String { rawValue }

    /// Content height of the floating chrome (excluding outer padding).
    func height(in maxHeight: CGFloat) -> CGFloat {
        switch self {
        case .bar:
            72
        case .peek:
            min(300, max(260, maxHeight * 0.36))
        case .half:
            min(520, max(380, maxHeight * 0.55))
        }
    }

    var cornerRadius: CGFloat {
        self == .bar ? 36 : 24
    }
}
