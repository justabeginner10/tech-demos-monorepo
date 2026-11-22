import SwiftUI

/// Where a toast pins. Mapped to `Popup.Position` next to the modifier.
enum ToastEdge: String, CaseIterable, Identifiable, Hashable {
    case top
    case bottom

    var id: String { rawValue }

    var title: String {
        switch self {
        case .top: "Top"
        case .bottom: "Bottom"
        }
    }

    var api: String {
        switch self {
        case .top: ".position(.top)"
        case .bottom: ".position(.bottom)"
        }
    }
}

/// `nil` is the package default: the popup never hides itself.
enum AutohideChoice: String, CaseIterable, Identifiable, Hashable {
    case off
    case two
    case four

    var id: String { rawValue }

    var title: String {
        switch self {
        case .off: "Off"
        case .two: "2s"
        case .four: "4s"
        }
    }

    var seconds: Double? {
        switch self {
        case .off: nil
        case .two: 2
        case .four: 4
        }
    }
}

/// Nine `Popup.Position` cases. `.center` is the usual popup; the rest pin a floater.
enum FloaterSlot: String, CaseIterable, Identifiable, Hashable {
    case topLeading
    case top
    case topTrailing
    case leading
    case center
    case trailing
    case bottomLeading
    case bottom
    case bottomTrailing

    var id: String { rawValue }

    var title: String {
        switch self {
        case .topLeading: "Top leading"
        case .top: "Top"
        case .topTrailing: "Top trailing"
        case .leading: "Leading"
        case .center: "Center"
        case .trailing: "Trailing"
        case .bottomLeading: "Bottom leading"
        case .bottom: "Bottom"
        case .bottomTrailing: "Bottom trailing"
        }
    }

    var api: String { ".\(rawValue)" }
}

/// How PopupView inserts the popup. Package default is `.window`.
enum HostMode: String, CaseIterable, Identifiable, Hashable {
    case overlay
    case window
    case sheet

    var id: String { rawValue }

    var title: String {
        switch self {
        case .overlay: "Overlay"
        case .window: "Window"
        case .sheet: "Sheet"
        }
    }

    var api: String {
        switch self {
        case .overlay: ".displayMode(.overlay)"
        case .window: ".displayMode(.window)"
        case .sheet: ".displayMode(.sheet)"
        }
    }

    var detail: String {
        switch self {
        case .overlay:
            "Drawn in the stage overlay. @State inside the popup updates. It stays under navigation bars."
        case .window:
            "Package default. A UIWindow above the app. Pass a Binding into the popup — @State in that body does not refresh."
        case .sheet:
            "SwiftUI fullScreenCover. One popup at a time. allowTapThroughBG is forced off."
        }
    }

    var stageNote: String {
        switch self {
        case .overlay:
            "Overlay measures this card."
        case .window:
            "Window covers the screen."
        case .sheet:
            "Sheet covers the screen."
        }
    }
}

/// Which sheet-style modifier the Sheets family mounts.
enum SheetKind: String, CaseIterable, Identifiable, Hashable {
    case center
    case card
    case scroll

    var id: String { rawValue }

    var title: String {
        switch self {
        case .center: "Center"
        case .card: "Drag card"
        case .scroll: "Scroll"
        }
    }

    var subtitle: String {
        switch self {
        case .center: ".type(.default) · centerScale"
        case .card: ".type(.toast) · .bottom · drag"
        case .scroll: ".scrollPopup · header"
        }
    }
}

/// Appear / disappear pair for the centered dialog.
/// A `.default` popup with no `appearFrom` slides up from the bottom.
enum CenterMotion: String, CaseIterable, Identifiable, Hashable {
    case zoom
    case slide
    case leaveUp
    case none

    var id: String { rawValue }

    var title: String {
        switch self {
        case .zoom: "Zoom"
        case .slide: "Slide"
        case .leaveUp: "Leave up"
        case .none: "None"
        }
    }

    var detail: String {
        switch self {
        case .zoom:
            "appearFrom and disappearTo are both .centerScale."
        case .slide:
            "Both stay nil. Center falls through to .bottomSlide."
        case .leaveUp:
            "Zoom in, then disappearTo(.topSlide)."
        case .none:
            "appearFrom(.none) skips the slide and the scale."
        }
    }
}

/// Outside-area fill. `backgroundView` wins when both are set; this demo sets one.
enum ScrimStyle: String, CaseIterable, Identifiable, Hashable {
    case clear
    case color
    case material

    var id: String { rawValue }

    var title: String {
        switch self {
        case .clear: "Clear"
        case .color: "Color"
        case .material: "Material"
        }
    }
}
