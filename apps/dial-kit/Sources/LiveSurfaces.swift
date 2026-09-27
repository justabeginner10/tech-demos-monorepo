import DialKit
import SwiftUI

/// Host-controlled DialRoot: Tune in the toolbar + a button, no FAB vs tab pill.
private struct HostTunedSurface<Content: View>: View {
    let family: LiveFamily
    @Binding var isPresented: Bool
    @ViewBuilder var content: () -> Content

    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 12) {
                DemoChrome.chartCard(title: family.title, subtitle: family.subtitle) {
                    content()
                }

                Button(family.tuneTitle) {
                    isPresented = true
                }
                .buttonStyle(.borderedProminent)
                .frame(maxWidth: .infinity)
            }

            DialRoot(
                position: .bottomRight,
                storageID: family.storageID,
                showsFAB: false,
                isPresented: $isPresented
            )
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Tune") {
                    isPresented = true
                }
            }
        }
    }
}

struct CardDialSurface: View {
    @StateObject private var dial: DialPanelState<CardModel>
    @State private var isDialPresented = false

    init() {
        _dial = StateObject(wrappedValue: LiveDialFactory.makeCard())
    }

    var body: some View {
        HostTunedSurface(family: .card, isPresented: $isDialPresented) {
            CardPreview(model: dial.values)
                .animation(dial.values.spring.demoAnimation, value: dial.values.cornerRadius)
                .animation(dial.values.spring.demoAnimation, value: dial.values.isEnabled)
                .animation(dial.values.spring.demoAnimation, value: dial.values.fill)
                .animation(dial.values.spring.demoAnimation, value: dial.values.style)
                .animation(dial.values.spring.demoAnimation, value: dial.values.title)
        }
    }
}

struct TypeDialSurface: View {
    @StateObject private var dial: DialPanelState<TypeModel>
    @State private var isDialPresented = false

    init() {
        _dial = StateObject(wrappedValue: LiveDialFactory.makeType())
    }

    var body: some View {
        HostTunedSurface(family: .type, isPresented: $isDialPresented) {
            TypePreview(model: dial.values)
        }
    }
}

struct ShadowDialSurface: View {
    @StateObject private var dial: DialPanelState<ShadowModel>
    @State private var isDialPresented = false

    init() {
        _dial = StateObject(wrappedValue: LiveDialFactory.makeShadow())
    }

    var body: some View {
        HostTunedSurface(family: .shadow, isPresented: $isDialPresented) {
            ShadowPreview(model: dial.values)
        }
    }
}

struct CardPreview: View {
    var model: CardModel

    var body: some View {
        ZStack {
            cardFill
            Text(model.title)
                .font(.title3.weight(.semibold))
                .foregroundStyle(.white)
                .opacity(model.isEnabled ? 1 : 0.55)
        }
        .frame(maxWidth: .infinity, minHeight: 180)
        .padding(28)
    }

    @ViewBuilder
    private var cardFill: some View {
        let shape = RoundedRectangle(cornerRadius: model.cornerRadius, style: .continuous)
        if model.style == "glass" {
            shape.fill(.ultraThinMaterial)
            shape.fill(model.fillColor.opacity(model.isEnabled ? 0.45 : 0.2))
        } else {
            shape.fill(model.fillColor)
        }
    }
}

struct TypePreview: View {
    var model: TypeModel

    var body: some View {
        Text(TypeModel.sample)
            .font(.system(size: model.fontSize, weight: model.fontWeight))
            .tracking(model.tracking)
            .lineSpacing(model.lineSpacing)
            .foregroundStyle(DialHex.color(model.textColor))
            .frame(maxWidth: .infinity, minHeight: 180, alignment: .topLeading)
            .padding(20)
    }
}

struct ShadowPreview: View {
    var model: ShadowModel

    var body: some View {
        RoundedRectangle(cornerRadius: 16, style: .continuous)
            .fill(Color(white: 0.16))
            .overlay {
                Text("Inset \(Int(model.inset))pt")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.secondary)
            }
            .shadow(
                color: model.shadowColor,
                radius: model.radius,
                x: model.offsetX,
                y: model.offsetY
            )
            .padding(model.inset)
            .frame(maxWidth: .infinity, minHeight: 180)
    }
}
