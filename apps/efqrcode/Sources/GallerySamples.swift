import SwiftUI

/// Frozen stand-ins for the Live families. The playground owns every generator.
enum GalleryCard: String, CaseIterable, Identifiable {
    case basic
    case image
    case bubble
    case line
    case d25
    case dsj
    case function
    case imageFill
    case randomRectangle
    case resampleImage
    case icon
    case recognizer

    var id: String { rawValue }

    var title: String {
        switch self {
        case .basic: "Basic"
        case .image: "Image"
        case .bubble: "Bubble"
        case .line: "Line"
        case .d25: "2.5D"
        case .dsj: "DSJ"
        case .function: "Function"
        case .imageFill: "Image fill"
        case .randomRectangle: "Random rect"
        case .resampleImage: "Resample"
        case .icon: "Icon"
        case .recognizer: "Recognizer"
        }
    }

    var subtitle: String {
        switch self {
        case .basic: "EFStyleBasicParams"
        case .image: "EFStyleImageParams"
        case .bubble: "EFStyleBubbleParams"
        case .line: "EFStyleLineParams"
        case .d25: "EFStyle25DParams"
        case .dsj: "EFStyleDSJParams"
        case .function: "EFStyleFunctionParams"
        case .imageFill: "EFStyleImageFillParams"
        case .randomRectangle: "EFStyleRandomRectangleParams"
        case .resampleImage: "EFStyleResampleImageParams"
        case .icon: "EFStyleParamIcon"
        case .recognizer: "Recognizer.recognize"
        }
    }

    var chips: [String] {
        switch self {
        case .basic:
            [".basic", "data", "position"]
        case .image:
            [".image", "watermarkImage"]
        case .bubble:
            ["dataColor", "dataCenterColor"]
        case .line:
            ["direction", "thickness"]
        case .d25:
            ["topColor", "dataHeight"]
        case .dsj:
            [".dsj", "defaultColor"]
        case .function:
            [".fade", ".circle"]
        case .imageFill:
            ["maskColor", "image"]
        case .randomRectangle:
            ["color", "0x14AA3C"]
        case .resampleImage:
            ["contrast", "exposure"]
        case .icon:
            ["percentage", "0.33 cap"]
        case .recognizer:
            ["CGImage", "[String]"]
        }
    }

    var preview: some View {
        VStack(alignment: .leading, spacing: 8) {
            snapshot
            chipRow
        }
    }

    @ViewBuilder
    private var snapshot: some View {
        switch self {
        case .basic:
            ModuleGrid(shape: .square, tint: DemoPalette.ink)
        case .image:
            BandBackdrop {
                ModuleGrid(shape: .square, tint: .black.opacity(0.82), drawsPlate: false)
            }
        case .bubble:
            ModuleGrid(shape: .circle, tint: Color(red: 6 / 255, green: 147 / 255, blue: 227 / 255))
        case .line:
            LineStandIn()
        case .d25:
            ExtrudedStandIn()
        case .dsj:
            DSJStandIn()
        case .function:
            ModuleGrid(shape: .circle, tint: DemoPalette.accent, fades: true)
        case .imageFill:
            BandBackdrop {
                ModuleGrid(shape: .square, tint: .black.opacity(0.28), drawsPlate: false)
            }
        case .randomRectangle:
            RandomRectStandIn()
        case .resampleImage:
            ResampleStandIn()
        case .icon:
            ZStack {
                ModuleGrid(shape: .square, tint: DemoPalette.ink)
                Circle()
                    .fill(DemoPalette.accent)
                    .frame(width: 36, height: 36)
                    .overlay {
                        Circle()
                            .fill(DemoPalette.page)
                            .frame(width: 14, height: 14)
                    }
            }
        case .recognizer:
            RecognizerStandIn()
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

private enum ModuleShape {
    case square
    case circle
}

private struct ModuleGrid: View {
    var shape: ModuleShape
    var tint: Color
    var fades: Bool = false
    var drawsPlate: Bool = true

    var body: some View {
        let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)
        LazyVGrid(columns: columns, spacing: 4) {
            ForEach(0 ..< 21, id: \.self) { index in
                let opacity = fades ? 0.35 + (Double(index % 7) / 10) : 1
                module
                    .opacity(opacity)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .frame(height: 148)
        .background {
            if drawsPlate {
                DemoPalette.canvas
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    @ViewBuilder
    private var module: some View {
        switch shape {
        case .square:
            RoundedRectangle(cornerRadius: 2, style: .continuous)
                .fill(tint)
                .aspectRatio(1, contentMode: .fit)
        case .circle:
            Circle()
                .fill(tint)
                .aspectRatio(1, contentMode: .fit)
        }
    }
}

private struct BandBackdrop<Content: View>: View {
    @ViewBuilder var content: () -> Content

    var body: some View {
        ZStack {
            HStack(spacing: 0) {
                DemoPalette.accent
                Color(red: 6 / 255, green: 147 / 255, blue: 227 / 255)
                Color(red: 20 / 255, green: 170 / 255, blue: 60 / 255)
                Color(red: 0.96, green: 0.94, blue: 0.90)
            }
            content()
        }
        .frame(height: 148)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

private struct LineStandIn: View {
    var body: some View {
        VStack(spacing: 8) {
            ForEach(0 ..< 6, id: \.self) { index in
                Capsule()
                    .fill(DemoPalette.ink.opacity(index.isMultiple(of: 2) ? 0.95 : 0.35))
                    .frame(height: 6)
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity)
        .frame(height: 148)
        .background(DemoPalette.canvas)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

private struct ExtrudedStandIn: View {
    var body: some View {
        Canvas { context, size in
            let origin = CGPoint(x: 28, y: 36)
            for row in 0 ..< 3 {
                for column in 0 ..< 4 {
                    let x = origin.x + CGFloat(column) * 36
                    let y = origin.y + CGFloat(row) * 28
                    var top = Path()
                    top.addRect(CGRect(x: x, y: y, width: 22, height: 14))
                    context.fill(top, with: .color(DemoPalette.ink))
                    var side = Path()
                    side.move(to: CGPoint(x: x + 22, y: y))
                    side.addLine(to: CGPoint(x: x + 30, y: y + 8))
                    side.addLine(to: CGPoint(x: x + 30, y: y + 22))
                    side.addLine(to: CGPoint(x: x + 22, y: y + 14))
                    side.closeSubpath()
                    context.fill(side, with: .color(DemoPalette.accent.opacity(0.7)))
                }
            }
        }
        .frame(height: 148)
        .background(DemoPalette.canvas)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

private struct DSJStandIn: View {
    var body: some View {
        HStack(spacing: 10) {
            RoundedRectangle(cornerRadius: 2).fill(Color(red: 0.965, green: 0.710, blue: 0.024))
            RoundedRectangle(cornerRadius: 2).fill(Color(red: 0.878, green: 0.125, blue: 0.125))
            RoundedRectangle(cornerRadius: 2).fill(Color(red: 0.043, green: 0.176, blue: 0.592))
        }
        .frame(height: 8)
        .padding(.horizontal, 28)
        .frame(maxWidth: .infinity)
        .frame(height: 148)
        .background(DemoPalette.canvas)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

private struct RandomRectStandIn: View {
    var body: some View {
        Canvas { context, size in
            let color = Color(red: 20 / 255, green: 170 / 255, blue: 60 / 255)
            let seeds: [(CGFloat, CGFloat, CGFloat, CGFloat)] = [
                (22, 28, 18, 10),
                (48, 24, 12, 20),
                (70, 40, 22, 8),
                (28, 56, 14, 16),
                (52, 62, 26, 12),
                (86, 58, 10, 22),
                (100, 30, 16, 14),
            ]
            for seed in seeds {
                let rect = CGRect(x: seed.0, y: seed.1, width: seed.2, height: seed.3)
                context.fill(Path(rect), with: .color(color))
            }
        }
        .frame(height: 148)
        .background(DemoPalette.canvas)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

private struct ResampleStandIn: View {
    var body: some View {
        let columns = Array(repeating: GridItem(.flexible(), spacing: 3), count: 8)
        LazyVGrid(columns: columns, spacing: 3) {
            ForEach(0 ..< 32, id: \.self) { index in
                RoundedRectangle(cornerRadius: 1)
                    .fill(swatch(index))
                    .aspectRatio(1, contentMode: .fit)
            }
        }
        .padding(16)
        .frame(height: 148)
        .background(DemoPalette.canvas)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private func swatch(_ index: Int) -> Color {
        switch index % 4 {
        case 0: DemoPalette.accent
        case 1: Color(red: 6 / 255, green: 147 / 255, blue: 227 / 255)
        case 2: Color(red: 20 / 255, green: 170 / 255, blue: 60 / 255)
        default: Color(red: 0.96, green: 0.94, blue: 0.90)
        }
    }
}

private struct RecognizerStandIn: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("EFQRCode.Recognizer")
                .font(.caption.monospaced())
                .foregroundStyle(DemoPalette.ink)
            Text("recognize() → [String]")
                .font(.caption.monospaced())
                .foregroundStyle(DemoPalette.inkMuted)
            Text("Reads the generated UIImage.")
                .font(.caption)
                .foregroundStyle(DemoPalette.inkMuted)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .frame(height: 148)
        .background(DemoPalette.canvas)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}
