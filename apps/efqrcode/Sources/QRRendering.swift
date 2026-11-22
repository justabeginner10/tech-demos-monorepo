import CoreGraphics
import CoreImage
import EFQRCode
import UIKit

/// Knobs the Live tab turns into one `EFQRCodeStyle`.
struct StyleKnobs: Equatable {
    var kind: QRStyleKind = .basic
    var foreground: InkChoice = .black
    var background: InkChoice = .white
    var dataShape: BasicDataShape = .rectangle
    var position: PositionShape = .rectangle
    var lineDirection: LineDirectionChoice = .x
    var lineThickness: CGFloat = 0.5
    var dataScale: CGFloat = 1
    var includeIcon: Bool = false
    var includeBackdropImage: Bool = false
    var useFillImage: Bool = true
    var imageMode: ImageModeChoice = .scaleAspectFill
    var function: FunctionRecipe = .fade
    var dataHeight: CGFloat = 1
    var positionHeight: CGFloat = 1
    var iconPercentage: CGFloat = 0.22
    var contrast: CGFloat = 0
    var exposure: CGFloat = 0
}

struct GeneratedCode {
    var image: UIImage
    var caption: String
}

enum DemoRenderError: Error {
    case artworkUnavailable
}

enum QRRendering {
    /// Same string the package's iOS example puts in the generator field.
    static let sampleText = "https://github.com/EFPrefix/EFQRCode"
    static let imageWidth: CGFloat = 280

    /// Package defaults: `EFStyleBasicParams()` and the caller's correction level.
    /// `Generator` itself defaults `errorCorrectLevel` to `.h` and requires a style.
    static func generateDefaultBasic(
        text: String,
        correction: CorrectionChoice
    ) throws -> GeneratedCode {
        try generate(
            text: text,
            correction: correction,
            style: .basic(params: EFStyleBasicParams())
        )
    }

    static func generate(
        text: String,
        correction: CorrectionChoice,
        knobs: StyleKnobs
    ) throws -> GeneratedCode {
        try generate(
            text: text,
            correction: correction,
            style: try makeStyle(knobs)
        )
    }

    static func recognize(_ image: UIImage) -> String {
        guard let cgImage = cgImage(from: image) else {
            return "The UIImage has no CGImage. Recognizer(image:) takes a CGImage."
        }
        let contents = EFQRCode.Recognizer(image: cgImage).recognize()
        if contents.isEmpty {
            return "recognize() returned an empty array."
        }
        return contents.joined(separator: "\n")
    }

    static func message(for error: Error) -> String {
        if case DemoRenderError.artworkUnavailable = error {
            return "Could not allocate the icon or fill CGImage."
        }
        guard let qr = error as? EFQRCodeError else {
            return String(describing: error)
        }
        switch qr {
        case .dataLengthExceedsCapacityLimit:
            return "EFQRCodeError.dataLengthExceedsCapacityLimit"
        case .text(_, let encoding):
            return "EFQRCodeError.text is incompatible with \(encoding)."
        case .internalError(let inner):
            return "EFQRCodeError.internalError(\(inner))"
        default:
            return String(describing: qr)
        }
    }

    // MARK: - Style

    static func makeStyle(_ knobs: StyleKnobs) throws -> EFQRCodeStyle {
        let icon = try icon(knobs)
        let backdrop = try backdrop(knobs)
        switch knobs.kind {
        case .basic:
            return .basic(params: EFStyleBasicParams(
                icon: icon,
                backdrop: backdrop,
                position: EFStyleBasicParamsPosition(
                    style: knobs.position.positionStyle,
                    size: 1,
                    color: knobs.foreground.color
                ),
                data: EFStyleBasicParamsData(
                    style: knobs.dataShape.dataStyle,
                    scale: knobs.dataScale,
                    color: knobs.foreground.color
                ),
                align: EFStyleBasicParamsAlign(color: knobs.foreground.color),
                timing: EFStyleBasicParamsTiming(color: knobs.foreground.color)
            ))
        case .image:
            return .image(params: EFStyleImageParams(
                icon: icon,
                backdrop: backdrop,
                image: try fillImage(knobs)
            ))
        case .bubble:
            // Center color is the bubble core. The backdrop stays white so the two do not collapse into one fill.
            let bubbleBackdrop = EFStyleParamBackdrop(
                cornerRadius: 0,
                color: InkChoice.white.color,
                image: nil,
                quietzone: nil
            )
            return .bubble(params: EFStyleBubbleParams(
                icon: icon,
                backdrop: bubbleBackdrop,
                dataColor: knobs.foreground.color,
                dataCenterColor: knobs.background.color,
                position: EFStyleBubbleParamsPosition(
                    style: knobs.position.positionStyle,
                    size: 1,
                    color: knobs.foreground.color
                )
            ))
        case .line:
            let thickness = min(max(knobs.lineThickness, 0.05), 1)
            return .line(params: EFStyleLineParams(
                icon: icon,
                backdrop: backdrop,
                position: EFStyleLineParamsPosition(
                    style: knobs.position.positionStyle,
                    size: 1,
                    color: knobs.foreground.color
                ),
                line: EFStyleLineParamsLine(
                    direction: knobs.lineDirection.direction,
                    thickness: thickness,
                    color: knobs.foreground.color
                )
            ))
        case .d25:
            return .d25(params: EFStyle25DParams(
                icon: icon,
                backdrop: backdrop,
                dataHeight: knobs.dataHeight,
                positionHeight: knobs.positionHeight,
                topColor: knobs.foreground.color,
                leftColor: knobs.foreground.faded(0.35),
                rightColor: knobs.foreground.faded(0.7)
            ))
        case .dsj:
            return .dsj(params: EFStyleDSJParams(
                icon: icon,
                backdrop: backdrop,
                position: EFStyleDSJParamsPosition(
                    style: knobs.position.positionStyle,
                    size: 0.925,
                    color: EFStyleDSJParamsPosition.defaultColor
                ),
                data: EFStyleDSJParamsData()
            ))
        case .function:
            let data = EFStyleFunctionParamsData(
                function: function(knobs),
                style: .round
            )
            return .function(params: EFStyleFunctionParams(
                icon: icon,
                backdrop: backdrop,
                position: EFStyleFunctionParamsPosition(
                    style: knobs.position.positionStyle,
                    size: 1,
                    color: knobs.foreground.color
                ),
                data: data
            ))
        case .imageFill:
            return .imageFill(params: EFStyleImageFillParams(
                icon: icon,
                backdrop: backdrop,
                image: try imageFill(knobs),
                backgroundColor: knobs.background.color
            ))
        case .randomRectangle:
            return .randomRectangle(params: EFStyleRandomRectangleParams(
                icon: icon,
                backdrop: backdrop,
                color: knobs.foreground.color
            ))
        case .resampleImage:
            return .resampleImage(params: EFStyleResampleImageParams(
                icon: icon,
                backdrop: backdrop,
                image: try resampleImage(knobs),
                dataColor: knobs.foreground.color
            ))
        }
    }

    // MARK: - Generate

    private static func generate(
        text: String,
        correction: CorrectionChoice,
        style: EFQRCodeStyle
    ) throws -> GeneratedCode {
        let generator = try EFQRCode.Generator(
            text,
            encoding: .utf8,
            errorCorrectLevel: correction.level,
            style: style
        )
        let image = try generator.toImage(width: imageWidth)
        let svg = try generator.toSVG()
        return GeneratedCode(
            image: image,
            caption: "toImage(width: 280) · toSVG \(svg.count) chars · \(correction.api)"
        )
    }

    private static func icon(_ knobs: StyleKnobs) throws -> EFStyleParamIcon? {
        guard knobs.includeIcon else { return nil }
        guard let image = DemoArtwork.seal() else { throw DemoRenderError.artworkUnavailable }
        let percentage = min(max(knobs.iconPercentage, 0.08), 0.33)
        return EFStyleParamIcon(
            image: .static(image: image),
            mode: knobs.imageMode.mode,
            alpha: 1,
            borderColor: DemoArtwork.rgb(1, 1, 1),
            percentage: percentage
        )
    }

    private static func backdrop(_ knobs: StyleKnobs) throws -> EFStyleParamBackdrop {
        let image: EFStyleParamBackdropImage?
        if knobs.includeBackdropImage {
            guard let cgImage = DemoArtwork.wash() else { throw DemoRenderError.artworkUnavailable }
            image = EFStyleParamBackdropImage(
                image: cgImage,
                alpha: 0.45,
                mode: knobs.imageMode.mode
            )
        } else {
            image = nil
        }
        return EFStyleParamBackdrop(
            cornerRadius: 0,
            color: knobs.background.color,
            image: image,
            quietzone: nil
        )
    }

    /// `EFStyleImageParams.image` has no default. Pass `nil` when the picture is off.
    private static func fillImage(_ knobs: StyleKnobs) throws -> EFStyleImageParamsImage? {
        guard knobs.useFillImage else { return nil }
        guard let image = DemoArtwork.wash() else { throw DemoRenderError.artworkUnavailable }
        return EFStyleImageParamsImage(
            image: .static(image: image),
            mode: knobs.imageMode.mode,
            alpha: 1,
            allowTransparent: false
        )
    }

    /// `EFStyleImageFillParams.image` has no default. Pass `nil` when the picture is off.
    private static func imageFill(_ knobs: StyleKnobs) throws -> EFStyleImageFillParamsImage? {
        guard knobs.useFillImage else { return nil }
        guard let image = DemoArtwork.wash() else { throw DemoRenderError.artworkUnavailable }
        return EFStyleImageFillParamsImage(
            image: .static(image: image),
            mode: knobs.imageMode.mode,
            alpha: 1
        )
    }

    /// `EFStyleResampleImageParams.image` has no default. Pass `nil` when the picture is off.
    private static func resampleImage(_ knobs: StyleKnobs) throws -> EFStyleResampleImageParamsImage? {
        guard knobs.useFillImage else { return nil }
        guard let image = DemoArtwork.wash() else { throw DemoRenderError.artworkUnavailable }
        return EFStyleResampleImageParamsImage(
            image: .static(image: image),
            mode: knobs.imageMode.mode,
            contrast: knobs.contrast,
            exposure: knobs.exposure
        )
    }

    private static func function(_ knobs: StyleKnobs) -> EFStyleFunctionParamsDataFunction {
        switch knobs.function {
        case .fade:
            .fade(dataColor: knobs.foreground.color)
        case .circle:
            .circle(
                dataColor: knobs.foreground.color,
                circleColor: InkChoice.tide.color
            )
        }
    }

    private static func cgImage(from image: UIImage) -> CGImage? {
        if let cgImage = image.cgImage {
            return cgImage
        }
        let source = image.ciImage ?? CIImage(image: image)
        guard let source else { return nil }
        return CIContext().createCGImage(source, from: source.extent)
    }
}

// MARK: - Package values

extension CorrectionChoice {
    var level: EFCorrectionLevel {
        switch self {
        case .l: .l
        case .m: .m
        case .q: .q
        case .h: .h
        }
    }
}

extension InkChoice {
    /// Device RGB, the same color space `CGColor.createWith(rgb:)` uses inside the package.
    /// That helper is not public, so the app builds `CGColor` itself.
    var color: CGColor {
        faded(1)
    }

    func faded(_ alpha: CGFloat) -> CGColor {
        let parts = components
        return DemoArtwork.rgb(parts.0, parts.1, parts.2, alpha)
    }

    private var components: (CGFloat, CGFloat, CGFloat) {
        switch self {
        case .black:
            (0.05, 0.05, 0.06)
        case .white:
            (1, 1, 1)
        case .ember:
            (1, 0.55, 0.22)
        case .tide:
            (6 / 255, 147 / 255, 227 / 255)
        case .moss:
            (20 / 255, 170 / 255, 60 / 255)
        case .paper:
            (0.96, 0.94, 0.90)
        }
    }
}

extension BasicDataShape {
    var dataStyle: EFStyleBasicParamsDataStyle {
        switch self {
        case .rectangle: .rectangle
        case .round: .round
        case .roundedRectangle: .roundedRectangle
        case .randomRound: .randomRound
        }
    }
}

extension PositionShape {
    var positionStyle: EFStyleParamsPositionStyle {
        switch self {
        case .rectangle: .rectangle
        case .round: .round
        case .roundedRectangle: .roundedRectangle
        case .planets: .planets
        case .dsj: .dsj
        }
    }
}

extension LineDirectionChoice {
    var direction: EFStyleLineParamsLineDirection {
        switch self {
        case .horizontal: .horizontal
        case .vertical: .vertical
        case .cross: .cross
        case .loopback: .loopback
        case .topLeftToBottomRight: .topLeftToBottomRight
        case .topRightToBottomLeft: .topRightToBottomLeft
        case .x: .x
        }
    }
}

extension ImageModeChoice {
    var mode: EFImageMode {
        switch self {
        case .scaleAspectFill: .scaleAspectFill
        case .scaleAspectFit: .scaleAspectFit
        case .scaleToFill: .scaleToFill
        }
    }
}

// MARK: - Drawn pictures

/// Original pictures for the icon and the fill / backdrop image.
/// No asset catalog and no sample image from the package.
enum DemoArtwork {
    static func rgb(_ red: CGFloat, _ green: CGFloat, _ blue: CGFloat, _ alpha: CGFloat = 1) -> CGColor {
        let space = CGColorSpaceCreateDeviceRGB()
        if let color = CGColor(colorSpace: space, components: [red, green, blue, alpha]) {
            return color
        }
        return CGColor(gray: 0, alpha: alpha)
    }

    static func seal() -> CGImage? {
        raster(side: 128) { context, side in
            context.setFillColor(rgb(1, 0.55, 0.22))
            context.fillEllipse(in: CGRect(x: 8, y: 8, width: side - 16, height: side - 16))
            context.setFillColor(rgb(0.08, 0.08, 0.10))
            context.fillEllipse(in: CGRect(x: 44, y: 44, width: side - 88, height: side - 88))
        }
    }

    static func wash() -> CGImage? {
        raster(side: 256) { context, side in
            let bands = [
                rgb(1, 0.55, 0.22),
                rgb(6 / 255, 147 / 255, 227 / 255),
                rgb(20 / 255, 170 / 255, 60 / 255),
                rgb(0.96, 0.94, 0.90),
            ]
            let bandHeight = side / CGFloat(bands.count)
            for (index, color) in bands.enumerated() {
                context.setFillColor(color)
                context.fill(CGRect(
                    x: 0,
                    y: CGFloat(index) * bandHeight,
                    width: side,
                    height: bandHeight
                ))
            }
        }
    }

    private static func raster(
        side: Int,
        draw: (CGContext, CGFloat) -> Void
    ) -> CGImage? {
        let space = CGColorSpaceCreateDeviceRGB()
        let info = CGBitmapInfo.byteOrder32Big.rawValue | CGImageAlphaInfo.premultipliedLast.rawValue
        guard let context = CGContext(
            data: nil,
            width: side,
            height: side,
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: space,
            bitmapInfo: info
        ) else {
            return nil
        }
        draw(context, CGFloat(side))
        return context.makeImage()
    }
}
