import SwiftUI

/// Original stylized map — not Apple MapKit tiles, not Apple Park.
///
/// The circular landmark is a civic amphitheater so the floating bar has
/// rich content to sit over, matching the Find My “bar over a map” feel.
struct MapCanvas: View {
    var selection: FindMyTab

    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size

            ZStack {
                MapPalette.ground
                park(in: size)
                bowl(in: size)
                roads(in: size)
                water(in: size)
                labels(in: size)
                pins(in: size)
            }
        }
        .ignoresSafeArea()
    }

    private func park(in size: CGSize) -> some View {
        RoundedRectangle(cornerRadius: 8, style: .continuous)
            .fill(MapPalette.park)
            .frame(width: size.width * 0.72, height: size.height * 0.42)
            .position(x: size.width * 0.52, y: size.height * 0.48)
    }

    private func bowl(in size: CGSize) -> some View {
        let center = CGPoint(x: size.width * 0.50, y: size.height * 0.42)
        return ZStack {
            Circle()
                .stroke(MapPalette.bowlRing, lineWidth: 18)
                .frame(width: 168, height: 168)
            Circle()
                .stroke(MapPalette.bowlRing.opacity(0.7), lineWidth: 10)
                .frame(width: 118, height: 118)
            Circle()
                .fill(MapPalette.parkDeep)
                .frame(width: 72, height: 72)
        }
        .position(center)
    }

    private func roads(in _: CGSize) -> some View {
        Canvas { context, canvasSize in
            var grid = Path()
            let step: CGFloat = 46
            for x in stride(from: 0, through: canvasSize.width, by: step) {
                grid.move(to: CGPoint(x: x, y: 0))
                grid.addLine(to: CGPoint(x: x, y: canvasSize.height))
            }
            for y in stride(from: 0, through: canvasSize.height, by: step) {
                grid.move(to: CGPoint(x: 0, y: y))
                grid.addLine(to: CGPoint(x: canvasSize.width, y: y))
            }
            context.stroke(grid, with: .color(MapPalette.road.opacity(0.35)), lineWidth: 1)

            var highway = Path()
            highway.move(to: CGPoint(x: 0, y: canvasSize.height * 0.72))
            highway.addQuadCurve(
                to: CGPoint(x: canvasSize.width, y: canvasSize.height * 0.78),
                control: CGPoint(x: canvasSize.width * 0.45, y: canvasSize.height * 0.66)
            )
            context.stroke(highway, with: .color(MapPalette.highway), lineWidth: 14)
            context.stroke(highway, with: .color(MapPalette.highwayDash), style: StrokeStyle(lineWidth: 1.4, dash: [10, 8]))

            var cross = Path()
            cross.move(to: CGPoint(x: canvasSize.width * 0.18, y: 0))
            cross.addLine(to: CGPoint(x: canvasSize.width * 0.22, y: canvasSize.height))
            context.stroke(cross, with: .color(MapPalette.road), lineWidth: 8)
        }
        .allowsHitTesting(false)
    }

    private func water(in size: CGSize) -> some View {
        Ellipse()
            .fill(MapPalette.water)
            .frame(width: size.width * 0.55, height: 90)
            .position(x: size.width * 0.78, y: size.height * 0.88)
            .blur(radius: 0.2)
    }

    private func labels(in size: CGSize) -> some View {
        ZStack {
            mapLabel("RIDGEWAY", at: CGPoint(x: size.width * 0.22, y: size.height * 0.16))
            mapLabel("HARBOR GREEN", at: CGPoint(x: size.width * 0.52, y: size.height * 0.33))
            mapLabel("CIVIC BOWL", at: CGPoint(x: size.width * 0.50, y: size.height * 0.42 + 58))
            mapLabel("NORTH QUAY", at: CGPoint(x: size.width * 0.78, y: size.height * 0.62))
        }
        .allowsHitTesting(false)
    }

    private func mapLabel(_ text: String, at point: CGPoint) -> some View {
        Text(text)
            .font(.system(size: 10, weight: .semibold, design: .rounded))
            .tracking(1.2)
            .foregroundStyle(.white.opacity(0.55))
            .position(point)
    }

    private func pins(in size: CGSize) -> some View {
        ForEach(MapPin.samples) { pin in
            let visible = pin.tabs.contains(selection)
            MapPinView(pin: pin)
                .position(
                    x: pin.unit.x * size.width,
                    y: pin.unit.y * size.height
                )
                .opacity(visible ? 1 : 0)
                .scaleEffect(visible ? 1 : 0.4)
                .allowsHitTesting(visible)
                .animation(.spring(duration: 0.48, bounce: 0.28), value: selection)
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
    let kind: Kind

    enum Kind {
        case person
        case device
        case item
        case me
    }

    static let samples: [MapPin] = [
        MapPin(
            id: "maya",
            title: "Maya",
            glyph: "M",
            color: Color(red: 0.95, green: 0.55, blue: 0.35),
            unit: UnitPoint(x: 0.50, y: 0.42),
            tabs: [.people],
            kind: .person
        ),
        MapPin(
            id: "jordan",
            title: "Jordan",
            glyph: "J",
            color: Color(red: 0.45, green: 0.72, blue: 0.95),
            unit: UnitPoint(x: 0.72, y: 0.55),
            tabs: [.people],
            kind: .person
        ),
        MapPin(
            id: "phone",
            title: "Pocket",
            glyph: "iphone",
            color: Color(red: 0.55, green: 0.80, blue: 0.55),
            unit: UnitPoint(x: 0.38, y: 0.50),
            tabs: [.devices],
            kind: .device
        ),
        MapPin(
            id: "tablet",
            title: "Travel",
            glyph: "ipad",
            color: Color(red: 0.40, green: 0.70, blue: 0.95),
            unit: UnitPoint(x: 0.64, y: 0.36),
            tabs: [.devices],
            kind: .device
        ),
        MapPin(
            id: "keys",
            title: "Keys",
            glyph: "key.fill",
            color: Color(red: 0.95, green: 0.78, blue: 0.30),
            unit: UnitPoint(x: 0.30, y: 0.58),
            tabs: [.items],
            kind: .item
        ),
        MapPin(
            id: "bag",
            title: "Bag",
            glyph: "backpack.fill",
            color: Color(red: 0.75, green: 0.55, blue: 0.95),
            unit: UnitPoint(x: 0.58, y: 0.60),
            tabs: [.items],
            kind: .item
        ),
        MapPin(
            id: "me",
            title: "You",
            glyph: "Y",
            color: Color(red: 0.35, green: 0.78, blue: 0.48),
            unit: UnitPoint(x: 0.48, y: 0.48),
            tabs: [.me, .people, .devices, .items],
            kind: .me
        ),
    ]
}

private struct MapPinView: View {
    var pin: MapPin

    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                Circle()
                    .fill(.white)
                    .frame(width: 36, height: 36)
                    .shadow(color: .black.opacity(0.28), radius: 6, y: 3)

                if pin.kind == .person || pin.kind == .me {
                    Circle()
                        .fill(pin.color.gradient)
                        .frame(width: 30, height: 30)
                        .overlay {
                            Text(pin.glyph)
                                .font(.caption.weight(.bold))
                                .foregroundStyle(.white)
                        }
                } else {
                    Circle()
                        .fill(pin.color.gradient)
                        .frame(width: 30, height: 30)
                        .overlay {
                            Image(systemName: pin.glyph)
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(.white)
                        }
                }
            }

            Text(pin.title)
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(.white)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(.black.opacity(0.35), in: Capsule())
        }
    }
}

private enum MapPalette {
    static let ground = Color(red: 0.27, green: 0.33, blue: 0.36)
    static let park = Color(red: 0.20, green: 0.42, blue: 0.32)
    static let parkDeep = Color(red: 0.16, green: 0.34, blue: 0.26)
    static let bowlRing = Color(red: 0.14, green: 0.28, blue: 0.24)
    static let road = Color(red: 0.46, green: 0.50, blue: 0.52)
    static let highway = Color(red: 0.38, green: 0.41, blue: 0.43)
    static let highwayDash = Color.white.opacity(0.55)
    static let water = Color(red: 0.22, green: 0.36, blue: 0.42)
}
