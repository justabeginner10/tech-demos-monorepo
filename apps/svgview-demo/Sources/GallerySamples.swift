import Foundation
import SVGView
import SwiftUI

private enum GallerySVG {
    static let dots = """
    <svg xmlns="http://www.w3.org/2000/svg" width="240" height="120" viewBox="0 0 240 120">
      <circle cx="48" cy="60" r="28" fill="#FF8A3D"/>
      <circle cx="120" cy="60" r="28" fill="#5B8CFF"/>
      <circle cx="192" cy="60" r="28" fill="#3DDC97"/>
    </svg>
    """

    static let diamond = """
    <svg xmlns="http://www.w3.org/2000/svg" width="240" height="120" viewBox="0 0 240 120">
      <rect x="16" y="16" width="208" height="88" rx="16" fill="#1C1C1E"/>
      <polygon points="120,28 168,60 120,92 72,60" fill="#C084FC"/>
    </svg>
    """

    static let wave = """
    <svg xmlns="http://www.w3.org/2000/svg" width="240" height="120" viewBox="0 0 240 120">
      <polyline points="12,80 48,40 84,80 120,40 156,80 192,40 228,80" fill="none" stroke="#7DD3FC" stroke-width="6" stroke-linecap="round" stroke-linejoin="round"/>
    </svg>
    """

    static let badge = """
    <svg xmlns="http://www.w3.org/2000/svg" width="240" height="120" viewBox="0 0 240 120">
      <rect x="70" y="22" width="100" height="76" rx="18" fill="#FF8A3D"/>
      <circle cx="120" cy="60" r="16" fill="#F5F5F7"/>
    </svg>
    """

    static let tilted = """
    <svg xmlns="http://www.w3.org/2000/svg" width="240" height="140" viewBox="0 0 240 140">
      <g opacity="0.9" transform="rotate(-14 120 70)">
        <rect x="36" y="36" width="168" height="68" rx="18" fill="#C084FC"/>
        <circle cx="78" cy="70" r="14" fill="#F5F5F7"/>
        <circle cx="168" cy="70" r="14" fill="#1C1C1E"/>
      </g>
    </svg>
    """

    static let meet = """
    <svg xmlns="http://www.w3.org/2000/svg" width="200" height="80" viewBox="0 0 200 80" preserveAspectRatio="xMidYMid meet">
      <rect x="0" y="0" width="200" height="80" fill="#5B8CFF"/>
      <circle cx="40" cy="40" r="22" fill="#FFE08A"/>
      <circle cx="160" cy="40" r="22" fill="#FF8A3D"/>
    </svg>
    """

    static let slice = """
    <svg xmlns="http://www.w3.org/2000/svg" width="200" height="80" viewBox="0 0 200 80" preserveAspectRatio="xMidYMid slice">
      <rect x="0" y="0" width="200" height="80" fill="#5B8CFF"/>
      <circle cx="40" cy="40" r="22" fill="#FFE08A"/>
      <circle cx="160" cy="40" r="22" fill="#FF8A3D"/>
    </svg>
    """

    static let sized = """
    <svg xmlns="http://www.w3.org/2000/svg" width="160" height="72" viewBox="0 0 160 72">
      <rect width="160" height="72" rx="12" fill="#141416"/>
      <text x="12" y="48" fill="#FF8A3D" font-family="Helvetica">Ag</text>
    </svg>
    """

    static let inches = """
    <svg xmlns="http://www.w3.org/2000/svg" width="160" height="72" viewBox="0 0 160 72">
      <rect width="160" height="72" rx="12" fill="#141416"/>
      <text x="12" y="48" fill="#F5F5F7" font-family="Helvetica" font-size="0.22in">Aa</text>
    </svg>
    """
}

private enum GalleryNodes {
    static func make() -> SVGNode {
        let background = SVGRect(x: 0, y: 0, width: 240, height: 140)
        background.fill = SVGLinearGradient(
            degree: 28,
            from: SVGColor(hex: "243044"),
            to: SVGColor(hex: "3A2A55")
        )

        let orb = SVGCircle(cx: 52, cy: 70, r: 34)
        orb.fill = SVGRadialGradient(
            cx: 0.5,
            cy: 0.4,
            r: 0.7,
            stops: [
                SVGStop(color: SVGColor(hex: "FFFFFF"), offset: 0),
                SVGStop(color: SVGColor(hex: "5B8CFF"), offset: 1),
            ]
        )

        let badge = SVGRect(x: 108, y: 28, width: 116, height: 72, rx: 16, ry: 16)
        badge.fill = SVGColor.by(name: "orange") ?? SVGColor(hex: "FFA500")
        badge.stroke = SVGStroke(fill: SVGColor(hex: "F5F5F7"), width: 3, dashes: [5, 4])

        let check = SVGPath(segments: [
            PathSegment(type: .M, data: [148, 64]),
            PathSegment(type: .L, data: [166, 84]),
            PathSegment(type: .L, data: [204, 46]),
        ])
        check.fill = nil
        check.stroke = SVGStroke(
            fill: SVGColor(hex: "F5F5F7"),
            width: 4,
            cap: .round,
            join: .round
        )

        let label = SVGText(
            text: "Nodes",
            font: SVGFont(name: "Helvetica", size: 16),
            fill: SVGColor(hex: "F5F5F7"),
            textAnchor: .leading,
            transform: CGAffineTransform(translationX: 112, y: 124)
        )

        return SVGViewport(
            width: SVGLength.pixels(240),
            height: SVGLength.pixels(140),
            viewBox: CGRect(x: 0, y: 0, width: 240, height: 140),
            preserveAspectRatio: SVGPreserveAspectRatio(),
            contents: [background, orb, badge, check, label]
        )
    }
}

struct FileCard: View {
    var isMounted: Bool

    var body: some View {
        DemoChrome.chartCard(title: "File", subtitle: "SVGView(contentsOf: shapes.svg)") {
            VStack(alignment: .leading, spacing: 8) {
                SVGWell(isMounted: isMounted, height: 168) {
                    bundled("shapes")
                }
                caption("Rect, circle, ellipse, line, polygon, polyline, and an even-odd path. contentsOf parses the bundle URL.")
                chipRow(["rect", "circle", "ellipse", "path"])
            }
        }
    }
}

struct StringCard: View {
    var isMounted: Bool

    var body: some View {
        DemoChrome.chartCard(title: "String", subtitle: "SVGView(string:)") {
            VStack(alignment: .leading, spacing: 8) {
                SVGWell(isMounted: isMounted, height: 140) {
                    SVGView(string: GallerySVG.dots)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                caption("The markup lives in the app. No file URL.")
                chipRow(["SVGView(string:)"])
            }
        }
    }
}

struct DataCard: View {
    var isMounted: Bool

    var body: some View {
        DemoChrome.chartCard(title: "Data", subtitle: "SVGView(data:)") {
            VStack(alignment: .leading, spacing: 8) {
                SVGWell(isMounted: isMounted, height: 140) {
                    SVGView(data: Data(GallerySVG.diamond.utf8))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                caption("UTF-8 bytes of an SVG string. Same parser as the string init, different entry point.")
                chipRow(["Data", "utf8"])
            }
        }
    }
}

struct StreamCard: View {
    var isMounted: Bool

    var body: some View {
        DemoChrome.chartCard(title: "Stream", subtitle: "SVGView(stream:)") {
            VStack(alignment: .leading, spacing: 8) {
                SVGWell(isMounted: isMounted, height: 140) {
                    streamPicture()
                }
                caption("InputStream is opened, parsed inside the initializer, then closed. The parse is synchronous.")
                chipRow(["InputStream"])
            }
        }
    }

    private func streamPicture() -> some View {
        let stream = InputStream(data: Data(GallerySVG.wave.utf8))
        stream.open()
        let picture = SVGView(stream: stream)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        stream.close()
        return picture
    }
}

struct XMLCard: View {
    var isMounted: Bool

    var body: some View {
        DemoChrome.chartCard(title: "XML", subtitle: "DOMParser.parse(string:) · SVGView(xml:)") {
            VStack(alignment: .leading, spacing: 8) {
                SVGWell(isMounted: isMounted, height: 140) {
                    xmlPicture()
                }
                caption("DOMParser returns an XMLElement. SVGView(xml:) is the step after that.")
                chipRow(["XMLElement"])
            }
        }
    }

    @ViewBuilder
    private func xmlPicture() -> some View {
        if let xml = DOMParser.parse(string: GallerySVG.badge) {
            SVGView(xml: xml)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            Text("No element")
                .font(.subheadline)
                .foregroundStyle(DemoPalette.inkMuted)
        }
    }
}

struct NodesCard: View {
    var isMounted: Bool

    var body: some View {
        DemoChrome.chartCard(
            title: "Nodes",
            subtitle: "SVGView(svg: SVGViewport(...))"
        ) {
            VStack(alignment: .leading, spacing: 8) {
                SVGWell(isMounted: isMounted, height: 160) {
                    SVGView(svg: GalleryNodes.make())
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                caption("Built without a parser. Linear and radial fills, SVGColor.by(name: \"orange\"), a dashed SVGStroke, PathSegment, and SVGText.")
                chipRow(["SVGViewport", "SVGPath", "SVGText"])
            }
        }
    }
}

struct GradientCard: View {
    var isMounted: Bool

    var body: some View {
        DemoChrome.chartCard(title: "Gradients", subtitle: "SVGView(contentsOf: gradient.svg)") {
            VStack(alignment: .leading, spacing: 8) {
                SVGWell(isMounted: isMounted, height: 156) {
                    bundled("gradient")
                }
                caption("fill=\"url(#id)\" resolves linearGradient and radialGradient from defs. Stops use stop-color and offset.")
                chipRow(["linearGradient", "radialGradient"])
            }
        }
    }
}

struct StrokeCard: View {
    var isMounted: Bool

    var body: some View {
        DemoChrome.chartCard(title: "Strokes", subtitle: "SVGView(contentsOf: strokes.svg)") {
            VStack(alignment: .leading, spacing: 8) {
                SVGWell(isMounted: isMounted, height: 156) {
                    bundled("strokes")
                }
                caption("stroke-dasharray, round cap, round join, and fill-opacity. A missing stroke attribute leaves SVGStroke nil.")
                chipRow(["dasharray", "linecap", "fill-opacity"])
            }
        }
    }
}

struct ReuseCard: View {
    var isMounted: Bool

    var body: some View {
        DemoChrome.chartCard(title: "Use", subtitle: "SVGView(contentsOf: reuse.svg)") {
            VStack(alignment: .leading, spacing: 8) {
                SVGWell(isMounted: isMounted, height: 120) {
                    bundled("reuse")
                }
                caption("A circle in defs is not drawn. Each use copies it and translates by x and y. The attribute is xlink:href.")
                chipRow(["defs", "use", "xlink:href"])
            }
        }
    }
}

struct TextCard: View {
    var isMounted: Bool

    var body: some View {
        DemoChrome.chartCard(title: "Text", subtitle: "SVGView(contentsOf: type.svg)") {
            VStack(alignment: .leading, spacing: 8) {
                SVGWell(isMounted: isMounted, height: 140) {
                    bundled("type")
                }
                caption("text-anchor start, middle, and end become HorizontalAlignment. x and y are a translation. The font is Font.custom.")
                chipRow(["start", "middle", "end"])
            }
        }
    }
}

struct StyleCard: View {
    var isMounted: Bool

    var body: some View {
        DemoChrome.chartCard(title: "Style", subtitle: "SVGView(contentsOf: style.svg)") {
            VStack(alignment: .leading, spacing: 8) {
                SVGWell(isMounted: isMounted, height: 120) {
                    bundled("style")
                }
                caption("A style element feeds the CSS index. Class .hot and id #cool set fill when the rect has no fill attribute.")
                chipRow(["class", "#id"])
            }
        }
    }
}

struct GroupCard: View {
    var isMounted: Bool

    var body: some View {
        DemoChrome.chartCard(title: "Group", subtitle: "SVGView(string:) · g") {
            VStack(alignment: .leading, spacing: 8) {
                SVGWell(isMounted: isMounted, height: 150) {
                    SVGView(string: GallerySVG.tilted)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                caption("The group carries opacity and rotate(angle cx cy). Children draw inside that transform.")
                chipRow(["opacity", "rotate"])
            }
        }
    }
}

struct ImageCard: View {
    var isMounted: Bool

    var body: some View {
        DemoChrome.chartCard(title: "Image", subtitle: "SVGView(contentsOf: image.svg)") {
            VStack(alignment: .leading, spacing: 8) {
                SVGWell(isMounted: isMounted, height: 140) {
                    bundled("image")
                }
                caption("The left image is swatch.png next to the file, loaded by the relative linker. The right image is a PNG data URI, which becomes SVGDataImage.")
                chipRow(["SVGURLImage", "SVGDataImage"])
            }
        }
    }
}

struct AspectCard: View {
    var isMounted: Bool

    var body: some View {
        DemoChrome.chartCard(title: "Aspect", subtitle: "preserveAspectRatio meet · slice") {
            VStack(alignment: .leading, spacing: 8) {
                SVGWell(isMounted: isMounted, height: 150) {
                    HStack(spacing: 8) {
                        aspectLabel("meet", GallerySVG.meet)
                        aspectLabel("slice", GallerySVG.slice)
                    }
                    .padding(8)
                }
                caption("The same 200 by 80 picture in a square stage. meet fits the whole viewBox. slice fills the stage and clips.")
                chipRow(["xMidYMid meet", "xMidYMid slice"])
            }
        }
    }

    private func aspectLabel(_ title: String, _ markup: String) -> some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption2.monospaced())
                .foregroundStyle(DemoPalette.inkMuted)
            SVGView(string: markup)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

struct SettingsCard: View {
    var isMounted: Bool

    var body: some View {
        DemoChrome.chartCard(title: "Settings", subtitle: "SVGParser.parse(string:settings:)") {
            VStack(alignment: .leading, spacing: 8) {
                SVGWell(isMounted: isMounted, height: 200) {
                    VStack(spacing: 8) {
                        HStack(spacing: 8) {
                            settingsLabel("fontSize 14", font: 14, ppi: 96, markup: GallerySVG.sized)
                            settingsLabel("fontSize 40", font: 40, ppi: 96, markup: GallerySVG.sized)
                        }
                        HStack(spacing: 8) {
                            settingsLabel("ppi 96", font: 16, ppi: 96, markup: GallerySVG.inches)
                            settingsLabel("ppi 192", font: 16, ppi: 192, markup: GallerySVG.inches)
                        }
                    }
                    .padding(8)
                }
                caption("The top row omits font-size, so SVGSettings.fontSize is the size. The bottom row is 0.22in, so ppi changes the pixel size. The default ppi is 96.")
                chipRow(["fontSize", "ppi"])
            }
        }
    }

    private func settingsLabel(_ title: String, font: CGFloat, ppi: CGFloat, markup: String) -> some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption2.monospaced())
                .foregroundStyle(DemoPalette.inkMuted)
            if let node = SVGParser.parse(
                string: markup,
                settings: SVGSettings(fontSize: font, ppi: ppi)
            ) {
                SVGView(svg: node)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
}

@ViewBuilder
private func bundled(_ name: String) -> some View {
    if let url = Artwork.url(name) {
        SVGView(contentsOf: url)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    } else {
        Text("Missing \(name).svg")
            .font(.subheadline)
            .foregroundStyle(DemoPalette.inkMuted)
    }
}

private func caption(_ text: String) -> some View {
    Text(text)
        .font(.caption)
        .foregroundStyle(DemoPalette.inkMuted)
        .fixedSize(horizontal: false, vertical: true)
        .padding(.horizontal, 8)
}

private func chipRow(_ labels: [String]) -> some View {
    HStack(spacing: 6) {
        ForEach(labels, id: \.self) { label in
            DemoChrome.chip(label)
        }
    }
    .padding(.horizontal, 8)
    .padding(.bottom, 8)
}
