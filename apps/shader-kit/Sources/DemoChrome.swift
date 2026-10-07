import ShaderKit
import ShaderCards
import SwiftUI

enum DemoTab: Hashable {
    case live
    case gallery
}

enum LiveFamily: String, CaseIterable, Identifiable, Hashable {
    case holo
    case cards
    case jelly

    var id: String { rawValue }

    var title: String {
        switch self {
        case .holo: "Holo"
        case .cards: "Cards"
        case .jelly: "Jelly"
        }
    }

    var subtitle: String {
        switch self {
        case .holo: "HolographicCardContainer"
        case .cards: "TradingCardView"
        case .jelly: "JellySwitch · JellyButton"
        }
    }
}

enum DemoPalette {
    static let page = Color(red: 8 / 255, green: 8 / 255, blue: 10 / 255)
    static let card = Color(red: 16 / 255, green: 16 / 255, blue: 18 / 255)
    static let canvas = Color(red: 10 / 255, green: 10 / 255, blue: 10 / 255)
    static let stroke = Color.white.opacity(0.12)
    /// Hardcoded so foil, glass, and system scheme cannot paint black-on-black chrome.
    static let ink = Color(red: 245 / 255, green: 245 / 255, blue: 247 / 255)
    static let inkMuted = Color(red: 198 / 255, green: 198 / 255, blue: 204 / 255)
    static let accent = Color(red: 1, green: 0.78, blue: 0.28)
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
}

/// Applies an ordered ShaderKit stack. Same reduce-to-`AnyView` pattern
/// ShaderCards uses internally — kept local so Gallery never imports it.
struct StackedShaders: ViewModifier {
    var effects: [ShaderEffect]

    func body(content: Content) -> some View {
        effects.reduce(AnyView(content)) { view, effect in
            AnyView(view.shader(effect))
        }
    }
}

extension Card {
    /// Layout from rarity, with every Metal pass stripped — the ShaderCards
    /// thumbnail recipe (`CardGalleryView.thumbnailFinish`).
    var staticThumbnailFinish: CardFinish {
        var finish = resolvedFinish
        finish.artEffects = []
        finish.cardEffects = []
        finish.frameMaskedEffects = []
        return finish
    }
}
