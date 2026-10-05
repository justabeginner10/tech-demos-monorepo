import SwiftUI
import WelcomeKit

/// Two-plus named apps the live sheet can switch between.
enum LivePreset: String, CaseIterable, Identifiable {
    case harbor
    case atelier
    case signal

    /// Isolated from the package default `"welcome"` so this playground can reset freely.
    static let firstLaunchID = "playground"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .harbor: "Harbor"
        case .atelier: "Atelier"
        case .signal: "Signal"
        }
    }

    var subtitle: String {
        switch self {
        case .harbor: "plain · teal · monochrome"
        case .atelier: "welcome(to:) · orange · hierarchical"
        case .signal: "whatsNew(in:) · indigo · palette"
        }
    }

    var headline: WelcomeHeadline {
        switch self {
        case .harbor: "Welcome to Harbor"
        case .atelier: .welcome(to: "Atelier")
        case .signal: .whatsNew(in: "Signal")
        }
    }

    var tint: Color {
        switch self {
        case .harbor: Color(red: 0.04, green: 0.52, blue: 0.56)
        case .atelier: Color(red: 0.82, green: 0.34, blue: 0.10)
        case .signal: Color(red: 0.33, green: 0.34, blue: 0.82)
        }
    }

    var features: [WelcomeFeature] {
        switch self {
        case .harbor:
            [
                WelcomeFeature(
                    id: "harbor-tides",
                    "Tide tables",
                    subtitle: "High and low water for this harbor only.",
                    systemImage: "water.waves"
                ),
                WelcomeFeature(
                    id: "harbor-ferry",
                    "Late ferry",
                    subtitle: "A ping when the last boat is about to leave.",
                    systemImage: "ferry.fill"
                ),
                WelcomeFeature(
                    id: "harbor-charts",
                    "Offline charts",
                    subtitle: "The map stays with you when the signal drops.",
                    systemImage: "map.fill"
                ),
            ]
        case .atelier:
            [
                WelcomeFeature(
                    id: "atelier-paint",
                    "Wet paint",
                    subtitle: "Notes stay on this device until you pin them.",
                    systemImage: "paintbrush.pointed.fill"
                ),
                WelcomeFeature(
                    id: "atelier-light",
                    "North light",
                    subtitle: "A quiet palette that still reads at 6am.",
                    systemImage: "sun.horizon.fill"
                ),
                WelcomeFeature(
                    id: "atelier-lamp",
                    "One lamp",
                    subtitle: "Focus mode hides everything but the page.",
                    systemImage: "lamp.desk.fill"
                ),
            ]
        case .signal:
            [
                WelcomeFeature(
                    id: "signal-ridge",
                    "Ridge tower",
                    subtitle: "Line-of-sight check before you hike.",
                    systemImage: "antenna.radiowaves.left.and.right",
                    tint: Color(red: 0.33, green: 0.34, blue: 0.82),
                    symbolRenderingMode: .palette,
                    symbolPalette: [
                        Color(red: 0.33, green: 0.34, blue: 0.82),
                        Color(red: 0.45, green: 0.78, blue: 0.96),
                    ]
                ),
                WelcomeFeature(
                    id: "signal-watch",
                    "Overnight watch",
                    subtitle: "Battery use dropped on the long sit.",
                    systemImage: "battery.100.bolt",
                    tint: Color(red: 0.18, green: 0.62, blue: 0.40)
                ),
                WelcomeFeature(
                    id: "signal-pin",
                    "Shared pin",
                    subtitle: "Drop a mark the rest of the watch can see.",
                    systemImage: "mappin.and.ellipse"
                ),
            ]
        }
    }

    var configuration: WelcomeConfiguration {
        var configuration = WelcomeConfiguration.default
        configuration.accentColor = tint
        configuration.continueTitle = continueTitle
        configuration.footnote = footnote
        switch self {
        case .harbor:
            configuration.symbolRenderingMode = .monochrome
            configuration.fontDesign = .default
            configuration.titleAlignment = .leading
        case .atelier:
            configuration.symbolRenderingMode = .hierarchical
            configuration.fontDesign = .rounded
            configuration.titleAlignment = .leading
        case .signal:
            configuration.symbolRenderingMode = .palette
            configuration.symbolPalette = [
                Color(red: 0.33, green: 0.34, blue: 0.82),
                Color(red: 0.45, green: 0.78, blue: 0.96),
            ]
            configuration.fontDesign = .serif
            configuration.titleAlignment = .leading
        }
        return configuration
    }

    var continueTitle: WelcomeText {
        switch self {
        case .harbor: "Get started"
        case .atelier: "Open the studio"
        case .signal: "See what’s new"
        }
    }

    var footnote: WelcomeText? {
        switch self {
        case .harbor: "You can change alerts later in Settings."
        case .atelier: nil
        case .signal: "Watch faces update on the next sync."
        }
    }

    var previewRows: [WelcomePreviewRow] {
        switch self {
        case .harbor:
            [
                WelcomePreviewRow("water.waves", "Tide tables", "High and low water for this harbor only."),
                WelcomePreviewRow("ferry.fill", "Late ferry", "A ping when the last boat is about to leave."),
                WelcomePreviewRow("map.fill", "Offline charts", "The map stays with you when the signal drops."),
            ]
        case .atelier:
            [
                WelcomePreviewRow("paintbrush.pointed.fill", "Wet paint", "Notes stay on this device until you pin them."),
                WelcomePreviewRow("sun.horizon.fill", "North light", "A quiet palette that still reads at 6am."),
                WelcomePreviewRow("lamp.desk.fill", "One lamp", "Focus mode hides everything but the page."),
            ]
        case .signal:
            [
                WelcomePreviewRow("antenna.radiowaves.left.and.right", "Ridge tower", "Line-of-sight check before you hike."),
                WelcomePreviewRow("battery.100.bolt", "Overnight watch", "Battery use dropped on the long sit."),
                WelcomePreviewRow("mappin.and.ellipse", "Shared pin", "Drop a mark the rest of the watch can see."),
            ]
        }
    }

    var continueLabel: String {
        switch self {
        case .harbor: "Get started"
        case .atelier: "Open the studio"
        case .signal: "See what’s new"
        }
    }

    var footnoteLabel: String? {
        switch self {
        case .harbor: "You can change alerts later in Settings."
        case .atelier: nil
        case .signal: "Watch faces update on the next sync."
        }
    }

    var leadLabel: String? {
        switch self {
        case .harbor: nil
        case .atelier: "Welcome to"
        case .signal: "What’s new in"
        }
    }

    var nameLabel: String {
        switch self {
        case .harbor: "Welcome to Harbor"
        case .atelier: "Atelier"
        case .signal: "Signal"
        }
    }
}

struct WelcomePreviewRow: Identifiable, Hashable {
    var symbol: String
    var title: String
    var subtitle: String

    var id: String { title }

    init(_ symbol: String, _ title: String, _ subtitle: String) {
        self.symbol = symbol
        self.title = title
        self.subtitle = subtitle
    }
}
