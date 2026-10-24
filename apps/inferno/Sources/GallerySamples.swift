import SwiftUI

/// Frozen marketing stand-ins. Live playground owns every shader.
enum GalleryFamily: String, CaseIterable, Identifiable {
    case shimmer
    case sinebow
    case lights
    case infrared
    case water
    case wave
    case loupe
    case circles
    case swirl
    case pixellate
    case wind
    case modifiers

    var id: String { rawValue }

    var title: String {
        switch self {
        case .shimmer: "Shimmer"
        case .sinebow: "Sinebow"
        case .lights: "Light grid"
        case .infrared: "Infrared"
        case .water: "Water"
        case .wave: "Wave"
        case .loupe: "Loupe"
        case .circles: "Circles"
        case .swirl: "Swirl"
        case .pixellate: "Pixellate"
        case .wind: "Wind"
        case .modifiers: "More modifiers"
        }
    }

    var subtitle: String {
        switch self {
        case .shimmer: "colorEffect · shimmer"
        case .sinebow: "colorEffect · sinebow"
        case .lights: "colorEffect · lightGrid"
        case .infrared: "View.infrared()"
        case .water: "distortionEffect · water"
        case .wave: "distortionEffect · wave"
        case .loupe: "layerEffect · loupe"
        case .circles: "AnyTransition.circles"
        case .swirl: "AnyTransition.swirl"
        case .pixellate: "AnyTransition.pixellate"
        case .wind: "AnyTransition.wind"
        case .modifiers: "View extensions · frozen"
        }
    }

    var chips: [String] {
        switch self {
        case .shimmer:
            ["duration 3", "width 0.3", "lightness 0.9"]
        case .sinebow:
            ["size", "time", "10 lines"]
        case .lights:
            ["density 8", "speed 3", "group 1"]
        case .infrared:
            ["luma", "cold to hot", "no knobs"]
        case .water:
            ["speed 3", "strength 3", "frequency 10"]
        case .wave:
            ["speed 5", "smoothing 10", "strength 5"]
        case .loupe:
            ["simpleLoupe", "warpingLoupe", "drag"]
        case .circles:
            ["size 20", "insertion", "Reveal"]
        case .swirl:
            ["radius 0.5", "both ways"]
        case .pixellate:
            ["squares 20", "steps 60"]
        case .wind:
            ["size 0.2", "insertion"]
        case .modifiers:
            ["checkerboard", "emboss", "variableBlur"]
        }
    }

    @ViewBuilder
    var preview: some View {
        VStack(alignment: .leading, spacing: 8) {
            snapshot
            chipRow
        }
    }

    @ViewBuilder
    private var snapshot: some View {
        switch self {
        case .shimmer:
            PaintedPoster(wash: .orange)
                .overlay(alignment: .leading) {
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [.clear, .white.opacity(0.55), .clear],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: 72)
                        .offset(x: 48)
                        .allowsHitTesting(false)
                }
        case .sinebow:
            Canvas { context, size in
                for index in 0 ..< 6 {
                    var path = Path()
                    let y = size.height * (0.18 + CGFloat(index) * 0.12)
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addCurve(
                        to: CGPoint(x: size.width, y: y),
                        control1: CGPoint(x: size.width * 0.3, y: y - 18),
                        control2: CGPoint(x: size.width * 0.7, y: y + 18)
                    )
                    context.stroke(
                        path,
                        with: .color(Color(hue: Double(index) / 6, saturation: 0.75, brightness: 1)),
                        lineWidth: 3
                    )
                }
            }
            .frame(height: 132)
            .background(Color.black.opacity(0.35), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        case .lights:
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 6), spacing: 8) {
                ForEach(0 ..< 18, id: \.self) { index in
                    Circle()
                        .fill(Color(hue: Double(index) / 18, saturation: 0.8, brightness: 1))
                        .frame(width: 14, height: 14)
                }
            }
            .padding(.vertical, 18)
            .frame(maxWidth: .infinity)
            .background(Color.black.opacity(0.35), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        case .infrared:
            PaintedPoster(wash: .thermal)
        case .water:
            Canvas { context, size in
                for index in 0 ..< 5 {
                    var path = Path()
                    let y = size.height * (0.22 + CGFloat(index) * 0.14)
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addQuadCurve(
                        to: CGPoint(x: size.width, y: y),
                        control: CGPoint(x: size.width / 2, y: y + (index.isMultiple(of: 2) ? 16 : -16))
                    )
                    context.stroke(path, with: .color(.white.opacity(0.7)), lineWidth: 2)
                }
            }
            .frame(height: 132)
            .background(PaintedPoster(wash: .ocean).clipped())
        case .wave:
            PaintedPoster(wash: .ocean)
                .overlay(alignment: .trailing) {
                    Rectangle()
                        .fill(Color.white.opacity(0.16))
                        .frame(width: 90)
                        .overlay {
                            VStack(spacing: 6) {
                                ForEach(0 ..< 5, id: \.self) { _ in
                                    Capsule().fill(Color.white.opacity(0.45)).frame(height: 3)
                                }
                            }
                            .padding(.horizontal, 12)
                        }
                }
        case .loupe:
            PaintedPoster(wash: .sunset)
                .overlay {
                    Circle()
                        .strokeBorder(Color.white.opacity(0.85), lineWidth: 3)
                        .background(Circle().fill(Color.white.opacity(0.12)))
                        .frame(width: 72, height: 72)
                }
        case .circles:
            PaintedPoster(wash: .sunset)
                .overlay {
                    HStack(spacing: 8) {
                        ForEach(0 ..< 5, id: \.self) { index in
                            Circle()
                                .fill(Color.white.opacity(0.25 + Double(index) * 0.12))
                                .frame(width: 18 + CGFloat(index) * 6, height: 18 + CGFloat(index) * 6)
                        }
                    }
                }
        case .swirl:
            Canvas { context, size in
                let center = CGPoint(x: size.width / 2, y: size.height / 2)
                var path = Path()
                path.move(to: center)
                for step in 0 ..< 48 {
                    let t = CGFloat(step) / 48
                    let angle = t * .pi * 3
                    let radius = t * min(size.width, size.height) * 0.42
                    path.addLine(to: CGPoint(x: center.x + cos(angle) * radius, y: center.y + sin(angle) * radius))
                }
                context.stroke(path, with: .color(.white.opacity(0.85)), lineWidth: 2)
            }
            .frame(height: 132)
            .background(PaintedPoster(wash: .sunset).clipped())
        case .pixellate:
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 3), count: 8), spacing: 3) {
                ForEach(0 ..< 32, id: \.self) { index in
                    Rectangle()
                        .fill(Color(hue: Double(index % 8) / 8, saturation: 0.65, brightness: 0.9))
                        .frame(height: 14)
                }
            }
            .padding(8)
            .background(Color.black.opacity(0.35), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        case .wind:
            PaintedPoster(wash: .ocean)
                .overlay(alignment: .trailing) {
                    VStack(spacing: 5) {
                        ForEach(0 ..< 7, id: \.self) { index in
                            Capsule()
                                .fill(Color.white.opacity(0.35))
                                .frame(width: CGFloat(40 + index * 8), height: 3)
                        }
                    }
                    .padding(.trailing, 12)
                }
        case .modifiers:
            HStack(spacing: 4) {
                ForEach(0 ..< 8, id: \.self) { index in
                    Rectangle()
                        .fill(index.isMultiple(of: 2) ? DemoPalette.accent : Color.white.opacity(0.85))
                }
            }
            .frame(height: 72)
            .frame(maxWidth: .infinity)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .padding(.vertical, 12)
        }
    }

    private var chipRow: some View {
        HStack(spacing: 6) {
            ForEach(chips, id: \.self) { chip in
                DemoChrome.chip(chip)
            }
        }
        .padding(.horizontal, 8)
        .padding(.bottom, 8)
    }
}

private struct PaintedPoster: View {
    enum Wash {
        case sunset
        case ocean
        case orange
        case thermal
    }

    var wash: Wash

    var body: some View {
        LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
            .frame(height: 132)
            .overlay(alignment: .bottomLeading) {
                Text(label)
                    .font(.caption.weight(.semibold).monospaced())
                    .foregroundStyle(.white)
                    .padding(10)
            }
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private var colors: [Color] {
        switch wash {
        case .sunset:
            [
                Color(red: 0.98, green: 0.46, blue: 0.16),
                Color(red: 0.45, green: 0.10, blue: 0.38),
            ]
        case .ocean:
            [
                Color(red: 0.10, green: 0.45, blue: 0.72),
                Color(red: 0.05, green: 0.12, blue: 0.32),
            ]
        case .orange:
            [
                Color(red: 0.55, green: 0.28, blue: 0.08),
                Color(red: 0.95, green: 0.72, blue: 0.35),
            ]
        case .thermal:
            [
                Color(red: 0.05, green: 0.15, blue: 0.85),
                Color(red: 0.95, green: 0.9, blue: 0.15),
                Color(red: 0.85, green: 0.08, blue: 0.08),
            ]
        }
    }

    private var label: String {
        switch wash {
        case .sunset: "POSTER"
        case .ocean: "RIPPLE"
        case .orange: "BAND"
        case .thermal: "LUMA"
        }
    }
}
