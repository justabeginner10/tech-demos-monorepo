import Rehearsal
import SwiftUI

/// Live `Rehearse` for `Showbill`. The package sheet is the control surface.
struct CardRehearseSurface: View {
    var body: some View {
        Rehearse(Showbill.self) { param in
            Showbill(
                title: param("title", default: "Night Shift"),
                nights: param("nights", range: 1 ... 6, default: 3),
                energy: param("energy", range: 0.0 ... 1.0, default: 0.65),
                starred: param("starred", default: true, animation: .default),
                accent: param("accent", default: DemoDefaults.showAccent),
                density: param(
                    "density",
                    default: ShowDensity.regular,
                    animation: .spring(response: 0.4, dampingFraction: 0.75)
                ),
                ribbon: param.picker(
                    "ribbon",
                    options: [ShowRibbon.hidden, .premiere, .soldOut],
                    default: .premiere
                )
            )
        }
        .background(DemoPalette.canvas, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(DemoPalette.stroke, lineWidth: 1)
                .allowsHitTesting(false)
        }
    }
}

/// Live `Rehearse` for editorial type. Size uses the explicit Int/Double sliders.
struct TypeRehearseSurface: View {
    var body: some View {
        Rehearse(TypeSample.self) { param in
            TypeSample(
                headline: param("headline", default: "Rehearse the type"),
                size: param("size", range: 16.0 ... 36.0, default: 24.0),
                tracking: param.slider("tracking", range: -1.0 ... 4.0, default: 0.2),
                leading: param.slider("leading", range: 0.0 ... 12.0, default: 6.0),
                weight: param("weight", default: TypeWeight.semibold),
                ink: param("ink", default: DemoDefaults.typeInk),
                italic: param("italic", default: false, animation: .default)
            )
        }
        .background(DemoPalette.canvas, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(DemoPalette.stroke, lineWidth: 1)
                .allowsHitTesting(false)
        }
    }
}

/// Live `Rehearse` for a layout grid. `columns` uses the stepper-only override.
struct LayoutRehearseSurface: View {
    var body: some View {
        Rehearse(StageGrid.self) { param in
            StageGrid(
                columns: param.stepper("columns", range: 1 ... 4, default: 3),
                spacing: param("spacing", range: 4.0 ... 24.0, default: 10.0),
                corner: param("corner", range: 4.0 ... 28.0, default: 14.0),
                inset: param("inset", range: 8.0 ... 28.0, default: 16.0),
                stacked: param("stacked", default: true, animation: .spring(response: 0.35, dampingFraction: 0.8)),
                fill: param("fill", default: DemoDefaults.stageFill),
                align: param("align", default: StageAlign.center)
            )
        }
        .background(DemoPalette.canvas, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(DemoPalette.stroke, lineWidth: 1)
                .allowsHitTesting(false)
        }
    }
}

#Preview("Showbill Rehearse") {
    CardRehearseSurface()
        .preferredColorScheme(.dark)
}

#Preview("Type Rehearse") {
    TypeRehearseSurface()
        .preferredColorScheme(.dark)
}

#Preview("Layout Rehearse") {
    LayoutRehearseSurface()
        .preferredColorScheme(.dark)
}
