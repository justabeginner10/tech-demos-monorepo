import SwiftUI

struct MapCanvas: View {
    var selection: FindMyTab

    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size
            ZStack {
                Color(red: 0.27, green: 0.33, blue: 0.36)

                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Color(red: 0.20, green: 0.42, blue: 0.32))
                    .frame(width: size.width * 0.7, height: size.height * 0.38)
                    .position(x: size.width * 0.52, y: size.height * 0.46)

                Circle()
                    .stroke(Color(red: 0.14, green: 0.28, blue: 0.24), lineWidth: 14)
                    .frame(width: 150, height: 150)
                    .position(x: size.width * 0.5, y: size.height * 0.42)

                Ellipse()
                    .fill(Color(red: 0.22, green: 0.36, blue: 0.42))
                    .frame(width: size.width * 0.5, height: 70)
                    .position(x: size.width * 0.78, y: size.height * 0.86)

                ForEach(MapPin.samples.filter { $0.tabs.contains(selection) }) { pin in
                    MapPinView(pin: pin)
                        .position(x: pin.unit.x * size.width, y: pin.unit.y * size.height)
                        .transition(.opacity.combined(with: .scale(scale: 0.85)))
                }
            }
            .animation(.snappy(duration: 0.28), value: selection)
            .drawingGroup()
        }
    }
}

private struct MapPin: Identifiable {
    let id: String
    let title: String
    let glyph: String
    let color: Color
    let unit: UnitPoint
    let tabs: Set<FindMyTab>
    let isGlyphSF: Bool

    static let samples: [MapPin] = [
        .init(id: "maya", title: "Maya", glyph: "M", color: Color(red: 0.95, green: 0.55, blue: 0.35), unit: UnitPoint(x: 0.50, y: 0.42), tabs: [.people], isGlyphSF: false),
        .init(id: "jordan", title: "Jordan", glyph: "J", color: Color(red: 0.45, green: 0.72, blue: 0.95), unit: UnitPoint(x: 0.72, y: 0.55), tabs: [.people], isGlyphSF: false),
        .init(id: "phone", title: "Pocket", glyph: "iphone", color: Color(red: 0.55, green: 0.80, blue: 0.55), unit: UnitPoint(x: 0.38, y: 0.50), tabs: [.devices], isGlyphSF: true),
        .init(id: "tablet", title: "Travel", glyph: "ipad", color: Color(red: 0.40, green: 0.70, blue: 0.95), unit: UnitPoint(x: 0.64, y: 0.36), tabs: [.devices], isGlyphSF: true),
        .init(id: "keys", title: "Keys", glyph: "key.fill", color: Color(red: 0.95, green: 0.78, blue: 0.30), unit: UnitPoint(x: 0.30, y: 0.58), tabs: [.items], isGlyphSF: true),
        .init(id: "bag", title: "Bag", glyph: "backpack.fill", color: Color(red: 0.75, green: 0.55, blue: 0.95), unit: UnitPoint(x: 0.58, y: 0.60), tabs: [.items], isGlyphSF: true),
        .init(id: "me", title: "You", glyph: "Y", color: Color(red: 0.35, green: 0.78, blue: 0.48), unit: UnitPoint(x: 0.48, y: 0.48), tabs: [.me, .people, .devices, .items], isGlyphSF: false),
    ]
}

private struct MapPinView: View {
    var pin: MapPin

    var body: some View {
        VStack(spacing: 3) {
            ZStack {
                Circle().fill(.white).frame(width: 34, height: 34)
                Circle().fill(pin.color).frame(width: 28, height: 28)
                if pin.isGlyphSF {
                    Image(systemName: pin.glyph)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(.white)
                } else {
                    Text(pin.glyph)
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.white)
                }
            }
            Text(pin.title)
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(.white)
                .padding(.horizontal, 5)
                .padding(.vertical, 2)
                .background(.black.opacity(0.4), in: Capsule())
        }
    }
}
