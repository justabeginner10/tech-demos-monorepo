import SwiftUI
import ThemeKit
#if canImport(UIKit)
import UIKit
#endif

/// Curated ThemePicker catalog — not all 33 daisyUI presets.
enum LiveCatalog {
    static let pickerIDs = ["default", "cupcake", "aqua", "nord", "dracula", "sunset"]

    static var pickerPresets: [ThemePreset] {
        pickerIDs.compactMap(ThemePreset.named)
    }
}

/// Isolated Theme instances for Gallery. Never assigned to `Theme.shared`.
enum IsolatedThemes {
    static let `default`: Theme = {
        let theme = Theme()
        ThemePreset.named("default")?.apply(to: theme)
        return theme
    }()

    static let ocean: Theme = {
        let theme = Theme()
        theme.loadTheme(named: "oceanTheme")
        return theme
    }()

    static let dracula: Theme = {
        let theme = Theme()
        ThemePreset.named("dracula")?.apply(to: theme)
        return theme
    }()

    static let nord: Theme = {
        let theme = Theme()
        ThemePreset.named("nord")?.apply(to: theme)
        return theme
    }()
}

/// Hex helpers for the Generator surface (`ColorPicker` + text field).
enum DemoHex {
    static let violet = "7C3AED"
    static let teal = "0FB4AB"
    static let pink = "FF0D87"
    static let orange = "F97316"

    static let swatches: [(label: String, hex: String)] = [
        ("Violet", violet),
        ("Teal", teal),
        ("Pink", pink),
        ("Orange", orange),
    ]

    static func normalize(_ raw: String) -> String {
        var hex = raw.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if hex.hasPrefix("#") {
            hex.removeFirst()
        }
        return hex
    }

    static func isRGB(_ hex: String) -> Bool {
        let cleaned = normalize(hex)
        guard cleaned.count == 6 else { return false }
        return cleaned.allSatisfy(\.isHexDigit)
    }

    static func color(_ hex: String) -> Color {
        Color(hex: normalize(hex))
    }

    static func string(from color: Color) -> String {
        #if canImport(UIKit)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        UIColor(color).getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return String(
            format: "%02X%02X%02X",
            Int((red * 255).rounded()),
            Int((green * 255).rounded()),
            Int((blue * 255).rounded())
        )
        #else
        return violet
        #endif
    }
}
