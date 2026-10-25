import SwiftUI

/// Frozen stand-ins for the Live families. The playground owns every cannon.
enum GalleryCard: String, CaseIterable, Identifiable {
    case shapes
    case emoji
    case letters
    case symbols
    case firework
    case hearts
    case rain
    case repeatBurst
    case cone
    case images

    var id: String { rawValue }

    var title: String {
        switch self {
        case .shapes: "Shapes"
        case .emoji: "Emoji"
        case .letters: "Letters"
        case .symbols: "Symbols"
        case .firework: "Firework"
        case .hearts: "Hearts"
        case .rain: "Rain"
        case .repeatBurst: "Repeat"
        case .cone: "Wedge"
        case .images: "Images"
        }
    }

    var subtitle: String {
        switch self {
        case .shapes: "ConfettiType.shape"
        case .emoji: ".text · emoji"
        case .letters: ".text · letters"
        case .symbols: ".sfSymbol"
        case .firework: "0° … 360°"
        case .hearts: ".text · hearts"
        case .rain: "repetitions 50"
        case .repeatBurst: "repetitions 3"
        case .cone: "60° … 120°"
        case .images: "ConfettiType.image"
        }
    }

    var chips: [String] {
        switch self {
        case .shapes:
            ["circle", "square", "triangle"]
        case .emoji:
            [".text", "🎉", "✨"]
        case .letters:
            [".text", "foregroundColor"]
        case .symbols:
            ["symbolName", "star.fill"]
        case .firework:
            ["num 50", "radius 200"]
        case .hearts:
            ["❤️", "💙", "💚", "🧡"]
        case .rain:
            ["num 1", "size 30", "0.1 s"]
        case .repeatBurst:
            ["× 3", "0.7 s"]
        case .cone:
            ["openingAngle", "closingAngle"]
        case .images:
            ["asset name", "not shipped"]
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
        case .shapes:
            ShapeFan(opening: 60, closing: 120, count: 10, reach: 78)
        case .emoji:
            GlyphFan(glyphs: ["🎉", "✨", "🎊", "🎉", "✨"], opening: 60, closing: 120)
        case .letters:
            GlyphFan(glyphs: ["A", "B", "C", "A", "B"], opening: 60, closing: 120)
        case .symbols:
            SymbolFan()
        case .firework:
            ShapeFan(opening: 0, closing: 360, count: 16, reach: 64, originY: 0.5)
        case .hearts:
            GlyphFan(glyphs: ["❤️", "💙", "💚", "🧡"], opening: 60, closing: 120)
        case .rain:
            RainMarks()
        case .repeatBurst:
            RepeatMarks()
        case .cone:
            ShapeFan(opening: 60, closing: 120, count: 8, reach: 86)
        case .images:
            ImagePlaceholder()
        }
    }

    private var chipRow: some View {
        HStack(spacing: 6) {
            ForEach(chips, id: \.self) { label in
                DemoChrome.chip(label)
            }
        }
        .padding(.horizontal, 8)
        .padding(.bottom, 8)
    }
}

/// Painted pieces in the same angle convention as the cannon: 0° right, 90° up.
private struct ShapeFan: View {
    var opening: Double
    var closing: Double
    var count: Int
    var reach: Double
    var originY: CGFloat = 0.62
    var drawsChrome: Bool = true

    var body: some View {
        let canvas = Canvas { context, size in
            let drawn = fanMarks(in: size)
            for mark in drawn.marks {
                context.fill(mark.path, with: .color(mark.color))
            }
            context.fill(Path(ellipseIn: drawn.dot), with: .color(Color.white.opacity(0.85)))
        }
        .frame(height: 148)

        return Group {
            if drawsChrome {
                canvas
                    .background(DemoPalette.canvas)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            } else {
                canvas
            }
        }
    }

    private func fanMarks(in size: CGSize) -> (marks: [FanMark], dot: CGRect) {
        let originX = size.width / 2
        let originY = size.height * self.originY
        let colors = fanColors
        let fullTurn = (closing - opening) >= 360
        var marks: [FanMark] = []
        for index in 0 ..< count {
            let steps = fullTurn ? count : max(count - 1, 1)
            let turns = Double(index) / Double(steps)
            let degrees = opening + turns * (closing - opening)
            let radians = degrees * Double.pi / 180
            let band = Double(index % 3) * 14
            let distance = reach - band
            let x = Double(originX) + cos(radians) * distance
            let y = Double(originY) - sin(radians) * distance * 0.82
            let rect = pieceRect(x: x, y: y)
            let path = fanPiece(kind: index % 5, in: rect)
            let color = colors[index % colors.count]
            marks.append(FanMark(path: path, color: color))
        }
        let dot = CGRect(x: originX - 3, y: originY - 3, width: 6, height: 6)
        return (marks, dot)
    }
}

private struct FanMark {
    var path: Path
    var color: Color
}

private func pieceRect(x: Double, y: Double) -> CGRect {
    let side: CGFloat = 12
    let originX = CGFloat(x) - 6
    let originY = CGFloat(y) - 6
    return CGRect(x: originX, y: originY, width: side, height: side)
}

private let fanColors: [Color] = [.blue, .red, .green, .yellow, .pink, .purple, .orange]

private func fanPiece(kind: Int, in rect: CGRect) -> Path {
    switch kind {
    case 0:
        return Path(ellipseIn: rect)
    case 1:
        return Path(rect)
    case 2:
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.closeSubpath()
        return path
    case 3:
        let thin = CGRect(x: rect.minX, y: rect.maxY - 3, width: rect.width, height: 3)
        return Path(thin)
    default:
        var path = Path()
        let arm = rect.insetBy(dx: rect.width * 0.32, dy: 0)
        let bar = rect.insetBy(dx: 0, dy: rect.height * 0.32)
        path.addRect(arm)
        path.addRect(bar)
        return path
    }
}

private struct GlyphFan: View {
    var glyphs: [String]
    var opening: Double
    var closing: Double

    var body: some View {
        ZStack {
            ForEach(glyphs.indices, id: \.self) { index in
                FanGlyph(
                    index: index,
                    count: glyphs.count,
                    glyph: glyphs[index],
                    opening: opening,
                    closing: closing
                )
            }
        }
        .frame(height: 148)
        .frame(maxWidth: .infinity)
        .background(DemoPalette.canvas)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

private struct FanGlyph: View {
    var index: Int
    var count: Int
    var glyph: String
    var opening: Double
    var closing: Double

    var body: some View {
        let span = max(count - 1, 1)
        let turns = count == 1 ? 0.5 : Double(index) / Double(span)
        let degrees = opening + turns * (closing - opening)
        let radians = degrees * Double.pi / 180
        let x = CGFloat(cos(radians) * 86)
        let y = CGFloat(-sin(radians) * 58)
        Text(glyph)
            .font(.system(size: 26))
            .foregroundStyle(DemoPalette.ink)
            .offset(x: x, y: y + 16)
    }
}

private struct SymbolFan: View {
    private let names = ["star.fill", "heart.fill", "party.popper", "seal.fill", "star.fill"]

    var body: some View {
        ZStack {
            ForEach(names.indices, id: \.self) { index in
                SymbolMark(index: index, count: names.count, name: names[index])
            }
        }
        .frame(height: 148)
        .frame(maxWidth: .infinity)
        .background(DemoPalette.canvas)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

private struct SymbolMark: View {
    var index: Int
    var count: Int
    var name: String

    var body: some View {
        let span = max(count - 1, 1)
        let turns = count == 1 ? 0.5 : Double(index) / Double(span)
        let degrees = 60.0 + turns * 60.0
        let radians = degrees * Double.pi / 180
        let x = CGFloat(cos(radians) * 86)
        let y = CGFloat(-sin(radians) * 58)
        Image(systemName: name)
            .font(.system(size: 22, weight: .semibold))
            .foregroundStyle(fanColors[index % fanColors.count])
            .offset(x: x, y: y + 16)
    }
}

private struct RainMarks: View {
    private let glyphs = ["💵", "💶", "💷", "💴"]

    var body: some View {
        ZStack {
            ForEach(0 ..< 8, id: \.self) { index in
                RainMark(index: index, glyph: glyphs[index % glyphs.count])
            }
        }
        .frame(height: 148)
        .frame(maxWidth: .infinity)
        .background(DemoPalette.canvas)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

private struct RainMark: View {
    var index: Int
    var glyph: String

    var body: some View {
        let column = CGFloat(index % 4)
        let row = CGFloat(index / 4)
        let x = (column - 1.5) * 36
        let y = 18 + row * 44
        Text(glyph)
            .font(.system(size: 22))
            .offset(x: x, y: y - 40)
    }
}

private struct RepeatMarks: View {
    var body: some View {
        ZStack {
            ShapeFan(opening: 60, closing: 120, count: 8, reach: 86, drawsChrome: false)
                .opacity(0.35)
            ShapeFan(opening: 60, closing: 120, count: 6, reach: 58, drawsChrome: false)
                .opacity(0.7)
            ShapeFan(opening: 60, closing: 120, count: 4, reach: 34, drawsChrome: false)
        }
        .frame(height: 148)
        .background(DemoPalette.canvas)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

private struct ImagePlaceholder: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                ForEach(["arb", "eth", "btc", "op"], id: \.self) { name in
                    Text(name)
                        .font(.caption.weight(.semibold).monospaced())
                        .foregroundStyle(DemoPalette.ink)
                        .frame(width: 44, height: 44)
                        .background(Color.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                }
            }
            Text(".image(\"name\") looks up an asset catalog image. This app does not ship those assets.")
                .font(.caption2)
                .foregroundStyle(DemoPalette.inkMuted)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, minHeight: 148, alignment: .leading)
        .padding(12)
        .background(DemoPalette.canvas)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}
