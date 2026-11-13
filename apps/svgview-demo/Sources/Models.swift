import Foundation
import SVGView
import SwiftUI

enum DemoTab: Hashable {
    case live
    case gallery
}

/// Files in `Sources/Artwork`, copied to the bundle root.
enum Artwork {
    static func url(_ name: String, extension ext: String = "svg") -> URL? {
        Bundle.main.url(forResource: name, withExtension: ext)
    }
}

enum MarkFill: String, CaseIterable, Identifiable, Hashable {
    case orange = "FF8A3D"
    case blue = "5B8CFF"
    case green = "3DDC97"
    case pink = "FF6B9A"

    var id: String { rawValue }

    var hex: String { rawValue }

    var title: String {
        switch self {
        case .orange: "Orange"
        case .blue: "Blue"
        case .green: "Green"
        case .pink: "Pink"
        }
    }

    var color: Color {
        switch self {
        case .orange: Color(red: 1, green: 138 / 255, blue: 61 / 255)
        case .blue: Color(red: 91 / 255, green: 140 / 255, blue: 1)
        case .green: Color(red: 61 / 255, green: 220 / 255, blue: 151 / 255)
        case .pink: Color(red: 1, green: 107 / 255, blue: 154 / 255)
        }
    }

    var paint: SVGColor {
        SVGColor(hex: hex)
    }
}

/// How Live obtains the `SVGNode` it then hands to `SVGView(svg:)`.
enum MarkSource: String, CaseIterable, Identifiable, Hashable {
    case file
    case string
    case data
    case nodes

    var id: String { rawValue }

    var title: String {
        switch self {
        case .file: "File"
        case .string: "String"
        case .data: "Data"
        case .nodes: "Nodes"
        }
    }

    var call: String {
        switch self {
        case .file: "SVGParser.parse(contentsOf: mark.svg)"
        case .string: "SVGParser.parse(string:)"
        case .data: "SVGParser.parse(data:)"
        case .nodes: "SVGViewport(width:height:viewBox:preserveAspectRatio:contents:)"
        }
    }

    var failure: String {
        switch self {
        case .file: "mark.svg is not in the bundle, or it did not parse."
        case .string: "The inline string did not parse."
        case .data: "The UTF-8 data did not parse."
        case .nodes: "The built tree was empty."
        }
    }

    func load() -> SVGNode? {
        switch self {
        case .file:
            guard let url = Artwork.url("mark") else { return nil }
            return SVGParser.parse(contentsOf: url)
        case .string:
            return SVGParser.parse(string: MarkDocument.svg)
        case .data:
            return SVGParser.parse(data: Data(MarkDocument.svg.utf8))
        case .nodes:
            return MarkDocument.built()
        }
    }
}

/// The live mark. The file `mark.svg` is this string.
/// `built()` constructs the same ids with model types.
enum MarkDocument {
    static let svg = """
    <svg xmlns="http://www.w3.org/2000/svg" width="200" height="200" viewBox="0 0 200 200">
      <rect id="plate" x="16" y="16" width="168" height="168" rx="28" fill="#1C1C1E"/>
      <polygon id="spark" points="156,36 164,52 180,60 164,68 156,84 148,68 140,60 148,52" fill="#FFE08A"/>
      <circle id="disc" cx="100" cy="100" r="52" fill="#FF8A3D" stroke="#F5F5F7" stroke-width="4"/>
      <circle id="pupil" cx="100" cy="100" r="16" fill="#F5F5F7"/>
    </svg>
    """

    static let sparkPoints: [CGPoint] = [
        CGPoint(x: 156, y: 36),
        CGPoint(x: 164, y: 52),
        CGPoint(x: 180, y: 60),
        CGPoint(x: 164, y: 68),
        CGPoint(x: 156, y: 84),
        CGPoint(x: 148, y: 68),
        CGPoint(x: 140, y: 60),
        CGPoint(x: 148, y: 52),
    ]

    static func built() -> SVGNode {
        let plate = SVGRect(x: 16, y: 16, width: 168, height: 168, rx: 28, ry: 28)
        plate.id = "plate"
        plate.fill = SVGColor(hex: "1C1C1E")

        let spark = SVGPolygon(sparkPoints)
        spark.id = "spark"
        spark.fill = SVGColor(hex: "FFE08A")

        let disc = SVGCircle(cx: 100, cy: 100, r: 52)
        disc.id = "disc"
        disc.fill = SVGColor(hex: "FF8A3D")
        disc.stroke = SVGStroke(fill: SVGColor(hex: "F5F5F7"), width: 4)

        let pupil = SVGCircle(cx: 100, cy: 100, r: 16)
        pupil.id = "pupil"
        pupil.fill = SVGColor(hex: "F5F5F7")

        let viewport = SVGViewport(
            width: SVGLength.pixels(200),
            height: SVGLength.pixels(200),
            viewBox: CGRect(x: 0, y: 0, width: 200, height: 200),
            preserveAspectRatio: SVGPreserveAspectRatio(),
            contents: [plate, spark, disc, pupil]
        )
        viewport.id = "mark"
        return viewport
    }
}

/// `onTapGesture` takes a nonisolated `() -> Void`.
/// SwiftUI delivers the tap on the main thread, so `MainActor.assumeIsolated` hops back.
enum NodeTap {
    nonisolated static func perform(
        _ body: @escaping @MainActor () -> Void
    ) -> () -> Void {
        {
            MainActor.assumeIsolated {
                body()
            }
        }
    }
}
