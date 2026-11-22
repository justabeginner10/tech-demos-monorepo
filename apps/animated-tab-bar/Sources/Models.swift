import AnimatedTabBar
import SwiftUI

/// SF Symbols used by the plain builder bar and by `WiggleButton`.
/// The example's third bar uses the same five names (`heart` through `book`).
enum SymbolTab: String, CaseIterable, Identifiable, Hashable {
    case heart
    case leaf
    case drop
    case circle
    case book

    var id: String { rawValue }

    var title: String { rawValue.capitalized }

    var symbolName: String { rawValue }

    /// Fill variant the example passes as `WiggleButton`'s `maskImage`.
    var fillSymbolName: String { rawValue + ".fill" }
}

/// Asset-catalog names for `DropletButton`. The package draws `Image(imageName)`,
/// which is not an SF Symbol. These five PDFs ship in this app's asset catalog.
enum DropletIcon: String, CaseIterable, Identifiable, Hashable {
    case house
    case search
    case bell
    case person
    case gear

    var id: String { rawValue }

    var title: String {
        switch self {
        case .house: "Home"
        case .search: "Search"
        case .bell: "Bell"
        case .person: "Person"
        case .gear: "Gear"
        }
    }

    var assetName: String {
        "droplet" + rawValue.prefix(1).uppercased() + rawValue.dropFirst()
    }
}

enum BallPath: String, CaseIterable, Identifiable, Hashable {
    case parabolic
    case teleport
    case straight

    var id: String { rawValue }

    var title: String {
        switch self {
        case .parabolic: "Parabolic"
        case .teleport: "Teleport"
        case .straight: "Straight"
        }
    }

    var detail: String {
        switch self {
        case .parabolic:
            "Package default. Quad curve, control point 100 pt above the buttons. Peak is about halfway there."
        case .teleport:
            "Shrink, hide, reappear. Example wiggle bar. Uses teleportEffect."
        case .straight:
            "Slide on y = 15. Example color bar. Indent slides with it."
        }
    }

    var trajectory: AnimatedTabBar.BallTrajectory {
        switch self {
        case .parabolic: .parabolic
        case .teleport: .teleport
        case .straight: .straight
        }
    }
}

/// Curves the example and the package defaults actually pass to `ballAnimation` / `indentAnimation`.
enum BarMotion: String, CaseIterable, Identifiable, Hashable {
    case easeOutDefault
    case easeOutShort
    case sampleSpring

    var id: String { rawValue }

    var title: String {
        switch self {
        case .easeOutDefault: "Ease out 0.6"
        case .easeOutShort: "Ease out 0.3"
        case .sampleSpring: "Spring 130"
        }
    }

    var api: String {
        switch self {
        case .easeOutDefault: ".easeOut(duration: 0.6)"
        case .easeOutShort: ".easeOut(duration: 0.3)"
        case .sampleSpring: ".interpolatingSpring(stiffness: 130, damping: 15)"
        }
    }

    var detail: String {
        switch self {
        case .easeOutDefault:
            "Package default for ballAnimation, indentAnimation, and buttonsAnimation."
        case .easeOutShort:
            "Example indent animation on the straight bar."
        case .sampleSpring:
            "Example ball animation on the straight bar. Stiffness 130, damping 15."
        }
    }

    var animation: Animation {
        switch self {
        case .easeOutDefault:
            .easeOut(duration: 0.6)
        case .easeOutShort:
            .easeOut(duration: 0.3)
        case .sampleSpring:
            .interpolatingSpring(stiffness: 130, damping: 15)
        }
    }
}

/// Colors named by the package defaults or the example's `Color+hex` palette.
enum BarInk: String, CaseIterable, Identifiable, Hashable {
    case white
    case black
    case red
    case sampleGrey
    case sampleLightGrey
    case samplePurple
    case sampleGreyFade
    case samplePurpleFade

    var id: String { rawValue }

    var title: String {
        switch self {
        case .white: "White"
        case .black: "Black"
        case .red: "Red"
        case .sampleGrey: "Grey"
        case .sampleLightGrey: "Light grey"
        case .samplePurple: "Purple"
        case .sampleGreyFade: "Grey 30%"
        case .samplePurpleFade: "Purple 30%"
        }
    }

    var color: Color {
        switch self {
        case .white:
            .white
        case .black:
            .black
        case .red:
            .red
        case .sampleGrey:
            Color(red: 12 / 255, green: 12 / 255, blue: 12 / 255)
        case .sampleLightGrey:
            Color(red: 177 / 255, green: 177 / 255, blue: 177 / 255)
        case .samplePurple:
            Color(red: 125 / 255, green: 38 / 255, blue: 254 / 255)
        case .sampleGreyFade:
            Color(red: 12 / 255, green: 12 / 255, blue: 12 / 255).opacity(0.3)
        case .samplePurpleFade:
            Color(red: 125 / 255, green: 38 / 255, blue: 254 / 255).opacity(0.3)
        }
    }
}
