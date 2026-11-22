import Foundation

/// The ten `EFQRCodeStyle` cases in EFQRCode 7.0.3.
/// Mapping onto the package enum lives in `QRRendering`.
enum QRStyleKind: String, CaseIterable, Identifiable, Hashable {
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
        }
    }

    var api: String {
        switch self {
        case .basic: ".basic"
        case .image: ".image"
        case .bubble: ".bubble"
        case .line: ".line"
        case .d25: ".d25"
        case .dsj: ".dsj"
        case .function: ".function"
        case .imageFill: ".imageFill"
        case .randomRectangle: ".randomRectangle"
        case .resampleImage: ".resampleImage"
        }
    }

    /// Styles whose params take an image the implementation reports as `watermarkImage`.
    var usesFillImage: Bool {
        switch self {
        case .image, .imageFill, .resampleImage:
            true
        case .basic, .bubble, .line, .d25, .dsj, .function, .randomRectangle:
            false
        }
    }

    var blurb: String {
        switch self {
        case .basic:
            "EFStyleBasicParams. Data, position, align, and timing each take a color."
        case .image:
            "EFStyleImageParams.image fills modules. getParamImages reports it as the watermark."
        case .bubble:
            "EFStyleBubbleParams dataColor and dataCenterColor. Position defaults to round."
        case .line:
            "EFStyleLineParamsLine direction and thickness. Thickness is clamped to (0, 1]."
        case .d25:
            "EFStyle25DParams top, left, and right faces, plus dataHeight and positionHeight."
        case .dsj:
            "EFStyleDSJParams. Position style defaults to .dsj. Data colors stay on the package defaults."
        case .function:
            "EFStyleFunctionParamsDataFunction .fade or .circle."
        case .imageFill:
            "EFStyleImageFillParams paints a picture behind the modules, then a mask color."
        case .randomRectangle:
            "EFStyleRandomRectangleParams color. The package default is green."
        case .resampleImage:
            "EFStyleResampleImageParamsImage contrast and exposure. The picture is the watermark image."
        }
    }
}

/// `EFCorrectionLevel` cases. The package default on `Generator` is `.h`.
enum CorrectionChoice: String, CaseIterable, Identifiable, Hashable {
    case l
    case m
    case q
    case h

    var id: String { rawValue }

    var title: String {
        switch self {
        case .l: "L · 7%"
        case .m: "M · 15%"
        case .q: "Q · 25%"
        case .h: "H · 30%"
        }
    }

    var api: String {
        switch self {
        case .l: ".l"
        case .m: ".m"
        case .q: ".q"
        case .h: ".h"
        }
    }
}

enum InkChoice: String, CaseIterable, Identifiable, Hashable {
    case black
    case white
    case ember
    case tide
    case moss
    case paper

    var id: String { rawValue }

    var title: String {
        switch self {
        case .black: "Black"
        case .white: "White"
        case .ember: "Ember"
        case .tide: "Tide"
        case .moss: "Moss"
        case .paper: "Paper"
        }
    }
}

/// `EFStyleBasicParamsDataStyle`.
enum BasicDataShape: String, CaseIterable, Identifiable, Hashable {
    case rectangle
    case round
    case roundedRectangle
    case randomRound

    var id: String { rawValue }

    var title: String {
        switch self {
        case .rectangle: "Rectangle"
        case .round: "Round"
        case .roundedRectangle: "Rounded"
        case .randomRound: "Random round"
        }
    }
}

/// `EFStyleParamsPositionStyle`.
enum PositionShape: String, CaseIterable, Identifiable, Hashable {
    case rectangle
    case round
    case roundedRectangle
    case planets
    case dsj

    var id: String { rawValue }

    var title: String {
        switch self {
        case .rectangle: "Rectangle"
        case .round: "Round"
        case .roundedRectangle: "Rounded"
        case .planets: "Planets"
        case .dsj: "DSJ"
        }
    }
}

/// `EFStyleLineParamsLineDirection`.
enum LineDirectionChoice: String, CaseIterable, Identifiable, Hashable {
    case horizontal
    case vertical
    case cross
    case loopback
    case topLeftToBottomRight
    case topRightToBottomLeft
    case x

    var id: String { rawValue }

    var title: String {
        switch self {
        case .horizontal: "Horizontal"
        case .vertical: "Vertical"
        case .cross: "Cross"
        case .loopback: "Loopback"
        case .topLeftToBottomRight: "TL → BR"
        case .topRightToBottomLeft: "TR → BL"
        case .x: "X"
        }
    }
}

/// `EFImageMode`.
enum ImageModeChoice: String, CaseIterable, Identifiable, Hashable {
    case scaleAspectFill
    case scaleAspectFit
    case scaleToFill

    var id: String { rawValue }

    var title: String {
        switch self {
        case .scaleAspectFill: "Aspect fill"
        case .scaleAspectFit: "Aspect fit"
        case .scaleToFill: "Scale to fill"
        }
    }
}

/// `EFStyleFunctionParamsDataFunction`.
enum FunctionRecipe: String, CaseIterable, Identifiable, Hashable {
    case fade
    case circle

    var id: String { rawValue }

    var title: String {
        switch self {
        case .fade: "Fade"
        case .circle: "Circle"
        }
    }
}
