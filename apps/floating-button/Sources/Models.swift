import SwiftUI

enum MenuTint: String, CaseIterable, Identifiable, Hashable {
    case amber
    case coral
    case teal
    case violet

    var id: String { rawValue }

    var color: Color {
        switch self {
        case .amber: Color(red: 0.96, green: 0.72, blue: 0.28)
        case .coral: Color(red: 0.93, green: 0.42, blue: 0.38)
        case .teal: Color(red: 0.32, green: 0.76, blue: 0.70)
        case .violet: Color(red: 0.58, green: 0.48, blue: 0.95)
        }
    }
}

struct MenuAction: Identifiable, Hashable {
    var id: String
    var title: String
    var symbol: String
    var tint: MenuTint
}

enum MenuCatalog {
    static let actions: [MenuAction] = [
        MenuAction(id: "pin", title: "Pin", symbol: "mappin", tint: .amber),
        MenuAction(id: "note", title: "Note", symbol: "note.text", tint: .coral),
        MenuAction(id: "photo", title: "Photo", symbol: "camera", tint: .teal),
        MenuAction(id: "link", title: "Link", symbol: "link", tint: .violet),
    ]

    /// Wider rows for the label menu. A different set from `actions` so the two
    /// surfaces are not the same buttons with a different frame.
    static let labels: [MenuAction] = [
        MenuAction(id: "new-pin", title: "New pin", symbol: "mappin.and.ellipse", tint: .amber),
        MenuAction(id: "new-note", title: "New note", symbol: "square.and.pencil", tint: .coral),
        MenuAction(id: "new-photo", title: "New photo", symbol: "camera.fill", tint: .teal),
    ]
}

enum StraightDirection: String, CaseIterable, Identifiable, Hashable {
    case left
    case right
    case top
    case bottom

    var id: String { rawValue }

    var title: String { rawValue.capitalized }

    /// The main button sits on the opposite edge so the items open into the stage.
    var anchor: MenuAnchor {
        switch self {
        case .left: .trailing
        case .right: .leading
        case .top: .bottom
        case .bottom: .top
        }
    }
}

/// Package `Alignment` cases. Named `RowAlignment` here so this file never has to
/// write the bare type `Alignment` next to SwiftUI.
enum RowAlignment: String, CaseIterable, Identifiable, Hashable {
    case left
    case right
    case top
    case bottom
    case center

    var id: String { rawValue }

    var title: String { rawValue.capitalized }
}

enum CircleTurn: String, CaseIterable, Identifiable, Hashable {
    case clockwise
    case counterClockwise

    var id: String { rawValue }

    var title: String {
        switch self {
        case .clockwise: "Clockwise"
        case .counterClockwise: "Counter"
        }
    }

    var call: String {
        switch self {
        case .clockwise: ".clockwise"
        case .counterClockwise: ".counterClockwise"
        }
    }
}

/// `mainZStackAlignment` takes SwiftUI's alignment, not the package enum.
enum StackAnchor: String, CaseIterable, Identifiable, Hashable {
    case center
    case top
    case bottom
    case leading
    case trailing

    var id: String { rawValue }

    var title: String { rawValue.capitalized }

    var value: Alignment {
        switch self {
        case .center: .center
        case .top: .top
        case .bottom: .bottom
        case .leading: .leading
        case .trailing: .trailing
        }
    }
}

enum MotionCurve: String, CaseIterable, Identifiable, Hashable {
    case easeInOut
    case spring
    case easeOut
    case linear
    case snappy

    var id: String { rawValue }

    var title: String {
        switch self {
        case .easeInOut: "Ease"
        case .spring: "Spring"
        case .easeOut: "Ease out"
        case .linear: "Linear"
        case .snappy: "Snappy"
        }
    }

    var call: String {
        switch self {
        case .easeInOut: ".easeInOut(duration: 0.4)"
        case .spring: ".spring(response: 0.45, dampingFraction: 0.72)"
        case .easeOut: ".easeOut(duration: 0.55)"
        case .linear: ".linear(duration: 0.25)"
        case .snappy: ".snappy(duration: 0.35)"
        }
    }

    var animation: Animation {
        switch self {
        case .easeInOut: .easeInOut(duration: 0.4)
        case .spring: .spring(response: 0.45, dampingFraction: 0.72)
        case .easeOut: .easeOut(duration: 0.55)
        case .linear: .linear(duration: 0.25)
        case .snappy: .snappy(duration: 0.35)
        }
    }
}

enum DelayChoice: String, CaseIterable, Identifiable, Hashable {
    case none
    case delta
    case explicit

    var id: String { rawValue }

    var title: String {
        switch self {
        case .none: "None"
        case .delta: "Delta"
        case .explicit: "Array"
        }
    }
}

enum DelayList {
    /// One entry per button. `buttonAnimation` indexes this array with `i` and with
    /// `count - i - 1`. A shorter array traps.
    static let pattern: [Double] = [0, 0.08, 0.22, 0.40]

    static func explicit(count: Int) -> [Double] {
        precondition(count >= 0 && count <= pattern.count)
        return Array(pattern.prefix(count))
    }
}

enum MenuFormat {
    static func size(_ size: CGSize) -> String {
        "\(points(size.width))×\(points(size.height))"
    }

    static func points(_ value: CGFloat) -> String {
        String(format: "%.0f", Double(value))
    }

    static func radians(_ degrees: Double) -> String {
        String(format: "%.2f", degrees * .pi / 180)
    }

    static func list(_ values: [Double]) -> String {
        values.map { String(format: "%.2f", $0) }.joined(separator: ", ")
    }
}

struct MainDisc: View {
    var isOpen: Bool
    var systemName: String = "plus"
    var tint: Color = DemoPalette.accent
    var diameter: CGFloat = 56

    var body: some View {
        ZStack {
            Circle().fill(tint)
            Image(systemName: systemName)
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(DemoPalette.page)
                .rotationEffect(.degrees(isOpen ? 45 : 0))
                .animation(.spring(response: 0.35, dampingFraction: 0.7), value: isOpen)
        }
        .frame(width: diameter, height: diameter)
        .shadow(color: tint.opacity(0.35), radius: 10, y: 6)
        .accessibilityLabel(isOpen ? "Close menu" : "Open menu")
    }
}

struct SubmenuDisc: View {
    var action: MenuAction
    var diameter: CGFloat = 44
    var onTap: () -> Void

    var body: some View {
        ZStack {
            Circle().fill(action.tint.color)
            Image(systemName: action.symbol)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.white)
        }
        .frame(width: diameter, height: diameter)
        .shadow(color: action.tint.color.opacity(0.35), radius: 8, y: 4)
        .onTapGesture(perform: onTap)
        .accessibilityLabel(action.title)
    }
}

/// Wide main button used by the label menu. The package measures whatever view it is given.
struct MainCapsule: View {
    var isOpen: Bool

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "plus")
                .font(.system(size: 16, weight: .bold))
                .rotationEffect(.degrees(isOpen ? 45 : 0))
                .animation(.spring(response: 0.35, dampingFraction: 0.7), value: isOpen)
            Text(isOpen ? "Close" : "New")
                .font(.subheadline.weight(.semibold))
        }
        .foregroundStyle(DemoPalette.page)
        .padding(.horizontal, 18)
        .frame(height: 56)
        .background(DemoPalette.accent, in: Capsule())
        .shadow(color: DemoPalette.accent.opacity(0.35), radius: 10, y: 6)
        .accessibilityLabel(isOpen ? "Close menu" : "Open menu")
    }
}

struct LabelRow: View {
    var action: MenuAction
    var onTap: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: action.symbol)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(action.tint.color)
                .frame(width: 22)
            Text(action.title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(DemoPalette.ink)
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 14)
        .frame(width: 176, height: 46)
        .background(DemoPalette.card, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .strokeBorder(DemoPalette.stroke, lineWidth: 1)
        }
        .onTapGesture(perform: onTap)
        .accessibilityLabel(action.title)
    }
}
