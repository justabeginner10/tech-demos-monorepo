import DialKit
import SwiftUI

/// README CardModel: title, radius, enabled, fill hex, glass/solid, motion.
struct CardModel: Codable, Equatable {
    var title = "Card"
    var cornerRadius = 24.0
    var isEnabled = true
    var fill = "#F97316"
    var style = "glass"
    var spring: DialSpring = .default
    var transition: DialTransition = .default

    static let titles = ["Card", "Poster", "Tile", "Panel", "Dial"]

    static func nextTitle(after current: String) -> String {
        guard let index = titles.firstIndex(of: current) else {
            return titles[0]
        }
        return titles[(index + 1) % titles.count]
    }

    static var controls: [DialControl<CardModel>] {
        [
            .text("title", keyPath: \.title, placeholder: "Title"),
            .slider("cornerRadius", keyPath: \.cornerRadius, range: 0.0...48.0, step: 1.0, unit: "pt"),
            .toggle("isEnabled", keyPath: \.isEnabled),
            .color("fill", keyPath: \.fill),
            .select(
                "style",
                keyPath: \.style,
                options: [
                    DialOption("glass", label: "Glass"),
                    DialOption("solid", label: "Solid"),
                ]
            ),
            .group(
                "motion",
                children: [
                    .spring("spring", keyPath: \.spring),
                    .transition("transition", keyPath: \.transition),
                    .action("shuffle"),
                ]
            ),
        ]
    }

    var fillColor: Color {
        isEnabled ? DialHex.color(fill) : Color(white: 0.35)
    }
}

/// Typography panel driving a sample paragraph.
struct TypeModel: Codable, Equatable {
    var fontSize = 17.0
    var weight = "regular"
    var tracking = 0.0
    var lineSpacing = 6.0
    var textColor = "#E5E7EB"

    static let sample = """
    DialKit binds a Codable model to sliders, toggles, hex colors, and \
    selects. Tune the paragraph here; the drawer writes into TypeModel \
    and this text follows dial.values.
    """

    static var controls: [DialControl<TypeModel>] {
        [
            .slider("fontSize", keyPath: \.fontSize, range: 12.0...28.0, step: 1.0, unit: "pt"),
            .select(
                "weight",
                keyPath: \.weight,
                options: [
                    DialOption("regular", label: "Regular"),
                    DialOption("medium", label: "Medium"),
                    DialOption("semibold", label: "Semibold"),
                    DialOption("bold", label: "Bold"),
                ]
            ),
            .slider("tracking", keyPath: \.tracking, range: -1.0...4.0, step: 0.1, unit: "pt"),
            .slider("lineSpacing", keyPath: \.lineSpacing, range: 0.0...16.0, step: 1.0, unit: "pt"),
            .color("textColor", keyPath: \.textColor),
        ]
    }

    var fontWeight: Font.Weight {
        switch weight {
        case "medium": .medium
        case "semibold": .semibold
        case "bold": .bold
        default: .regular
        }
    }
}

/// Cheap third panel: shadow offsets on a still card.
struct ShadowModel: Codable, Equatable {
    var radius = 18.0
    var offsetX = 0.0
    var offsetY = 10.0
    var opacity = 0.4
    var color = "#000000"
    var inset = 20.0

    static var controls: [DialControl<ShadowModel>] {
        [
            .slider("radius", keyPath: \.radius, range: 0.0...40.0, step: 1.0, unit: "pt"),
            .slider("offsetX", keyPath: \.offsetX, range: -24.0...24.0, step: 1.0, unit: "pt"),
            .slider("offsetY", keyPath: \.offsetY, range: -24.0...24.0, step: 1.0, unit: "pt"),
            .slider("opacity", keyPath: \.opacity, range: 0.0...1.0, step: 0.05),
            .color("color", keyPath: \.color),
            .slider("inset", keyPath: \.inset, range: 8.0...36.0, step: 1.0, unit: "pt"),
        ]
    }

    var shadowColor: Color {
        DialHex.color(color).opacity(opacity)
    }
}

/// Hex strings stored by DialKit color controls (`#RGB`, `#RRGGBB`, `#RRGGBBAA`).
enum DialHex {
    static func color(_ hex: String) -> Color {
        let cleaned = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var value: UInt64 = 0
        guard Scanner(string: cleaned).scanHexInt64(&value) else {
            return .orange
        }

        let red: Double
        let green: Double
        let blue: Double
        let alpha: Double

        switch cleaned.count {
        case 3:
            red = Double((value >> 8) & 0xF) / 15
            green = Double((value >> 4) & 0xF) / 15
            blue = Double(value & 0xF) / 15
            alpha = 1
        case 6:
            red = Double((value >> 16) & 0xFF) / 255
            green = Double((value >> 8) & 0xFF) / 255
            blue = Double(value & 0xFF) / 255
            alpha = 1
        case 8:
            red = Double((value >> 24) & 0xFF) / 255
            green = Double((value >> 16) & 0xFF) / 255
            blue = Double((value >> 8) & 0xFF) / 255
            alpha = Double(value & 0xFF) / 255
        default:
            return .orange
        }

        return Color(red: red, green: green, blue: blue, opacity: alpha)
    }
}

extension DialSpring {
    var demoAnimation: Animation {
        let physics = resolvedPhysics
        return .interpolatingSpring(
            mass: physics.mass,
            stiffness: physics.stiffness,
            damping: physics.damping
        )
    }
}

/// Isolated factories so Swift 6 accepts the `@StateObject` seed plus `onAction`.
@MainActor
enum LiveDialFactory {
    static func makeCard() -> DialPanelState<CardModel> {
        let relay = CardActionRelay()
        let dial = DialPanelState(
            name: "Card",
            initial: CardModel(),
            controls: CardModel.controls,
            onAction: { path in
                Task { @MainActor in
                    relay.handle(path)
                }
            }
        )
        relay.dial = dial
        return dial
    }

    static func makeType() -> DialPanelState<TypeModel> {
        DialPanelState(
            name: "Typography",
            initial: TypeModel(),
            controls: TypeModel.controls
        )
    }

    static func makeShadow() -> DialPanelState<ShadowModel> {
        DialPanelState(
            name: "Shadow",
            initial: ShadowModel(),
            controls: ShadowModel.controls
        )
    }
}

@MainActor
private final class CardActionRelay {
    weak var dial: DialPanelState<CardModel>?

    func handle(_ path: String) {
        guard path == "motion.shuffle", let dial else { return }
        var next = dial.values
        next.title = CardModel.nextTitle(after: next.title)
        withAnimation(dial.values.spring.demoAnimation) {
            dial.values = next
        }
    }
}
