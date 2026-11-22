import AnchoredPopup
import SwiftUI

enum PopupAnchor {
    static let minimal = "minimal-anchor"
    static let placement = "placement-anchor"
    static func corner(_ spot: CornerSpot) -> String { "corner-\(spot.rawValue)" }
    static func behavior(_ mode: DisplayChoice) -> String { "behavior-\(mode.rawValue)" }
}

enum NoteCycle {
    static let names = ["Ada", "Lin", "Noor"]

    static func next(after name: String) -> String {
        guard let index = names.firstIndex(of: name) else { return names[0] }
        return names[(index + 1) % names.count]
    }
}

/// Source default for `anchorRelative` is `.free` (`AnchoredPopupPosition` in PublicAPI.swift).
/// The package README says `.safeArea`. This demo follows the source.
enum BoundsChoice: String, CaseIterable, Identifiable, Hashable {
    case free
    case safeArea
    case screen

    var id: String { rawValue }

    var title: String {
        switch self {
        case .free: "Free"
        case .safeArea: "Safe"
        case .screen: "Screen"
        }
    }

    var call: String {
        switch self {
        case .free: ".free"
        case .safeArea: ".safeArea"
        case .screen: ".screen"
        }
    }

    var mode: AnchoredPopupBoundsMode {
        switch self {
        case .free: .free
        case .safeArea: .safeArea
        case .screen: .screen
        }
    }
}

enum CornerSpot: String, CaseIterable, Identifiable, Hashable {
    case topLeading
    case topTrailing
    case bottomLeading
    case bottomTrailing

    var id: String { rawValue }

    var title: String {
        switch self {
        case .topLeading: "Top leading"
        case .topTrailing: "Top trailing"
        case .bottomLeading: "Bottom leading"
        case .bottomTrailing: "Bottom trailing"
        }
    }

    var shortTitle: String {
        switch self {
        case .topLeading: "TL"
        case .topTrailing: "TR"
        case .bottomLeading: "BL"
        case .bottomTrailing: "BR"
        }
    }

    var systemImage: String {
        switch self {
        case .topLeading: "arrow.down.right"
        case .topTrailing: "arrow.down.left"
        case .bottomLeading: "arrow.up.right"
        case .bottomTrailing: "arrow.up.left"
        }
    }

    var alignment: Alignment {
        switch self {
        case .topLeading: .topLeading
        case .topTrailing: .topTrailing
        case .bottomLeading: .bottomLeading
        case .bottomTrailing: .bottomTrailing
        }
    }

    /// The same corner of the popup sticks to this corner of the disc, so the card grows inward.
    var unitPoint: UnitPoint {
        switch self {
        case .topLeading: .topLeading
        case .topTrailing: .topTrailing
        case .bottomLeading: .bottomLeading
        case .bottomTrailing: .bottomTrailing
        }
    }

    var unitCall: String {
        switch self {
        case .topLeading: ".topLeading"
        case .topTrailing: ".topTrailing"
        case .bottomLeading: ".bottomLeading"
        case .bottomTrailing: ".bottomTrailing"
        }
    }

    func call(bounds: BoundsChoice) -> String {
        ".anchorRelative(\(unitCall), boundsMode: \(bounds.call))"
    }
}

enum PlacementKind: String, CaseIterable, Identifiable, Hashable {
    case auto
    case screen
    case absolute

    var id: String { rawValue }

    var title: String {
        switch self {
        case .auto: "Auto"
        case .screen: "Screen"
        case .absolute: "Absolute"
        }
    }
}

enum StageSeat: String, CaseIterable, Identifiable, Hashable {
    case topLeading
    case topTrailing
    case center
    case bottomLeading
    case bottomTrailing

    var id: String { rawValue }

    var title: String {
        switch self {
        case .topLeading: "Top leading"
        case .topTrailing: "Top trailing"
        case .center: "Center"
        case .bottomLeading: "Bottom leading"
        case .bottomTrailing: "Bottom trailing"
        }
    }

    var alignment: Alignment {
        switch self {
        case .topLeading: .topLeading
        case .topTrailing: .topTrailing
        case .center: .center
        case .bottomLeading: .bottomLeading
        case .bottomTrailing: .bottomTrailing
        }
    }
}

enum ScreenPoint: String, CaseIterable, Identifiable, Hashable {
    case center
    case top
    case bottom
    case leading
    case trailing
    case topLeading

    var id: String { rawValue }

    var title: String {
        switch self {
        case .center: "Center"
        case .top: "Top"
        case .bottom: "Bottom"
        case .leading: "Leading"
        case .trailing: "Trailing"
        case .topLeading: "Top leading"
        }
    }

    var unitPoint: UnitPoint {
        switch self {
        case .center: .center
        case .top: .top
        case .bottom: .bottom
        case .leading: .leading
        case .trailing: .trailing
        case .topLeading: .topLeading
        }
    }

    var call: String {
        switch self {
        case .center: ".center"
        case .top: ".top"
        case .bottom: ".bottom"
        case .leading: ".leading"
        case .trailing: ".trailing"
        case .topLeading: ".topLeading"
        }
    }
}

enum DisplayChoice: String, CaseIterable, Identifiable, Hashable {
    case window
    case sheet

    var id: String { rawValue }

    var title: String {
        switch self {
        case .window: "Window"
        case .sheet: "Sheet"
        }
    }

    var mode: DisplayMode {
        switch self {
        case .window: .window
        case .sheet: .sheet
        }
    }

    var call: String {
        switch self {
        case .window: ".window"
        case .sheet: ".sheet"
        }
    }
}

/// Stored default on `PopupParameters` is `.easeIn(duration: 0.3)`.
/// The `animation(_:)` doc comment says easeOut. This list follows the stored value.
enum PopupMotion: String, CaseIterable, Identifiable, Hashable {
    case easeIn
    case snappy
    case easeOut
    case linear

    var id: String { rawValue }

    var title: String {
        switch self {
        case .easeIn: "Ease in"
        case .snappy: "Snappy"
        case .easeOut: "Ease out"
        case .linear: "Linear"
        }
    }

    var call: String {
        switch self {
        case .easeIn: ".easeIn(duration: 0.3)"
        case .snappy: ".snappy(duration: 0.35)"
        case .easeOut: ".easeOut(duration: 0.45)"
        case .linear: ".linear(duration: 0.2)"
        }
    }

    var animation: Animation {
        switch self {
        case .easeIn: .easeIn(duration: 0.3)
        case .snappy: .snappy(duration: 0.35)
        case .easeOut: .easeOut(duration: 0.45)
        case .linear: .linear(duration: 0.2)
        }
    }
}

enum BackdropChoice: String, CaseIterable, Identifiable, Hashable {
    case blur
    case heavyBlur
    case color
    case none
    case custom

    var id: String { rawValue }

    var title: String {
        switch self {
        case .blur: "Blur"
        case .heavyBlur: "Blur 16"
        case .color: "Color"
        case .none: "None"
        case .custom: "View"
        }
    }

    var call: String {
        switch self {
        case .blur: ".blur(radius: 6)"
        case .heavyBlur: ".blur(radius: 16)"
        case .color: ".color(...)"
        case .none: ".none"
        case .custom: "AnchoredPopupBackground(viewBuilder:)"
        }
    }

    var background: AnchoredPopupBackground {
        switch self {
        case .blur:
            return .blur(radius: 6)
        case .heavyBlur:
            return .blur(radius: 16)
        case .color:
            return .color(Color(red: 0.10, green: 0.08, blue: 0.16).opacity(0.78))
        case .none:
            return .none
        case .custom:
            return AnchoredPopupBackground {
                ZStack {
                    Color.black.opacity(0.42)
                    VStack {
                        Spacer()
                        Text("viewBuilder")
                            .font(.caption.monospaced())
                            .foregroundStyle(.white.opacity(0.85))
                            .padding(.bottom, 36)
                    }
                }
            }
        }
    }
}
