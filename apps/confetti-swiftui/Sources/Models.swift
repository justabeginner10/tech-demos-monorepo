import SwiftUI

/// Package-default spectrum, plus three smaller palettes.
/// Spectrum matches the `colors` default on `confettiCannon`.
enum BurstPalette: String, CaseIterable, Identifiable, Hashable {
    case spectrum
    case poster
    case ice
    case gold

    var id: String { rawValue }

    var title: String {
        switch self {
        case .spectrum: "Spectrum"
        case .poster: "Poster"
        case .ice: "Ice"
        case .gold: "Gold"
        }
    }

    var colors: [Color] {
        switch self {
        case .spectrum:
            [.blue, .red, .green, .yellow, .pink, .purple, .orange]
        case .poster:
            [.red, .white]
        case .ice:
            [.cyan, .white, .mint, .blue]
        case .gold:
            [
                Color(red: 1, green: 0.84, blue: 0.35),
                Color(red: 1, green: 0.55, blue: 0.15),
                .white,
            ]
        }
    }
}

/// Piece sets the Live "Pieces" family can mount.
/// `ConfettiType` values are built next to the cannon, not here.
enum PieceSet: String, CaseIterable, Identifiable, Hashable {
    case shapes
    case circles
    case triangles
    case squares
    case ribbons
    case crosses
    case emoji
    case letters
    case symbols

    var id: String { rawValue }

    var title: String {
        switch self {
        case .shapes: "All shapes"
        case .circles: "Circles"
        case .triangles: "Triangles"
        case .squares: "Squares"
        case .ribbons: "Ribbons"
        case .crosses: "Crosses"
        case .emoji: "Emoji"
        case .letters: "Letters"
        case .symbols: "Symbols"
        }
    }

    var api: String {
        switch self {
        case .shapes: "ConfettiType.allCases"
        case .circles: ".shape(.circle)"
        case .triangles: ".shape(.triangle)"
        case .squares: ".shape(.square)"
        case .ribbons: ".shape(.slimRectangle)"
        case .crosses: ".shape(.roundedCross)"
        case .emoji: ".text"
        case .letters: ".text"
        case .symbols: ".sfSymbol"
        }
    }

    var summary: String {
        switch self {
        case .shapes:
            "allCases is the five shapes. Text, symbols, and images are not in that list."
        case .circles:
            "One shape. The cannon still crosses it with every color in the palette."
        case .triangles:
            "ConfettiType.shape(.triangle) draws the package Triangle."
        case .squares:
            "ConfettiType.shape(.square) draws a rectangle."
        case .ribbons:
            "slimRectangle is a thin bar along the bottom of the confetti frame."
        case .crosses:
            "roundedCross is the package cross shape."
        case .emoji:
            "Text confetti. Emoji usually keep their own colors; foregroundColor still runs."
        case .letters:
            "Plain text takes the palette through foregroundColor."
        case .symbols:
            "SF Symbols use the symbolName label and take the palette color."
        }
    }
}

/// README samples. Arguments are applied in LiveSurfaces.
enum CannonRecipe: String, CaseIterable, Identifiable, Hashable {
    case firework
    case hearts
    case rain
    case repeatBurst

    var id: String { rawValue }

    var title: String {
        switch self {
        case .firework: "Firework"
        case .hearts: "Hearts"
        case .rain: "Rain"
        case .repeatBurst: "Repeat"
        }
    }

    var summary: String {
        switch self {
        case .firework:
            "num 50, opening 0°, closing 360°, radius 200. Other arguments stay at the package defaults."
        case .hearts:
            "confettis are four heart strings. Count, angles, and colors stay at the defaults."
        case .rain:
            "num 1, four bill strings, size 30, 50 repetitions, interval 0.1. Haptics are passed false here."
        case .repeatBurst:
            "repetitions 3, interval 0.7. Shapes and colors stay at the defaults."
        }
    }

    var chips: [String] {
        switch self {
        case .firework:
            ["num 50", "0°…360°", "radius 200"]
        case .hearts:
            [".text", "❤️ 💙 💚 🧡"]
        case .rain:
            ["num 1", "× 50", "haptics off"]
        case .repeatBurst:
            ["× 3", "0.7 s", "defaults"]
        }
    }
}
