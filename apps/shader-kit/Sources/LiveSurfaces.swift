import ShaderCards
import ShaderKit
import ShaderKitUI
import SwiftUI

/// One tilt-interactive `HolographicCardContainer`. The stack picker restyles
/// this card — it does not add a second Metal surface.
struct HoloCardSurface: View {
    @State private var stack: HoloStack = .codex

    private let cardWidth: CGFloat = 260
    private let cardHeight: CGFloat = 380

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            controls

            HolographicCardContainer(
                width: cardWidth,
                height: cardHeight,
                cornerRadius: 20,
                shadowColor: stack.shadow,
                rotationMultiplier: 13,
                interactionMode: .surfacePointer
            ) {
                DemoHoloFace(stack: stack)
                    .id(stack)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    private var controls: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("HolographicCardContainer")
                    .font(.headline)
                    .foregroundStyle(DemoPalette.ink)
                Spacer()
                Text(stack.caption)
                    .font(.caption.monospaced())
                    .foregroundStyle(DemoPalette.inkMuted)
                    .lineLimit(1)
            }

            LabeledContent("Stack") {
                Picker("Stack", selection: $stack) {
                    ForEach(HoloStack.allCases) { item in
                        Text(item.title).tag(item)
                    }
                }
                .pickerStyle(.menu)
                .labelsHidden()
                .tint(DemoPalette.ink)
            }
            .foregroundStyle(DemoPalette.ink)

            Text(
                "Effects sit on the fill only, so the title stays high-contrast ink. "
                    + "Pointer-absolute tilt (`.surfacePointer`). Two or three shader passes."
            )
            .font(.caption)
            .foregroundStyle(DemoPalette.inkMuted)
        }
        .padding(14)
        .background(DemoPalette.card, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(DemoPalette.stroke, lineWidth: 1)
        }
    }
}

/// One `TradingCardView` from ShaderCards. Switching the library card
/// restyles this surface — it does not stack a second foil host.
struct TradingCardSurface: View {
    @State private var pick: LibraryCard = .emberfox

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            controls

            TradingCardView(pick.card, width: 260)
                .id(pick)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    private var controls: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("TradingCardView")
                    .font(.headline)
                    .foregroundStyle(DemoPalette.ink)
                Spacer()
                Text(pick.caption)
                    .font(.caption.monospaced())
                    .foregroundStyle(DemoPalette.inkMuted)
            }

            LabeledContent("Card") {
                Picker("Card", selection: $pick) {
                    ForEach(LibraryCard.allCases) { item in
                        Text(item.title).tag(item)
                    }
                }
                .pickerStyle(.menu)
                .labelsHidden()
                .tint(DemoPalette.ink)
            }
            .foregroundStyle(DemoPalette.ink)

            Text(
                "ShaderCards wraps the face in `HolographicCardContainer` with "
                    + "`.surfacePointer`. Drag the foil. Gallery uses `CardFaceView` with "
                    + "every Metal pass stripped."
            )
            .font(.caption)
            .foregroundStyle(DemoPalette.inkMuted)
        }
        .padding(14)
        .background(DemoPalette.card, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(DemoPalette.stroke, lineWidth: 1)
        }
    }
}

/// ShaderKitUI jelly. Switch and Button never mount together.
struct JellySurface: View {
    @State private var control: JellyControl = .toggle
    @State private var isOn = false
    @State private var tapCount = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            controls

            Group {
                switch control {
                case .toggle:
                    JellySwitch(
                        isOn: $isOn,
                        jellyColor: DemoPalette.accent,
                        darkMode: true,
                        soundEnabled: false
                    )
                case .button:
                    JellyButton(
                        action: { tapCount += 1 },
                        jellyColor: Color(red: 0.95, green: 0.35, blue: 0.55),
                        darkMode: true,
                        soundEnabled: false
                    )
                }
            }
            .id(control)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .strokeBorder(DemoPalette.stroke, lineWidth: 1)
                    .allowsHitTesting(false)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    private var controls: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(control == .toggle ? "JellySwitch" : "JellyButton")
                    .font(.headline)
                    .foregroundStyle(DemoPalette.ink)
                Spacer()
                Text(statusCaption)
                    .font(.caption.monospaced())
                    .foregroundStyle(DemoPalette.inkMuted)
            }

            Picker("Control", selection: $control) {
                ForEach(JellyControl.allCases) { item in
                    Text(item.title).tag(item)
                }
            }
            .pickerStyle(.segmented)

            Text(
                "Ray-marched jelly from ShaderKitUI. Sounds off. Dark ambient. "
                    + "Tap the switch or mash the button — only one jelly is live."
            )
            .font(.caption)
            .foregroundStyle(DemoPalette.inkMuted)
        }
        .padding(14)
        .background(DemoPalette.card, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(DemoPalette.stroke, lineWidth: 1)
        }
    }

    private var statusCaption: String {
        switch control {
        case .toggle: isOn ? "on" : "off"
        case .button: "taps \(tapCount)"
        }
    }
}

#Preview("Holo card") {
    HoloCardSurface()
        .padding()
        .background(DemoPalette.page)
        .preferredColorScheme(.dark)
}

#Preview("Trading card") {
    TradingCardSurface()
        .padding()
        .background(DemoPalette.page)
        .preferredColorScheme(.dark)
}

#Preview("Jelly") {
    JellySurface()
        .padding()
        .background(DemoPalette.page)
        .preferredColorScheme(.dark)
}
