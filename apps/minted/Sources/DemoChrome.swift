import Minted
import SwiftUI

enum DemoTab: Hashable {
    case live
    case gallery
}

enum LiveFamily: String, CaseIterable, Identifiable, Hashable {
    case award
    case pin
    case reverse

    var id: String { rawValue }

    var title: String {
        switch self {
        case .award: "Award"
        case .pin: "Pin"
        case .reverse: "Reverse"
        }
    }

    var subtitle: String {
        switch self {
        case .award: "SpinningCoinView · CoinDesign"
        case .pin: "SpinningArtworkCoinView"
        case .reverse: "initialRotation: .pi"
        }
    }
}

enum DemoPalette {
    static let page = Color(red: 8 / 255, green: 8 / 255, blue: 10 / 255)
    static let card = Color(red: 16 / 255, green: 16 / 255, blue: 18 / 255)
    static let canvas = Color(red: 10 / 255, green: 10 / 255, blue: 10 / 255)
    static let stroke = Color.white.opacity(0.12)
    /// Hardcoded so SceneKit clear backgrounds and system scheme cannot paint black-on-black chrome.
    static let ink = Color(red: 245 / 255, green: 245 / 255, blue: 247 / 255)
    static let inkMuted = Color(red: 198 / 255, green: 198 / 255, blue: 204 / 255)
    static let accent = Color(red: 1, green: 0.80, blue: 0.52)
}

enum DemoChrome {
    static func chartCard<Content: View>(
        title: String,
        subtitle: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(DemoPalette.ink)
                Spacer()
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(DemoPalette.inkMuted)
            }

            content()
                .padding(.horizontal, 4)
                .padding(.bottom, 6)
                .background(DemoPalette.canvas)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .padding(14)
        .background(DemoPalette.card, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(DemoPalette.stroke, lineWidth: 1)
                .allowsHitTesting(false)
        }
    }

    static func chip(_ text: String) -> some View {
        Text(text)
            .font(.caption2.weight(.medium).monospaced())
            .foregroundStyle(DemoPalette.ink)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.white.opacity(0.12), in: Capsule())
    }

    static func coinStage<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(DemoPalette.canvas, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .strokeBorder(DemoPalette.stroke, lineWidth: 1)
                    .allowsHitTesting(false)
            }
    }
}

enum DemoSilhouette: String, CaseIterable, Identifiable, Hashable {
    case seal
    case octagon
    case circle
    case diamond

    var id: String { rawValue }

    var title: String {
        switch self {
        case .seal: "Seal"
        case .octagon: "Octagon"
        case .circle: "Circle"
        case .diamond: "Diamond"
        }
    }

    var minted: CoinSilhouette {
        switch self {
        case .seal: .seal
        case .octagon: .octagon
        case .circle: .circle
        case .diamond: .diamond
        }
    }
}

extension CoinEngraving {
    var title: String {
        switch self {
        case .petals: "Petals"
        case .rays: "Rays"
        case .lattice: "Lattice"
        case .plain: "Plain"
        }
    }
}

extension ArtworkCoin.Sample {
    var title: String {
        switch self {
        case .eiffelTower: "Eiffel"
        case .swissAlps: "Alps"
        case .amsterdamCanals: "Canals"
        case .alhambra: "Alhambra"
        case .acropolis: "Acropolis"
        case .santorini: "Santorini"
        case .mountFuji: "Fuji"
        case .kinkakuJi: "Kinkaku-ji"
        }
    }
}
